% Determine displacement of ON subfield from OFF subfield
% 
% Displacement is based on the parameter subfieldCortDist
% Look at the receptive field (OFF subfield) of a cell that is
% subfieldCortDist mm away from the cell in question. The distance of that
% receptive field from the cell's OFF subfield is the displacement of the
% ON subfield.
% 
% This function looks at the four cells that are that distance from the
% cell in question (top,bottom,left,right) then averages the distances of
% those receptive fields from the subfield of the cell in question

function [displacements,out] = onSubfieldDisplacement(offField,params)

dims = params.dims + 1;

%n is how many cells away to look for the receptive field distance
n = floor(params.V1.subfieldCortDist / params.cellSz); 
if n == 0
    n = ceil(params.V1.subfieldCortDist / params.cellSz);
end

eccen = offField.eccenFlat;
angle = offField.angleFlat;

displacements = NaN(size(eccen));
notNanI = find(~isnan(eccen));
neighborInds = NaN(numel(notNanI),4);
neighborDists = NaN(size(neighborInds));

for ind = 1:numel(notNanI)
    if 1 == 1 || i == 6 || i ==1004
        thoo = 3;
    end
    i = notNanI(ind);
    cellEccen = eccen(i);
    cellAngle = visualToStandardPolar(angle(i));
    [cellX,cellY] = pol2cart(deg2rad(cellAngle),cellEccen);
    cellCoords = [cellX,cellY];
    [cellSubI,cellSubJ] = ind2sub([dims,dims],i);
    if cellSubI+n < dims
        neighborInds(ind,1) = sub2ind([dims,dims],cellSubI+n,cellSubJ);
    end
    if cellSubI-n > 0
        neighborInds(ind,2) = sub2ind([dims,dims],cellSubI-n,cellSubJ);
    end
    if cellSubJ+n < dims
        neighborInds(ind,3) = sub2ind([dims,dims],cellSubI,cellSubJ+n);
    end
    if cellSubJ-n > 0
        neighborInds(ind,4) = sub2ind([dims,dims],cellSubI,cellSubJ-n);
    end
    neighborNotNan = find(~isnan(neighborInds(ind,:)));
    for j = 1:length(neighborNotNan)
        jnd = neighborNotNan(j);
        neighborEccen = eccen(neighborInds(ind,jnd));
        neighborAngle = visualToStandardPolar(angle(neighborInds(ind,jnd)));
        [neighborX,neighborY] = pol2cart(deg2rad(neighborAngle),neighborEccen);
        neighborCoords = [neighborX,neighborY];
        neighborDists(ind,jnd) = sqrt(sum(cellCoords-neighborCoords).^2);
    end
    displacements(i) = mean(neighborDists(~isnan(neighborDists)));
end
out.neighborInds = neighborInds;
out.neighborDists = neighborDists;

end