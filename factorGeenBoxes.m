function [out] = factorGeenBoxes(boundingBoxes, X, Y, width, height)
out = [];
for i = 1:length(boundingBoxes)
    boundingBox = boundingBoxes(i).BoundingBox;
    if boundingBox(3) == 0 || boundingBox(4) == 0
        continue
    end
    
    xp = max(1, ceil(boundingBox(1)));
    xk = min(X, floor(boundingBox(1)+boundingBox(3)));
    yp = max(1, ceil(boundingBox(2)));
    yk = min(Y, floor(boundingBox(2)+boundingBox(4)));

    xc = floor((xp+xk)/2);
    yc = floor((yp+yk)/2);

    xp = max(1, min(X-width+1, xc-width/2));
    yp = max(1, min(Y-height+1, yc+yk-yp-height));
    
    out = [out, [xp; yp; width; height]];
end