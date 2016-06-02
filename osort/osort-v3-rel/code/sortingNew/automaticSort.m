function automaticSort(basepath, filenameIn)


cd(basepath)
in=[basepath filenameIn '_spikes_unsorted.mat'];
'opening:'
in
load(in);


newSpikesPositive=[];
newSpikesNegative=[];
newTimestampsPositive=[];
newTimestampsNegative=[];
assignedPositive=[];
assignedNegative=[];
usePositive=[];
useNegative=[];


for j=1:2
    allSpikes=[];
    allTimestamps=[];
    
    if j==1
        %positive
	    allSpikes=OKspikesPositive;
	    allTimestamps=OKtimestampsPositive;
    else
        %negative
	    allSpikes=OKspikesNegative*-1;
	    allTimestamps=OKtimestampsNegative;
    end
	
	[newSpikes,newTimestamps,didntPass] = postDetectionFilter( allSpikes, allTimestamps);
	newSpikes = realigneSpikes(newSpikes);
	
	'convert to RBF'
	[spikesRBF, spikesSolved] = RBFconv( newSpikes );
	spikesSolved = realigneSpikes(spikesSolved);
	
	%6. calculate threshold
	x=1:size(spikesSolved,2);
	[weights,weightsInv] = setDistanceWeight(x);
	globalMean = mean(spikesSolved);
	globalStd  = std(spikesSolved);
	initialThres = ((globalStd.^2)*weights)/256;
	
	'find mean clusters'
	[NrOfclustersFound, assignedCluster, meanSpikeForms, rankedClusters ] = sortBlock(spikesSolved, newTimestamps, initialThres);
	
	
	%8. merge mean clusters
	[meanWaveforms,meanClusters] = createMeanWaveforms( size(spikesSolved,1), meanSpikeForms, rankedClusters, initialThres);
	
	'assign'
	
	%9. now re-cluster, using this new mean waveforms
	[assignedCluster, rankedClusters ] = assignToWaveform(spikesSolved, newTimestamps, meanClusters, initialThres);


    if j==1 
        %positive
        newSpikesPositive=newSpikes;
        newTimestampsPositive=newTimestamps;
        assignedPositive=assignedCluster;
    else
        %negative    
        newSpikesNegative=newSpikes;
        newTimestampsNegative=newTimestamps;
        assignedNegative=assignedCluster;        
    end
end

%--store
'store'
save([basepath filenameIn '_spikes_sorted.mat'], 'newSpikesPositive', 'newSpikesNegative', 'newTimestampsPositive', 'newTimestampsNegative','assignedPositive','assignedNegative', 'usePositive', 'useNegative');
