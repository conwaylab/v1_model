%Accounts for orientation, but not gaussian
%Cell responds if stimulus is within sigma

function [activations,isActive] = cellActivationsNoGauss(cellModel,stim,params)

spiralR = stim.radius;
spiralTh = stim.theta;
stimAngles = stim.angles;

orientation = cellModel.orientationFlat;
eccen = cellModel.eccenFlat;
angle = cellModel.angleFlat;
sigma = cellModel.sigmaFlat;
responseSigma = params.responseSigma;


isActive = zeros(size(cellModel.eccenFlat));
activations = zeros(size(cellModel.eccenFlat));

nonNanI = find(~isnan(eccen));
for i = 1:numel(nonNanI)
    ind = nonNanI(i);
    vertexEccen = eccen(ind);
    vertexSigma = sigma(ind);
    vertexAngle = angle(ind);
    vertOrientPref = orientation(ind);

    d = sqrt(vertexEccen^2 + spiralR.^2 - 2*vertexEccen*spiralR.*cosd(spiralTh-vertexAngle));
    withinSigma = abs(d) < vertexSigma;
    
    if sum(withinSigma) > 0
        activatingPtAngles = stimAngles(withinSigma);
        stimAngle = mean(activatingPtAngles);
        activations(ind) = orientationResponseMagnitude(vertOrientPref,stimAngle,responseSigma);
        isActive(ind) = 1;
    end
end

end