function  cur_object = next_object_finder( cur_object )
%% variable from main programe
% cur_object = evalin('base','cur_object');
% start_arrow_id = evalin('base','start_arrow_id');
% object_id = evalin('base','object_id');
props = evalin('base','props');
% k1 = evalin('base','k1');
arrow_ind = zeros(0,1); 
arrow_ind = evalin('base','arrow_ind');

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
x_length = round(props(cur_object).BoundingBox(3));
y_length = round(props(cur_object).BoundingBox(4));
iteration =0;

for i =  1:y_length
    for j = 1:x_length
        c = round(props(cur_object).BoundingBox(1))-1+j;
        r = round(props(cur_object).BoundingBox(2))-1+i;
      if (im(r,c,1)>220 && im(r,c,2)>67 && im(r,c,3)<40)
         yellow_matrix = [yellow_matrix;[c,r]];  
%          text (X_bd,Y_bd,'arrow','color','black')
      end
      iteration = iteration +1;
    end
     
end
% Central point of yellow area 

yellow_cid = mean(yellow_matrix);

x_yellow_cid =yellow_cid(1);
y_yellow_cid =-yellow_cid(2);
y_cid = -props(cur_object).Centroid(2);
x_cid = props(cur_object).Centroid(1);

k1 = (y_yellow_cid- y_cid)/(x_yellow_cid-x_cid);
y_s = round(k1* props(path).BoundingBox(1));
intercept =  y_yellow_cid - k1*x_yellow_cid;
%% search for next objects
% Arrow direction detection 
 direction = 1;
 
 if x_yellow_cid < x_cid
     direction =-1
 else 
      direction = 1
 end
 
 
 step_c = 0.01;
 
 found_point =zeros(0,2);
 Hunting_start_c = round(yellow_cid(1));
 Hunting_end_c = round(yellow_cid(1)+ 100* direction);
 Hunting_start_r = round(yellow_cid(1));
 Hunting_end_r = round(yellow_cid(1)+ 100* direction);
 
 step = 2*direction;
 for  c = Hunting_start_c:direction:Hunting_end_c 
      c1 = c + step;
      c2 = c + 2*step;
      
      r = -round(k1*c+intercept);
      r1 = -round(k1*(c1)+intercept);
      r2 = -round(k1*(c2)+intercept);

      if (im(r,c,1)<=8 && im(r,c,2)<=8 && im(r,c,3)<=8) && (im(r1,c1,1)<=251 && im(r1,c1,2)<=251 && im(r1,c1,3)<=251) && (im(r2,c2,1)>=251 && im(r2,c2,2)>=251 && im(r2,c2,3)>=251)
      found_point =[c2,r2];
      break;
      else 
      end
 end

 

 checkpint = 8;
 figure,
   dataset_found_point = zeros(0,2);
  dataset_found_point = [dataset_found_point;[x_cid,y_cid]];
  dataset_found_point = [dataset_found_point;[x_yellow_cid,y_yellow_cid]];
  
 plot(dataset_found_point(:,1),dataset_found_point(:,2),'bx')
 axis([0 640 -480 0]);
%% find the index 
for i = 1: length(Bounding_box_stru)
    if ismember(found_point(1),Bounding_box_stru(i).Matrix(:,1)) && ismember(found_point(2),Bounding_box_stru(i).Matrix(:,2))
         checkpint = 8;
        if Bounding_box_stru(i).Is_arrow ==1
        cur_object =Bounding_box_stru(i).Index;
        assignin('base', 'cur_object', Bounding_box_stru(i).Index);
        break;
        end
    end
end
checkpint = 8;
end

