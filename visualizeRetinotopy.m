clearvars

[params,paths] = initializeParametersVariableDisplacement();
% [params,paths] = initializeParameters();

[offField,onField] = makeFlatMaps(params,paths);

keyboard
%% View flatmaps as heatmaps and ON/OFF subfield centers in visual coords
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

<<<<<<< HEAD
keyboard

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

=======
>>>>>>> 0282137dfa672accc43909e6deb635817371377f
keyboard 


onAngles = visualToStandardPolar(onField.angleFlat);
offAngles = visualToStandardPolar(offField.angleFlat);

[offX,offY] = pol2cart(deg2rad(offAngles),offField.eccenFlat);
[onX,onY] = pol2cart(deg2rad(onAngles),onField.eccenFlat);

figure
scatter(offX,offY)
hold on
scatter(onX,onY)

keyboard 

%% Lee figure 2c

[x,y] = meshgrid(1:401,1:401);
figure

%off azimuth
az = offX(~isnan(offX));
[~,sortI] = sort(az);
corticalCoords = zeros(length(offAngles),2);
corticalCoords(:,1) = reshape(x,[],1);
corticalCoords(:,2) = reshape(y,[],1);
corticalCoords = corticalCoords(~isnan(offX),:);
corticalCoords = corticalCoords(sortI,:);
c = linspace(1,80,size(corticalCoords,1));

subplot(2,2,1)
scatter(corticalCoords(:,1),corticalCoords(:,2),[],c,'filled')
title('OFF azimuth')
colorbar
axis equal
axis tight

%off elevation
elev = offY(~isnan(offY));
[~,sortI] = sort(elev);
corticalCoords = zeros(length(offAngles),2);
corticalCoords(:,1) = reshape(x,[],1);
corticalCoords(:,2) = reshape(y,[],1);
corticalCoords = corticalCoords(~isnan(offY),:);
corticalCoords = corticalCoords(sortI,:);

subplot(2,2,2)
scatter(corticalCoords(:,1),corticalCoords(:,2),[],c,'filled')
title('OFF elev')
colorbar
axis equal
axis tight

%on azimuth
az = onX(~isnan(onX));
[~,sortI] = sort(az);
corticalCoords = zeros(length(offAngles),2);
corticalCoords(:,1) = reshape(x,[],1);
corticalCoords(:,2) = reshape(y,[],1);
corticalCoords = corticalCoords(~isnan(onX),:);
corticalCoords = corticalCoords(sortI,:);

subplot(2,2,3)
scatter(corticalCoords(:,1),corticalCoords(:,2),[],c,'filled')
title('ON azimuth')
colorbar
axis equal
axis tight

%on elevation
elev = onY(~isnan(onY));
[~,sortI] = sort(elev);
corticalCoords = zeros(length(offAngles),2);
corticalCoords(:,1) = reshape(x,[],1);
corticalCoords(:,2) = reshape(y,[],1);
corticalCoords = corticalCoords(~isnan(onY),:);
corticalCoords = corticalCoords(sortI,:);

subplot(2,2,4)
scatter(corticalCoords(:,1),corticalCoords(:,2),[],c,'filled')
title('ON elev')
colorbar
axis equal
axis tight

keyboard

%% look at receptive subfields near the fovea

%indices of a foveal window
x = 2:28;
y = 198:236;

[subC,subR] = meshgrid(x,y);
subR = reshape(subR,[],1);
subC = reshape(subC,[],1);
corticalCoords = [subR,subC];
windowInds = sub2ind(size(offField.angle),subR,subC);
notNanI = find(~isnan(offField.angle)==1);
inds = intersect(windowInds,notNanI);

%view the area of V1 we are interested in
v1Display = zeros(size(offField.angle));
v1Display(~isnan(offField.angle)) = 0.5;
v1Display(inds) = 1;
figure
imagesc(v1Display)
axis equal
axis tight

keyboard

%plot the receptive fields of the cells in visual coordinates
offEccen = offField.eccen(y,x);
offAngle = offField.angle(y,x);
onEccen = onField.eccen(y,x);
onAngle = onField.angle(y,x);

offEccen = reshape(offEccen,[],1);
onEccen = reshape(onEccen,[],1);
onAngle = reshape(onAngle,[],1);
offAngle = reshape(offAngle,[],1);

[~,sortedI] = sort(subR);

offAngle = offAngle(sortedI);
offEccen = offEccen(sortedI);
onAngle = onAngle(sortedI);
onEccen = onEccen(sortedI);

onAngles = visualToStandardPolar(onAngle);
offAngles = visualToStandardPolar(offAngle);

[foveaOffX,foveaOffY] = pol2cart(deg2rad(offAngles),offEccen);
[foveaOnX,foveaOnY] = pol2cart(deg2rad(onAngles),onEccen);

c = linspace(1,80,size(corticalCoords,1));

figure
subplot(1,2,1)
scatter(foveaOffX,foveaOffY,[],c,'filled')
xlim([-0.1,0.7])
ylim([-0.6,0.8])

hold on
subplot(1,2,2)
scatter(foveaOnX,foveaOnY,[],c,'filled')
xlim([-0.1,0.7])
ylim([-0.6,0.8])

keyboard

%% Lee

offXSquare = reshape(offX,401,401);
offYSquare = reshape(offY,401,401);
onXSquare = reshape(onX,401,401);
onYSquare = reshape(onY,401,401);

%this way doesn't work well for the whole frame, but it's easy for a region
figure
subplot(2,2,1)
imagesc(offXSquare(y,x))
title('OFF azimuth')
colorbar
subplot(2,2,2)
imagesc(offYSquare(y,x))
title('OFF elev')
colorbar
subplot(2,2,3)
imagesc(onXSquare(y,x))
title('ON azimuth')
colorbar
subplot(2,2,4)
imagesc(onYSquare(y,x))
title('ON elev')
colorbar


%% this way works for the whole frame, but having trouble getting it to work
%for a region
[x,y] = meshgrid(regionRow,regionCol);

offXregion = reshape(offX,401,401);
offXregion = offXregion(regionRow,regionCol);
offYregion = reshape(offY,401,401);
offYregion = offYregion(regionRow,regionCol);

onXregion = reshape(onX,401,401);
onXregion = onXregion(regionRow,regionCol);
onYregion = reshape(onY,401,401);
onYregion = onYregion(regionRow,regionCol);

figure

subplot(1,2,1)
az = offXregion(~isnan(offXregion));
[~,sortI] = sort(az);
corticalCoords = zeros(numel(x),2);
corticalCoords(:,1) = reshape(x,[],1);
corticalCoords(:,2) = reshape(y,[],1);
corticalCoords = corticalCoords(~isnan(offXregion),:);
corticalCoords = corticalCoords(sortI,:);
c = linspace(1,80,size(corticalCoords,1));

scatter(corticalCoords(:,1),corticalCoords(:,2),[],c,'filled')
colorbar
axis equal
axis tight

subplot(1,2,2)
elev = offYregion(~isnan(offYregion));
[~,sortI] = sort(elev);
corticalCoords = zeros(numel(x),2);
corticalCoords(:,1) = reshape(x,[],1);
corticalCoords(:,2) = reshape(y,[],1);
corticalCoords = corticalCoords(~isnan(offXregion),:);
corticalCoords = corticalCoords(sortI,:);
c = linspace(1,80,size(corticalCoords,1));

scatter(corticalCoords(:,1),corticalCoords(:,2),[],c,'filled')
colorbar
axis equal
axis tight
