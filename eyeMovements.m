function spirals = eyeMovements(spiralParams,numMovs,movDist)

th = spiralParams.th;
b = spiralParams.b;
a = spiralParams.a;

eyeMoveMax = movDist;
centerInit = [0,0];

spirals = struct('coords',[],'angles',[],'theta',[],'radius',[],'center',[]);
prevCenter = centerInit;

for i = 1:numMovs
    moveAngle = rand * 2*pi;
    moveDist = eyeMoveMax;
    gazeCenter = prevCenter + [cos(moveAngle),sin(moveAngle)]*moveDist;
    spirals(i) = logSpiral(th,b,a,gazeCenter);
    prevCenter = gazeCenter;
end

% make all movements from [0,0]
