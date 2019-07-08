# 3D Pose Projection Onto Egocentric Video Frames

This repository contains the MATLAB code for projecting a sequence of 3D poses onto a sequence of frames. Both sequences were recorded at the same time and they have to be already synchronized. This code is thought to be used with 3D poses obtained using MVN Awinda, but the code provided can easily be adapted to other sources. 

## Main script
To project a sequence of 3D poses onto a sequences of frames one needs to use the interactive app in file poseProjectionMultiplePnP.m . In the script one can how to use it to obtain the projections. 

This app is capable of:
* Obtain the camera position and orientation needed to execute the projection using an EPnP algorithm. To do so, the user has to manually select the 2D correspondences.
* The user can manually adjust the estimated camera pose in order to fine tune the results
* Show the projection of the 3D poses onto the frames on screen
* Export the projection as a MP4 file

## Example of usage
