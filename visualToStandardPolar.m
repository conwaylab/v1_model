function polAngles = visualToStandardPolar(visAngles)
polAngles = zeros(size(visAngles));
for i = 1:numel(visAngles)
    if visAngles(i) < -90
       polAngles(i) = 90 - visAngles(i) - 360;
    else
        polAngles(i) = 90 - visAngles(i);
    end
end

end