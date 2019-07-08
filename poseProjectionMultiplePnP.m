% Pose Projection Interactive App (Multiple frame PnP)
% Gabriel Coll Ribes
% July, 2019
%-------------------------------------------------------------

%Name of the MVNX file containing the sequences of 3D poses
mvnx_root='Data/Egocentric_Example.mvnx';


%Checking if already uploaded MVNX file, otherwise, upload it
%When a MVNX file is uploaded for the first time, a comment in the struct
%is added for identification purposes. Also, the file is saved as a .mat
%file. This is done because uploading a .mvnx is much slower than uploading
%a .mat one. This saves time when a file is used more than one.

if exist('mvnx','var')==1 && length(mvnx.comment)==length(mvnx_root) && all(mvnx.comment==mvnx_root)
    clearvars -except mvnx mvnx_root
else
    %check whether it was saved as mat
    fname=strcat(mvnx_root(1:end-4),'mat');
    if isfile(fname)
        mvnx=load(fname);
        mvnx=mvnx.mvnx;
    else
        mvnx=load_mvnx(mvnx_root);
        save(fname,'mvnx');
        
    end
    mvnx.comment=mvnx_root;
    clearvars -except mvnx mvnx_root
    %if one wants to use another file, delete the previous 
    %mvnx variable from the workspace
end

close all;

%Adding the needed paths
addpath('./Hager');
video="Egocentric_Example"; %Subfolder in "Frames" with the frames of sequence
frames_root=char(strcat("./Frames/",video));

%Camera calibration results saved as a mat file
l=load('videocamera_calibration.mat'); mtx=l.mtx; dist=l.dist; clear l;
original_mtx=mtx;

%------ PARAMETERS FOR THE FUNCTION---------------------------------------
%We load the sync value that will be used to synchronize the frames & poses
%We also load to which segment of the skeleton the camera is attached to

[sync, ref_segment]=getParameters(video); %Check this function!
vframes=[71]; %List of the frames to be used for the EPnP
dframes=vframes-sync+3; %Mapping the video frames to data frames
test_frame=[750:2:850]; %List of frames that will be used for previewing the results
withLabels=false;       %Boolean for the use of labels in the projections

skip=2; fps=60/skip;    %Parameters for exporting a video
video_frames=5:skip:895;
stamp=datestr(clock);   %Automatic name for the projection video
stamp=strrep(stamp,'-','');
stamp=strrep(stamp,':','');
stamp=strrep(stamp,' ','');
gif_name=strcat(video,"_projection_",stamp);

%Parameters for the iterative EPnP
max_iter=400; noise=0.01;

avail_segments=["right wrist", "right elbow", "left wrist", "left elbow",...
                "right toe", "right ankle", "right knee", "right hip",...
                "left toe", "left ankle", "left knee", "left hip", "hip",...
                "right upper","left upper"];

%create bank of frames
bank=containers.Map('KeyType','double', 'ValueType', 'any');
for frame=vframes
    frameMap=containers.Map;
    imagename=strcat(frames_root,'/frame_',int2str(frame),'.jpg');
    image=imread(imagename);
%     image=flip(image,1);
%     image=flip(image,2);
    frameMap('image')=image;
    frameMap('vframe')=frame;
    frameMap('dframe')=frame-sync+3;
    s=size(image); height=s(1);width=s(2); clear s;
    
    selected=1:length(avail_segments);
    
    selected=getSelected(video,frame);
    
    frameMap('selected')=selected;
    frameMap('tags')=avail_segments(selected);
    bank(frame)=frameMap;
end

noise=noise*min(height,width);



%-------GETTING THE CORRESPONDENCES---------------------------------------
%GUI for manually selecting the image points. I.e. pointing out where are the
%selected joints of the real person

f1=figure();
img_points=[];
obj_points=[];

for i=vframes
    fbank=bank(i);
    a=selectImagePoints(fbank,noise,f1); %Manual selection of image points
    img_points=[img_points;a];
    a=obtainObjPoints(mvnx,fbank,ref_segment); %Obtaining the correspondences in the MVNX data
    obj_points=[obj_points;a];
    hold on;
    pause(0.2);
    clf(f1);
end

close(f1);




%----ITERATIVE EPnP MAIN LOOP---------------------------------------------
finished=false;
fine_tuned=false;
while ~finished
    %calculate R and T
    if ~fine_tuned
        [R,T,error]=iterativePnP(img_points,obj_points,mtx,noise); %Check out this function!
    end

    %Project results

    f2=knownProjection(test_frame,sync,R,T,mvnx,ref_segment,mtx,1,frames_root, withLabels); %Check out this function!
    close(f2);
    
    %Select next step
    response=questdlg('What to do?', "Options","Edit","Others","Close","Close");
    if response=="Others"
        response=questdlg('What to do?', "Options","Export","Fine tune","Close","Close");
    end
    
    if response =="Export"
        %Export the results of the projection as a video.
        createProjectionsMP4(char(gif_name),video_frames,sync,R,T,mvnx,ref_segment,mtx,fps, frames_root, withLabels);
        finished=true;
    elseif response=="Edit"
        %Edit the manually selected image points
        bank=editBank(bank);
        finished=false;
        fine_tuned=false;
    elseif response == "Fine tune"
        % With this function one can manually adjust the matrix R and T by
        % rotating and moving the camera
        [R,T]=adjustResultsManually(vframes(1),sync,R,T,mvnx,ref_segment,mtx,frames_root, withLabels);
        finished=false;
        fine_tuned=true;
    else
        finished=true; break;
    end
end