function out = checkOutOfRange(regionCenter,regionSize,dims)

xStart = regionCenter(1)-floor(regionSize/2);
x = xStart:xStart+regionSize-1;
yStart = regionCenter(2)-floor(regionSize/2);
y = yStart:yStart+regionSize-1;

out = 0;
if sum(x < 1) > 0 
    out = 1;
elseif sum(y < 1) > 0
    out = 2;
elseif sum(x > dims) > 0
    out = 3;
elseif sum(y > dims) > 0
    out = 4;
end

end