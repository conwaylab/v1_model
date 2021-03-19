%Create a Archimedean spiral shaped stimulus

function archSpiral = archSpiralStimTest(a,b,N,d)

a = 1;
b = 1

theta = zeros(N,1);
for i = 2:N
    theta(i) = thetaStep(theta(i-1),a,b,d);
end

r = a+b*theta;

x = r.*cos(theta);
y = r.*sin(theta);

archSpiral.coords = [x,y];
% 
% angles = zeros(N,1);
% for i = 1:size(archSpiral.coords,1)-1
%     point1 = archSpiral.coords(i,:);
%     point2 = archSpiral.coords(i+1,:);
%     tanTheta = (point2(2)-point1(2))/(point2(1)-point1(1));
%     angles(i) = real(atand(tanTheta));
% end
% angles(N) = angles(N-1);
% 
% negAngleI = angles < 0;
% angles(negAngleI) = angles(negAngleI) + 180;
% 
% archSpiral.angles = angles;
% 
% [spiralTh,spiralR] = cart2pol(archSpiral.coords(:,1),archSpiral.coords(:,2));
% spiralTh = rad2deg(spiralTh);
% archSpiral.theta = standardPolarToVisual(spiralTh);
% archSpiral.radius = spiralR;

end

%calculate the value of the next theta so all points are equidistant 
function theta2 = thetaStep(theta1,a,b,d)

theta2 = theta1 + 2*asin(d / (2*(a+b*theta1)));

end