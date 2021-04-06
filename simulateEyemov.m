% close all
clearvars

[params,paths] = initializeParametersVariableDisplacement();
% [params,paths] = initializeParameters();

[offField,onField] = makeFlatMaps(params,paths);

dims = params.dims+1;

keyboard
%% get response to several eye movements

numEyeMove = 2;
numIter = 2;

spiral.th = linspace(0,360,250);
spiral.b = 0.7;
spiral.a = 0.08;
eyeMoveMax = 0.5;

[allOffResponses,allOnResponses,spirals] = eyeMovementResponse(offField,onField,...
    spiral,numEyeMove,eyeMoveMax,params);

figure
scatter(spirals(1).coords(:,1),spirals(1).coords(:,2))

% shuffleInds = randperm(numEyeMove);
% offResponsesFlat(:,1) = mean(allOffResponses(:,shuffleInds(1:numEyeMove/2)),2);
% offResponsesFlat(:,2) = mean(allOffResponses(:,shuffleInds(numEyeMove/2:numEyeMove)),2);
% onResponsesFlat(:,1) = mean(allOnResponses(:,shuffleInds(1:numEyeMove/2)),2);
% onResponsesFlat(:,2) = mean(allOnResponses(:,shuffleInds(numEyeMove/2:numEyeMove)),2);

offResponsesFlat = allOffResponses;
onResponsesFlat = allOnResponses;
offResponses2D = reshape(offResponsesFlat,dims,dims,numEyeMove);
onResponses2D = reshape(onResponsesFlat,dims,dims,numEyeMove);

keyboard


%%

eccen = [0,7];
angle = [10,170];

eccenInds1 = find(offField.eccen > 1); 
eccenInds2 = find(offField.eccen < 6);
eccenInds = intersect(eccenInds1,eccenInds2);
angleInds1 = find(offField.angle > 80);
angleInds2 = find(offField.angle < 100);
angleInds = intersect(angleInds1,angleInds2);
inds = intersect(eccenInds,angleInds);

[subR,subC] = ind2sub([401,401],inds);


offResponseFovea = offResponsesFlat(inds,:);
onResponseFovea = onResponsesFlat(inds,:);

% figure
% subplot(2,2,1)
% imagesc(offResponses2D(inds,1))
% subplot(2,2,2)
% imagesc(offResponses2D(inds,2))
% 
% subplot(2,2,3)
% imagesc(onResponses2D(inds,1))
% subplot(2,2,4)
% imagesc(onResponses2D(inds,2))

offCorr = corr(offResponseFovea(:,1),offResponseFovea(:,2))
onCorr = corr(onResponseFovea(:,1),onResponseFovea(:,2))

figure
scatter(offResponseFovea(:,1),offResponseFovea(:,2))
ylim([0,1.4])
xlim([0,1.4])
axis equal
axis square

%% look at a small window near the fovea
% x = 2:28;
% y = 198:236;
x = 1:401;
y = 1:401;


[subC,subR] = meshgrid(x,y);
subR = reshape(subR,[],1);
subC = reshape(subC,[],1);
foveaInds = sub2ind(size(offField.angle),subR,subC);

offResponseFovea = offResponsesFlat(foveaInds,:);
onResponseFovea = onResponsesFlat(foveaInds,:);

figure
subplot(2,2,1)
imagesc(offResponses2D(y,x,1))
subplot(2,2,2)
imagesc(offResponses2D(y,x,2))

subplot(2,2,3)
imagesc(onResponses2D(y,x,1))
subplot(2,2,4)
imagesc(onResponses2D(y,x,2))

offCorr = corr(offResponseFovea(:,1),offResponseFovea(:,2))
onCorr = corr(onResponseFovea(:,1),onResponseFovea(:,2))

isV1 = offField.isV1;
offCorr = corr(offResponseFovea(isV1,1),offResponseFovea(isV1,2))
onCorr = corr(onResponseFovea(isV1,1),onResponseFovea(isV1,2))

figure
scatter(offResponseFovea(:,1),offResponseFovea(:,2))
ylim([0,1.4])
xlim([0,1.4])
axis equal
axis square

figure
scatter(onResponseFovea(:,1),onResponseFovea(:,2))
ylim([0,1.4])
xlim([0,1.4])
axis equal
axis square

figure
scatter(spirals(1).coords(:,1),spirals(2).coords(:,2))
hold on
scatter(spirals(2).coords(:,1),spirals(2).coords(:,2))

