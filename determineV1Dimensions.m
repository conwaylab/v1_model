% approximate the length of V1 and how much cortical area each index in the
% matrices encompasses

function params = determineV1Dimensions(offField,params)

dims = params.dims+1;
% how many indices from the top
isV1 = offField.isV1;
isV1 = reshape(isV1,dims,dims);
row = zeros(1,size(isV1,2));
topDist = 0;
while ~sum(row)
    topDist = topDist + 1;
    row = isV1(topDist,:);
end

row = zeros(1,size(isV1,2));
bottomDist = size(isV1,1)+1;
while ~sum(row)
    bottomDist = bottomDist - 1;
    row = isV1(bottomDist,:);
end

col = zeros(size(isV1,1),1);
leftDist = 0;
while ~sum(col)
    leftDist = leftDist + 1;
    col = isV1(:,leftDist);
end

col = zeros(size(isV1,1),1);
rightDist = size(isV1,2)+1;
while ~sum(col)
    rightDist = rightDist - 1;
    col = isV1(:,rightDist);
end

params.V1.numRows = bottomDist - topDist;
params.V1.numCols = rightDist - leftDist;
params.V1.numCells = params.V1.numRows * params.V1.numCols;
params.areaPerCell = params.V1.area / params.V1.numCells;
params.cellSz = sqrt(params.areaPerCell);

end