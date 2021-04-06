function onField = placeOnSubfield(offField,params)

eccenDisp = offField.displacementFlat;

% noise added to the displacement of ON subfield from OFF subfield
dispNoiseCoeff = params.dispNoiseCoeff;
% noise added to the displacement angle
angleNoiseCoeff = params.angleNoiseCoeff;

offSigma = offField.sigmaFlat;
offEccen = offField.eccenFlat;
offAngle = offField.angleFlat;
orientationPref = offField.orientationFlat;

onField.angleFlat = NaN(size(offAngle));
onField.eccenFlat = NaN(size(offEccen));
onField.sigmaFlat = offSigma;
onField.orientationFlat = orientationPref;

notNanI = find(~isnan(offEccen));
for i = 1:numel(notNanI)
    ind = notNanI(i);
    cellSign = randi(2)*2 - 3;
    eccenDisp(ind) = cellSign*(eccenDisp(ind));
    eccenDisp(ind) = eccenDisp(ind) + normrnd(0,dispNoiseCoeff)*abs(eccenDisp(ind));
    
    dispAngle = orientationPrefToDispAngle(orientationPref(ind)) + normrnd(0,angleNoiseCoeff);
    dispAngle = dispAngle + normrnd(0,angleNoiseCoeff);
    dispAngle = standardPolarToVisual(dispAngle);
    [onField.angleFlat(ind),onField.eccenFlat(ind)] = addPolarVec(offAngle(ind),...
        offEccen(ind),dispAngle,eccenDisp(ind));
    if onField.eccenFlat(ind) > 120
        eccenDisp(ind) = eccenDisp(ind)*-1;
        [onField.angleFlat(ind),onField.eccenFlat(ind)] = addPolarVec(offAngle(ind),...
            offEccen(ind),dispAngle,eccenDisp(ind));
    end
    
    if onField.angleFlat(ind) < 0 || onField.angleFlat(ind) > 180
        eccenDisp(ind) = eccenDisp(ind)*-1;
        [onField.angleFlat(ind),onField.eccenFlat(ind)] = addPolarVec(offAngle(ind),...
            offEccen(ind),dispAngle,eccenDisp(ind));
    end
end

onField.eccenDisp = eccenDisp;

end
