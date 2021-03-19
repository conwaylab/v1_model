% close all
% clearvars

initializeParameters
load([paths.modelDir params.desc '.mat'])

dims = params.dims+1;

%% define sensors
sensorParams.startCoord = [100,5];
sensorParams.endCoord = [325,325];
sensorParams.sensorsPerRow = 5;
sensorParams.distCoeff = 0.001;
sensorLocs = defineSensors(sensorParams);

sensorView = zeros(size(offField.orientation));
for i = 1:length(sensorLocs)
    sensorView(sensorLocs(i,1),sensorLocs(i,2)) = 1;
end

[cellCoordX,cellCoordY] = meshgrid(1:dims,1:dims);
cellCoordX = reshape(cellCoordX,[],1);
cellCoordY = reshape(cellCoordY,[],1);
notnanI = ~isnan(offField.orientationFlat);

%% get response to several eye movements

numIter = 40;

th = linspace(0,360,250);
b = 0.7;
a = 0.08;

eyeMoveMax = 0.1;
centerInit = [0,0];

stim = struct('coords',[],'angles',[],'theta',[],'radius',[]);
offResponses = zeros(numel(offField.eccen),numIter);
onResponses = zeros(numel(offField.eccen),numIter);
sensorOffResponse = zeros(length(sensorLocs),numIter);
sensorOnResponse = zeros(length(sensorLocs),numIter);

% parpool('local',8)

parfor i = 1:numIter
    disp(i)
    moveAngle = rand * 2*pi;
    moveDist = rand * eyeMoveMax;
    gazeCenter = centerInit + [cos(moveAngle),sin(moveAngle)]*moveDist;
    stim(i) = logSpiral(th,b,a,gazeCenter);

    offResponses(:,i) = cellActivations(offField,stim(i),params);
    onResponses(:,i) = cellActivations(onField,stim(i),params);
    
    offResponsesFlat = reshape(offResponses(:,i),[],1);
    offActivity = [cellCoordX,cellCoordY,offResponsesFlat];
    sensorOffResponse(:,i) = getSensorResponse(sensorLocs,offActivity(notnanI,:),sensorParams.distCoeff);

    onResponsesFlat = reshape(onResponses(:,i),[],1);
    onActivity = [cellCoordX,cellCoordY,onResponsesFlat];
    sensorOnResponse(:,i) = getSensorResponse(sensorLocs,onActivity(notnanI,:),sensorParams.distCoeff);

end

offResponses = reshape(offResponses,[size(offField.eccen),numIter]);
onResponses = reshape(onResponses,[size(onField.eccen),numIter]);


keyboard

%% correlation between eye movements

% nanI = isnan(offField.orientationFlat);
% i1 = randi(numIter);
% i2 = randi(numIter);
% corr2noNan(offResponses(:,:,i1),offResponses(:,:,i2),nanI)
% corr2noNan(onResponses(:,:,i1),onResponses(:,:,i2),nanI)

% offCorrs = [];
% onCorrs = [];
% 
% for i = 1:numIter
%     for j = 1:numIter
%         if i ~= j
%            offCorrs = [offCorrs corr2noNan(offResponses(:,:,i),offResponses(:,:,j),nanI)];
%            onCorrs = [onCorrs corr2noNan(onResponses(:,:,i),onResponses(:,:,j),nanI)];
%         end
%     end
% end

upper95I = uint32(floor(numel(offCorrs) - numel(offCorrs)*0.025));
lower95I = uint32(floor(numel(offCorrs)*0.025));

offCorrs = sort(offCorrs);

offCorrUpper95 = offCorrs(upper95I);
offCorrLower95 = offCorrs(lower95I);

onCorrs = sort(onCorrs);

onCorrUpper95 = onCorrs(upper95I);
onCorrLower95 = onCorrs(lower95I);

offCorrMean = mean(offCorrs);
offCorrStd = std(offCorrs);
onCorrMean = mean(onCorrs);
onCorrStd = std(onCorrs);

offUpper95Dist = abs(offCorrMean - offCorrUpper95);
offLower95Dist = abs(offCorrMean - offCorrLower95);

