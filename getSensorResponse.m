%use inverse square law to determine cell's contribution to response

function response = getSensorResponse(sensorCoords,activity,distCoeff)
numCells = size(activity,1);
numSensors = size(sensorCoords,1);
% distances = zeros(numCells,1);
response = zeros(numSensors,1);
for i = 1:numSensors
    for j = 1:numCells
        distance = sqrt((sensorCoords(i,1)-activity(j,1))^2+(sensorCoords(i,2)-activity(j,2))^2);
        response(i) = response(i) + activity(j,3) / (distance^2 + distCoeff);
    end

end