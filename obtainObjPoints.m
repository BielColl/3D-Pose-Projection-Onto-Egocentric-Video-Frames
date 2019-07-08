function [obj_points]=obtainObjPoints(mvnx,bank, ref_segment)

dframe=bank('dframe');
%Importing MVNX Data and reshaping it
pos_data = mvnx.subject.frames.frame(dframe).position;
pos_data=reshape(pos_data,3,length(pos_data)/3)';
pos_data=pos_data*1000;

%New world coordinate system
if ref_segment>=0
    head_pos=pos_data(ref_segment,:);
    quats=mvnx.subject.frames.frame(dframe).orientation;
    quats=reshape(quats,4,length(quats)/4)';
    head_quat=quats(ref_segment,:);
end
segmentIndex;

segments=[];
for label=bank('tags')
    segments=[segments,segIndex(char(label))];
end
obj_points=[];

for i=segments
   row=pos_data(i,:);
   if ref_segment~=-1
       p=changeCoordinateSystem(row,head_quat,head_pos);
   else
       p=row;
   end
   obj_points=[obj_points;reshape(p,1,3)];
end
end