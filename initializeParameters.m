function [params,paths] = initializeParameters()

% initialize paths
paths.subjectDir = [pwd '/lilac4_sim'];
addpath(genpath(paths.subjectDir));
paths.modelDir = [pwd '/models/'];

% flat map params
params.dims = 400; %actual size will be mapDims+1
params.pinwheelSz = 400;

% temporary variable until I fix the simulation up:
params.variableDisplacement = 0;

% cortical model params
params.dispNoiseCoeff = 0; %noise added to the on field placement
params.angleNoiseCoeff = 0; %noise added to displacement angle
params.responseSigma = 0.1;

% cortical dimensions looked up online
params.V1.area = 2400; %mm^2
params.V1.subfieldCortDist = 0.5; %mm

%numbers to determine displacement of ON subfield from OFF
params.numbers.humanOcDomWidth = 863; %um
params.numbers.catOcDomWidth = 500; %um
params.numbers.shrewOcDomWidth = params.numbers.catOcDomWidth; %don't have actual number yet
params.numbers.shrewOnDisp = 2; %deg visual angle
params.numbers.catOnDisp = params.numbers.shrewOnDisp; %don't have actual number yet
% params.eccenDispMag = params.numbers.shrewOnDisp/(params.numbers.humanOcDomWidth/params.numbers.shrewOcDomWidth);




params.desc = ['dim[',num2str(params.dims),']_pinwheel[',num2str(params.pinwheelSz),...
    ']_dispNoiseCoeff[',num2str(params.dispNoiseCoeff),']_angleNoiseCoeff[',num2str(params.angleNoiseCoeff),...
    ']_responseSigma[',num2str(params.responseSigma),']'];



