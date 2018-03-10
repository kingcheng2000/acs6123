close all;
clear all;
clc
%% Reading image
im = imread('Treasure_easy.jpg'); % change name to process other images
figure,
imshow(im); 
info = imfinfo('Treasure_easy.jpg');

%% Binarisation
bin_threshold = 0.05; % parameter to vary
bin_im = im2bw(im, bin_threshold);
figure,
imshow(bin_im);  
          
%% Extracting connected components
con_com = bwlabel(bin_im);
imshow(label2rgb(con_com));

%% Computing objects properties
props = regionprops(con_com);
Idx_props = length(props);

%% Drawing bounding boxes
n_objects = numel(props);
imshow(im);
hold on;
for object_id = 1 : n_objects
    rectangle('Position', props(object_id).BoundingBox, 'EdgeColor', 'b');
end
% hold off;
Box_cid = zeros(0,2);
for i = 1: Idx_props
    % matrice row extention 
    Box_cid = [Box_cid ; round(props(i).Centroid)];
    str = num2str(Idx_props)
    text(Box_cid(1),Box_cid(2),str,'Color','red','FontSize',14);
end
% Bounding box1

% [nr,nc,np]= size(im);
% newIm= zeros(nr,nc,np);
% newIm= uint8(newIm);

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
figure,
imshow(Bound_im)
imhist(Bound_im)
% figure,
% for i = 1:Idx_props
%     Bound_im =imcrop(im,props(i).BoundingBox)
%     subplot(2,Idx_props,i);
%     imshow(Bound_im);
%     subplot(2,Idx_props,Idx_props+i);
%     imhist(Bound_im);
% end
%% color yellow detection 
% figure;
% imshow(im);
% for r= X_bd:(X_bd+X_width)
%     for c= Y_bd:(Y_bd+Y_height)
%         if ( im(r,c,1)>247 && im(r,c,2)>218 && im(r,c,3)>234 )
%          text (X_bd,Y_bd,'arrow','color','black')
%           endif 
%         else 
%           text (X_bd,Y_bd,'not a arrow');
%           hold on;
%         end
%     end
% end
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
      text( props(object_id).BoundingBox(1), props(object_id).BoundingBox(2),'arrow','color','blue','FontSize',14);
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
