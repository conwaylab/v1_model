function spirals = centeredEyeMovements(spiralParams,numMovs,movDist,center)

th = spiralParams.th;
b = spiralParams.b;
a = spiralParams.a;

spirals = struct('coords',[],'angles',[],'theta',[],'radius',[],'center',[]);

spirals(1) = logSpiral(th,b,a,center);
angles = linspace(0,2*pi,numMovs);

for i = 2:numMovs
    moveAngle = angles(i);
    gazeCenter = center + [cos(moveAngle),sin(moveAngle)]*movDist;
    spirals(i) = logSpiral(th,b,a,gazeCenter);
end