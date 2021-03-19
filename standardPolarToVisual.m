function visAngles = standardPolarToVisual(polAngles)
visAngles = zeros(size(polAngles));
for i = 1:numel(polAngles)
    if polAngles(i) < -90
       visAngles(i) = 90 - polAngles(i) - 360;
    else
        visAngles(i) = 90 - polAngles(i);
    end
end

end