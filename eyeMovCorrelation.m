close all
clearvars

[params,paths] = initializeParametersVariableDisplacement();
% [params,paths] = initializeParameters();

dims = params.dims+1;
[offField,onField] = makeFlatMaps(params,paths);

simResponseDir = fullfile(pwd,'Response_Eye_Movements');
responseFileName = 'onOffResponses1';
responseFilePath = fullfile(simResponseDir,responseFileName);
loadEyeMovs = 1;
loadResponses = 1;

%% make several eye movements

% %should make another eye movement function that keeps all eye movements
% %within a given window. In the current one, the eye movements can travel
% %far from the initial since its sequential
% load('onOffResponsesTmp','spirals')
% load the spirals 
if loadEyeMovs
    load(responseFilePath,'spirals')
    numEyeMovs = numel(spirals);
else
    numEyeMovs = 100;
    spiral.th = linspace(0,360,250);
    spiral.b = 0.7;
    spiral.a = 0.18;
    eyeMoveDist = 0.5;
    spirals = centeredEyeMovements360(spiral,numEyeMovs,eyeMoveDist,[0,0]);
end

%% get the response to each eye movement
if loadResponses
    load([responseFilePath '.mat'],'allOffResponses','allOnResponses',...
        'onSigmaFractions')
else
%     onSigmaFractions = [0.5,1,2,3,5];
    onSigmaFractions = [1,2,3];
    parpool('local',8)
    for iter = 1:numel(onSigmaFractions)
        params.onSigmaFraction = onSigmaFractions(iter);
        [offField,onField] = makeFlatMaps(params,paths);
        dims = params.dims+1;
        parfor i = 1:numEyeMovs
            disp(i)
            allOffResponses(:,i,iter) = cellActivations(offField,spirals(i),params);
            allOnResponses(:,i,iter) = cellActivations(onField,spirals(i),params);
        end
    end
    save([responseFilePath '.mat'],'allOffResponses','allOnResponses','spirals',...
        'onSigmaFractions')
    
    % save a text file with all the info
    txtPath = fullfile(simResponseDir,[responseFileName,'.txt']);
    fileID = fopen(txtPath,'w');
    fprintf(fileID,'Sigma Fractions: ');
    fprintf(fileID,['[',num2str(onSigmaFractions),']','\n\n']);
    fprintf(fileID,'Spiral Params\n');
    fprintf(fileID,['a: ',num2str(spiral.a),'\n']);
    fprintf(fileID,['b: ',num2str(spiral.b),'\n']);
    fprintf(fileID,['eyeMoveMax: ',num2str(eyeMoveDist),'\n']);
    fprintf(fileID,['numEyeMovs: ',num2str(numEyeMovs),'\n']);
    fclose(fileID);
    
    data.sigma
    
end

keyboard

nSigFrac = numel(onSigmaFractions);
allOffResponses2D = reshape(allOffResponses,401,401,100,nSigFrac);
allOnResponses2D = reshape(allOnResponses,401,401,100,nSigFrac);

figure
imagesc(allOffResponses2D(:,:,1,1))

%% define an area based on eccentricity and angle bounds
% Seems that when the region does not include the low eccentricity area
% near the fovea, the OFF correlations are significantly greater than the
% ON

iSig = 1;
isV1 = offField.isV1;

maxEccenMult = 1.1;
maxEccen = max(spirals(1).coords,[],'all')*maxEccenMult;
% maxEccen = 6;
% minEccen = 0;
minEccen = 0.7; %ignores areas near the fovea

eccenRange = [minEccen,maxEccen];
angleRange = [0,180];
edges = [125,310];

inds = defineRegion(offField,eccenRange,angleRange,edges);
samp = allOnResponses2D(:,:,1,iSig);
samp(inds) = 1;

figure
imagesc(samp)


%% get the correlations and plot scatter of ON corr vs OFF corr
iSig = 1;
for i = 1:100
    offCorrs1(i) = corr(allOffResponses(inds,1,iSig),allOffResponses(inds,i,iSig));
    onCorrs1(i) = corr(allOnResponses(inds,1,iSig),allOnResponses(inds,i,iSig));
end

figure
scatter(offCorrs1,onCorrs1)
line([0,1],[0,1])

compareOnOff = offCorrs1' - onCorrs1';
checkCorrs = [offCorrs1',onCorrs1'];
sum(compareOnOff > 0) / numel(compareOnOff)

%% Look at the eye movement with the maximum on correlation relative to OFF

[~,minI] = min(compareOnOff);

sampOffResponsesFlat1 = allOffResponses(:,1,iSig);
sampOffResponsesFlat2 = allOffResponses(:,minI,iSig);
sampOnResponsesFlat1 = allOnResponses(:,1,iSig);
sampOnResponsesFlat2 = allOnResponses(:,minI,iSig);

