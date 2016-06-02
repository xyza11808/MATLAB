%merges similar mean waveforms of different clusters.
%
%minClustSize: min number of spikes that need to be associated to a cluster
%for it to be considered a mean waveform
%
%
%returns:
%meanWaveforms: mean waveforms of top clusters
%meanClusters: merged mean waveforms
%
%
%
function [meanWaveforms,meanClusters,meanClustersToConsider] = createMeanWaveforms( nrSpikes, meanSpikeForms, rankedClusters, thres, minClustSize)

meanWaveforms = [];

%find all mean clusters such that 80% are covered; max 20

percentageCovered=.90;
for meanClustersToConsider=1:size(meanSpikeForms,1)
    
    ind=size(rankedClusters,1)-meanClustersToConsider;
    if ind<1
        ind=1;
    end
    
    if (sum(rankedClusters(ind:end,2)) >= percentageCovered * nrSpikes || rankedClusters(ind,2)<=minClustSize)
        break;
    end
end

meanClustersToConsider

nrAssigned=[];
for i=1:meanClustersToConsider
    meanWaveforms(i,:) = meanSpikeForms( rankedClusters(end+1-i,1), : );
    nrAssigned(i) = rankedClusters(end+1-i,2);
end

nrAssigned
nrSpikes

%
%meanWaveforms -> is ordered according to rank.
%
%

%6. merge mean clusters, according to order
success=true;
meanClusters=meanWaveforms;
loops=1;
while success && loops<10000
    [meanClusters,success] = clusterMeans(meanClusters, nrAssigned, thres);
    loops=loops+1;
end

