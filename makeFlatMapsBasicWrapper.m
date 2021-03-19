clearvars

%The basic wrapper to call makeFlatMaps
% initializeParametersVariableDisplacement
initializeParameters

% params.desc = ['dim',num2str(params.dims),'_pinwheel',num2str(params.pinwheelSz),...
%     '_onSigmaFrac',num2str(params.onSigmaFraction),'_dispNoiseCoeff',...
%     num2str(params.dispNoiseCoeff),'_angleNoiseCoeff',num2str(params.angleNoiseCoeff),...
%     '_disp' num2str(params.disp)];

[offField,onField] = makeFlatMaps(params,paths);
% save([paths.modelDir params.desc '.mat'],'offField','onField','params')
