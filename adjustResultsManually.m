function [R,T] = adjustResultsManually(vframe,sync,R,T,mvnx,ref_segment,mtx,frame_root, withLabels)
% Interactive app to manually adjust the camera pose for the projection

fa=figure('Position',[450,10,800,800]);
fs=figure('Name',strcat('3DPose'),'Position',[10,10,250,350]);
ax={'x','y','z'};
savedR=R; savedT=T;
puf=vframe+50;
plf=vframe;
while true
    fa=knownProjection(vframe,sync,R,T,mvnx,ref_segment,mtx,1, frame_root,withLabels, fa);
    fs=plotSkeleton(mvnx,vframe-sync,ref_segment,R,T,fs);
    resp=RTcontrolDial(vframe,puf,plf);
    rch=convertStringsToChars(resp);
    if rch(1)=='p'
        values=rch(3:end); indx=strfind(values,'_');
        low=str2num(values(1:indx(1)-1));
        skip=str2num(values(indx(1)+1:indx(2)-1));
        up=str2num(values(indx(2)+1:end));
        preview=low:skip:up;
        
        close(fs);
        fa=knownProjection(preview,sync,R,T,mvnx,ref_segment,mtx,1, frame_root,withLabels, fa);
        puf=up; plf=low;
        fs=figure('Name',strcat('3DPose'),'Position',[10,10,250,350]);
        
    elseif rch(1)=='s'
        vframe=str2num(rch(4:end));
        if vframe<=sync
            vframe=1+sync;
        end
        plf=vframe; puf=vframe+50;
    elseif resp=="reset"
        R=savedR; T=savedT;
    elseif resp=="exit"
        close(fa);
        close(fs);
        break
    elseif rch(1)=='t'
        %translation
        resp=convertStringsToChars(resp);
        direction=find([ax{:}]==resp(2));
        if resp(3)=='p'
            sentit=1;
        else
            sentit=-1;
        end
        
        value=str2num(rch(strfind(rch,'_')+1:end));

        T(direction)=T(direction)-sentit*value;
    elseif rch(1)=='r' && rch(2)~='e'
        %rotation
        resp=convertStringsToChars(resp);
        direction=find([ax{:}]==resp(2));
        if resp(3)=='p'
            sentit=1;
        else
            sentit=-1;
        end
        value=str2num(rch(strfind(rch,'_')+1:end));
        value=value*(pi/180);
        
        Rbefore=R;
        rot_vector=R(:,direction);
        for i=1:3
            if i~=direction
                R(:,i)=rotateVector(R(:,i),rot_vector,sentit*value);
            end
        end
        
        T=R*inv(Rbefore)*T;
        
    elseif strlength(resp)==4
        if resp=="fmmf"
            vframe=vframe-10;
        elseif resp=="fmff"
            vframe=vframe-1;
        elseif resp=="fpff"
            vframe=vframe+1;
        else
            vframe=vframe+10;
        end
            
    end
end


end