function [inds,subs] = defineWindow(regionCenter,regionSize,dims)

xStart = regionCenter(1)-floor(regionSize/2);
x = xStart:xStart+regionSize-1;
yStart = regionCenter(2)-floor(regionSize/2);
y = yStart:yStart+regionSize-1;

%catch out of bound subscripts
isOutOfRange = checkOutOfRange(regionCenter,regionSize,dims);
if isOutOfRange == 1
    ME = MException('MyComponent:outOfRange', ...
        'Negative column subscript');
    throw(ME)
elseif isOutOfRange == 2
    ME = MException('MyComponent:outOfRange', ...
        'Negative row subscript');
    throw(ME)
elseif isOutOfRange == 3
    ME = MException('MyComponent:outOfRange', ...
        'Column exceeds dimension');
    throw(ME)
elseif isOutOfRange == 4
    ME = MException('MyComponent:outOfRange', ...
        'Row exceeds dimension');
    throw(ME)
end
[subC,subR] = meshgrid(x,y);
subR = reshape(subR,[],1);
subC = reshape(subC,[],1);
inds = sub2ind([dims,dims],subR,subC);
subs = [subR,subC];
end