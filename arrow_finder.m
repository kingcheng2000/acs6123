
function  [arrow_ind] = arrow_finder()

object_id = evalin('base','object_id');
props = evalin('base','props');
arrow_ind = zeros(0,1); 

for object_id = 1: length(props)
     if (props(object_id).Area > 1700)
      text (props(object_id).BoundingBox(1), props(object_id).BoundingBox(2),'not arrow','color','blue','FontSize',14);
     else
      arrow_ind = [arrow_ind ;object_id];
      str = num2str(object_id);
      text( props(object_id).BoundingBox(1), props(object_id).BoundingBox(2),str,'color','blue','FontSize',14);
     end
end

end

