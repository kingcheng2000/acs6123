load opticalFlowTest;
[Vx,Vy]=opticalFlow(I1,I2,'smooth',1,'radius',10,'type','LK');
subplot(1,2,1),imshow(double(Vx),[]);
subplot(1,2,2),imshow(double(Vy),[]);