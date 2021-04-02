function response = orientationResponseMagnitude(idealAngle,stimAngle)

baselineResponse = 0.5*cosd(2*(stimAngle-idealAngle)) + 0.5;

% response = abs(baselineResponse + normrnd(0,sigma));
response = baselineResponse;

x = linspace(0,180,720);
y = 0.5*cosd(2*x) + 0.5;

end

