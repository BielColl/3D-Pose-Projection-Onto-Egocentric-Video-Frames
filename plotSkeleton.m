function fs=plotSkeleton(mvnx,dframes,ref_segment,R,T,fs)

if ~exist('fs','var')
    fs=figure('Name',strcat('3DPose'),'Position',[10,10,250,350]);
else
    figure(fs)
end



if ~exist('R','var') || ~exist('T','var')
    plotCamera=false;
else
    plotCamera=true;
end

    function newAxes=getAxisLim(posData,prevAxes,camPoint, camAxesPoints)
        if exist('camPoint','var') && exist('camAxesPoints','var')
            posData=[posData;camPoint;camAxesPoints];
        end
        %find max
        newAxes=[min(posData(:,1)),max(posData(:,1)),...
            min(posData(:,2)),max(posData(:,2)),...
            min(posData(:,3)),max(posData(:,3))];
        if length(prevAxes)==6
            for i=1:length(newAxes)
                if rem(i,2)==0 %maxim
                    if prevAxes(i)>newAxes(i)
                        newAxes(i)=prevAxes(i);
                    end
                else %minim
                    if prevAxes(i)<newAxes(i)
                        newAxes(i)=prevAxes(i);
                    end
                end
            end
        end
        
    end

axLim=[];
for dframe = dframes
    %Obtain points in 3D
    d=mvnx.subject.frames.frame(dframe).position;
    data=[];
    for idx = 1:length(mvnx.subject.frames.frame(dframe).position)/3
        di=1+(idx-1)*3;
        data=[data;d(di:di+2)]; 
    end
    if plotCamera
        if ref_segment~=-1
            orien=mvnx.subject.frames.frame(dframe).orientation; 
            di=1+(ref_segment-1)*4; quat=orien(di:di+3); Rh2w=quat2mat(quat); 
            Th2w=data(ref_segment,:);

            vs=-inv(R)*T;vs=vs/1000;
            v=Th2w'+Rh2w*vs; v=v';

            camAx=[]; 
            for i=1:3
                a=R;
                
                a=a*0.15;
                a=v'+Rh2w*a;

                camAx=[camAx;a'];
            end
        else
            v=-inv(R)*T; v=v/1000;
            
            if iscolumn(v)
                camAx=R+v;
            else 
                camAx=R+v';
            end
            
        end
        
        if norm(v-data(ref_segment,:))>2
            fprintf('Camera error \n');
            v=data(ref_segment,:);
        end

    end
    
    
    dx=data(:,1);dy=data(:,2);dz=data(:,3);
    %Segments

    segments=[10,11;9,10;14,15;14,13;19,18;18,17;17,16;16,1;1,20;...
                20,21;21,22;22,23;1,2;2,3;3,4;4,5;5,6;6,7;...
                8,9;13,12;5,12;5,8;12,8;];

    %Plot 3d

    scatter3(dx,dy,dz,'filled','MarkerFaceColor','b');
    
    if plotCamera
        axLim=getAxisLim(data,axLim,v,camAx);
    else
        axLim=getAxisLim(data,axLim);
    end
    axis(axLim);
    set(gca,'DataAspectRatio',[1,1,1]);
    hold on;
    if plotCamera
        scatter3(v(1),v(2),v(3),'filled','MarkerFaceColor','g');
        cl={'r','g','b'};
        for i=1:3
            a=camAx(i,:);
            line([a(1),v(1)],[a(2),v(2)],[a(3),v(3)],'Color',char(cl(i)));
        end
    end
    for row =segments.'
       p1=data(row(1),:);
       p2=data(row(2),:);
       
       line([p1(1),p2(1)],[p1(2),p2(2)],[p1(3),p2(3)],'Color','r');
    end
    pause(1/60); hold off;
end

end