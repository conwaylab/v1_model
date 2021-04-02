function response = sigmaResponseMagnitude(d,sigma)

normpdfPeak = normpdf(0,0,sigma);
response = normpdf(d,0,sigma)/normpdfPeak;

x = linspace(-1,1,100);
for i = 1:numel(x)
    y(i) = normpdf(x(i),0,sigma);
end

end