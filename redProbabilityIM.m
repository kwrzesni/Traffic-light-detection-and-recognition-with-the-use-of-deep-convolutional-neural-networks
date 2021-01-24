function out = redProbabilityIM(im, redModel)
ind = sub2ind([256, 256],double(im(:, :, 3)+1),double(im(:, :, 1)+1));
out = redModel(ind);
end