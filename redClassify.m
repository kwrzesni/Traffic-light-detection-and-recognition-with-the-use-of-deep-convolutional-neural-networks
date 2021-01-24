function [labels] = redClassify3(im, bundingBoxes, trueBoundingBoxes, redModel)
labels = [];
%image sizes
[Y, X] = size(im, 1, 2);
P = X*Y;

%image of probability density
im_prob = redProbabilityIM(im, redModel);
    

    
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
    if trueBox(1)+trueBox(3)-1 > 20
        trueBox(3) = 20-trueBox(1)+1;
    end
    trueBox(2) = trueBox(2)-box(2)+1;
    if trueBox(2) < 1
        trueBox(4) = trueBox(4) - (1 - trueBox(2));
        trueBox(2) = 1;
    end
    if trueBox(2)+trueBox(4)-1 > 50
        trueBox(4) = 50-trueBox(2)+1;
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
                   y < trueBox(2)+trueBox(4)+2 || y > trueBox(2)+4*trueBox(4)
                    object_mask(y, x, :) = 255;
                end
            end
        end
    end
   
    bad_y = 0;
    for y = 1:size(trueObject, 1)
        p = 0;
        q = 0;
        for x = 1:size(trueObject, 2)
            if trueObject(y, x) == 1
                if q == 0
                    p = x;
                else
                    bad_y = bad_y + 1;
                    break
                end
            else
                if p ~= 0
                    q = 1;
                end
            end
        end 
    end
    bad_x = 0;
    for x = 1:size(trueObject, 2)
        p = 0;
        q = 0;
        for y = 1:size(trueObject, 1)
            if trueObject(y, x) == 1
                if q == 0
                    p = y;
                else
                    bad_x = bad_x + 1;
                    break
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
    
    onlyObject = im_crop;
    bad_x = 0;
    for x = 1:X
        for y = 1:Y
            if x < trueBox(1) || x >= trueBox(1)+trueBox(3) || ...
               y < trueBox(2) || y >= trueBox(2)+trueBox(4)
                onlyObject(y, x, :) = 0;
            end
        end 
    end 
    onlyObjectGray = rgb2gray(onlyObject);
    M = max(max(onlyObjectGray));
    prog = 0.7*double(M)/255;
    onlyObjectBin = imbinarize(onlyObjectGray, prog);
    
    hols_y = 0;
    for y = 1:size(onlyObjectBin, 1)
        p = 0;
        q = 0;
        for x = 1:size(onlyObjectBin, 2)
            if onlyObjectBin(y, x) == 1
                if q == 0
                    p = x;
                else
                    hols_y = hols_y + 1;
                    break
                end
            else
                if p ~= 0
                    q = 1;
                end
            end
        end 
    end
    hols_x = 0;
    for x = 1:size(trueObject, 2)
        p = 0;
        q = 0;
        for y = 1:size(trueObject, 1)
            if trueObject(y, x) == 1
                if q == 0
                    p = y;
                else
                    hols_x = hols_x + 1;
                    p = y;
                end
            else
                if p ~= 0
                    q = 1;
                end
            end
        end
    end
    w=trueBox(3);
    h=min(50,trueBox(2)+4*trueBox(4))-min(50, trueBox(2)+trueBox(4)+2)+1;
    if 0
        subplot(4,5,1)
        imshow(im_crop, [])
        title(num2str(bad_x/(trueBox(3)+1)))
        subplot(4,5,2)
        imshow(object, [])
        title(num2str(bad_y/(trueBox(4)+1)))
        subplot(4,5,3)
        imshow(trueObject, [])
        title(num2str(sum(sum(trueObject))/((trueBox(3)+1)*(trueBox(4)+1))))
        subplot(4,5,4)
        imshow(object_mask, [])
        subplot(4,5,5)
        imshow(object_bin, [])
        a = sum(sum(object_bin))/(w*h);
        title(num2str(a))
        subplot(4,5,6)
        imshow(onlyObject, [])
        subplot(4,5,7)
        imshow(onlyObjectGray, [])
        title(num2str(sum(sum(onlyObjectBin))/sum(sum(trueObject))))
        subplot(4,5,8)
        imshow(onlyObjectBin, [])
        title(num2str(hols_y))
        W = waitforbuttonpress;
        while W ~= 1
            W = waitforbuttonpress;
        end
    end
    s = sum(sum(object_bin));
    if sum(sum(object_bin))/(w*h) < 0.6 || ...
       bad_x/(trueBox(3)+1) >= 0.15 || bad_y/(trueBox(4)+1)>= 0.15 
        label = 0;
    elseif hols_y <= 2 && hols_x <= 2
        label = 3;
    else
        label = 4;
    end
    labels = [labels, label];
end