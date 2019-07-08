function [R,T,min_error]=iterativePnP(img_points,obj_points,mtx,noise,min_error)
%Iterative EPnP function that will provide the camera pose
%Input variables:
%       - Img_points: list of the 2D correspondences for the EPnP
%       - Obj_points: list of the 3D correspondences for the EPnP
%       - mtx:        matrix of the intrinsic parameters of the camera
%       - noise:      percentage of noise to be applied in the algorithm
%       - min_error:  minimal error admisable in the projection


finished=false;
if ~exist('min_error','var')
    min_error=Inf; %If not indicated there is no minimal
end

if ~exist('noise','var')
    noise=1; 
end
max_iter=400; %Maxim number of iteration

Rs=[]; Ts=[];
if exist('cp_img_points','var')~=1 %if copy not exists
   cp_img_points=img_points; 
else
   img_points=cp_img_points; %cp_img_points is later used to save the original img_points
end    
best_image=img_points; %this variable saves the image points with best results


for tries=1:max_iter

    %Obtain some R and T
    if size(Rs,1)==0 %Random initialization of the R matrix at first
        Rini=randrotmat(1);
    else
        if myError>50 %If the error is too big, randmom initialization
            Rini=randrotmat(1);
        else
            Rini=Rs; % Else, we'll use the best result until now
        end
    end
    
    
    if tries<0.5*max_iter
        %For the first half of the iteration, no noise is added
        [R,T,rec,num_iter]=Hager(obj_points,cp_img_points,mtx,Rini);
    else
        %For the second half, we will add noise to the image points
        %This will add little variations to the points
        
        noised=addNoise2Points(img_points(:,[1,2]),noise);
        cp_img_points=[noised,ones(length(noised(:,1)),1)];
        [R,T,rec,num_iter]=Hager(obj_points,cp_img_points,mtx,Rini);
    end

    %Now, we'll calculate the error of this R & T

    %First project obj_points to the frames
    imgp=[];
    for i=1:length(obj_points(:,1))
        p=obj_points(i,:)';
        p=R*p+T;
        p=mtx*p;
        p=p./p(end);
        imgp=[imgp;p(1),p(2)];  
    end
    
    %The error is calculated as the average distance from the projected obj_points
    %to the corresponding img_points
    
    myError=cp_img_points(:,[1,2])-imgp;
    myError=myError(:,1).^2+myError(:,2).^2;
    myError=sum(sqrt(myError))/length(img_points(:,1));
    if myError<min_error && size(R,1)==3 && size(R,2)==3 %if it's the best result until now, we save it
        clear min_error;
        clear Rs;
        clear Ts;
        min_error=myError;
        if tries>0.5*max_iter
           best_image=cp_img_points;
        end
        Rs=R;Ts=T;
        if min_error<0.5
            break
        end
    end
end

end