rows = randi(401,401);
cols = randi(401,401);
sampOffResponses1 = reshape(sampOffResponsesFlat1,size(rows,1),size(cols,2));
sampOffResponses2 = reshape(sampOffResponsesFlat2,size(rows,1),size(cols,2));
sampOnResponses1 = reshape(sampOnResponsesFlat1,size(rows,1),size(cols,2));
sampOnResponses2 = reshape(sampOnResponsesFlat2,size(rows,1),size(cols,2));

figure
subplot(2,2,1)
imagesc(sampOffResponses1)
subplot(2,2,2)
imagesc(sampOffResponses2)
subplot(2,2,3)
imagesc(sampOnResponses1)
subplot(2,2,4)
imagesc(sampOnResponses2)

% figure
% scatter(sampOffResponses1(inds),sampOffResponses2(inds))
% title('OFF')
% figure
% scatter(sampOnResponses1(inds),sampOnResponses2(inds))
% title('ON')

%% try averaging all the eye movements except the central one and then correlating
iSig = 3;
regionOffResponses = allOffResponses(inds,:,:);
regionOnResponses = allOnResponses(inds,:,:);

regOffMovMeanResponse = squeeze(mean(regionOffResponses(:,2:end,:),2));
regOnMovMeanResponse = squeeze(mean(regionOnResponses(:,2:end,:),2));

offCorr2 = corr(regionOffResponses(:,1,iSig),regOffMovMeanResponse(:,iSig))
onCorr2 = corr(regionOnResponses(:,1,iSig),regOnMovMeanResponse(:,iSig))

bootsamples = randi(99,1000,99)+1;
for i = 1:1000
    regOffMovMeanResponse = squeeze(mean(regionOffResponses(:,bootsamples(i,:),iSig),2));
    regOnMovMeanResponse = squeeze(mean(regionOnResponses(:,bootsamples(i,:),iSig),2));
    offCorrBoot(i) = corr(regionOffResponses(:,1,iSig),regOffMovMeanResponse);
    onCorrBoot(i) = corr(regionOnResponses(:,1,iSig),regOnMovMeanResponse);
end

offCorrBootSort = sort(offCorrBoot);
onCorrBootSort = sort(onCorrBoot);

mean(offCorrBoot)
offCorrCI = [offCorrBootSort(25),offCorrBootSort(975)]
mean(onCorrBoot)
onCorrCI = [onCorrBootSort(25),onCorrBootSort(975)]

offOnCorrBootDiff = offCorrBoot - onCorrBoot;
p = sum(offOnCorrBootDiff <= 0) / 1000


%% divide V1 into a bunch of windows

windowSize = 50;
stepSize = 50;

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
V1WindowCntrs = windowCntrs(isV1Window,:);
V1WindowCntrInds = sub2ind([dims,dims],V1WindowCntrs(:,2),V1WindowCntrs(:,1));

%% define a region in which to correlate the responses in the windows

%view each window with its index for iV1
v1Display = zeros(size(offField.angle));
v1Display(offField.isV1) = 0.1;
figure
imagesc(v1Display)
hold on
for i = 1:length(V1WindowCntrs)
   text(V1WindowCntrs(i,1),V1WindowCntrs(i,2),num2str(i),'FontSize',9); 
end

% define and view a region
regionWindowInds = 1:100;
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

%% correlate the response to each eye position to the first eye position 
% within each of the windows

offCorrs = zeros(numEyeMovs,numel(iV1),numel(onSigmaFractions));
onCorrs = zeros(numEyeMovs,numel(iV1),numel(onSigmaFractions));

for iSig = 1:5
    for iWin = 1:numel(iV1)
        disp(iWin)
        thisOffResponse = allOffResponses(windowInds(:,iV1(iWin)),:,iSig);
        thisOnResponse = allOnResponses(windowInds(:,iV1(iWin)),:,iSig);
        for iPos = 1:numEyeMovs
            offCorrs(iPos,iWin,iSig) = corr(thisOffResponse(:,iPos),...
                thisOffResponse(:,1));
            onCorrs(iPos,iWin,iSig) = corr(thisOnResponse(:,iPos),...
                thisOnResponse(:,1));
        end
    end
end

offCorrMean = squeeze(mean(offCorrs(2:numEyeMovs,:,:),2));
onCorrMean = squeeze(mean(onCorrs(2:numEyeMovs,:,:),2));
offOnDiff = offCorrMean - onCorrMean;

%%
figure
scatter(offCorrMean(:,3),onCorrMean(:,3))
line([0,1],[0,1])
%%
offCheck = allOffResponses(:,2:3,2);
onCheck = allOnResponses(:,2:3,2);
offCheck2D = reshape(offCheck,401,401,2);
onCheck2D = reshape(onCheck,401,401,2);

x = 10:28;
y = 208:236;
[subC,subR] = meshgrid(x,y);
subR = reshape(subR,[],1);
subC = reshape(subC,[],1);
foveaInds = sub2ind(size(offField.angle),subR,subC);

