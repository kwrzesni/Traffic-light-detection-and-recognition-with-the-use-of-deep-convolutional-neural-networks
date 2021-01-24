function [out, nDetected, nFiltered] = redDetection(im, redModel)
    %image sizes
    [Y, X] = size(im, 1, 2);
    P = X*Y;

    %image of probability density
    im_prob = redProbabilityIM(im, redModel);
    
    %image close
    
    
    %binarization
    im_bin=imbinarize(im_prob, 4e-4);
    %im_bin=imbinarize(im_prob, 8e-5);
    
    SE = strel('disk', 3);
    im_close = imclose(im_bin, SE);
    
    %indexation
    im_ind = bwlabel(im_close, 8);
    
    %geometry coefficients calculation
    geometricCoefficients = getGeometricCoefficients(im_ind);
    
    %filtering
    out = im_ind;
    nDetected = length(unique(im_ind))-1;
    filteredObjects = [];
    for x=1:X
        for y=1:Y
            pixel = im_ind(y, x);
            if pixel ~= 0
                if geometricCoefficients.area(pixel) > 1200 || ...
                   geometricCoefficients.area(pixel) < 10 || ...
                   geometricCoefficients.width(pixel) < 5 || ...
                   geometricCoefficients.height(pixel) < 5 || ...
                   geometricCoefficients.maxDividedByMin(pixel) > 2
                    out(y, x) = 0;
                else
                    out(y, x) = pixel;
                    filteredObjects = [filteredObjects, pixel];
                end
            end
        end
    end
    
    im1 = im;
    for x=1:X
        for y=1:Y
            if im_close(y, x) ~= 0
                im1(y, x, :) = [255, 0, 255];
            end
        end
    end
    
    im2 = im;
    for x=1:X
        for y=1:Y
            if out(y, x) ~= 0
                im2(y, x, :) = [255, 0, 255];
            end
        end
    end
    
    nFiltered = length(unique(filteredObjects));
end