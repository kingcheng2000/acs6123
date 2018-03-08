clear all
close all
clc

%% lab5_4 
% Create a video reader object to read the ‘visionface.avi’ 
video_file='visionface.avi';
vidReader=VideoReader(video_file);
frame_number=round(vidReader.Duration * vidReader.FrameRate);
% Create optical flow object
opticFlow = opticalFlowLK('NoiseThreshold',0.009);

% Read the first frame
frameRGB_1st = readFrame(vidReader);
% Extract the part of the image's region 
% this will be used to compute colour template of the object
colourRegion = frameRGB_1st(132:132 + 80, 279:279+60, :);
% Computer colour histograms 
red_channel   =   frameRGB_1st(:, :, 1); 
green_channel =   frameRGB_1st(:, :, 2); 
blue_channel  =   frameRGB_1st(:, :, 3);

%% three constraints 
% illustrate the first frame from video stream
% ???? normalise the histograms 
figure,imshow(frameRGB_1st);

figure, imhist(red_channel);
xlabel('Number of bins (256 by default for a greyscale image)')
ylabel('red-channel Histogram counts ')
title ('red channel')

figure, imhist(green_channel);
xlabel('Number of bins (256 by default for a greyscale image)')
ylabel('green-channel Histogram counts ')
title ('green channel')


figure, imhist(green_channel);
xlabel('Number of bins (256 by default for a greyscale image)')
ylabel('blue-channel Histogram counts ')
title ('blue channel')

% colour constraints 
colour_threshold = 1.0e-08;
% the proximity constraint of the tracking points
proximity_threshold = 3;

% Initialisation the optical flow object
Optical_Obj = estimateFlow(frameRGB_1st);

bbox = [266, 121, 83, 93];