%% define a bunch of windows that cover all of V1 
windowSize = 30;
stepSize = 30;
windowInds = zeros(windowSize*windowSize,dims*dims);
windowSubs = zeros(windowSize*windowSize,2,dims*dims);
windowCntrs = zeros(dims*dims,2);
numWindows = 0;
for i = 1:stepSize:dims
    for j = 1:stepSize:dims
        if checkOutOfRange([i,j],windowSize,dims) == 0
            numWindows = numWindows+1;
            [windowInds(:,numWindows),windowSubs(:,:,numWindows)] = defineWindow([i,j],windowSize,dims);
            windowCntrs(numWindows,:) = [i,j];
        end
    end
end
windowInds = windowInds(:,1:numWindows);
windowSubs = windowSubs(:,:,1:numWindows);
windowCntrs = windowCntrs(1:numWindows,:);

isV1 = zeros(size(windowInds));
for i = 1:size(windowInds,2)
    isV1(:,i) = offField.isV1(windowInds(:,i));
end
isV1Window = ~any(~isV1);
iV1 = find(isV1Window);

%% View the windows 
v1Display = zeros(size(offField.angle));
v1Display(offField.isV1) = 0.1;
v1Display(windowInds(:,iV1)) = 0.5;
figure
imagesc(v1Display)

for i = 1:numel(iV1)
    wInd = iV1(i);
    minRow = min(windowSubs(:,2,wInd));
    maxRow = max(windowSubs(:,2,wInd));
    minCol = min(windowSubs(:,1,wInd));
    maxCol = max(windowSubs(:,1,wInd));
    line([minRow minRow],[minCol maxCol],'Color',[0 0 0])
    line([maxRow maxRow],[minCol maxCol],'Color',[0 0 0])
    line([minRow maxRow],[minCol minCol],'Color',[0 0 0])
    line([minRow maxRow],[maxCol maxCol],'Color',[0 0 0])
end
axis equal
axis tight

%% Organize the responses into the windows 
offResponseFlat = zeros([size(windowInds),numIter]);
onResponseFlat = zeros([size(windowInds),numIter]);
for i = 1:size(windowInds,2)
    for j = 1:numIter
        offResponseFlat(:,i,j) = offResponsesFlat(windowInds(:,i),j);
        onResponseFlat(:,i,j) = onResponsesFlat(windowInds(:,i),j);
    end
end

offResponse = reshape(offResponseFlat,windowSize,windowSize,numWindows,numIter);
onResponse = reshape(onResponseFlat,windowSize,windowSize,numWindows,numIter);

V1OffResponse = offResponse(:,:,isV1Window,:);
V1OnResponse = onResponse(:,:,isV1Window,:);
V1OffResponseFlat = offResponseFlat(:,isV1Window,:);
V1OnResponseFlat = onResponseFlat(:,isV1Window,:);

V1WindowCntrs = windowCntrs(isV1Window,:);
V1WindowCntrInds = sub2ind([dims,dims],V1WindowCntrs(:,2),V1WindowCntrs(:,1));

% get the correlation of responses within each window
offCorrs = zeros(numel(iV1),1);
onCorrs = zeros(numel(iV1),1);
for i = 1:numel(iV1)
    offCorrs(i) = corr(V1OffResponseFlat(:,i,1),V1OffResponseFlat(:,i,2));
    onCorrs(i) = corr(V1OnResponseFlat(:,i,1),V1OnResponseFlat(:,i,2));
end

windowCorrs = [offCorrs,onCorrs];
sum(windowCorrs(:,1) > windowCorrs(:,2)) / numel(iV1)

figure
scatter(offCorrs,onCorrs)
hold on
line([0,1],[0,1])

%% see where the OFF correlation is greater than the ON correlation by
% a defined threshold

thresh = 0.02;
offGreaterOn = (windowCorrs(:,1) - windowCorrs(:,2)) > thresh;
sum(offGreaterOn) / numel(iV1)

v1Display = zeros(size(offField.angle));
v1Display(offField.isV1) = 0.1;
v1Display(windowInds(:,iV1)) = 0.5;
for i = 1:numel(iV1)
    if offGreaterOn(i)
        v1Display(windowInds(:,iV1(i))) = 1;
    end
end
figure
imagesc(v1Display)

for i = 1:numel(iV1)
    wInd = iV1(i);
    minRow = min(windowSubs(:,2,wInd));
    maxRow = max(windowSubs(:,2,wInd));
    minCol = min(windowSubs(:,1,wInd));
    maxCol = max(windowSubs(:,1,wInd));
    line([minRow minRow],[minCol maxCol],'Color',[0 0 0])
    line([maxRow maxRow],[minCol maxCol],'Color',[0 0 0])
    line([minRow maxRow],[minCol minCol],'Color',[0 0 0])
    line([minRow maxRow],[maxCol maxCol],'Color',[0 0 0])
