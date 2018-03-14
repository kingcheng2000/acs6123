%% Lab5_frame reader
clear all
close
clc
%% Video creator
    VidReader = VideoReader('red_square_video.mp4');
    frame_number=round(VidReader.Duration * VidReader.FrameRate);
    vidWidth = VidReader.Width;
    vidHeight = VidReader.Height;

% Create optical flow object
    opticFlow = opticalFlowLK('NoiseThreshold',0.009);

tracks =zeros(0,2);   
% Top left point
% Read the first frame 
    frame_RGB =  readFrame(VidReader);
    frame_Gray = rgb2gray(frame_RGB);
    Corner_point = corner(frame_Gray,'MinimumEigenvalue');
    corner_x = min(Corner_point(:,1));
    corner_y = min(Corner_point(:,2));
% Add position of this point as the first position in the track;
tracks = [corner_x,corner_y];
% initialize the optical flow object
    flow = estimateFlow(opticFlow,frame_Gray);
% Video to frames

    mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
% Read one fram at a time until the end of the video is reached 
for  i = 2:frame_number
    while hasFrame(VidReader)
    frame_RGB =  readFrame(VidReader);
    frame_Gray = rgb2gray(frame_RGB);
    Corner_point = corner(frame_Gray,'MinimumEigenvalue');
% Find the nearest corner point to your first position from the track
    Distance = zeros(0,1);
    Matrix_dis = zeros(0,3);
  for i = 1: length(Corner_point);
      Distance = [Distance;sqrt(Corner_point(i,1) - corner_x)^2 + (Corner_point(i,2) - corner_y)^2];    
  end
    Matrix_dis = [Corner_point Distance];

    corner_x = min(Matrix_dis(:,1));
    corner_y = min(Matrix_dis(:,2));
% Compute an optical flow  for this point (between frames 1 and 2);
    flow = estimateFlow(opticFlow,frame_Gray);
    x_new = corner_x + flow.Vx(round(corner_y), round(corner_x));
    y_new = corner_y + flow.Vy(round(corner_y), round(corner_x));
    
    tracks =[tracks;x_new,y_new];
    
 

% Visualise the track on the last frame of the video
    imshow(frame_RGB) 
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off 
    end
end
load red_square_gt.mat
figure;
plot(tracks(:,1),tracks(:,2),'r*');
hold on 
plot(gt_track_spatial(:,1),gt_track_spatial(:,2),'bs');
figure;

for i = 1:length(tracks)
    RMSe(i)= sqrt((tracks(i,1)-gt_track_spatial(i,1))^2+(tracks(i,2)-gt_track_spatial(i,2))^2)
    
bar(i,RMSe(i));
hold on
end
x =8;
%% tracks and detections

% build cost matrix between current positions and detection points
cost = zeros(size(track_points, 1), size(detection_points, 1));
for i = 1:size(track_points, 1)
    for j = 1 : size(detection_points, 1)
        cost(i, j) = norm(track_points(i, :) - detection_points(j, :));
    end
end
    
% compute assigments between currents positions and detection points
costOfNonAssignment = 10;
[assignments, unassignedTracks, unassignedDetections] = ...
 assignDetectionsToTracks(cost, costOfNonAssignment);



%% video reading
% Create an video reader object 
    video_file='red_square_video.mp4';
    vidReader=VidReader(video_file);
    frame_number=round(vidReader.Duration * vidReader.FrameRate);
% Create optical flow object
    opticFlow = opticalFlowLK('NoiseThreshold',0.009);
% Find left top point of the red square on the first frame 

    C = corner(frame1_Gray,'MinimumEigenvalue');
 % Top left point
    top_left  = min(C);
     
    frame1_x = min(C(:,1));
    frame1_y = min(C(1,:));
    flow1 = estimateFlow(opticFlow,frame1_Gray); 
%     x_new = corner_x + flow1.Vx(round(corner_y), round(corner_x));
%     y_new = corner_y + flow1.Vy(round(corner_y), round(corner_x));
    x_new = frame1_x + flow1.Vx(round(frame1_y), round(frame1_x));
    y_new = frame1_y + flow1.Vy(round(frame1_y), round(frame1_x));
    
%% Read 2nd frame and find the corner points 
    frame2 = mov(2).cdata;
    frame2_RGB = mov(2).cdata;
    frame2_Gray = rgb2gray(frame2_RGB);
% Corner points (corner) in frame 2
    C2 = corner(frame2_Gray,'MinimumEigenvalue');
    
% Find the nearest corner point to your first position from the track
Distance = zeros(0,1);
Matrix_dis = zeros(0,3);
  for i = 1: length(C2);
      Distance = [Distance;sqrt(C2(i,1) - frame1_x)^2 + (C2(i,2) - frame1_y)^2];    
  end
    Matrix_dis = [C2 Distance];
    corner_x = min(Matrix_dis(:,1));
    corner_y = min(Matrix_dis(1,:));
% Compute an optical for this point (between frames 1 and 2); 
    flow2 = estimateFlow(opticFlow,frame2_Gray);
    x_new = corner_x + flow2.Vx(round(corner_y), round(corner_x));
    y_new = corner_y + flow2.Vy(round(corner_y), round(corner_x));
    

    imshow(frame2_RGB) 
    hold on
    plot(flow,'DecimationFactor',[5 5],'ScaleFactor',10)
    hold off 
    
    
    
    

    
VidReader =8;
%% sepetate video to frame
for i=1:frame_number
frame_ind = 1;
end
% Create an video reader object 
    while hasFrame(vidReader)
    frameRGB = readFrame(vidReader);
    frameGray = rgb2gray(frameRGB);
    C = corner(frameGray,'MinimumEigenvalue');
% Add position of this point as the first position in the track
    flow = estimateFlow(opticFlow,frameGray); 
    corner_x = min(C(:,1));
    corner_y = min(C(1,:));
% Corner points in frame 2

% Compute a new position of the point by adding the found velocity vector to the current position
 
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