function [out] = drawBoxes(im, boxes, labels)
out = im;
wrong_color = [255 0 255];
green_circle = [0 255 0];
green_arrow = [0 255 255];
red_circle = [255 0 0];
red_arrow = [128 0 0];

for i = 1:size(boxes, 2)
    switch labels(i)
        case 0
            color = wrong_color;
        case 1
            color = green_circle;
        case 2
            color = green_arrow;
        case 3
            color = red_circle;
        case 4
            color = red_arrow;
    end
    box = boxes(:, i);
    
    xp = box(1);
    xk = box(1)+box(3)-1;
    yp = box(2);
    yk = box(2)+box(4)-1;
    
    
    for x = xp:xk
        out(yp, x, :) = color;
        out(min(yk, yp+1), x, :) = color;
        out(max(yp, yk-1), x, :) = color;
        out(yk, x, :) = color;
    end
    for y = yp:yk
        out(y, xp, :) = color;
        out(y, min(xk, xp+1), :) = color;
        out(y, max(xp, xk-1), :) = color;
        out(y, xk, :) = color;
    end
end
end