end
axis equal
axis tight

%% 
ind = 17;
offCorrs(ind)
onCorrs(ind)

figure
scatter(V1OffResponseFlat(:,ind,1),V1OffResponseFlat(:,ind,2))
ylim(xlim)
title('Off corr')
axis equal
axis square

figure
scatter(V1OnResponseFlat(:,ind,1),V1OnResponseFlat(:,ind,2))
ylim(xlim)
title('On corr')
axis equal
axis square

%% average the response within each subregion and then correlate subregion
%   mean responses

V1OffResponseMean = squeeze(mean(V1OffResponseFlat));
V1OnResponseMean = squeeze(mean(V1OnResponseFlat));

% view the indices of each window to choose a region center
% v1Display = zeros(size(offField.angle));
% v1Display(offField.isV1) = 0.1;
% figure
% imagesc(v1Display)
% hold on
% for i = 1:length(V1WindowCntrs)
%    text(V1WindowCntrs(i,1),V1WindowCntrs(i,2),num2str(i),'FontSize',9); 
% end
% trying to draw box around each window, didn't work
% for i = 1:size(windowSubs,3)
%     minRow = min(windowSubs(:,2,i));
%     maxRow = max(windowSubs(:,2,i));
%     minCol = min(windowSubs(:,1,i));
%     maxCol = max(windowSubs(:,1,i));
%     line([minCol minCol],[minCol maxCol])
%     line([maxCol maxCol],[minCol maxCol])
%     line([minCol maxCol],[minCol minCol])
%     line([minCol maxCol],[maxCol maxCol])
% end
% axis equal
% axis tight

% choose a region of subregions and correlate the mean region responses
% within it

% trying to do a more automatic way to define regions based on windows
% regionSize = windowSize*4;
% regionCntrInd = 17;
% regionCntr = V1WindowCntrs(regionCntrInd,:);
% numWindows = 0;
% add the window size to the center ind to see the lower and upper bounds
% of rows and cols for the window

%% temporarily for quickness, I'll just choose the window inds from the
% previous plot

% regionWindowInds = [15,16,17,18,19,8,9,10,11,12,22,23,24,25,26,1,2,3,4,5,6];
regionWindowInds = 1:10;
regionOffResponses = V1OffResponseMean(regionWindowInds,:);
regionOnResponses = V1OnResponseMean(regionWindowInds,:);

% view the region
v1Display = zeros(size(offField.angle));
v1Display(offField.isV1) = 0.1;
v1Display(windowInds(:,iV1(regionWindowInds))) = 0.5;
figure
imagesc(v1Display)

for i = 1:numel(regionWindowInds)
    wInd = iV1(regionWindowInds(i));
    minRow = min(windowSubs(:,2,wInd));
    maxRow = max(windowSubs(:,2,wInd));
    minCol = min(windowSubs(:,1,wInd));
    maxCol = max(windowSubs(:,1,wInd));
    line([minRow minRow],[minCol maxCol],'Color',[0 0 0])
    line([maxRow maxRow],[minCol maxCol],'Color',[0 0 0])
    line([minRow maxRow],[minCol minCol],'Color',[0 0 0])
    line([minRow maxRow],[maxCol maxCol],'Color',[0 0 0])
end
axis equal
axis tight

corr(regionOffResponses(:,1),regionOffResponses(:,2))
corr(regionOnResponses(:,1),regionOnResponses(:,2))

%% view averaged responses

regionInds = windowInds(:,iV1(regionWindowInds));
regionInds = reshape(regionInds,[],1);
[regionR,regionC] = ind2sub([401,401],regionInds);

offResponses = reshape(offResponsesFlat,401,401,[]);
onResponses = reshape(onResponsesFlat,401,401,[]);

caxisLims = [0,0.6];

x = 2:28;
y = 198:236;

figure
subplot(2,2,1)
imagesc(offResponses(y,x,1))
title('OFF 1')
caxis(caxisLims)

subplot(2,2,2)
imagesc(offResponses(y,x,2))
title('OFF 2')
caxis(caxisLims)

subplot(2,2,3)
imagesc(onResponses(y,x,1))
title('ON 1')
caxis(caxisLims)

subplot(2,2,4)
imagesc(onResponses(y,x,2))
caxis(caxisLims)
title('ON 2')

