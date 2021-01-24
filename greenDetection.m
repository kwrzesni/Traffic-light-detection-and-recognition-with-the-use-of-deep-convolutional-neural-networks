function [out, nDetected, nFiltered] = greenDetection(im, greenModel)
    
    %image sizes
    [Y, X] = size(im, 1, 2);
    P = X*Y;

    %image of probability density
    im_prob = greenProbabilityIM(im, greenModel);
    
    %image close
    
    
    %binarization
    im_bin=imbinarize(im_prob, 4e-4);
    
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
                   %geometricCoefficients.areaDividedByBoundingBoxArea(pixel) < 0.5
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
    
%     im_hsv = rgb2hsv(im);
%     im_v = im_hsv(:,:,3);
%     m = min(min(im_v));
%     im_gray_bin = ~imbinarize(im_v, 0.3);
    
%     im1_masked = im1;
%     for x=1:X
%         for y=1:Y
%             if im_gray_bin(y, x) == 1
%                 im1_masked(y, x, :) = 0;
%             end
%         end
%     end
%     
%     im2_masked = im2;
%     for x=1:X
%         for y=1:Y
%             if im_gray_bin(y, x) == 1
%                 im2_masked(y, x, :) = 0;
%             end
%         end
%     end
%     
    if 0
        imshow(im_prob, [])
        waitforbuttonpress
        imshow(im_bin, [])
        waitforbuttonpress
        imshow(im_close, [])
        waitforbuttonpress
        imshow(im_ind, [])
        waitforbuttonpress
%         imshow(im1, [])
%         waitforbuttonpress
%         imshow(im2, [])
%         waitforbuttonpress
%         waitforbuttonpress
%         imshow(im_gray_bin, [])
%         waitforbuttonpress
%         imshow(im1_masked, [])
%         waitforbuttonpress
%         imshow(im2_masked, [])
%         waitforbuttonpress
% %         subplot(4,5,5)
% %         imshow(im_filtered, [])
%         subplot(4,5,6)
%         imshow(object_mask, [])
%         subplot(4,5,7)
%         imshow(object_bin, [])
%         subplot(4,5,8)
%         imshow(whole_object_bin, [])
%         title(num2str(label))
        
    end
    
    nFiltered = length(unique(filteredObjects));
end