
function sensorCoords = defineSensors(sensorParams)

startCoord = sensorParams.startCoord;
endCoord = sensorParams.endCoord;
sensorsPerRow = sensorParams.sensorsPerRow;

rowLength = endCoord(1) - startCoord(1);
if mod(rowLength,sensorsPerRow) ~= 0
   sensorsPerRow = idivide(rowLength,uint32(sensorsPerRow)); 
end

rowSensors = linspace(startCoord(1),startCoord(1)+rowLength,sensorsPerRow+1);
spacing = rowSensors(2) - rowSensors(1);

colLength = endCoord(2) - startCoord(2);
colSensors = startCoord(2):spacing:endCoord(2);

numSensors = length(rowSensors)*length(colSensors);

sensorCoords = zeros(numSensors,2);
sensorCount = 1;
for i = 1:length(rowSensors)
    for j = 1:length(colSensors)
        sensorCoords(sensorCount,1) = rowSensors(i);
        sensorCoords(sensorCount,2) = colSensors(j);
        sensorCount = sensorCount+1;
    end
end

end