%% Labs total
clear all
close all
clc
%% lab1  
%% Detection of an area of a predefined colour
% Color the duck yellow!
% Change the colour of the white pixels of an image to 
% yellow on the image 
im= imread('duckMallardDrake.jpg');
figure,imshow(im);
[nr,nc,np]= size(im);
newIm= zeros(nr,nc,np);
newIm= uint8(newIm);
 
for r= 1:nr
    for c= 1:nc
        if ( im(r,c,1)>180 && im(r,c,2)>180 && im(r,c,3)>180 )
            % white feather of the duck; now change it to yellow
            newIm(r,c,1)= 225;
            newIm(r,c,2)= 225;
            newIm(r,c,3)= 0;
        else  % the rest of the picture; no change
            for p= 1:np
                newIm(r,c,p)= im(r,c,p);
            end
        end
    end
end
 
figure,imshow(newIm);
figure,
subplot(1,2,1);
imshow(im)

subplot(1,2,2);
imshow(newIm)
%% Find the pixels indexes with the yellow colour on the image ‘Two_colour.jpg
im = imread('Two_colour.jpg'); % read the image
figure;
imshow(im);
 
% extract RGB channels separatelly
red_channel = im(:, :, 1); 
green_channel = im(:, :, 2); 
blue_channel = im(:, :, 3); 
 
% label pixels of yellow colour
yellow_map = green_channel > 150 & red_channel > 150 & blue_channel < 50; 
% extract pixels indexes
[i_yellow, j_yellow] = find(yellow_map > 0); 

% visualise the results
figure;
imshow(im); % plot the image
hold on;
scatter(j_yellow, i_yellow, 5, 'd') % highlighted the yellow pixels

%% 
x = linspace(0,3*pi,200);
y = cos(x) + rand(1,200);  
subplot(1,2,1)
scatter(x,y);


x1 = linspace(0,3*pi,100000);
y1 = cos(x1) + rand(1,100000);  
subplot(1,2,2)
scatter(x1,y1,0.1)





