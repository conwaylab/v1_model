%right now I don't think that points are spaced equally, but that's okay
%for now since they are closer near the center, which corresponds to fovea

% a controls how large the spiral is
% b controls how tightly the spiral is wound
function logSpiral = logSpiral(th,b,a,center)

shifts = [0,45,90,135,180,225,270,315];
theta = zeros(length(shifts),length(th));
r = zeros(size(theta));
x = zeros(size(theta));
y = zeros(size(theta));

for i = 1:length(shifts)
   theta(i,:) = mod(th+shifts(i),360); 
   theta(i,:) = deg2rad(theta(i,:));
   r(i,:) = exp(b*theta(i,:)) * a;
   [x(i,:),y(i,:)] = pol2cart(deg2rad(th),r(i,:));
end

coords = cat(3,x,y);

angles = zeros(length(shifts),length(th));
for i = 1:length(shifts)
    for j = 1:size(coords,2)-1
        point1 = squeeze(coords(i,j,:));
        point2 = squeeze(coords(i,j+1,:));
        tanTheta = (point2(2)-point1(2))/(point2(1)-point1(1));
        angles(i,j) = real(atand(tanTheta));
    end
    angles(i,size(coords,2)) = angles(i,size(coords,2)-1);
end

negAngleI = angles < 0;
angles(negAngleI) = angles(negAngleI) + 180;

logSpiral.coords = reshape(coords,[],2);
logSpiral.coords = logSpiral.coords + center;
logSpiral.angles = reshape(angles,[],1);

[spiralTh,spiralR] = cart2pol(logSpiral.coords(:,1),logSpiral.coords(:,2));
spiralTh = rad2deg(spiralTh);
logSpiral.theta = standardPolarToVisual(spiralTh);
logSpiral.radius = spiralR;
logSpiral.center = center;

end