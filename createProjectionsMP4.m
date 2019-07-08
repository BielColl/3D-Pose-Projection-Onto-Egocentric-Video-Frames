function []=createProjectionsMP4(gif_name,vframes,sync,R,T,mvnx,ref_segment,mtx,fps, frame_root, withLabels)
%Function that saves a video with the projected skeleton. Works exactly as
%the knownProjection function, but saves the results. 
% Parameters:
%       - gif_name:     Name of the saved video
%       - vframe:       List of video frames to be used
%       - sync:         sync value
%       - R, T:         results of the EPnP. It's the camera pose
%       - mvnx:         struct containing the 3D poses
%       - ref_segment:  segment of the 3D skeleton at which the camera is attached to
%       - mtx:          intrinsic parameters of the camera
%       - n_loops:      in case the projection it's wanted to be seen several times
%       - frame_root:   where the frames are saved
%       - withLabels:   true if the joints of the skeleton have to have it's names 
%       - f:            figure in which is the projection is shown

gifcount=1;
figname="exportMovie";
f2=figure('name',figname);
max_size=1080;
v=VideoWriter(char(gif_name));
v.FrameRate=fps;
knownSize=false;
open(v);
count=0; total=length(vframes);

%Create the colos of the segments of the skeleton

segments=[10,11;9,10;14,15;14,13;19,18;18,17;17,16;16,1;1,20;...
            20,21;21,22;22,23;1,2;2,3;3,4;4,5;5,6;6,7;...
            8,9;13,12;5,12;5,8;12,8;];
colors=[];
hue=linspace(0,1,length(segments(:,1)));

for h = hue
    hsv=[h,1,0.9];
    color=hsv2rgb(hsv);
    colors=[colors;color];
end

% Creating movie
wf= waitbar(0,'Please wait...','Name','Exporting movie...');
for f = vframes
    count=count+1;
        
    set(f2,'name',strcat(figname," Frame: ",num2str(f)," [",num2str(ceil((count*100)/total)),"%]"));
    perc=count/total; waitbar(perc,wf,sprintf('%12.2f %%',perc*100));
    
    imagename=strcat(frame_root,'/frame_',int2str(f),'.jpg');
    image=imread(imagename);
%     image=flip(image,1);
%     image=flip(image,2);
    % image=undistort(image,mtx,dist);
    imshow(image);
    frame=f-sync+3;

    clear pos_data;
    pos_data = mvnx.subject.frames.frame(frame).position;
    pos_data=reshape(pos_data,3,length(pos_data)/3)';
    pos_data=pos_data*1000;
    if ref_segment>=0
        head_pos=pos_data(ref_segment,:);
        quats=mvnx.subject.frames.frame(frame).orientation;
        quats=reshape(quats,4,length(quats)/4)';
        head_quat=quats(ref_segment,:);
    end
    % index=[11,10,15,21,17,22,23,18,19,1,16,20]; %rows to select
    index=1:length(mvnx.subject.segments.segment);
    obj_points=[];
    for i =index
       row=pos_data(i,:);
       if ref_segment>=0
           p=changeCoordinateSystem(row,head_quat,head_pos);
       else
           p=row;
       end
       obj_points=[obj_points;reshape(p,1,3)];
    end


    hold on
    img=[];
    for i = 1:length(obj_points(:,1))
        p=obj_points(i,:)';
        p=R*p+T;
    %     p=applyDistortion(p,mtx,dist)';
        p=mtx*p;
        p=p./p(end);
        img=[img;p(1),p(2)];
    end


    scatter(img(:,1),img(:,2),10,'blue','filled','MarkerFaceColor','k');

    names=mvnx.subject.segments.segment;
    labels=[];
    im_size=size(image); h=im_size(1);w=im_size(2); clear im_size;

    for i=1:length(names)
        labels=[labels,string(names(i).label)];
    end
    for i = 1:length(img(:,1))
        mp=img(i,:);
        if withLabels
            text(mp(1),mp(2), labels(i), 'Color', 'white');
        end
    end
    segments=[10,11;9,10;14,15;14,13;19,18;18,17;17,16;16,1;1,20;...
        20,21;21,22;22,23;1,2;2,3;3,4;4,5;5,6;6,7;...
        8,9;13,12;5,12;5,8;12,8;];
    off=1*w;
    colorCount=1;
    for row =segments.'
       p1=img(row(1),:);
       p2=img(row(2),:);
       if inSight(p1,h,w,off) && inSight(p2,h,w,off)
           plot([p1(1),p2(1)],[p1(2),p2(2)],'Color',colors(colorCount,:),'LineWidth',3);
       end
       colorCount=colorCount+1;
    end
    frame=getframe(f2);im=frame2im(frame);
    s=size(im);
    if ~knownSize
        if max(s)>max_size 
            factor=max_size/max(s);
            im=imresize(im,factor);
            nh=size(im,1); nw=size(im,2);
            while mod(nh,2)~=0 || mod(nw,2)~=0
                im=imresize(im,0.99);
                nh=size(im,1); nw=size(im,2);
            end
        end
    else
       factor=nh/s(1);
       im=imresize(im,factor);
    end
    writeVideo(v,im);
    
    gifcount=gifcount+1;
    hold off;
end
close(f2);
close(v);
close(wf);

