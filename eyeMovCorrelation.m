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
    spiral.a = 0.08;
    eyeMoveDist = 0.5;
    spirals = centeredEyeMovements(spiral,numEyeMovs,eyeMoveDist,[0,0]);
end

%% get the response to each eye movement

if loadResponses
    load([responseFilePath '.mat'],'allOffResponses','allOnResponses',...
        'onSigmaFractions')
else
    onSigmaFractions = [0.5,1,2,3,5];
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
end

keyboard


%% divide V1 into a bunch of windows

windowSize = 15;
stepSize = 7;

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

for iSig = 1:3
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

offCorrMean = squeeze(mean(offCorrs(2:numEyeMovs,:,:)));
onCorrMean = squeeze(mean(onCorrs(2:numEyeMovs,:,:)));
offOnDiff = offCorrMean - onCorrMean;

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