warning('off','all')
load('greenModel')
load('redModel')
load('net')

dir_in = ('Berlin/');
listing = dir(dir_in);
for i = 3:length(listing)
    path = [dir_in, listing(i).name];
    im = imread(path);
    [Y, X] = size(im, 1, 2);
    [im_green, nGreenDetected, nGreenFiltered] = greenDetection(im, greenModel);
    [im_red, nRedDetected, nRedFiltered] = redDetection(im, redModel);
    greenBoxes = [];
    if max(max(im_green)) > 0
        boundingBoxes = regionprops(im_green, 'BoundingBox');
        greenBoxes = factorGeenBoxes(boundingBoxes, X, Y, 20, 50);
    end

    redBoxes = [];
    if max(max(im_red)) > 0
        boundingBoxes = regionprops(im_red, 'BoundingBox');
        redBoxes = factorRedBoxes(boundingBoxes, X, Y, 20, 50);
    end
    
    boxes = [greenBoxes, redBoxes];
    if ~isempty(boxes)
        labels = netClassify(im, boxes, net);
        im = drawBoxes(im, boxes, labels);
    end
    imshow(im)
    title([num2str(i-2), ', ', ...
        num2str(nGreenDetected + nRedDetected), ', ', ...
        num2str(nGreenFiltered + nRedFiltered)])
    pause(0.0001)
    waitforbuttonpress
end


