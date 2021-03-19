function [params,paths] = initializeParametersVariableDisplacement()

%initialize paths
paths.subjectDir = [pwd '/lilac4_sim'];
addpath(genpath(paths.subjectDir));
paths.modelDir = [pwd '/models/Variable_Displacement/'];

%temporary variable until I fix the simulation up:
params.variableDisplacement = 1;

%flat map params
params.dims = 400; %actual size will be mapDims+1
params.pinwheelSz = 400;

%cortical model params
params.onSigmaFraction = 2; %what percent of the sigma the on cell should be displaced
params.disp = 0; %a constant to be added to the ON subfield displacement
params.dispNoiseCoeff = 0; %noise added to the on subfield placement
params.angleNoiseCoeff = 0; %noise added to displacement angle

%cell response params
params.responseSigma = 0.1;

% cortical dimensions looked up online
params.V1.area = 2400; %mm^2
params.V1.subfieldCortDist = 1; %mm

params.desc = ['dim',num2str(params.dims),'_pinwheel',num2str(params.pinwheelSz),...
    '_onSigmaFrac',num2str(params.onSigmaFraction),'_dispNoiseCoeff',...
    num2str(params.dispNoiseCoeff),'_angleNoiseCoeff',num2str(params.angleNoiseCoeff),...
    '_disp' num2str(params.disp)];




