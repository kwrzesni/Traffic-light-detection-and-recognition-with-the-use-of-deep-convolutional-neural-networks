function [labels] = netClassify(im, boxes, net)
labels = [];
for i = 1:size(boxes, 2)
    box = [boxes(1, i), boxes(2, i), boxes(3, i)-1, boxes(4, i)-1];
    object = imcrop(im, box);

    label = double(classify(net, object))-1;
    labels = [labels, label];
end
end