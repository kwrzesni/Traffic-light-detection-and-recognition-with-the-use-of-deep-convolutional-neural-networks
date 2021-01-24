function [labels] = greenClassify3(im, bundingBoxes, trueBoundingBoxes, greenModel)
labels = [];
%image sizes
[Y, X] = size(im, 1, 2);
P = X*Y;

%image of probability density
im_prob = greenProbabilityIM(im, greenModel);
    

    
%binarization
im_bin=imbinarize(im_prob, 4e-4);


SE = strel('disk', 3);
im_close = imclose(im_bin, SE);

for i = 1:size(bundingBoxes, 2)
    label = 0;
    box = [bundingBoxes(1, i), bundingBoxes(2, i), bundingBoxes(3, i)-1, bundingBoxes(4, i)-1];
    trueBox = [trueBoundingBoxes(1, i), trueBoundingBoxes(2, i), trueBoundingBoxes(3, i)-1, trueBoundingBoxes(4, i)-1];
    trueBox(1) = trueBox(1)-box(1)+1;
    if trueBox(1) < 1
        trueBox(3) = trueBox(3) - (1 - trueBox(1));
        trueBox(1) = 1;
    end
    trueBox(2) = trueBox(2)-box(2)+1;
    if trueBox(2) < 1
        trueBox(4) = trueBox(4) - (1 - trueBox(2));
        trueBox(2) = 1;
    end
    im_crop = imcrop(im, box);
    object = imcrop(im_close, box);
    trueObject = imcrop(object, trueBox);
    
    
    
    [Y, X] = size(object, 1, 2);

    
    object_mask = im_crop;
    if label == 0
        for x = 1:X
            for y = 1:Y
                if x < trueBox(1) || x >= trueBox(1)+trueBox(3) || ...
                   y < trueBox(2)-4*trueBox(4) || y >= trueBox(2)-3
                    object_mask(y, x, :) = 255;
                end
            end
        end
    end
    
    object_mask2 = im_crop;
    if label == 0
        for x = 1:X
            for y = 1:Y
                if x < trueBox(1) || x >= trueBox(1)+trueBox(3) || ...
                   y < trueBox(2)-3 || y > trueBox(2)+trueBox(4)
                    object_mask2(y, x, :) = 255;
                end
            end
        end
    end

    for y = 1:size(trueObject, 1)
        p = 0;
        q = 0;
        for x = 1:size(trueObject, 2)
            if trueObject(y, x) == 1
                if q == 0
                    p = x;
                else
                    trueObject(y, p:x) = 1;
                end
            else
                if p ~= 0
                    q = 1;
                end
            end
        end 
    end
    for x = 1:size(trueObject, 2)
        p = 0;
        q = 0;
        for y = 1:size(trueObject, 1)
            if trueObject(y, x) == 1
                if q == 0
                    p = y;
                else
                    trueObject(p:y, x) = 1;
                end
            else
                if p ~= 0
                    q = 1;
                end
            end
        end 
    end 
    im_hsv = rgb2hsv(object_mask);
    im_v = im_hsv(:,:,3);
    m = min(min(im_v));
    object_bin = ~imbinarize(im_v, min(0.3, m+20/255));
    
    im_hsv = rgb2hsv(object_mask2);
    im_v = im_hsv(:,:,3);
    object_bin2 = ~imbinarize(im_v, min(0.3, m+20/255));
    for x = 1:X
        for y = 1:Y
            object_bin2(y, x) = max(object_bin2(y, x), object(y, x));
        end
    end
    
    if 0
        subplot(4,5,1)
        imshow(im_crop, [])
        subplot(4,5,2)
        imshow(object, [])
        subplot(4,5,3)
        imshow(trueObject, [])
        title(num2str(sum(sum(trueObject))/((trueBox(3)+1)*(trueBox(4)+1))))
        subplot(4,5,4)
        imshow(object_mask, [])
        subplot(4,5,5)
        imshow(object_bin, [])
        title(num2str(sum(sum(object_bin)/(trueBox(3)*(max(1,trueBox(2)-3)-max(1, trueBox(2)-4*trueBox(4)))))))
        waitforbuttonpress
    end
    
    if sum(sum(object_bin)) < 0.7 * trueBox(3)*(max(1,trueBox(2)-3)-max(1, trueBox(2)-4*trueBox(4)))
        label = 0;
    elseif sum(sum(trueObject)) > 0.6 * (trueBox(3)+1)*(trueBox(4)+1)
        label = 1;
    else
        label = 2;
    end
    labels = [labels, label];
end