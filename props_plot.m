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
    plot(props(object_id).Centroid(1),props(object_id).Centroid(2),'r.','markers',12);
end
% hold off;
%% Central point of yellow area 
% yellow area matrix
x = round(props(1).BoundingBox(1));
y = round(props(1).BoundingBox(2));
x1 = round(props(1).BoundingBox(3));
y1 = round(props(1).BoundingBox(4));
nr =length(x1-x);
nc= length(y1-y);
newIm = zeros(0,0,3);
yellow_idx= zeros(0,2);
newIm_idx =zeros(0,2);

for r = x: (x+x1)
        for c= y:(y+y1)
        if ( im(r,c,1)>236 && (148<im(r,c,2)<234) && (13<im(r,c,3)<31))
            % white feather of the duck; now change it to yellow
%               yellow_idx =  find(im(r,c));
                newIm_idx = [newIm_idx;[r c]];
            end
        end
end


