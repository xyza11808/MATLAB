%
%erases spurious spikes that dont have a sufficient overshoot
%
%
%
function [newSpikes,newTimestamps, didntPass] = postDetectionFilter( allSpikes, allTimestamps)

toKeep=zeros(1,size(allSpikes,1));

for i=1:size(allSpikes,1)
    currentSpike = allSpikes(i,:) ;    
    
    if abs(min(currentSpike)) >= 0.3* max(currentSpike)
            toKeep(i)=1;
    end
    
end




newSpikes=allSpikes( find(toKeep), :);
newTimestamps=allTimestamps(find(toKeep));

didntPass=allSpikes( find(toKeep==0),:);