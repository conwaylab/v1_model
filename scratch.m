clearvars

load(['lilac4_sim/lh_retino'])

%make a spiral stimulus
N = 2000;
d = 1;
scale = 0.06;
spiral = archSpiralStim([0,0],N,d,scale);

figure
scatter(spiral.coords(:,1),spiral.coords(:,2))

[spiralTh,spiralR] = cart2pol(spiral.coords(:,1),spiral.coords(:,2));
spiralTh = rad2deg(spiralTh);
spiralTh = standardPolarToVisual(spiralTh);

vareaI = varea > 0;
angleVis = angle(vareaI);
eccenVis = eccen(vareaI);
sigmaVis = sigma(vareaI);
orientationPref = rand(size(angleVis)) * 180;

%for each vertex, find the points of the stim that fit within its
%eccentricity +- sigma range
isActive = zeros(size(angleVis));
activations = zeros(size(angleVis));
angleThresh = 5;
for iVert = 1:numel(angleVis)
    vertexEccen = eccenVis(iVert);
    vertexSigma = sigmaVis(iVert);
    vertexAngle = angleVis(iVert);
    vertOrientPref = orientationPref(iVert);
    stimPoints = abs(spiralR-vertexEccen) < vertexSigma;
    stimPoints2 = abs(spiralTh-vertexAngle) < angleThresh;
    activatingPoints = stimPoints .* stimPoints2;
    
    if sum(activatingPoints) > 0
        activatingPtAngles = spiral.angles(logical(activatingPoints));
        stimAngle = mean(activatingPtAngles);
        activations(iVert) = cellResponseMagnitude(vertOrientPref,stimAngle,0.02)*5;
        isActive(iVert) = 1;
    end
end
isActiveAllVert = zeros(size(angle));
isActiveAllVert(vareaI) = isActive;
activationsAllVert = zeros(size(angle));
activationsAllVert(vareaI) = activations;
% save('sampleActivations.mat','isActiveAllVert','activationsAllVert');

%% place eccen and angle of ON subfields for each vertex next 
% show this plot to Eli: the ON subfields for ret locations near 0 deg and
% 180 deg end up on the opposite side of the visual field when the
% displacement (cellSign) is negative. Maybe it's okay to fix the cell sign
% at +1? But that's not what we see in the Lee paper

orientationPref = rand(size(angleVis)) * 180;
% orientationPref = ones(size(angleVis)) * 180;

%this won't work anymore becasue I edited placeOnSubfield to take offField
%instead of each thing individually. Will have to change offField to be a
%nvertx1 struct with single values for each parameter
offField.angle = angleVis;
offField.eccen = eccenVis;
offField.sigma = sigmaVis;

offField.angleFlat = angleVis;
offField.eccenFlat = eccenVis;
offField.sigmaFlat = sigmaVis;

offField.orientation = orientationPref;
offField.orientationFlat = orientationPrefCol;
params.dispPrcnt = 0.5;
onField.angle = zeros(size(angleVis));
onField.eccen = zeros(size(eccenVis));
for i = 1:numel(angleVis)
    [onField.angle(i),onField.eccen(i)] = placeOnSubfieldOld(offField.angle(i),...
        offField.eccen(i),offField.sigma(i),offField.orientation(i),params);
end

onField = placeOnSubfield(offField,params);
onField.angle = onField.angleFlat;
onField.eccen = onField.eccenFlat;

onAngles = visualToStandardPolar(onField.angle);
offAngles = visualToStandardPolar(offField.angleFlat);

[offX,offY] = pol2cart(deg2rad(offAngles),offField.eccenFlat);
[onX,onY] = pol2cart(deg2rad(onAngles),onField.eccen);

figure
scatter(offX,offY)
hold on
scatter(onX,onY)

%%
onAngle = onField.angle;
onEccen = onField.eccen;

onAngle = zeros(size(angle));
onEccen = zeros(size(eccen));

onAngle(vareaI) = onField.angle;
onEccen(vareaI) = onField.eccen;
% save('lh_on_retino','onAngle','onEccen')

%% look at angles near 0 or near 180
thresh = 5;
vertAnglesI = (offField.angle < thresh) | (abs(offField.angle-180) < thresh);

