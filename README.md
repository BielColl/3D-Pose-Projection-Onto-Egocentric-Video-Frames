# 3D Pose Projection Onto Egocentric Video Frames

This repository contains the MATLAB code for projecting a sequence of 3D poses onto a sequence of frames. Both sequences were recorded at the same time and they have to be already synchronized. This code is thought to be used with 3D poses obtained using MVN Awinda, but the code provided can easily be adapted to other sources. 

![Alt Text](https://github.com/BielColl/3D-Pose-Projection-Onto-Egocentric-Video-Frames/blob/master/example.gif)


## Main script
To project a sequence of 3D poses onto a sequences of frames one needs to use the interactive app in file **poseProjectionMultiplePnP.m** . In the script one can how to use it to obtain the projections. 

This app is capable of:
* Obtain the camera position and orientation needed to execute the projection using an EPnP algorithm. To do so, the user has to manually select the 2D correspondences.
* The user can manually adjust the estimated camera pose in order to fine tune the results
* Show the projection of the 3D poses onto the frames on screen
* Export the projection as a MP4 file

## Workflow
Here is an example of the workflow that one may use when projecting a new sequence.
1. Synchronize both sequences. The script will need a synchronization value that will let it map between video frames and data frames. This value is computed by subtracting the data indices to the video frame indices.
2. Save the sync value and the reference segment in file *getParameters.m*. The reference segment indicates to which element the camera is attached to. For example, if it's equal to 7, it's indicating that the camera is attached to the head segment of the virtual skeleton. If it's equal to -1, it's assumed that the camera is static and in a third person point of view.
3. Add in file *getSelected.m* the joints that will be used for the EPnP at each one of the frames that one wants to use.
4. Change the *video* and the *mvnx_root* variables in *poseProjectionMultiplePnP.m*, which indicates with folder of frames and which .mvnx file have to be opened. 
5. Execute the script *poseProjectionMultiplePnP.m*
6. Manually select the 2D correspondences 
7. Check the results on screen
8. Decide what to do:

    * **Edit the 2D correspondences :** Simply move the previously selected points to the new position. Then click **n** to go to   the next frame. If its the last one, the results will be reprocessed. Then, they will be showed again and one can decide again what to do.
    * **Fine tune the results:** Using a GUI one can adjust the results for the camera position and orientation. On screen, one will find a projection using the current camera pose, a representation of the skeleton and and the camera using its current pose and a menu. From the menu, one can adjust the camera position and orientation using the local axes from the camera. One also can select which frame is constantly been shown on screen or show a projected sequence. 
        - X-Axis: Pointing from left to right in the camera image
        - Y-Axis: Pointing from top to bottom in the camera image
        - Z-Axis: Perpendicular to X and Y. Pointing in the direction in which the camera is facing.
    * **Export the results as a MP4 video:** Using a preestablished name a set of frames will be exported as a video. The frames to be exported are defined in the variable *video_frames* in *poseProjectionMultiplePnP.m*.
    
## Example

One can see that the *Frames* folder is empty, but there is one .mvnx file in the *Data* folder colled *Egocentric_Example.mvnx*. One can download the corresponding sequence of frames from [here](https://www.dropbox.com/s/qdr75fmidd8csdr/Frames.rar?dl=0). 
