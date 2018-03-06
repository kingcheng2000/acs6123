clear all
close all
clc

%% lab5_4 
video_file='visionface.avi';
vidReader=VideoReader(video_file);
frame_number=round(vidReader.Duration * vidReader.FrameRate);
% Create optical flow object
opticFlow = opticalFlowLK('NoiseThreshold',0.009);
%% sepetate video to frame
Fra_index =1:frame_number;

    frameRGB = readFrame(vidReader);
    frameGray = rgb2gray(frameRGB);

    imshow(frameRGB);
 	
    % extract RGB channels separatelly
    red_channel   =   frameRGB(:, :, 1); 
    green_channel =   frameRGB(:, :, 2); 
    blue_channel  =   frameRGB(:, :, 3); 
    imshow(red_channel);
    imshow(green_channel);
    imshow(blue_channel);

%     colourRegion = frame(132:132 + 80, 279:279+60, :) 
