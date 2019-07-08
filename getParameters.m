function [sync,ref_segment]=getParameters(video)
%Sync values
%sync = video_index - 3DPose_index

switch video
    case "Egocentric_Example"
        sync=-61;
    case "ThirdPerson_Example"
        sync=-164;
    otherwise
        fprintf("Caution: no saved sync value for these files, assuming 0. \n");
        sync=0;
end

%Reference segments values
% ref_segment=7   ----> Camera atached to segment 7 (head)
% ref_segment=-1  ----> Camera static and in a third person POV
switch video
    case "Egocentric_Example"
        ref_segment=7;
    case "ThirdPerson_Example"
        ref_segment=-1;
    otherwise
        fprintf("Caution: no saved reference segment for these files, assuming fixed camera. \n");
        ref_segment=-1;
end


end