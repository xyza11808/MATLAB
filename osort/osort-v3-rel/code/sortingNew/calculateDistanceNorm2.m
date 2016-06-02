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
function [diffs] = calculateDistanceNorm2(baseClusters, mTo)
n=size(baseClusters,1);
diffs=zeros(n,1);
for i=1:n
        mFrom =  baseClusters(i,:);
        diffs(i) = norm(mFrom - mTo);
end




