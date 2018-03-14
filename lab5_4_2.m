clear all
close all
clc

%% lab5 Section 4
video_file='visionface.avi';
VidReader=VideoReader(video_file);
frame_number=round(VidReader.Duration * VidReader.FrameRate);
% Create optical flow object
opticFlow = opticalFlowLK('NoiseThreshold',0.009);
%% seprete video to frame
    Fra_index =1:frame_number;

    frame_RGB = readFrame(VidReader);
    frame_Gray = rgb2gray(frame_RGB);
%Extract the part of the image 
    colourRegion = frame_RGB(132:132 + 80, 279:279+60,:);

    imshow(frame_RGB);
 	
%First constraint extract RGB channels separatelly
    red_channel   =   colourRegion(:, :, 1); 
    green_channel =   colourRegion(:, :, 2); 
    blue_channel  =   colourRegion(:, :, 3); 
    
    
    
    [r_counts,r_binLocations] = imhist(red_channel);
    [g_counts,g_binLocations] = imhist(green_channel);
    [b_counts,b_binLocations] = imhist(blue_channel);
% nominal r g b 
    r_numerator =zeros(0,1);
for i = 1: length(r_counts)
    r_numerator = [r_numerator;r_binLocations(i,1)*r_counts(i,1)];
end
    red_hist = sum(r_numerator)/(sum(r_binLocations)*255);
    
    g_numerator =zeros(0,1);
for i = 1: length(g_counts)
    g_numerator = [g_numerator;g_binLocations(i,1)*r_counts(i,1)];
end
    green_hist = sum(g_numerator)/(sum(g_binLocations)*255);
    
    b_numerator =zeros(0,1);
for i = 1: length(b_counts)
    b_numerator = [b_numerator;b_binLocations(i,1)*b_counts(i,1)];
end
    blue_hist = sum(b_numerator)/(sum(b_binLocations)*255);
   
%% histogram illustrator   
%     figure,
%     subplot(3,1,1);
%     imhist(red_channel);
%     title('red channel histogram')
%     
%     subplot(3,1,2);
%     imhist(green_channel);
%     title('green channel histogram')
%     
%     subplot(3,1,3);   
%     imhist(blue_channel);
%     title('blue channel histogram')
%%
%Second constraint colour constraint 
%     colour_threshold = 1.0e-08;
%  (red_hist(cur_color(1) + 1) * green_hist(cur_color(2) + 1) *...
%      blue_hist(cur_color(3) +1) < colour_threshold);
%Third constraint proximity constraint of the tracking points
    proximity_threshold = 3;
%Initialize the optical flow object
    flow = estimateFlow(opticFlow,frame_Gray);
%Read from second frame  

 for  i = 2:frame_number
    while hasFrame(VidReader)
        frame_RGB =  readFrame(VidReader);
        frame_Gray = rgb2gray(frame_RGB);
        imshow(frame_RGB);
        hold on;
        bbox = [266, 121, 83, 93];
        rectangle('Position', bbox, 'EdgeColor', 'b');
        flow = estimateFlow(opticFlow,frame_Gray);
%Extrac interesting points     
    [row, col] = find(flow.Vx ~= 0);
    interesting_points = [col, row];
    bbox_metrix = zeros(0,2);
    end
 end
 %bounding box matrix
     for i= 266: (266+83)
       for j = 121:(121+93)
        bbox_metrix=[bbox_metrix;[i,j]];
       end
    end
    figure,
    plot(bbox_metrix(:,1),bbox_metrix(:,2),'r.')
%inteetsting_points in  bounding box
    LiA = ismember(interesting_points,bbox_metrix,'rows');
    interesting_points_ind = [interesting_points LiA];
    in_bboxpoint = zeros(0,2);
    A=zeros;
%filter points not in bounding_box 
for i = 1:length(interesting_points)
     if interesting_points_ind(i,3)== 1
     in_bboxpoint = [in_bboxpoint;[interesting_points_ind(i,1),interesting_points_ind(i,2)]];
     A =[A;i];
    end
end

x =8;

 
 
 
 
 