vertAnglesI2 = (offField.angle < thresh);

eccenCutoff = 30;
highEccenI = offField.eccen > eccenCutoff;

vertHighEccenI = logical(highEccenI.*vertAnglesI2);

figure
scatter(offX(vertHighEccenI),offY(vertHighEccenI))
hold on
scatter(onX(vertHighEccenI),onY(vertHighEccenI))

figure
scatter(offX(vertAnglesI2),offY(vertAnglesI2))
hold on
scatter(onX(vertAnglesI2),onY(vertAnglesI2))

figure
hist(orientationPref(vertHighEccenI))

% figure
% hist(orientationPref2(vertAnglesI));

%%
eccenDisp = 2;
iVert = 5;
orientationPref(iVert)
vertOrientationPref = standardPolarToVisual(orientationPref(iVert));
[onSubfieldA,onSubfieldE] = addPolarVec(angleVis(iVert),eccenVis(iVert),vertOrientationPref,eccenDisp);


% plot for checking
% th1 = visualToStandardPolar(angleVis(iVert));
% th2 = visualToStandardPolar(onSubfieldA);
% 
% [x1,y1] = pol2cart(deg2rad(th1),eccen(iVert));
% [x2,y2] = pol2cart(deg2rad(th2),onSubfieldE);
% 
% figure
% scatter(x1,y1)
% hold on
% scatter(x2,y2)
% xlim([-10,10])
% ylim([-10,10])

%% visualize result of creatOnOffModel
load('On-Off_Model_sz201.mat')

offAnglesStd = visualToStandardPolar(offField.angleFlat);
onAnglesStd = visualToStandardPolar(onField.angleFlat);

[offX,offY] = pol2cart(deg2rad(offAnglesStd),offField.eccenFlat);
[onX,onY] = pol2cart(deg2rad(onAnglesStd),onField.eccenFlat);

figure
scatter(offX,offY)
hold on
scatter(onX,onY)

%%
figure
subplot(1,4,1)
imagesc(offField.orientation)
title('Orientation columns')
colormap hsv
axis equal
colorbar
axis equal
axis tight

subplot(1,4,2)
imagesc(offField.angle)
title('Angle')
colormap hsv
colorbar
axis equal
axis tight

subplot(1,4,3)
imagesc(offField.eccen)
title('Eccentricity')
colormap hsv
colorbar
axis equal
axis tight

subplot(1,4,4)
imagesc(offField.sigma)
title('pRF Sigma')
colormap hsv
colorbar
axis equal
axis tight

%%
figure
subplot(1,4,1)
imagesc(onField.orientation)
title('Orientation columns')
colormap hsv
axis equal
colorbar
axis equal
axis tight

subplot(1,4,2)
imagesc(onField.angle)
title('Angle')
colormap hsv
colorbar
axis equal
axis tight

subplot(1,4,3)
imagesc(onField.eccen)
title('Eccentricity')
colormap hsv
colorbar
axis equal
axis tight

subplot(1,4,4)
imagesc(onField.sigma)
title('pRF Sigma')
colormap hsv
colorbar
axis equal
axis tight

%%
a = 1;
b = 5;
d = 1;
N = 1000;
stim = archSpiralStimTest(a,b,N,d);

figure
scatter(stim.coords(:,1),stim.coords(:,2))
xlim([-100,100])
ylim([-100,100])

%%
notnan = ~isnan(onField.orientationFlat);
shuffleI = randperm(sum(notnan));

angle = onField.angleFlat(notnan);
eccen = onField.eccenFlat(notnan);
sigma = onField.sigmaFlat(notnan);
angle = angle(shuffleI);
eccen = eccen(shuffleI);
sigma = sigma(shuffleI);

onField.angleFlat(notnan) = angle;
onField.eccenFlat(notnan) = eccen;
onField.sigmaFlat(notnan) = sigma;
onField.angle = reshape(onField.angleFlat,401,401);
onField.eccen = reshape(onField.eccenFlat,401,401);
onField.sigma = reshape(onField.sigmaFlat,401,401);

%%
figure
histogram(offField.eccenFlat)
title('off eccen')
figure
histogram(onField.eccenFlat)
title('on eccen')
