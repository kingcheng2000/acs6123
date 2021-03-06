close all;
clear all;
clc
%% Reading image
im = imread('Treasure_hard.jpg'); % change name to process other images
% figure,
% imshow(im); 
info = imfinfo('Treasure_hard.jpg');

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
arrow_ind = zeros(0,1);
for object_id = 1: Idx_props
     if (props(object_id).Area > 1700)
      text (props(object_id).BoundingBox(1), props(object_id).BoundingBox(2),'not arrow','color','blue','FontSize',14);
     else
      arrow_ind = [arrow_ind ;object_id];
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

%% Hunting
% Detection of yellow area
cur_object = start_arrow_id; % start from the red arrow
path = cur_object;
yellow_matrix = zeros(0,2);
x_length = round(props(cur_object).BoundingBox(3));;
y_length = round(props(cur_object).BoundingBox(4));;
iteration =0;

for i =  1:y_length
    for j = 1:x_length
        c = round(props(cur_object).BoundingBox(1))-1+j;
        r = round(props(cur_object).BoundingBox(2))-1+i;
      if ( im(r,c,1)>220 && im(r,c,2)>67 && im(r,c,3)<40 )
         yellow_matrix = [yellow_matrix;[c,r]];  
         text (X_bd,Y_bd,'arrow','color','black')
      end
      iteration = iteration +1;
    end
     
end
% Central point of yellow area 

yellow_cid = mean(yellow_matrix);
y_cid = props(cur_object).Centroid(2);
x_cid = props(cur_object).Centroid(1);
k1 = (yellow_cid(2)- y_cid)/(yellow_cid(1)-x_cid);
y_s = round(k1* props(path).BoundingBox(1));
intercept =  yellow_cid(2) - k1*yellow_cid(1);

%% search for next objects
% Arrow direction detection 
 if (yellow_cid(2) > Box_cid(cur_object,1) )   
      direction = 1;
 else 
      direction = -1;
 end
 step = 2*direction;
 found_point =zeros(0,2);
 Hunting_start = round(yellow_cid(1));
 Hunting_end = round(yellow_cid(1)+ 100* direction);
 for  c = Hunting_start:direction:Hunting_end 

      c1 = c + step;
      c2 = c + 2*step;
      
      r=round(k1*c+intercept);
      r1 = round(k1*(c1)+intercept);
      r2= round(k1*(c2)+intercept);

      if (im(r,c,1)<=8 && im(r,c,2)<=8 && im(r,c,3)<=8 )&& (im(r1,c1,1)<=251 && im(r1,c1,2)<=251 && im(r1,c1,3)<=251 ) && (im(r2,c2,1)>=251 && im(r2,c2,2)>=251 && im(r2,c2,3)>=251 )
      found_point =[r2,c2];
      break;
      end
 end
 
%% find the index 
for i = 1: length(Bounding_box_stru)
    if ismember(found_point,Bounding_box_stru(i).Matrix)
        if Bounding_box_stru(i).Is_arrow ==1
        cur_object =Bounding_box_stru(i).Index;
        break;
        end
    end
end
checkpoint = 8;
% while the current object is an arrow, continue to search
while ismember(cur_object, arrow_ind) 
    % You should develop a function next_object_finder, which returns
    % the ID of the nearest object, which is pointed at by the current
    % arrow. You may use any other parameters for your function.

    cur_object = next_object_finder(cur_object);
    path(end + 1) = cur_object;
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



