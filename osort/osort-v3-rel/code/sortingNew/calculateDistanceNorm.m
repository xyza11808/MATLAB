%
%norm as distance measurements (if whitened). takes all whitened spikes of
%two clusters and calculates the distance in terms of standard deviations
%(projection test).
%
%spikes: whitened spikes
%baseClusters: all baseclusters
%baseSpikesID: mapping of IDs to basecluster indexes
%toID: id of to cluster
%assigned: to which cluster is each spike assigned
%
%urut/nov05
function [diffs] = calculateDistanceNorm(spikes, baseClusters, baseSpikesID, toID, assigned)
n=size(baseClusters,1);
diffs=zeros(n,1);
mTo = mean( spikes( find(assigned==toID),: ) );
for i=1:n
        fromID = baseSpikesID(find(baseSpikesID(:,2)==i),1);
        mFrom =  mean( spikes( find(assigned==fromID),: ) );
        diffs(i) = norm(mFrom - mTo);
end




