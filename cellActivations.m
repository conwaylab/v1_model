function activations = cellActivations(cellModel,stim,params)

spiralR = stim.radius;
spiralTh = stim.theta;
stimAngles = stim.angles;

orientation = cellModel.orientationFlat;
eccen = cellModel.eccenFlat;
angle = cellModel.angleFlat;
sigma = cellModel.sigmaFlat;
responseSigma = params.responseSigma;


activations = zeros(size(cellModel.eccenFlat));
nonNanI = find(~isnan(eccen));

for i = 1:numel(nonNanI)
    ind = nonNanI(i);
    vertexEccen = eccen(ind);
    vertexSigma = sigma(ind);
    vertexAngle = angle(ind);
    vertOrientPref = orientation(ind);

    d = sqrt(vertexEccen^2 + spiralR.^2 - 2*vertexEccen*spiralR.*cosd(spiralTh-vertexAngle));
    
    [~,closestI] = min(d);
    sigmaResponse = sigmaResponseMagnitude(d(closestI),vertexSigma);
    
    stimAngle = stimAngles(closestI);
    orientationResponse = orientationResponseMagnitude(vertOrientPref,...
        stimAngle);

    activations(ind) = abs(sigmaResponse*orientationResponse + normrnd(0,responseSigma));
    
end

end