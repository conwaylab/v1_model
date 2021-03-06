clearvars 
close all

diary

onSigmaFractions = [0.01,0.1,1,3]
eyeMoveDists = [0.1,0.3,0.5]
pinwheelSzs = [100,400,800]

saveDir = '/data/singhsr/Intermediates_Study/Light_Dark/simulation/cortical_model/Param_Variation/';
%saveDir = 'O:/Intermediates_Study/Light_Dark/simulation/cortical_model/Param_Variation/';

exist(saveDir)

iterationName = 'param_variation3'

[params,paths] = initializeParametersVariableDisplacement;
%% make several eye movements
numEyeMovs = 100;
spiral.th = linspace(0,360,250);
spiral.b = 0.7;
spiral.a = 0.08;

%% save text info file
infoFilepath = fullfile(saveDir,[iterationName '.txt']);
fileID = fopen(infoFilepath,'w');
fprintf(fileID,'Sigma Fractions: ');
fprintf(fileID,['[',num2str(onSigmaFractions),']','\n\n']);

fprintf(fileID,'eyeMoveDists: ');
fprintf(fileID,['[',num2str(eyeMoveDists),']','\n\n']);

fprintf(fileID,'pinwheelSzs: ');
fprintf(fileID,['[',num2str(pinwheelSzs),']','\n\n']);

fprintf(fileID,'Spiral Params\n');
fprintf(fileID,['a: ',num2str(spiral.a),'\n']);
fprintf(fileID,['b: ',num2str(spiral.b),'\n']);
fprintf(fileID,['numEyeMovs: ',num2str(numEyeMovs),'\n']);
fclose(fileID);

info.onSigmaFractions = onSigmaFractions;
info.eyeMoveDists = eyeMoveDists;
info.pinwheelSzs = pinwheelSzs;
info.a = spiral.a;
info.b = spiral.b;
info.numEyeMovs = numEyeMovs;
jsonStr = jsonencode(info);

jsonFilepath = fullfile(saveDir,[iterationName '.json']);
fileID = fopen(jsonFilepath,'w');
fprintf(fileID,jsonStr);
fclose(fileID);

%% get the response to each eye movement
%parpool('local',8)
allOffResponses = cell(numel(onSigmaFractions),numel(eyeMoveDists),numel(pinwheelSzs));
allOnResponses = cell(numel(onSigmaFractions),numel(eyeMoveDists),numel(pinwheelSzs));
allSpirals = cell(numel(eyeMoveDists),1);
for iSig = 1:numel(onSigmaFractions)
    disp(['On Sigma Fraction: ' num2str(onSigmaFractions(iSig))]);
    for iEye = 1:numel(eyeMoveDists)
        eyeMoveDist = eyeMoveDists(iEye);
        disp(['Eye movement distance: ' num2str(eyeMoveDist)]);
        spirals = centeredEyeMovements360(spiral,numEyeMovs,eyeMoveDist,[0,0]);
        for iPin = 1:numel(pinwheelSzs)
            disp(['Pinwheel Sz: ' num2str(pinwheelSzs(iPin))]);
            params.onSigmaFraction = onSigmaFractions(iSig);
            params.pinwheelSz = pinwheelSzs(iPin);
            [offField,onField] = makeFlatMaps(params,paths);
            dims = params.dims+1;
            offResponses = zeros(dims*dims,numEyeMovs);
            onResponses = zeros(dims*dims,numEyeMovs);
            parfor i = 1:numEyeMovs
                offResponses(:,i) = cellActivations(offField,spirals(i),params);
                onResponses(:,i) = cellActivations(onField,spirals(i),params);
            end
            allOffResponses{iSig,iEye,iPin} = offResponses(offField.isV1,:);
            allOnResponses{iSig,iEye,iPin} = onResponses(onField.isV1,:);
        end
        allSpirals{iEye} = spirals;
    end
end
disp('DONE')
matFilepath = fullfile(saveDir,[iterationName '.mat']);
save(matFilepath,'allOffResponses','allOnResponses','allSpirals','-v7.3')