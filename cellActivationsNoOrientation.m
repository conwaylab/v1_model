function activations = cellActivationsNoOrientation(cellModel,stim,params)

spiralR = stim.radius;
spiralTh = stim.theta;

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
    
    d = sqrt(vertexEccen^2 + spiralR.^2 - 2*vertexEccen*spiralR.*cosd(spiralTh-vertexAngle));
    
    [~,closestI] = min(d);
    sigmaResponse = sigmaResponseMagnitude(d(closestI),vertexSigma);
    
    activations(ind) = abs(sigmaResponse + normrnd(0,responseSigma));
end

end