offResponseFovea = offCheck(foveaInds,:);
onResponseFovea = onCheck(foveaInds,:);

figure
subplot(2,2,1)
imagesc(offCheck2D(y,x,1))
subplot(2,2,2)
imagesc(offCheck2D(y,x,2))

subplot(2,2,3)
imagesc(onCheck2D(y,x,1))
subplot(2,2,4)
imagesc(onCheck2D(y,x,2))

offCorr = corr(offResponseFovea(:,1),offResponseFovea(:,2))
onCorr = corr(onResponseFovea(:,1),onResponseFovea(:,2))



%%
allOffResponses2D = reshape(allOffResponses,401,401,100,4);
allOnResponses2D = reshape(allOnResponses,401,401,100,4);

figure
subplot(2,2,1)
imagesc(allOffResponses2D(:,:,firstInd(3),3))
subplot(2,2,2)
imagesc(allOffResponses2D(:,:,secondInd(3),3))
subplot(2,2,3)
imagesc(allOnResponses2D(:,:,firstInd(3),3))
subplot(2,2,4)
imagesc(allOnResponses2D(:,:,secondInd(3),3))

figure
scatter(spirals(firstInd(3)).coords(:,1),spirals(firstInd(3)).coords(:,2))
hold on
scatter(spirals(secondInd(3)).coords(:,1),spirals(secondInd(3)).coords(:,2))

spiral1 = spirals(firstInd(3));
spiral2 = spirals(secondInd(3));
sqrt(sum((spiral1.center-spiral2.center).^2))

check2 = cellActivations(offField,spirals(20),params);
check2 = reshape(check2,401,401);
figure
imagesc(check2)
figure
imagesc(allOffResponses2D(:,:,40,1))

%% OLD APPROACHES

% % Split the movements randomly into two sets, averaged, and got the
% % correlation between each set. No longer using because I realized that
% % averaging the sets makes the eye movement distance irrelevant 
% for i = 1:1000
%     permInds = randperm(numEyeMovs);
%     if mod(i,10) == 0
%         disp(i)
%     end
%     offResponseSet1 = regionOffResponses(:,permInds(1:idivide(numEyeMovs,uint8(2))),:);
%     offResponseSet2 = regionOffResponses(:,permInds(idivide(numEyeMovs,uint8(2))+1:end),:);
%     onResponseSet1 = regionOnResponses(:,permInds(1:idivide(numEyeMovs,uint8(2))),:);
%     onResponseSet2 = regionOnResponses(:,permInds(idivide(numEyeMovs,uint8(2))+1:end),:);
%     
%     offSet1Mean = squeeze(mean(offResponseSet1,2));
%     offSet2Mean = squeeze(mean(offResponseSet2,2));
%     onSet1Mean = squeeze(mean(onResponseSet1,2));
%     onSet2Mean = squeeze(mean(onResponseSet2,2));
% 
%     % get the correlation between the means above
%     offCorr(i) = corr(offSet1Mean(:,iSig),offSet2Mean(:,iSig));
%     onCorr(i) = corr(onSet1Mean(:,iSig),onSet2Mean(:,iSig));
% end
% 
% % this p value is not very reliable: get very different values on each
% % iteration
% % probably because there are wayy more than 1000 permutations of 100
% % elements, so repeating the permutations 1000 times won't be
% % representative of the possibilities 
% onOffDiff = offCorr-onCorr;
% p = sum(onOffDiff < 0) / 1000
% 
% offResponseSet1 = allOffResponses(:,permInds(1:idivide(numEyeMovs,uint8(2))),:);
% offResponseSet2 = allOffResponses(:,permInds(idivide(numEyeMovs,uint8(2))+1:end),:);
% onResponseSet1 = allOnResponses(:,permInds(1:idivide(numEyeMovs,uint8(2))),:);
% onResponseSet2 = allOnResponses(:,permInds(idivide(numEyeMovs,uint8(2))+1:end),:);
% 
% offSet1Mean = squeeze(mean(offResponseSet1,2));
% offSet2Mean = squeeze(mean(offResponseSet2,2));
% onSet1Mean = squeeze(mean(onResponseSet1,2));
% onSet2Mean = squeeze(mean(onResponseSet2,2));
%     
% offSet1Mean2D = reshape(offSet1Mean,dims,dims,[]);
% offSet2Mean2D = reshape(offSet2Mean,dims,dims,[]);
% onSet1Mean2D = reshape(onSet1Mean,dims,dims,[]);
% onSet2Mean2D = reshape(onSet2Mean,dims,dims,[]);
% 
% figure
% subplot(2,2,1)
% imagesc(offSet1Mean2D(:,:,iSig))
% subplot(2,2,2)
% imagesc(offSet2Mean2D(:,:,iSig))
% subplot(2,2,3)
% imagesc(onSet1Mean2D(:,:,iSig))
% subplot(2,2,4)
% imagesc(onSet2Mean2D(:,:,iSig))