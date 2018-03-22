close all;
clear all;
clc
%% Reading image
im = imread('Treasure_hard.jpg'); % change name to process other images
figure,
imshow(im); 
info = imfinfo('Treasure_hard.jpg');

%% Binarisation
bin_threshold = 0.05; % parameter to vary ,testing the and trying to fi
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
figure,
imshow(Bound_im)
imhist(Bound_im)

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

%% Detection of yellow area
cur_object = start_arrow_id; % start from the red arrow
path = cur_object;
yellow_matrix = zeros(0,2);

 
for i =  1:Box_stru(cur_object).y_length
    for j = 1:Box_stru(cur_object).x_length
        c = Box_stru.x_aix-1+i;
        r = Box_stru.y_aix-1+j;
      if ( im(r,c,1)>247 && im(r,c,2)>218 && im(r,c,3)>234 )
         yellow_matrix = [yellow_matrix;[c,r]];  
         text (X_bd,Y_bd,'arrow','color','black')
      end
    end
     
end

test_point =8;
%% Central point of yellow area 
% yellow area matrix
cur_object = start_arrow_id; % start from the red arrow
path = cur_object;
x = round(props(path).BoundingBox(1));
y = round(props(path).BoundingBox(2));
x1 = round(props(path).BoundingBox(3));
y1 = round(props(path).BoundingBox(4));
x_c = round(props(path).Centroid(1)); 
y_c = round(props(path).Centroid(2)); 
nr =length(x1-x);
nc= length(y1-y);
newIm = zeros(0,0,3);
yellow_idx= zeros(0,2);
newIm_idx =zeros(0,2);
% yellow area coordinates
r = x: (x+x1)
c= y:(y+y1) 
while(0<r<480)
for r = y:(y+y1)  
        for c= x:(x+x1)  
        if ( (239<im(r,c,1)<241) && (223<im(r,c,2)<234) && (25<im(r,c,3)<30))
            % white feather of the duck; now change it to yellow
            % yellow_idx =  find(im(r,c));
                newIm_idx = [newIm_idx;[c r]];
        end
        end
        end
end

test_point =8;
% maximam and minimal slop of line with central point
C = min(newIm_idx);
B = max(newIm_idx);
Yelllow_m = median(newIm_idx);
k1 = (Yelllow_m(2)- props(path).Centroid(2))/(Yelllow_m(1)- props(path).Centroid(1));
y_s = round(k1* props(path).BoundingBox(1));
%% search for nect objects
if (Yelllow_m > x_c )
    for r = Yelllow_m(1):(Yelllow_m(1)+100)
        while(0<r<640)
            c = k1*r;
          if (im(r,c,1)==255 && im(r,c,2)==255 && im(r,c,3)==255 )
           found_point =[r,c];
          else 
              break;
        end
        end
    end
   else
    for r = Yelllow_m(1):(Yelllow_m(1)-100)
               if (0<r<640)
            c = k1*r;
          if (im(r,c,1)==255 && im(r,c,2)==255 && im(r,c,3)==255 )
           found_point =[r,c];
          else 
              break;
        end
    end
    end
end
%%

found_point = zeros(0,2);
for i = 1: Idx_props
    for r= round(props(i).BoundingBox(1)): (round(props(i).BoundingBox(1))+80)
        for  c=y_s:(y_s+120)
            if ( 0<r<68 && 0<c<480)
            if (im(r,c,1)==255 && im(r,c,2)==255 && im(r,c,3)==255 )
                found_point =[r,c];
            end
            else
                break;
        end  
    end
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
