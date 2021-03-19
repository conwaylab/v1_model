function [offWinResponse,onWinResponse] = responseWindows(offResponses,onResponses,...
    windowInds)

numIter = size(offResponses,2);

offWinResponse = zeros([size(windowInds),numIter]);
onWinResponse = zeros([size(windowInds),numIter]);
for i = 1:size(windowInds,2)
    for j = 1:numIter
        offWinResponse(:,i,j) = offResponses(windowInds(:,i),j);
        onWinResponse(:,i,j) = onResponses(windowInds(:,i),j);
    end
end

end