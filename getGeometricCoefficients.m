function [ coefficients ] = getGeometricCoefficients(im)
    nObjects = max(im(:));
    res = regionprops(im, 'Area', 'BoundingBox', 'Image');

    coefficients.maxDividedByMin = zeros(1, nObjects);
    coefficients.area = zeros(1, nObjects);
    coefficients.areaDividedByBoundingBoxArea = zeros(1, nObjects);
    coefficients.width = zeros(1, nObjects);
    coefficients.height = zeros(1, nObjects);
    
    for i = 1:nObjects
        bb = res(i).BoundingBox;
        
        area = res(i).Area;
        maxDividedByMin = max(bb(3:4))/min(bb(3:4));
        areaDividedByBoundingBoxArea = double(area)/double(bb(3)*bb(4));
        
        coefficients.maxDividedByMin(i) = maxDividedByMin;
        coefficients.area(i) = area;
        coefficients.areaDividedByBoundingBoxArea(i) = areaDividedByBoundingBoxArea;
        coefficients.width(i) = ceil(bb(3));
        coefficients.height(i) = ceil(bb(4));
    end
end

