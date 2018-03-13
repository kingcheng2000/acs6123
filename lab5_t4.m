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
% for i=1:frame_number
frame_ind = 1;
    while hasFrame(vidReader)
    frameRGB = readFrame(vidReader);
    frameGray = rgb2gray(frameRGB);
    C = corner(frameGray,'MinimumEigenvalue');
    flow = estimateFlow(opticFlow,frameGray); 
    corner_x = min(C(:,1));
    corner_y = min(C(1,:));
    x_new = corner_x + flow.Vx(round(corner_y), round(corner_x));
    y_new = corner_y + flow.Vy(round(corner_y), round(corner_x));
    X_trace(frame_ind+1) =[x_new]+X_trace(frame_ind+1);
    Y_trace(frame_ind+1) =[y_new]+Y_trace(frame_ind+1);
    imshow(frameGray)
    hold on
    plot(corner_x,corner_y,'rx');
%     plot(corner_x(i+1),corner_y(i+1),'rx');
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off
    frame_ind = frame_ind+1;
    end 


% end

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