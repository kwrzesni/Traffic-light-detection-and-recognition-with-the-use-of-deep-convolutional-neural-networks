warning('off','all')
load('greenModel')
load('redModel')

dir_in = ('Berlin');
listing = dir(dir_in);
for i = 3:length(listing)
    path = [dir_in, '/', listing(i).name];
    im = imread(path);
    [Y, X] = size(im, 1, 2);
    [im_green, nGreenDetected, nGreenFiltered] = greenDetection(im, greenModel);
    [im_red, nRedDetected, nRedFiltered] = redDetection(im, redModel);
    greenBoxes = [];
    greenLabels = [];
    if max(max(im_green)) > 0
        boundingBoxes = regionprops(im_green, 'BoundingBox');
        [greenBoxes, trueGreen] = factorGeenBoxes2(boundingBoxes, X, Y, 20, 50);
        greenLabels = greenClassify(im, greenBoxes, trueGreen, greenModel);
    end
    

    redBoxes = [];
    redLabels = [];
    if max(max(im_red)) > 0
        boundingBoxes = regionprops(im_red, 'BoundingBox');
        [redBoxes, trueRed] = factorRedBoxes2(boundingBoxes, X, Y, 20, 50);
        redLabels = redClassify(im, redBoxes, trueRed, redModel);
    end
    
    
    boxes = [greenBoxes, redBoxes];
    
    
    redLabels = redClassify3(im, redBoxes, trueRed, redModel);
    labels = [greenLabels, redLabels];
    if ~isempty(boxes)
        im = drawBoxes(im, boxes, labels);
    end
    subplot(1,1,1);
    imshow(im)
    title([num2str(i-2), ', ', ...
        num2str(nGreenDetected + nRedDetected), ', ', ...
        num2str(nGreenFiltered + nRedFiltered)])
    pause(0.0001)
    waitforbuttonpress
end


