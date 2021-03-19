function [offResponses,onResponses,spirals] = eyeMovementResponse(offField,onField,...
    spiralParams,numMovs,movDist,params)

th = spiralParams.th;
b = spiralParams.b;
a = spiralParams.a;

eyeMoveMax = movDist;
centerInit = [0,0];

spirals = struct('coords',[],'angles',[],'theta',[],'radius',[],'center',[]);
offResponses = zeros(numel(offField.eccen),numMovs);
onResponses = zeros(numel(offField.eccen),numMovs);
prevCenter = centerInit;

% parpool('local',8)

% define all the spirals first

disp('Defining Spirals')

for i = 1:numMovs
    moveAngle = rand * 2*pi;
    moveDist = eyeMoveMax;
    gazeCenter = prevCenter + [cos(moveAngle),sin(moveAngle)]*moveDist;
    spirals(i) = logSpiral(th,b,a,gazeCenter);
    prevCenter = gazeCenter;
end

disp('Done with spirals, beginning parfor')
for i = 1:numMovs
    disp(i)
    offResponses(:,i) = cellActivations(offField,spirals(i),params);
    onResponses(:,i) = cellActivations(onField,spirals(i),params);
end