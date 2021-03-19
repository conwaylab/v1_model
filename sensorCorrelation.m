close all
clearvars

initializeParameters
load([paths.modelDir params.desc '.mat'])

%% define sensors
sensorParams.startCoord = [100,5];
sensorParams.endCoord = [325,325];
sensorParams.sensorsPerRow = 5;
sensorParams.distCoeff = 0.01;
sensorLocs = defineSensors(sensorParams);

sensorView = zeros(size(offField.orientation));
for i = 1:length(sensorLocs)
    sensorView(sensorLocs(i,1),sensorLocs(i,2)) = 1;
end

[cellCoordX,cellCoordY] = meshgrid(1:401,1:401);
cellCoordX = reshape(cellCoordX,[],1);
cellCoordY = reshape(cellCoordY,[],1);
notnanI = ~isnan(offField.orientationFlat);


%% get response to several eye movements
N = 1500;
d = 1;
b = 7;
scale = 0.06;
numIter = 100;

eyeMoveMax = 0.1;
centerInit = [0,0];

archSpiral = struct('coords',[],'angles',[],'theta',[],'radius',[]);
offResponses = zeros(numel(offField.eccen),numIter);
onResponses = zeros(numel(offField.eccen),numIter);
sensorOffResponse = zeros(length(sensorLocs),numIter);
sensorOnResponse = zeros(length(sensorLocs),numIter);

parpool('local',16)

parfor i = 1:numIter
    disp(i)
    moveAngle = rand * 2*pi;
    moveDist = rand * eyeMoveMax;
    gazeCenter = centerInit + [cos(moveAngle),sin(moveAngle)]*moveDist;
    archSpiral(i) = archSpiralStim(gazeCenter,b,N,d,scale);
    offResponses(:,i) = cellActivations(offField,archSpiral(i),params);
    onResponses(:,i) = cellActivations(onField,archSpiral(i),params);
    
    offResponsesFlat = reshape(offResponses(:,i),[],1);
    offActivity = [cellCoordX,cellCoordY,offResponsesFlat];
    sensorOffResponse(:,i) = getSensorResponse(sensorLocs,offActivity(notnanI,:),sensorParams.distCoeff);

    onResponsesFlat = reshape(onResponses(:,i),[],1);
    onActivity = [cellCoordX,cellCoordY,onResponsesFlat];
    sensorOnResponse(:,i) = getSensorResponse(sensorLocs,onActivity(notnanI,:),sensorParams.distCoeff);

end

delete(gcp('nocreate'))
keyboard

offResponses = reshape(offResponses,[size(offField.eccen),numIter]);
onResponses = reshape(onResponses,[size(onField.eccen),numIter]);

%% correlation between eye movements

offDists = pdist(sensorOffResponse','spearman');
onDists = pdist(sensorOnResponse','spearman');

mean(offDists)
mean(onDists)

offDists = sort(offDists);
onDists = sort(onDists);

% figure
% subplot(2,2,1)
% imagesc(offResponses(:,:,1))
% subplot(2,2,2)
% imagesc(offResponses(:,:,2))
% subplot(2,2,3)
% imagesc(onResponses(:,:,1))
% subplot(2,2,4)
% imagesc(onResponses(:,:,2))

keyboard
