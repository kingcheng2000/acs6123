%% Lab5_frame reader
clear all
close
clc
%% Video creator
xyloObj = VideoReader('red_square_video.mp4');

vidWidth = xyloObj.Width;
vidHeight = xyloObj.Height;

mov = struct('cdata',zeros(vidHeight,vidWidth,3,'uint8'),...
    'colormap',[]);
% Read one fram at a time until the end of the video is reached 
k = 1;
while hasFrame(xyloObj)
    mov(k).cdata = readFrame(xyloObj);
    k = k+1;
end

%% video reading
% Create an video reader object 
    video_file='red_square_video.mp4';
    vidReader=VideoReader(video_file);
    frame_number=round(vidReader.Duration * vidReader.FrameRate);
% Create optical flow object
    opticFlow = opticalFlowLK('NoiseThreshold',0.009);
% Find left top point of the red square on the first frame 
    frameRGB = readFrame(vidReader);
    frameGray = rgb2gray(frameRGB);
    C = corner(frameGray,'MinimumEigenvalue');
 % Top left point
    top_left  = min(C);
    
    flow = estimateFlow(opticFlow,frameGray); 
    corner_x = min(C(:,1));
    corner_y = min(C(1,:));
% Read 2nd frame and find the corner points 
    frame2 = mov(2).cdata;
    frame2_RGB = mov(2).cdata;
    frame2_Gray = rgb2gray(frame2_RGB);
    C = corner(frame2_Gray,'MinimumEigenvalue');
    

x =8;
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