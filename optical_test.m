hbfr = video.BinaryFileReader('Filename', 'viptraffic.bin'); % read the binary video
 


hcr = video.ChromaResampler(...
  'Resampling', '4:2:0 (MPEG1) to 4:4:4', ...
  'InterpolationFilter', 'Pixel replication');

hcsc1 = video.ColorSpaceConverter('Conversion', 'YCbCr to RGB');
hcsc2 = video.ColorSpaceConverter('Conversion', 'RGB to intensity');



hidtc = video.ImageDataTypeConverter('OutputDataType', 'single');

hof = video.OpticalFlow( ...
    'OutputValue', 'Horizontal and vertical components in complex form', ...
    'ReferenceFrameDelay', 3);

hmean1 = video.Mean;
hmean2 = video.Mean('RunningMean', true);


hmedianfilt = video.MedianFilter2D;


hclose = video.MorphologicalClose('Neighborhood', strel('line',5,45));
hblob = video.BlobAnalysis( ...
                    'CentroidOutputPort', false, ...
                    'AreaOutputPort', true, ...
                    'BoundingBoxOutputPort', true, ...
                    'OutputDataType', 'double', ...
                    'NumBlobsOutputPort',  false, ...
                    'MinimumBlobAreaSource', 'Property', ...
                    'MinimumBlobArea', 250, ...
                    'MaximumBlobAreaSource', 'Property', ...
                    'MaximumBlobArea', 3600, ...
                    'FillValues', -1, ...
                    'MaximumCount', 80);



herode = video.MorphologicalErode('Neighborhood', strel('square',2));



hshapeins1 = video.ShapeInserter( ...
            'BorderColor', 'Custom', ...
            'CustomBorderColor', [0 1 0]);
hshapeins2 = video.ShapeInserter( ...
            'Shape','Lines', ...
            'BorderColor', 'Custom', ...
            'CustomBorderColor', [255 255 0]);



htextins = video.TextInserter( ...
        'Text', '%4d', ...
        'Location',  [0 0], ...
        'Color', [1 1 1], ...
        'FontSize', 12);


hVideo1 = video.VideoPlayer('Name', 'Original Video');
hVideo1.Position(1) = round(0.4*hVideo1.Position(1)) ;
hVideo1.Position(2) = round(1.5*(hVideo1.Position(2))) ;
hVideo1.Position([4 3]) = [200 200];

hVideo2 = video.VideoPlayer('Name', 'Motion Vector');
hVideo2.Position(1) = hVideo1.Position(1) + 350;
hVideo2.Position(2) =round(1.5* hVideo2.Position(2));
hVideo2.Position([4 3]) = [200 200];

hVideo3 = video.VideoPlayer('Name', 'Thresholded Video');
hVideo3.Position(1) = hVideo2.Position(1) + 350;
hVideo3.Position(2) = round(1.5*(hVideo3.Position(2))) ;
hVideo3.Position([4 3]) = [200 200];

hVideo4 = video.VideoPlayer('Name', 'Results');
hVideo4.Position(1) = hVideo1.Position(1);
hVideo4.Position(2) = round(0.3*(hVideo4.Position(2))) ;
hVideo4.Position([4 3]) = [200 200];

% Initialize some variables used in plotting motion vectors.
MotionVecGain = 20;
line_row =  22;
borderOffset   = 5;
decimFactorRow = 5;
decimFactorCol = 5;
firstTime = true;

while ~isDone(hbfr)
    [y, cb, cr] = step(hbfr);      % Read input video frame
    [cb, cr] = step(hcr, cb, cr);
    imrgb = step(hcsc1, cat(3,y,cb,cr)); % Convert image from YCbCr to RGB
    image = step(hidtc, imrgb);          % Convert image to single
    I = step(hcsc2, image);        % Convert color image to intensity
    of = step(hof, I);             % Estimate optical flow

    % Thresholding and Region Filtering.
    y1 = of .* conj(of);
    % Compute the velocity threshold from the matrix of complex velocities.
    vel_th = 0.5 * step(hmean2, step(hmean1, y1));

    % Threshold the image and then filter it to remove fine speckle noise.
    filteredout = step(hmedianfilt, y1 >= vel_th);

    % Perform erosion operation to thin-out the parts of the road followed
    % by the closing operation to remove gaps in the blobs.
    th_image = step(hclose, step(herode, filteredout));

    % Regional Filtering.

    % Estimate the area and bounding box of the blobs in the thresholded
    % image.
    [area, bbox] = step(hblob, th_image);
    % Select those boxes which are in our ROI.
    Idx = bbox(1,:) > line_row;

    % The next lines of code exclude other objects (like parts of the road)
    % which are also segmented as blobs and select only cars. When the
    % ratio between the area of the blob and the area of the bounding box
    % is above 0.4 (40%), it is considered as a car and hence the bounding
    % box for that object is used. Otherwise the bounding box is removed.
    ratio = zeros(1, length(Idx));
    ratio(Idx) = single(area(1,Idx))./single(bbox(3,Idx).*bbox(4,Idx));
    ratiob = ratio > 0.4;
    count = int32(sum(ratiob));    % Number of cars
    bbox(:, ~ratiob) = int32(-1);

    % Draw bounding rectangles around the tracked cars.
    y2 = step(hshapeins1, image, bbox);

    % Display the number of cars tracked and a white line showing ROI.
    y2(22:23,:,:) = 1;             % The white line.
    y2(1:15,1:30,:) = 0;           % Background for displaying count
    image_out = step(htextins, y2, count);

    % Generate the coordinate points for plotting motion vectors.
    if firstTime
      [R C] = size(of);            % Height and width in pixels
      RV = borderOffset:decimFactorRow:(R-borderOffset);
      CV = borderOffset:decimFactorCol:(C-borderOffset);
      [Y X] = meshgrid(CV,RV);
      firstTime = false;
    end

    % Calculate and draw the motion vectors.
    tmp = of(RV,CV) .* MotionVecGain;
    lines = [X(:)';Y(:)';X(:)' + imag(tmp(:))';Y(:)' + real(tmp(:))'];
    mv_video = step(hshapeins2, image, lines);

    step(hVideo1, image);          % Display Original Video
    step(hVideo2, mv_video);       % Display video with motion vectors
    step(hVideo3, th_image);       % Display Thresholded Video
    step(hVideo4, image_out);      % Display video with bounding boxes
end





                      
