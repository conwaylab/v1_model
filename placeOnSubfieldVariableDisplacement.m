function onField = placeOnSubfieldVariableDisplacement(offField,params)

dispPrcnt = params.onSigmaFraction;
dispNoiseCoeff = params.dispNoiseCoeff;
angleNoiseCoeff = params.angleNoiseCoeff;

offSigma = offField.sigmaFlat;
offEccen = offField.eccenFlat;
offAngle = offField.angleFlat;
orientationPref = offField.orientationFlat;

onField.angleFlat = NaN(size(offAngle));
onField.eccenFlat = NaN(size(offEccen));
onField.sigmaFlat = offSigma;
onField.orientationFlat = orientationPref;

eccenDisp = zeros(size(onField.orientationFlat));

notNanI = find(~isnan(offEccen));
for i = 1:numel(notNanI)
    ind = notNanI(i);
    cellSign = randi(2)*2 - 3;
    eccenDisp(ind) = cellSign*(offSigma(ind)*dispPrcnt + params.disp);
    eccenDisp(ind) = eccenDisp(ind) + normrnd(0,dispNoiseCoeff)*abs(eccenDisp(ind));
    if eccenDisp(ind) + offEccen(ind) > 120
        eccenDisp(ind) = eccenDisp(ind)*-1;
    end
    if eccenDisp(ind) + offEccen(ind) < 5
        eccenDisp(ind) = eccenDisp(ind)*-1;
    end
    dispAngle = orientationPrefToDispAngle(orientationPref(ind));
    dispAngle = dispAngle + normrnd(0,angleNoiseCoeff);
    [onField.angleFlat(ind),onField.eccenFlat(ind)] = addPolarVec(offAngle(ind),...
        offEccen(ind),dispAngle,eccenDisp(ind));
    if onField.eccenFlat(ind) > 120
        eccenDisp(ind) = eccenDisp(ind)*-1;
        [onField.angleFlat(ind),onField.eccenFlat(ind)] = addPolarVec(offAngle(ind),...
            offEccen(ind),dispAngle,eccenDisp(ind));
    end
    
    if onField.angleFlat(ind) < -5 || onField.angleFlat(ind) > 180
        eccenDisp(ind) = eccenDisp(ind)*-1;
        [onField.angleFlat(ind),onField.eccenFlat(ind)] = addPolarVec(offAngle(ind),...
            offEccen(ind),dispAngle,eccenDisp(ind));
    end
end

onField.eccenDisp = eccenDisp;

end
