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
figure;
imshow(im);
hold on;
for object_id = 1 : n_objects
    rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'b');
end
hold off;

%% Arrow/non-arrow determination
arrow_ind = arrow_finder();
%% build data structure Bounding box data sets AND Yellow area data sets, 
Yellow_matrix = zeros(0,2);
Yellow_dataset = zeros(0,2);
iteration =0;
for i = 1:length(props)
   box_x = round(props(i).BoundingBox(1));
   box_y = round(props(i).BoundingBox(2));
   x_length= round(props(i).BoundingBox(3));
   y_length= round(props(i).BoundingBox(4));
   Boundbox_dataset= zeros(0,2);
   for c = box_x :box_x+x_length
       for r = box_y :box_y+y_length
           Boundbox_dataset = [Boundbox_dataset;[c,r]];
                 if ( im(r,c,1)>250 && im(r,c,2)>230 && im(r,c,3)<50 )
%                    Yellow_matrix = [Yellow_matrix;[c,r]]; 
                 end
       end
       if ismember(i,arrow_ind)
           m =1;
       else
           m =0;
       end
       iteration = iteration +1;
%        Yellow_dataset = [Yellow_matrix;[c,r]];
%        yellow_cid = mean(Yellow_matrix);
%        Bounding_box_stru(i) = struct('Index',i,'Matrix',Boundbox_dataset,'Yellow_matrix',Yellow_matrix,'Yellow_cid',yellow_cid,'Is_arrow',m); 
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
 
%% Detection of yellow area
cur_object = start_arrow_id; % start from the red arrow
path = cur_object;
for i = 1: length(props)
    
Yellow_matrix = zeros(0,2);
yellow_cid = zeros(0,2);

   box_x = round(props(i).BoundingBox(1));
   box_y = round(props(i).BoundingBox(2));
   x_length= round(props(i).BoundingBox(3));
   y_length= round(props(i).BoundingBox(4));

for c = box_x: box_x + x_length 
    for r = box_y: box_y+y_length
    if ( im(r,c,1)>250 && im(r,c,2)>230 && im(r,c,3)<50 )
         Yellow_matrix = [Yellow_matrix;[c,r]];  
         yellow_cid = mean(Yellow_matrix);
%          text (X_bd,Y_bd,'arrow','color','black')
     end
      iteration = iteration +1;
    end  
    Yellow_matrix_stru(i) = struct('Index',i,'Matrix',Yellow_matrix,'Yellow_cid',yellow_cid); 
    end
end

% Central point of yellow area 
yellow_cid = mean(Yellow_matrix);

x_yellow_cid =yellow_cid(1);
y_yellow_cid =-yellow_cid(2);
y_cid = props(cur_object).Centroid(2);
x_cid = props(cur_object).Centroid(1);

k1 = (y_yellow_cid - y_cid)/(x_yellow_cid-x_cid);
y_s = round(k1* props(path).BoundingBox(1));
intercept =  y_yellow_cid - k1*x_yellow_cid;

%% plot arrow in spatial 
% figure;
% 
% P1_x = Bounding_box_stru.Matrix;
% plot(P1_x(:,1),-P1_x(:,2),'rx');
% axis([0 640 -480 0])
% hold on
% P1_cx =props(1).Centroid
% plot(P1_cx(1),-P1_cx(2),'bo')
% hold on 
% P1_yx = Yellow_matrix_stru.Yellow_cid
% plot(P1_yx(1),-P1_yx(2),'go')
% hold on 
% 
% P2_x = Bounding_box_stru(2).Matrix;
% plot(P2_x(:,1),-P2_x(:,2),'rx');
% axis([0 640 -480 0])
% hold on
% P2_cx =props(2).Centroid
% plot(P2_cx(1),-P2_cx(2),'bo')
% hold on 
% P2_yx = Yellow_matrix_stru(2).Yellow_cid
% plot(P2_yx(1),-P2_yx(2),'go')
% hold on 
% 
% kp = (-P1_cx(2)+ P1_yx(2))/(P1_cx(1)-P1_yx(1));
% p_intercept = -P1_yx(2)- kp*P1_yx(1);
% p_x= 0:1:100;
% p_y = kp*p_x + p_intercept
% plot(p_x,p_y,'k-')
% check_point = 8;
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
