%
%processes a block of spikes (after detection) and returns the threshold
%for clustering and the mean waveforms for assigning individual spikes to
%clusters.
%
%inputs:
%spikes
%timestamps
%stdEstimate: estimate of std of filtered raw signal (for threshold
%calculation)
%
%minClustSize: min number of spikes that need to be associated to a cluster
%for it to be considered a mean waveform
%
%
%urut/april04
function [meanWaveforms,meanClusters, initialThres] = findInitialMeanWaveforms(allSpikes, allTimestamps, stdEstimate, minClustSize)





%initialThres = stdEstimate*^2;

initialThres = getThreshold(allSpikes, stdEstimate );


'find mean clusters'
[NrOfclustersFound, assignedCluster, meanSpikeForms, rankedClusters ] = sortBlock(allSpikes, allTimestamps, initialThres);
	
	
%8. merge mean clusters
[meanWaveforms,meanClusters] = createMeanWaveforms( size(allSpikes,1), meanSpikeForms, rankedClusters, initialThres, minClustSize);


%meanClusters contains merged mean waveforms