onUpper95Dist = abs(onCorrMean - onCorrUpper95);
onLower95Dist = abs(onCorrMean - onCorrLower95);


figure
bar(1,offCorrMean)
hold on
erOff = errorbar(1,offCorrMean,offLower95Dist,offUpper95Dist)

bar(2,onCorrMean)
hold on
erOn = errorbar(2,onCorrMean,onLower95Dist,onUpper95Dist)
%% scratch
offDists = pdist(sensorOffResponse','spearman');
onDists = pdist(sensorOnResponse','spearman');


mean(offDists)
mean(onDists)

offSensorView = zeros([(size(offField.orientation)-1)/5,numIter]);
onSensorView = zeros([(size(offField.orientation)-1)/5,numIter]);
sensorView = zeros((size(offField.orientation)-1)/5);
for iter = 1:numIter
    for i = 1:length(sensorLocs)
        offSensorView(sensorLocs(i,1)/5,sensorLocs(i,2)/5,iter) = sensorOffResponse(i,iter);
        onSensorView(sensorLocs(i,1)/5,sensorLocs(i,2)/5,iter) = sensorOnResponse(i,iter);
        sensorView(sensorLocs(i,1)/5,sensorLocs(i,2)/5) = 1;
    end
end

figure
imagesc(sensorView)

figure
subplot(2,2,1)
imagesc(offSensorView(:,:,1))
axis equal
axis tight
subplot(2,2,2)
imagesc(offSensorView(:,:,2))
axis equal
axis tight
subplot(2,2,3)
imagesc(onSensorView(:,:,1))
axis equal
axis tight
subplot(2,2,4)
imagesc(onSensorView(:,:,2))
axis equal
axis tight

figure
subplot(2,2,1)
imagesc(offResponses(:,:,1))
axis equal
axis tight
subplot(2,2,2)
imagesc(offResponses(:,:,2))
axis equal
axis tight
subplot(2,2,3)
imagesc(onResponses(:,:,1))
axis equal
axis tight
subplot(2,2,4)
imagesc(onResponses(:,:,2))
axis equal
axis tight


%% make video of responses to various eye movements
figure
for i = 1:numIter
    scatter(stim(i).coords(:,1),stim(i).coords(:,2))
    xlim([-15,15])
    ylim([-15,15])
    spiralFrames(i) = getframe(gcf);
    pause(0.1)
    clf
end

figure
for i = 1:numIter
    imagesc(offResponses(:,:,i))
    axis square 
    axis tight
    offResponseFrames(i) = getframe(gcf);
    pause(0.1)
    clf
end
v = VideoWriter(['videos/dark_activations_bigmove.avi']);
v.Quality = 100;
v.FrameRate = 1;
open(v)
writeVideo(v, offResponseFrames)
close(v)

figure
for i = 1:numIter
    imagesc(onResponses(:,:,i))
    axis square 
    axis tight
    onResponseFrames(i) = getframe(gcf);
    pause(0.1)
    clf
end
v = VideoWriter(['videos/light_activations.avi']);
v.Quality = 100;
v.FrameRate = 1;
open(v)
writeVideo(v, onResponseFrames)
close(v)

keyboard

%zoom in to a section
iRange = 150:200;
jRange = 75:125;
fileSuffix = ['_',num2str(iRange(1)),'-',num2str(iRange(end)),...
    '_', num2str(jRange(1)),'-',num2str(jRange(end))];

figure
for i = 1:numIter
    imagesc(offResponses(iRange,jRange,i))
    axis square 
    axis tight
    offResponseFrames(i) = getframe(gcf);
    pause(0.1)
    clf
end
v = VideoWriter(['videos/dark_activations' fileSuffix '.avi']);
v.Quality = 100;
v.FrameRate = 1;
open(v)
writeVideo(v, offResponseFrames)
close(v)

figure
for i = 1:numIter
    imagesc(onResponses(iRange,jRange,i))
    axis square 
    axis tight
    onResponseFrames(i) = getframe(gcf);
    pause(0.1)
    clf
end
v = VideoWriter(['videos/light_activations' fileSuffix '.avi']);
v.Quality = 100;
v.FrameRate = 1;
open(v)
writeVideo(v, onResponseFrames)
close(v)
