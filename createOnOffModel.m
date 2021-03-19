function [offField,onField,params] = createOnOffModel(corticalModel,params)

offField = corticalModel;
offField.eccenFlat = reshape(offField.eccen,[],1);
offField.angleFlat = reshape(offField.angle,[],1);
offField.sigmaFlat = reshape(offField.sigma,[],1);
nanInds = isnan(offField.eccenFlat);
offField.orientation(nanInds) = NaN;
offField.orientationFlat = reshape(offField.orientation,[],1);
offField.isV1 = ~isnan(offField.orientationFlat);


%% temporary block until I fix simulation
if params.variableDisplacement == 1
    onField = placeOnSubfieldVariableDisplacement(offField,params);
else
    params = determineV1Dimensions(offField,params);
    [offField.displacementFlat,out] = onSubfieldDisplacement(offField,params);
    offField.out = out;
    onField = placeOnSubfield(offField,params);
    onField.out = out;
    onField.displacementFlat = offField.displacementFlat;
end
%%
onField.eccen = reshape(onField.eccenFlat,size(offField.eccen));
onField.angle = reshape(onField.angleFlat,size(offField.angle));
onField.sigma = reshape(onField.sigmaFlat,size(offField.sigma));
nanInds = isnan(onField.eccenFlat);
onField.orientation(nanInds) = NaN;
onField.orientation = reshape(onField.orientationFlat,size(offField.orientation));
onField.isV1 = ~isnan(onField.orientationFlat);

end
