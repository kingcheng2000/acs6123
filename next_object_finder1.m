
function  cur_object = next_object_finder( cur_object )
% Find next object's bounding box index

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
%% Arrow index building 
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

%% Detection of yellow area
% cur_object = start_arrow_id; % start from the red arrow
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
%          text (X_bd,Y_bd,'arrow','color','black')
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
 if (yellow_cid(1) > x_cid )   
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
 checkpoint =8;
%% find the index 
for i = 1: length(Bounding_box_stru)
    if ismember(found_point,Bounding_box_stru(i).Matrix)
        if Bounding_box_stru(i).Is_arrow ==1
        cur_object =Bounding_box_stru(i).Index;
        break;
        end
    end
end

end

