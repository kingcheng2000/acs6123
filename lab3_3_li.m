close all;
clear all;
clc


%% Reading image
im = imread('Treasure_hard.jpg'); % change name to process other images
% figure,
% imshow(im); 
%info = imfinfo('Treasure_hard.jpg');

%% Binarisation
bin_threshold = 0.05; % parameter to vary ,testing the and trying to fi
bin_im = im2bw(im, bin_threshold);
figure,
% imshow(bin_im);  
          
%% Extracting connected components
con_com = bwlabel(bin_im);
imshow(label2rgb(con_com));

%% Computing objects properties
props = regionprops(con_com);
Idx_props = length(props);

%% Drawing bounding boxes
n_objects = numel(props);
% imshow(im);
hold on;
for object_id = 1 : n_objects
    rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'b');
end
% hold off;
Box_matrix = zeros(0,4);
Box_cid = zeros(0,2);
% new matrix build according to bounding box 
for i = 1: Idx_props
    Box_cid = [Box_cid ; round(props(i).Centroid)];
    Box_matrix = [Box_matrix ;[round(props(i).BoundingBox(1)),round(props(i).BoundingBox(2)),round(props(i).BoundingBox(3)),round(props(i).BoundingBox(4))]];
 
    str = num2str(Idx_props);
    text(Box_cid(1),Box_cid(2),str,'Color','red','FontSize',14);
end
   Box_stru = struct('x_aix',Box_matrix(:,1),'y_aix',Box_matrix(:,2),'x_length',Box_matrix(:,3),'y_length',Box_matrix(:,4));
   
%% Arrow/non-arrow determination
% You should develop a function arrow_finder, which returns the IDs of the arrow objects. 
% IDs are from the connected component analysis order. You may use any parameters for your function. 
% bounding box imhist
% X_boundingbox_start_point Y_boundingbox_start_point
X_bd =      round(props(1).BoundingBox(1));
Y_bd  =     round(props(1).BoundingBox(2));
X_width =   round(props(1).BoundingBox(3));
Y_height =  round(props(1).BoundingBox(4));

% Bound_im = imcrop(im,X_bd,Y_bd,abs(X_width),abs(Y_height));
Bound_im = imcrop(im,props(1).BoundingBox);
% figure,
% imshow(Bound_im)
% imhist(Bound_im)

%% Area 
figure;
imshow(im);
hold on
treasure_index = 0;
arrow_ind = zeros(0,1);
for object_id = 1: Idx_props
    if (props(object_id).Area > 3700)
        treasure_index = object_id;
    end
    
     if (props(object_id).Area > 1700)
      text (props(object_id).BoundingBox(1), props(object_id).BoundingBox(2),'not arrow','color','blue','FontSize',14);
     else
      arrow_ind(length(arrow_ind) + 1) = object_id;
      str = num2str(object_id);
      text( props(object_id).BoundingBox(1), props(object_id).BoundingBox(2),str,'color','blue','FontSize',14);
     end
end

%% building boudingbox data set 


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

min_distance = 1000000;

for i = 1:length(props)
    current_props = props(i);
    m = 0;
    if ismember(i,arrow_ind)
       m =1;
    end
       
    yellow_cid = find_yellow_circle_central_point(current_props, im);
    [k, b ,direct] = get_line_param(current_props.Centroid, yellow_cid);
    d = 0;
    
    if i ~= treasure_index && m == 1
        d = get_distance(current_props.Centroid, props(treasure_index).Centroid);
    end
    
    if min_distance > d && d > 0
        min_distance = d;
    end
    
    ArrowInfo(i) = struct('Index',i, 'Is_arrow',m, 'Centroid', current_props.Centroid, 'yellow_cid', yellow_cid, 'k' ,k, 'b', b, 'direct',direct, 'arrow_treasure_distance', d); 
end 

%% Hunting
% Detection of yellow area
cur_object = start_arrow_id; % start from the red arrow
path = cur_object;
arrow_box = props(cur_object);

current_id = start_arrow_id;
arrow_pass = zeros(0,2);
arrow_pass(1) = current_id;
arrow_discard = zeros(0,2);
is_found = true;
distance_weight = 0.7;
angle_weight = 0.3;

% while the current object is an arrow, continue to search
while is_found 
    % You should develop a function next_object_finder, which returns
    % the ID of the nearest object, which is pointed at by the current
    % arrow. You may use any other parameters for your function.
    [is_found, next_id, cost] = find_next_arrow(current_id, arrow_pass, arrow_discard, ArrowInfo, distance_weight, angle_weight);
    
