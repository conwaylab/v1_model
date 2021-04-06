close all
clearvars

dims = 700; %dimensions of retinotopy map
%% load the coord structures from step 1
if ~exist('b_lh')
    load('allVertexCoords.mat');
end
if ~exist('bflat')
    load('flatmapV1.mat')
end

lhCoords = squeeze(b_lh.coordMap.coords);
rhCoords = squeeze(b_rh.coordMap.coords);
flatCoords = squeeze(bflat.coordMap.coords);
flatCoords1D = reshape(flatCoords,[],3);


%% register the vertices with the flat map coords for left hemi
load('lh_retino.mat')
vareaI = varea > 0;

lhVisCoords = lhCoords(vareaI,:);
flatInds = zeros(size(lhVisCoords,1),1);
for i = 1:length(lhVisCoords)
    coord = lhVisCoords(i,:);
    V = flatCoords1D - coord;
    D = sqrt(sum(V.^2,2));
    [~,flatInds(i)] = min(D);
end

angleVis = angle(vareaI);
eccenVis = eccen(vareaI);
sigmaVis = sigma(vareaI);
vareaVis = varea(vareaI);

angle2D = zeros(size(flatCoords(:,:,1)));
eccen2D = zeros(size(flatCoords(:,:,1)));
sigma2D = zeros(size(flatCoords(:,:,1)));
varea2D = zeros(size(flatCoords(:,:,1)));

for i = 1:length(flatInds)
   angle2D(flatInds(i)) = angleVis(i); 
   eccen2D(flatInds(i)) = eccenVis(i); 
   sigma2D(flatInds(i)) = sigmaVis(i); 
   varea2D(flatInds(i)) = vareaVis(i);
end

%% for any zeros, take the average of the surrounding 8 regions

notV1 = varea2D ~= 1;
angle2D(notV1) = 0;
sigma2D(notV1) = 0;
eccen2D(notV1) = 0;

angle2D = fillZeroEntries(angle2D);
eccen2D = fillZeroEntries(eccen2D);
sigma2D = fillZeroEntries(sigma2D);

%% increase resolution of flat maps by interpolating
interpLev = (length(angle2D)-1) / dims;
sz = (length(angle2D) - 1) / 2;
[X,Y] = meshgrid(-sz:sz);
[Xq,Yq] = meshgrid(-sz:interpLev:sz);
angle2DHighRes = interp2(X,Y,angle2D,Xq,Yq);
eccen2DHighRes = interp2(X,Y,eccen2D,Xq,Yq);
sigma2DHighRes = interp2(X,Y,sigma2D,Xq,Yq);

eccenZeros = eccen2DHighRes == 0;
eccen2DHighRes(eccenZeros) = NaN;

angleZeros = angle2DHighRes == 0;
angle2DHighRes(angleZeros) = NaN;

sigmaZeros = sigma2DHighRes == 0;
sigma2DHighRes(sigmaZeros) = NaN;

flatRetinotopy.eccen = eccen2DHighRes;
flatRetinotopy.angle = angle2DHighRes;
flatRetinotopy.sigma = sigma2DHighRes;

save(['retinotopyMaps_sz_' num2str(dims+1) '.mat'],'flatRetinotopy')
