%Given the OFF subfield location in polar coordinates and an orientation
%preference, place the ON subfields
%Derivation from https://math.stackexchange.com/questions/1365622/adding-two-polar-vectors

function [th,r] = addPolarVec(th1,r1,th2,r2)

r = sqrt(r1.^2+r2.^2 + 2.*r1.*r2.*cosd(th2-th1));
th = th1 + atan2d(r2.*sind(th2-th1),r1+r2.*cosd(th2-th1));

end