%     if current_id == 27
%         testa = 0;
%     end
    
    if is_found
        is_discard = 0;
        if(length(arrow_pass) > 1)
            last_index = length(arrow_pass) - 1;
            [d, last_cost] = get_cost(ArrowInfo, arrow_pass(last_index), next_id, distance_weight, angle_weight);
            
            if(cost > last_cost)
                arrow_discard(length(arrow_discard) + 1) = arrow_pass(length(arrow_pass));
                arrow_pass(length(arrow_pass)) = [];
                is_discard = 1;
            end
        end
        
        if is_discard ~= 1
            arrow_pass(length(arrow_pass) + 1) = next_id;
            current_id = next_id;
        end
    end
    
end
checkpoint = 8;
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

function central_point = find_yellow_circle_central_point(box, img)
    yellow_matrix = zeros(0,2);
    x_length = round(box.BoundingBox(3));
    y_length = round(box.BoundingBox(4));
    index = 1;
    
    for i =  1:y_length
        for j = 1:x_length
            c = round(box.BoundingBox(1))-1+j;
            r = round(box.BoundingBox(2))-1+i;
          if ( img(r,c,1)>220 && img(r,c,2)>67 && img(r,c,3)<40 )
             yellow_matrix(index, 1) = c;  
             yellow_matrix(index, 2) = r;  
             index = index + 1;
          end
        end

    end
    % Central point of yellow area 

    central_point = mean(yellow_matrix);
end

function [k, b ,direct] = get_line_param(point1, point2)
    y_cid = point1(2);
    x_cid = point1(1);
    y_d = point2(2)- y_cid;
    x_d = point2(1)-x_cid;
    k = (y_d)/(x_d);
    b = point2(2) - k * point2(1);
    direct = -1;
    if y_d > 0
        direct = 1;
    end
end

function d = get_distance(first_point, second_point)
    x_d = first_point(1) - second_point(1);
    y_d = first_point(2) - second_point(2);
    d = sqrt(x_d * x_d + y_d * y_d);
end

function [d, cost] = get_cost(ArrowInfo, point1_index, point2_index, distance_weight, angle_weight)
    PI = 3.1415159;
    d = get_distance(ArrowInfo(point1_index).Centroid, ArrowInfo(point2_index).Centroid);
    c1 = atan(ArrowInfo(point1_index).k) * 180 / PI;
    c2 = atan(ArrowInfo(point2_index).k) * 180 / PI;
    angle1 = get_real_angle(c1, ArrowInfo(point1_index).direct);
    angle2 = get_real_angle(c2, ArrowInfo(point2_index).direct);
    angle = abs(angle2 - angle1);
    
    if angle > 180
        angle = 360 - angle;
    end
    
    cost = d * distance_weight + angle * angle_weight;
end

function [is_found, next_id, min_cost] = find_next_arrow(current_id, arrow_pass, arrow_discard, ArrowInfo, distance_weight, angle_weight)
    min_cost = 1000000;
    is_found = false;
    next_id = 0;
    for i = 1: length(ArrowInfo)
        if ~(ismember(i, arrow_pass) || ismember(i, arrow_discard) || ArrowInfo(i).Is_arrow == 0)
            [d1, cost] = get_cost(ArrowInfo, current_id, i, distance_weight, angle_weight);
            d2 = get_distance(ArrowInfo(current_id).yellow_cid, ArrowInfo(i).yellow_cid);
            
            [x1, y1] = get_line_point_shadow(ArrowInfo(current_id).k, ArrowInfo(current_id).b, ArrowInfo(i).Centroid(1), ArrowInfo(i).Centroid(2));
            [x2, y2] = get_line_point_shadow(ArrowInfo(current_id).k, ArrowInfo(current_id).b, ArrowInfo(i).yellow_cid(1), ArrowInfo(i).yellow_cid(2));
            
            [k1, b1 ,direct1] = get_line_param(ArrowInfo(current_id).Centroid, [x1, y1]);
            [k2, b2 ,direct2] = get_line_param(ArrowInfo(current_id).yellow_cid, [x2, y2]);
            
            if d2 < d1 && ((ArrowInfo(current_id).direct > 0 && y2 <= ArrowInfo(current_id).yellow_cid(2)) || (ArrowInfo(current_id).direct < 0 && y2 > ArrowInfo(current_id).yellow_cid(2)))
            elseif ArrowInfo(current_id).direct == (-direct1) && ArrowInfo(current_id).direct == (-direct2)
            else
                if min_cost > cost
                    min_cost = cost;
                    is_found = true;
                    next_id = i;
                end
            end
            
        end
    end
end

function angle = get_real_angle(angle_value, direct)
    angle = angle_value;
    
    if direct == 1 && angle_value < 0
        angle = 180 + angle_value;
    elseif direct == -1 && angle_value < 0
        angle = 360 + angle_value;
    elseif direct == -1 && angle_value > 0
        angle = 180 + angle_value;
    end
end

function [x1, y1] = get_line_point_shadow(k, b, x0, y0)
    x1 = (k * y0 + x0 - k * b) / (k^2 + 1);
    y1 = (k^2 * y0 + k * x0 + b) / (k^2 + 1);
end
