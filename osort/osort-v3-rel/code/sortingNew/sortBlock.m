%
%sorts a block of spikes
%
%-------------------------
%inputs:
%allSpikes: block of spikes, 256 datapoints each
%
%allTimestamps: timestamp for each spike. arbitrary units.
%
%returns:
%NrOfclustersFound
%
%assignedCluster: for each spike, which cluster # (clusters are arbitrarly
%numbered)
%
%meanSpikeForm: mean spike for every cluster
%
%rankedClusters: sorts (ascending) clusters according to nr of spikes
%associated. first column=cluster nr, second column=nr of spikes
%associated.
%
%%urut/april04
function [NrOfclustersFound, assignedCluster, meanSpikeForms, rankedClusters ] = sortBlock(allSpikes, allTimestamps, thres)

%cluster positive spikes
[NrOfclustersFound, assignedCluster] = clusterSpikes( allSpikes, allTimestamps, thres );

meanSpikeForms = getMeanSpikeForms(allSpikes, assignedCluster, NrOfclustersFound );

elementsInCluster=zeros(NrOfclustersFound,2 );
for i=1:NrOfclustersFound
    elementsInCluster(i,1) = i;
    elementsInCluster(i,2) = length( find(assignedCluster==i) );
end
rankedClusters = sortrows( elementsInCluster, 2);

