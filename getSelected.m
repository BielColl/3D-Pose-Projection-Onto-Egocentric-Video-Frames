function [selected] = getSelected(video,vframe)
%This function returns the preestablished selected joints to use for the
%EPnP algorithm. Given a video and the video frame, it returns a vector
%with the joints indices to be used.
switch video    
    case "ThirdPerson_Example"
        switch vframe
            case 382
%                 selected=[1:13];
                selected=[1,3,2,4,5,9];
        end
    case "Egocentric_Example"
        switch vframe
            case 71
                selected=[1,3,2,4,5,9];
            case 516
                selected=[1,2,4,5,9,6];
            case 583
                selected=[1,3,4,5,9,7,11,8,12,13];
        end
end

%If a selection of joints was not preestablished for this video frame, it's
%assumed that joints with indices 1 to 13 can be used. This includes the
%joints from the arms, legs and the pelvis. 

if ~exist('selected','var')
    fprintf("Caution: no selected subjects saved for these files, assuming all \n");
    selected=[1:13];
end

end