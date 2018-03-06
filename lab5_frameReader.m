%% Lab5_frame reader
clear all
close
clc

%% video reading
video_file='red_square_video.mp4';
vidReader=VideoReader(video_file);
frame_number=round(vidReader.Duration * vidReader.FrameRate);
% Create optical flow object
opticFlow = opticalFlowLK('NoiseThreshold',0.009);
%% sepetate video to frame
Fra_index =1:frame_number;
 for i = 1 : frame_number
    frameRGB = read(vidReader,i);
    frameGray = rgb2gray(frameRGB);
    C = corner(frameGray); 
    flow = estimateFlow(opticFlow,frameGray); 
    corner_x = min(C (:,1));
    corner_y = min(C (1,:));;
    imshow(frameGray)
    hold on
    plot(corner_x,corner_y,'rx');
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off
    x_new = corner_x + flow.Vx(round(corner_y), round(corner_x));
    y_new = corner_y + flow.Vy(round(corner_y), round(corner_x));
    x(i+1)= corner_x + x_new;
    y(i+1)= corner_y + y_new;
 end 
 plot(x,y)
% Visualise also the ground truth track (in spatial coordinates)
load red_square_gt.mat
% 
%
y = gt_track_spatial(:,1);
x = gt_track_spatial(:,2);
plot (x,y)

%% Estimate and display the optical flow of objects in the video
% while hasFrame(vidReader)
%     frameRGB = readFrame(vidReader);
%     frameGray = rgb2gray(frameRGB);
%   
%     flow = estimateFlow(opticFlow,frameGray); 
% 
%     imshow(frameRGB) 
%     hold on
%     plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
%     hold off 
% end