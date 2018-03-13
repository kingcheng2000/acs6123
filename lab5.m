clear all
close all
clc
%% optical flow estimation 

videoReader = VideoReader('red_square_video.mp4');
frameRGB = readFrame(videoReader);
frameGrey = rgb2gray(frameRGB);

opticFlow = opticalFlowLK('NoiseThreshold',0.009);
flow = estimateFlow(opticFlow,frameGrey);

%%
