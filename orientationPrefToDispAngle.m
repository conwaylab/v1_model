function angle = orientationPrefToDispAngle(orientationPrefs)
angle = zeros(size(orientationPrefs));
for i = 1:numel(orientationPrefs)
    if orientationPrefs(i) < 90
       angle(i) = orientationPrefs + 90;
    else
       angle(i) = orientationPrefs - 90;
    end
end

end