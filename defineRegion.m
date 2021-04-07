function regionInds = defineRegion(model,eccenRange,angleRange,edges)

eccenInds1 = find(model.eccen >= eccenRange(1));
eccenInds2 = find(model.eccen <= eccenRange(2));
eccenInds = intersect(eccenInds1,eccenInds2);
angleInds1 = find(model.angle >= angleRange(1));
angleInds2 = find(model.angle <= angleRange(2));
angleInds = intersect(angleInds1,angleInds2);

regionInds = intersect(eccenInds,angleInds);

%remove edges (top and bottom)
if nargin > 3
    [subY,subX] = ind2sub([401,401],regionInds);
    subYinds1 = find(subY > edges(1));
    subYinds2 = find(subY < edges(2));
    subYinds = intersect(subYinds1,subYinds2);
    subInds = subYinds;
    subY = subY(subInds);
    subX = subX(subInds);
    regionInds = sub2ind([401,401],subY,subX);
end


end