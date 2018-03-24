close all;
clear all;
clc

%% Reading image
im = imread('Treasure_hard.jpg'); % change name to process other images
imshow(im);

%% Binarisation
bin_threshold = 0.05; % parameter to vary
bin_im = im2bw(im, bin_threshold);
imshow(bin_im);

%% Extracting connected components
con_com = bwlabel(bin_im);
imshow(label2rgb(con_com));

%% Computing objects properties
props = regionprops(con_com);

%% Drawing bounding boxes
n_objects = numel(props);
imshow(im);
hold on;
for object_id = 1 : n_objects
    rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'b');
end
hold off;
%% build data structure yellow area data sets, bounding box data sets 


check_point =8;
%% Arrow/non-arrow determination
% You should develop a function arrow_finder, which returns the IDs of the arror objects. 
% IDs are from the connected component analysis order. You may use any parameters for your function. 

 
arrow_ind = arrow_finder();

check_point =8;


for i = 1:length(props)
   box_x = round(props(i).BoundingBox(1));
   box_y = round(props(i).BoundingBox(2));
   x_length= round(props(i).BoundingBox(3));
   y_length= round(props(i).BoundingBox(4));
   Boundbox_dataset= zeros(0,2);
   for j = box_x :box_x+x_length
       for k = box_y :box_y+y_length
           Boundbox_dataset = [Boundbox_dataset;[j,k]];
       end
       if ismember(i,arrow_ind)
           m =1;
       else
           m =0;
       end
       Bounding_box_stru(i) = struct('Index',i,'Matrix',Boundbox_dataset,'Is_arrow',m); 
   end
   
end 

%% Finding red arrow
n_arrows = numel(arrow_ind);
start_arrow_id = 0;
% check each arrow until find the red one
for arrow_num = 1 : n_arrows
    object_id = arrow_ind(arrow_num);    % determine the arrow id
    
    % extract colour of the centroid point of the current arrow
    centroid_colour = im(round(props(object_id).Centroid(2)), round(props(object_id).Centroid(1)), :); 
    if centroid_colour(:, :, 1) > 240 && centroid_colour(:, :, 2) < 10 && centroid_colour(:, :, 3) < 10
	% the centroid point is red, memorise its id and break the loop
        start_arrow_id = object_id;
        break;
    end
end

 
%% Hunting
cur_object = start_arrow_id; % start from the red arrow
path = cur_object;
 
% while the current object is an arrow, continue to search
while ismember(cur_object, arrow_ind) 
    % You should develop a function next_object_finder, which returns
    % the ID of the nearest object, which is pointed at by the current
    % arrow. You may use any other parameters for your function.

    cur_object = next_object_finder(cur_object);
    path(end + 1) = cur_object;
end

%% visualisation of the path
imshow(im);
hold on;
for path_element = 1 : numel(path) - 1
    object_id = path(path_element); % determine the object id
    rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'y');
    str = num2str(path_element);
    text(props(object_id).BoundingBox(1), props(object_id).BoundingBox(2), str, 'Color', 'r', 'FontWeight', 'bold', 'FontSize', 14);
end

% visualisation of the treasure
treasure_id = path(end);
rectangle('Position', props(treasure_id).BoundingBox, 'EdgeColor', 'g');