%%
V1OffResponseMapFlat = zeros([dims*dims,2]);
V1OnResponseMapFlat = zeros([dims*dims,2]);
for i = 1:length(V1WindowCntrInds)
    inds = iV1(i);
    V1OffResponseMapFlat(windowInds(:,inds),1) = V1OffResponseMean(i,1);
    V1OffResponseMapFlat(windowInds(:,inds),2) = V1OffResponseMean(i,2);
    V1OnResponseMapFlat(windowInds(:,inds),1) = V1OnResponseMean(i,1);
    V1OnResponseMapFlat(windowInds(:,inds),2) = V1OnResponseMean(i,2);
end
V1OffResponseMap = reshape(V1OffResponseMapFlat,[dims,dims,2]);
V1OnResponseMap = reshape(V1OnResponseMapFlat,[dims,dims,2]);

caxisLims = [0,0.6];

figure
subplot(2,2,1)
imagesc(V1OffResponseMap(:,:,1))
caxis(caxisLims)

subplot(2,2,2)
imagesc(V1OffResponseMap(:,:,2))
caxis(caxisLims)

subplot(2,2,3)
imagesc(V1OnResponseMap(:,:,1))

subplot(2,2,4)
imagesc(V1OnResponseMap(:,:,2))
caxis(caxisLims)

%% correlation between eye movements of subregions of V1 response map - 1
%   Pick a region to look at
windowSize = 15;
regionCenter = [10,230]; %[x,y]/[col,row]
[windowInds,~] = defineWindow(regionCenter,windowSize,dims);

isV1 = find(offField.isV1);
inds = intersect(windowInds,isV1);

%view the subregion of V1 that we are interested in
v1Display = zeros(size(offField.angle));
v1Display(offField.isV1) = 0.5;
v1Display(inds) = 1;
figure
imagesc(v1Display)
axis equal
axis tight
keyboard

%% correlation between eye movements of subregions of V1 response map - 2
%   View the response map of that region and calculate the correlation
%   coeff
offResponseFlat = offResponsesFlat(windowInds,:);
onResponseFlat = onResponsesFlat(windowInds,:);
offResponse = reshape(offResponseFlat,windowSize,windowSize,numIter);
onResponse = reshape(onResponseFlat,windowSize,windowSize,numIter);

figure
imagesc(offResponse(:,:,1))

figure
imagesc(onResponse(:,:,1))

nanI = isnan(offResponse(:,:,1));
corr2noNan(offResponse(:,:,1),offResponse(:,:,2),nanI)
corr2noNan(onResponse(:,:,1),onResponse(:,:,2),nanI)

keyboard

%% correlate the responses within each subregion
offCorrs = zeros(sum(isV1Window),1);
onCorrs = zeros(sum(isV1Window),1);
count = 1;
for i = 1:numel(iV1)
    offCorrs(i) = corr(V1OffResponseFlat(:,i,1),V1OffResponseFlat(:,i,2));
    onCorrs(count) = corr(V1OnResponseFlat(:,i,1),V1OnResponseFlat(:,i,2));
    count = count+1;
end

compareOnOffCorr = [offCorrs,onCorrs];
onOffCorrDiff = offCorrs - onCorrs;

%view location of a random region that was correlated
i = randi(numel(iV1));
windowI = iV1(i);
v1Display = zeros(size(offField.angle));
v1Display(offField.isV1) = 0.5;
v1Display(windowInds(:,windowI)) = 1;
figure
imagesc(v1Display)
axis equal
axis tight

sum(onOffCorrDiff > 0)

%% compare ON and OFF responses of regions side by side
sum(onOffCorrDiff > 0)
check1 = compareOnOffCorr(onOffCorrDiff < 0,:);
onGreaterOff = find(onOffCorrDiff<0);
offGreaterOn = find(onOffCorrDiff>0);
% ind = onGreaterOff(randi(numel(onGreaterOff)));
ind = offGreaterOn(randi(numel(offGreaterOn)));

figure
subplot(2,2,1)
imagesc(V1OffResponse(:,:,ind,1));
hold on

subplot(2,2,2)
imagesc(V1OffResponse(:,:,ind,2));

subplot(2,2,3)
imagesc(V1OnResponse(:,:,ind,1));

subplot(2,2,4)
imagesc(V1OnResponse(:,:,ind,2));

%% trying to make heatmap of on/off corr difference, not yet successful
onOffCorrDiffSc = onOffCorrDiff*100;

isV1 = find(offField.isV1);
inds = intersect(windowInds,isV1);

%view the subregion of V1 that we are interested in
v1Display = zeros(size(offField.angle));
v1Display(offField.isV1) = 0.1;
v1Display(V1WindowCntrInds) = onOffCorrDiffSc;
figure
imagesc(v1Display)
hold on
colorbar
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
