close all
clearvars

initializeParametersVariableDisplacement
dims = params.dims+1;
[offField,onField] = makeFlatMaps(params,paths);

%% make several eye movements

numEyeMovs = 100;

spiral.th = linspace(0,360,250);
spiral.b = 0.7;
spiral.a = 0.08;
eyeMoveMax = 0.1;

%should make another eye movement function that keeps all eye movements
%within a given window. In the current one, the eye movements can travel
%far from the initial since its sequential
spirals = eyeMovements(spiral,numEyeMovs,eyeMoveMax);

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

% view each window with its index for iV1
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


%% get the response to each eye movement

initializeParametersVariableDisplacement
% initializeParameters

onSigmaFractions = [0.2,1,3,5,10];

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

save('onOffResponsesTmp','allOffResponses','allOnResponses','spirals')

%% 
shuffleInds = randperm(numEyeMovs);
for iter = 1:numel(onSigmaFractions)
    % shuffle the responses, divide into two groups, average each groupy
    firstHalfI = 1:numEyeMovs/2;
    secondHalfI = (numEyeMovs/2+1):numEyeMovs;
    offResponse(:,1) = mean(allOffResponses(:,shuffleInds(firstHalfI),iter),2);
    offResponse(:,2) = mean(allOffResponses(:,shuffleInds(secondHalfI),iter),2);
    onResponse(:,1) = mean(allOnResponses(:,shuffleInds(firstHalfI),iter),2);
    onResponse(:,2) = mean(allOnResponses(:,shuffleInds(secondHalfI),iter),2);


    % get the average response in each of the previously defined windows

    [offWinResponse,onWinResponse] = responseWindows(offResponse,onResponse,...
        windowInds);

    offWinResponse2D = reshape(offWinResponse,windowSize,windowSize,numWindows,2);
    onWinResponse2D = reshape(onWinResponse,windowSize,windowSize,numWindows,2);

    % only the response windows that encompass V1
    V1OffResponse2D = offWinResponse2D(:,:,isV1Window,:);
    V1OnResponse2D = onWinResponse2D(:,:,isV1Window,:);
    V1OffResponse = offWinResponse(:,isV1Window,:);
    V1OnResponse = onWinResponse(:,isV1Window,:);

    % average the response within each subregion and then correlate subregion
    %   mean responses

    V1OffResponseMean = squeeze(mean(V1OffResponse));
    V1OnResponseMean = squeeze(mean(V1OnResponse));

    regionOffResponses(:,:,iter) = V1OffResponseMean(regionWindowInds,:);
    regionOnResponses(:,:,iter) = V1OnResponseMean(regionWindowInds,:);

    corrsOff(iter) = corr(regionOffResponses(:,1,iter),regionOffResponses(:,2,iter));
    corrsOn(iter) = corr(regionOnResponses(:,1,iter),regionOnResponses(:,2,iter));

end

%% 
nRuns = 10;

for i = 1:nRuns
    ind1 = randi(numEyeMovs);
    ind2 = ind1;
    while ind2==ind1
        ind2 = randi(numEyeMovs);
    end
    firstInd(i) = ind1;
    secondInd(i) = ind2;
    for iter = 1:numel(onSigmaFractions)
        thisOffResponse(:,1) = allOffResponses(:,ind1,iter);
        thisOffResponse(:,2) = allOffResponses(:,ind2,iter);
        thisOnResponse(:,1) = allOnResponses(:,ind1,iter);
        thisOnResponse(:,2) = allOnResponses(:,ind2,iter);
        
        [offWinResponse,onWinResponse] = responseWindows(thisOffResponse,thisOnResponse,...
            windowInds);

        offWinResponse2D = reshape(offWinResponse,windowSize,windowSize,numWindows,2);
        onWinResponse2D = reshape(onWinResponse,windowSize,windowSize,numWindows,2);

        % only the response windows that encompass V1
        V1OffResponse2D = offWinResponse2D(:,:,isV1Window,:);
        V1OnResponse2D = onWinResponse2D(:,:,isV1Window,:);
        V1OffResponse = offWinResponse(:,isV1Window,:);
        V1OnResponse = onWinResponse(:,isV1Window,:);

        % average the response within each subregion and then correlate subregion
        %   mean responses

        V1OffResponseMean = squeeze(mean(V1OffResponse));
        V1OnResponseMean = squeeze(mean(V1OnResponse));

        regionOffResponses(:,:,iter) = V1OffResponseMean(regionWindowInds,:);
        regionOnResponses(:,:,iter) = V1OnResponseMean(regionWindowInds,:);

        corrsOff(iter,i) = corr(regionOffResponses(:,1,iter),regionOffResponses(:,2,iter));
        corrsOn(iter,i) = corr(regionOnResponses(:,1,iter),regionOnResponses(:,2,iter));

    end
end

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