close all
clearvars

%% load all the data and information
saveDir = '/data/singhsr/Intermediates_Study/Light_Dark/simulation/cortical_model/Param_Variation/';
%saveDir = 'O:/Intermediates_Study/Light_Dark/simulation/cortical_model/Param_Variation/';

iterationName = 'param_variation1';

[params,paths] = initializeParametersVariableDisplacement;
dims = params.dims+1;
[offField,onField] = makeFlatMaps(params,paths);

jsonFileID = fopen(fullfile(saveDir,[iterationName '.json']),'r');
jsonStr = fscanf(jsonFileID,'%c');
info = jsondecode(jsonStr);
onSigmaFractions = info.onSigmaFractions;
eyeMoveDists = info.eyeMoveDists;
pinwheelSzs = info.pinwheelSzs;
numEyeMovs = info.numEyeMovs;

nSigFracs = numel(onSigmaFractions);
nEyeDists = numel(eyeMoveDists);
nPinSzs = numel(pinwheelSzs);

matFilepath = fullfile(saveDir,[iterationName '.mat']);
disp('loading')
load(matFilepath,'allOffResponses','allOnResponses');
disp('done loading')

%keyboard

%% define a region for the analysis

th = linspace(0,360,250);
centerSpiral = logSpiral(th,info.b,info.a,[0,0]); %change this to get the spiral from the loaded spirals

isV1 = offField.isV1;

maxEccenMult = 1.1;
maxEccen = max(centerSpiral.coords,[],'all')*maxEccenMult;
minEccen = 0.7; %ignores areas near the fovea

eccenRange = [minEccen,maxEccen];
angleRange = [0,180];
edges = [125,310];

inds = defineRegion(offField,eccenRange,angleRange,edges);
v1Display = zeros(dims,dims);
v1Display(isV1) = 0.5;
v1Display(inds) = 1;
figure
imagesc(v1Display)

%% get correlations

% allOffCorrs = zeros(numEyeMovs-1,nSigFracs,nEyeDists,nPinSzs);
% allOnCorrs = zeros(numEyeMovs-1,nSigFracs,nEyeDists,nPinSzs);
% 
% for iSig = 1:nSigFracs
%     for iEye = 1:nEyeDists
%         for iPin = 1:nPinSzs
%             offResponses = zeros(dims*dims,numEyeMovs);
%             onResponses = zeros(dims*dims,numEyeMovs);
%             offResponses(isV1,:) = allOffResponses{iSig,iEye,iPin};
%             onResponses(isV1,:) = allOnResponses{iSig,iEye,iPin};
% 
%             offCorrs = zeros(numEyeMovs-1,1);
%             onCorrs = zeros(numEyeMovs-1,1);
%             for iMov = 2:numEyeMovs
%                 offCorrs(iMov-1) = corr(offResponses(inds,1),offResponses(inds,iMov));
%                 onCorrs(iMov-1) = corr(onResponses(inds,1),onResponses(inds,iMov));
%                 allOffCorrs(:,iSig,iEye,iPin) = offCorrs;
%                 allOnCorrs(:,iSig,iEye,iPin) = onCorrs;
%             end
%         end
%     end
% end

%% visualize the correlations

% onOffCorrDiff = allOffCorrs - allOnCorrs;
% meanOnOffCorrDiff = squeeze(mean(onOffCorrDiff,1));
% 
% for iPin = 1:nPinSzs
% figure
% imagesc(meanOnOffCorrDiff(:,:,iPin))
% grid on
% colorbar
% caxis([0,0.5])
% xticks([0,1,2,3,4,5]+0.5)
% xticklabels(num2str(eyeMoveDists))
% xlabel('eye move dist')
% yticks([0,1,2,3,4,5]+0.5)
% yticklabels(num2str(onSigmaFractions))
% ylabel('on sigma fraction')
% title(num2str(pinwheelSzs(iPin)))
% end
%% 
% figure 
% scatter(allOffCorrs(:,3,3,3),allOnCorrs(:,3,3,3))
% hold on
% line([0,1],[0,1])
% testdiff = allOffCorrs(:,3,3,3)-allOnCorrs(:,3,3,3);
% sum(testdiff>0)/numel(testdiff)

%% average all the eye movements except the central one and then correlate
p = zeros(nSigFracs,nEyeDists,nPinSzs);
bootsamples = randi(numEyeMovs-1,1000,numEyeMovs-1)+1;
for iSig = 1:nSigFracs
    disp(['iSig: ' num2str(iSig)])
    for iEye = 1:nEyeDists
        disp(['iEye: ' num2str(iEye)])
        for iPin = 1:nPinSzs
            disp(['iPin: ' num2str(iPin)])
            offResponses = zeros(dims*dims,numEyeMovs);
            onResponses = zeros(dims*dims,numEyeMovs);
            offResponses(isV1,:) = allOffResponses{iSig,iEye,iPin};
            onResponses(isV1,:) = allOnResponses{iSig,iEye,iPin};
            regionOffResponses = offResponses(inds,:);
            regionOnResponses = onResponses(inds,:);
            regOffMovMeanResponse = squeeze(mean(regionOffResponses(:,2:end),2));
            regOnMovMeanResponse = squeeze(mean(regionOnResponses(:,2:end),2));

            offCorr = corr(regionOffResponses(:,1),regOffMovMeanResponse);
            onCorr = corr(regionOnResponses(:,1),regOnMovMeanResponse);

            %bootsamples = randi(49,1000,49)+1;
            offCorrBoot = zeros(1000,1);
            onCorrBoot = zeros(1000,1);
            parfor i = 1:1000
                regOffMovMeanResponse = squeeze(mean(regionOffResponses(:,bootsamples(i,:)),2));
                regOnMovMeanResponse = squeeze(mean(regionOnResponses(:,bootsamples(i,:)),2));
                offCorrBoot(i) = corr(regionOffResponses(:,1),regOffMovMeanResponse);
                onCorrBoot(i) = corr(regionOnResponses(:,1),regOnMovMeanResponse);
            end

            offCorrBootSort = sort(offCorrBoot);
            onCorrBootSort = sort(onCorrBoot);

            offOnCorrBootDiff = offCorrBoot - onCorrBoot;
            p(iSig,iEye,iPin) = sum(offOnCorrBootDiff <= 0) / 1000;
        end
    end
end

%% 

figSaveDir = ['eccen_',num2str(eccenRange(1)),'-',num2str(eccenRange(2)),...
    '_angle_',num2str(angleRange(1)),'-',num2str(angleRange(2))];
figSavePath = [saveDir 'Bootstrp_method1/' figSaveDir filesep];
if ~exist(figSavePath,'dir')
    mkdir(figSavePath)
end

for iPin = 1:nPinSzs
    f = figure;
    imagesc(p(:,:,iPin))
    grid on
    colorbar
    caxis([0,1])
    xticks([0,1,2,3,4,5]+0.5)
    xticklabels(num2str(eyeMoveDists))
    xlabel('eye move dist')
    yticks([0,1,2,3,4,5]+0.5)
    yticklabels(num2str(onSigmaFractions))
    ylabel('on sigma fraction')
    title(num2str(pinwheelSzs(iPin)))
    print('-f',[figSavePath iterationName '_Pin' num2str(pinwheelSzs(iPin))],'-dpng','-r300')
end