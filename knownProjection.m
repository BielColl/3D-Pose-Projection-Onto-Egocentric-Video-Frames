function f2 = knownProjection(vframe,sync,R,T,mvnx,ref_segment,mtx,n_loops, frame_root, withLabels, f)
% This function computes the projection of a sequence of 3D poses onto a
% sequence of frames. Then, it showes it on screen
% Parameters:
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


figname="known";

if nargin == 10
    f2=figure('name',figname);
else
    f2=f;
    figure(f);
end
flag=0;
count=0;
total=length(vframe);

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

%Checking if there is data and frames within the range asked to project. If
%some of the frames in the range are not available, the range is shortened.

m=mink(vframe,1); 
if m<=sync
    vframe=vframe+(sync-m);
    fprintf('Non existing data asked, moving vframe range up to minimum \n')
end

totaldframes=length(mvnx.subject.frames.frame);
m=maxk(vframe,1); m=m-sync;
if m>totaldframes
    fprintf('Frames too high found. Not representing those \n');
    if length(vframe)==1
        vframe=0;
    else
        vframe=vframe(vframe<totaldframes+sync);
    end
end

%------------Projection loop----------------------------------------------
for loop=1:n_loops
    for f = vframe
        count=count+1;
        set(f2,'name',strcat(figname," Frame: ",num2str(f)," [",num2str(ceil((count*100)/total)),"%]"));
        
        %Showing the video frame
        imagename=strcat(frame_root,'/frame_',int2str(f),'.jpg');
        image=imread(imagename);
        imshow(image);
        hold on;
        frame=f-sync+3;
        
        %Import the 3D skeleton
        clear pos_data;
        pos_data = mvnx.subject.frames.frame(frame).position;
        pos_data=reshape(pos_data,3,length(pos_data)/3)';
        pos_data=pos_data*1000;
        
        %If the camera is attached to some skeleton segment, obtained its
        %current position and orientation
        if ref_segment>=0
            head_pos=pos_data(ref_segment,:);
            quats=mvnx.subject.frames.frame(frame).orientation;
            quats=reshape(quats,4,length(quats)/4)';
            head_quat=quats(ref_segment,:);
        end
        index=1:length(mvnx.subject.segments.segment);
        
        %Import the joints of the skeleton
        obj_points=[];
        for i =index
           row=pos_data(i,:);
           if ref_segment~=-1
               %If the camera is attached to some skeleton segment, the
               %position of the skeleton joints are redefined in a
               %coordinate system relative to that segment
               p=changeCoordinateSystem(row,head_quat,head_pos);
           else
               p=row;
           end
           obj_points=[obj_points;reshape(p,1,3)];
        end
        
        %Obtain the coordinates of the resulting projection of the skeleton
        %joints
        
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

        
        %---Drawing the skeleton-------------------------------------
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
        count=1;
        for row =segments.'
           p1=img(row(1),:);
           p2=img(row(2),:);
           if inSight(p1,h,w,off) && inSight(p2,h,w,off)
               plot([p1(1),p2(1)],[p1(2),p2(2)],'Color',colors(count,:),'LineWidth',3);
           end
           count=count+1;
        end
        pause(1/60); hold off;
    
    if flag==1
        break
    end
        
    end
end

hold on;
end