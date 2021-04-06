close all
clearvars

[params,paths] = initializeParametersVariableDisplacement();
% [params,paths] = initializeParameters();

[offField,onField] = makeFlatMaps(params,paths);

dims = params.dims+1;

%% make spiral stim
% N = 1500;
% d = 1;
% b = 7;
% scale = 0.02;
% center = [1,1];
% spiral = archSpiralStim(center,b,N,d,scale);

th = linspace(0,360,250);
b = 0.7;
a = 0.08;
spiral = logSpiral(th,b,a,[0,0]);

figure
scatter(spiral.coords(:,1),spiral.coords(:,2))
axis equal

cellResponsesOff= cellActivations(offField,spiral,params);
cellResponsesOff = reshape(cellResponsesOff,dims,dims);

cellResponsesOn = cellActivations(onField,spiral,params);
cellResponsesOn = reshape(cellResponsesOn,dims,dims);

figure
subplot(1,2,1)
imagesc(cellResponsesOff)
colorbar
title('OFF Response')
axis square
axis tight

subplot(1,2,2)
imagesc(cellResponsesOn)
colorbar
title('ON Response')
axis square
axis tight

keyboard


%% look at subregion
regionSize = 15;
regionCenter = [14,215]; %[x,y] or [col,row]
windowInds = defineWindow(regionCenter,regionSize,dims);

offResponse = cellResponsesOff(windowInds);
onResponse = cellResponsesOn(windowInds);

%% SCRATCH BELOW

%take average of several, plot, get 2D correlation
offMean1 = mean(offResponses(:,:,1:10),3);
offMean2 = mean(offResponses(:,:,11:20),3);
onMean1 = mean(onResponses(:,:,1:10),3);
onMean2 = mean(onResponses(:,:,11:20),3);

nanI = isnan(offField.orientationFlat);
r = corr2noNan(offMean1,offMean2,nanI)
r = corr2noNan(onMean1,onMean2,nanI)


figure
subplot(2,2,1)
imagesc(offMean1)
subplot(2,2,2)
imagesc(offMean2)
subplot(2,2,3)
imagesc(onMean1)
subplot(2,2,4)
imagesc(onMean2)

corr2(offMean1(175:225,150:200),offMean2(175:225,150:200))
corr2(onMean1(175:225,150:200),onMean2(175:225,150:200))

%2d correlation between individual presentations
nanI = isnan(offField.orientationFlat);
corr2noNan(offResponses(:,:,1),offResponses(:,:,2),nanI)
corr2noNan(onResponses(:,:,1),onResponses(:,:,2),nanI)

%random line stim
lims = 5;
x = linspace(-lims,lims,500);
y = x;
stim.coords = [x',y'];
[th,r] = cart2pol(x,y);
th = rad2deg(th);
stim.theta = standardPolarToVisual(th);
stim.radius = r;
figure
plot(x,y)

offResponse = cellActivationsNoOrientation(cellModel,stim,params);
offResponse = reshape(offResponse,401,401);

figure
imagesc(offResponse)

%% temp
notNan = ~isnan(offField.eccenFlat);
notNanI = find(notNan);
eccen = offField.eccenFlat(notNan);
angle = offField.angleFlat(notNan);
disps = offField.displacementFlat(notNan);
ind = 12;

check = zeros(3,5);
neighborInds = offField.out.neighborInds(ind,:);
neighborDists = offField.out.neighborDists(ind,:);
check(1,1) = eccen(ind);
check(2,1) = angle(ind);
check(3,1) = disps(ind);
for i = 1:4
    if ~isnan(neighborInds(i))
        check(1,i+1) = eccen(neighborInds(i));
        check(2,i+1) = angle(neighborInds(i));
        check(3,i+1) = neighborDists(i);
    else
        check(1,i+1) = NaN;
        check(2,i+1) = NaN;
        check(3,i+1) = NaN;
    end
end

displacement = reshape(offField.displacementFlat,401,401);
figure
imagesc(displacement)
colormap hsv
