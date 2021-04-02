function [offField,onField,params] = makeFlatMaps(params,paths)

dims = params.dims+1;
load([paths.subjectDir filesep 'retinotopyMaps_sz_' num2str(dims) '.mat'],'flatRetinotopy');
%% make pinwheels

% initializeParametersVariableDisplacement
params.pinwheelSz
interpLev = params.dims / params.pinwheelSz;
pinwheels = makePinwheels(params.pinwheelSz,interpLev,0); %need to edit this function
% 
pinwheels = pinwheels(1:dims,1:dims);
pinwheels = rad2deg(pinwheels);
negDegrees = pinwheels < 0;
pinwheels(negDegrees) = pinwheels(negDegrees) + 180;

% load('pinwheels.mat')

% pinwheels = rand(dims,dims)*2*pi-pi;


%% save model
corticalModel.eccen = flatRetinotopy.eccen;
corticalModel.angle = flatRetinotopy.angle;
corticalModel.sigma = flatRetinotopy.sigma;
corticalModel.orientation = pinwheels;

[offField,onField] = createOnOffModel(corticalModel,params);


end