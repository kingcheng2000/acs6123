n_objects = numel(props);
function  arrow_finder(n_objects)
find arrow in image
detaile information 
arrow_ind = 0;
Area_thrd = 1500;

im = imread('Treasure_hard.jpg'); % change name to process other images
bin_threshold = 0.05; % parameter to vary
bin_im = im2bw(im, bin_threshold);
con_com = bwlabel(bin_im);
props = regionprops(con_com);
n_objects = numel(props);
arrow_ind =0;
Box_end = n_objects;
for i = 1:Box_end
    if props.(i)Area < Area_thrd;
        Box_id = i;
    else 
        Box_id = Box_id+1 
end
end
end