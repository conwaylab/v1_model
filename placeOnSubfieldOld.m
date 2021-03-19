function [angle,eccen] = placeOnSubfield(offAngle,offEccen,offSigma,orientationPref,params)

dispPrcnt = params.dispPrcnt;

cellSign = randi(2)*2 - 3;
% cellSign = 1;

% try using pRF sigma to determine displacement
eccenDisp = offSigma*dispPrcnt*cellSign;
% eccenDisp = 4*cellSign;

dispAngle = orientationPrefToDispAngle(orientationPref);

[angle,eccen] = addPolarVec(offAngle,offEccen,dispAngle,eccenDisp);


end