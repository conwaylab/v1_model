function response = sigmaResponseMagnitude(d,sigma)

normpdfPeak = normpdf(0,0,sigma);
response = normpdf(d,0,sigma)/normpdfPeak;

end