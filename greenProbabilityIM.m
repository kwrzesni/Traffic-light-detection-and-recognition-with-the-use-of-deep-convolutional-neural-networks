function [out] = greenProbabilityIM(im, greenModel)
ind = sub2ind([256, 256], double(im(:, :, 2)+1), double(im(:, :, 1)+1));
out = greenModel(ind);
end