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
    imhis_m_r = [r_counts,r_binLocations];
    imhis_m_g = [g_counts,g_binLocations];
    imhis_m_b = [b_counts,b_binLocations];
% nominal r g b 
    r_numerator =zeros(0,1);
    total_counter_r = sum(imhis_m_r(:,1));
    total_counter_g = sum(imhis_m_g(:,1));
    total_counter_b = sum(imhis_m_b(:,1));
    
    red_hist = zeros();
    green_hist = zeros();
    blue_hist = zeros();
for i = 1: length(r_counts)
    red_hist = [red_hist;imhis_m_r(i,1)/total_counter_r];
end
    
for i = 1: length(g_counts)
    green_hist = [green_hist;imhis_m_g(i,1)/total_counter_g];
end

for i = 1: length(b_counts)
    blue_hist = [blue_hist;imhis_m_b(i,1)/total_counter_b];
end

%%
%Second constraint colour constraint 

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
 
 figure,
%  plot(interesting_points(:,1),interesting_points(:,2),'y.')
%  hold on
 %bounding box matrix
     for i= 266: (266+83)
       for j = 121:(121+93)
        bbox_metrix=[bbox_metrix;[i,j]];
       end
     end
    plot(bbox_metrix(:,1),bbox_metrix(:,2),'r.');
    hold on
%inteetsting_points in  bounding box
    LiA = ismember(interesting_points,bbox_metrix,'rows');
    interesting_points_ind = [interesting_points LiA];
    in_bbox_matrix = zeros(0,2);
    A=zeros;
%filter points not in bounding_box 
for i = 1:length(interesting_points)
     if interesting_points_ind(i,3)== 1
     in_bbox_matrix = [in_bbox_matrix;[interesting_points_ind(i,1),interesting_points_ind(i,2)]];
     A =[A;i];
    end
end
%Second constraint
cur_color = zeros(0,3);
in_color_matrix = zeros(0,2);
colour_threshold = 1.0e-08;
for i = 1:length(in_bbox_matrix)
    red_channel   =   frame_RGB(in_bbox_matrix(i,1), in_bbox_matrix(i,2), 1); 
    green_channel =   frame_RGB(in_bbox_matrix(i,1), in_bbox_matrix(i,2), 2); 
    blue_channel  =   frame_RGB(in_bbox_matrix(i,1), in_bbox_matrix(i,2), 3); 
    cur_color = [red_channel green_channel blue_channel];
    if (red_hist(cur_color(1) + 1)* green_hist(cur_color(2) + 1) * blue_hist(cur_color(3)+ 1) < colour_threshold)
    in_color_matrix = [in_color_matrix;[in_bbox_matrix(i,1),in_bbox_matrix(i,2)]];
    else
        break;
    end
end
x = sum(red_hist(:,1));
y = sum(green_hist(:,1));
z = sum(blue_hist(:,1));

plot(in_color_matrix(:,1),in_color_matrix(:,2),'bx');
hold on
x =8;
%%
%Third constraint proximity constraint of the tracking points

% [s_row,s_col] = find(min(in_color_matrix(1)));
% start_point  = min(in_color_matrix); 
start_point = [in_color_matrix(1,1),in_color_matrix(1,2)];
% x_end = max(max(in_color_matrix(1)));
x_end = 317;
y_end = max(in_color_matrix(2));
in_prox_matrix = zeros(0,2);
for i = start_point(1):6:x_end
     for j = start_point(2):6:y_end
         in_prox_matrix =[in_prox_matrix;[i,j]];
     end
end
plot(in_prox_matrix(:,1),in_prox_matrix(:,2),'gs');
x =9;
y =10;
% build cost matrix between current positions and detection points

cost = zeros(size(track_points, 1), size(detection_points, 1));
for i = 1:size(track_points, 1)
    for j = 1 : size(detection_points, 1)
        cost(i, j) = norm(track_points(i, :) - detection_points(j, :));
    end
end
    
% compute assigments between currents positions and detection points
costOfNonAssignment = 10;
[assignments, unassignedTracks, unassignedDetections] = assignDetectionsToTracks(cost, costOfNonAssignment);

 
 
 
 
 