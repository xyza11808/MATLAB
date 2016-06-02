%
%calculates performance of sorting algorithm by comparing to ground truth
%
%was previously part of plotGeneratedSpiketrain.m
%
%spikeTimestampsDetected: detected spikes from sorting
%spiketimesSimulated: ground truth
%
%reorder: mapping of cluster numbers
%nrAssigned: mapping of cluster numbers to how many were found in this
%cluster
%assigned: mapping of each spike to its assigned cluster number
%
%nrAssigned has two columns, first column is the cluster nr, second column
%is the nr of spikes assigned to this cluster. it is sorted according to
%cluster size, ascending. It is returned by sortSpikesOnline.m
%
%urut/nov05
function [perf, indsNoiseWaveforms, trueDetections, falseDetections, misses ] = evalPerformance(nrNeurons, spikeTimestampsDetected, spiketimesSimulated, reorder, nrAssigned, assigned)

%tolerance=15;  %allow 15 datasamples jitter due to re-sampling,re-alignment etc

% tolerance in us

tolerance=5000;  %make relatively large,because some simulations were made with timestamps that dont take into account new alignment scheme

[trueDetections, falseDetections,misses] = evalSimulatedPerfDetection( spiketimesSimulated, spikeTimestampsDetected, tolerance );
detected=trueDetections;

indsNoiseWaveforms=[];

perf=[]; %TP FP Misses
for i=1:nrNeurons

        
    
    indsOfNeuron = find( nrAssigned(end-reorder(2,i)+1,1)==assigned);
    
    timestampsOfClass = spikeTimestampsDetected( indsOfNeuron );
    origTimestampsOfClass = spiketimesSimulated{i};
    %origWaveformsOfClass = waveformsOrig{i};
    
    %origTimestampsOfClass = origTimestampsOfClass(100:end);  %discard first X (=initialization)
    
    %plot( 20:240,origWaveformsOfClass' ,colors{i});
    
    [detected(i) length(find( nrAssigned(end-reorder(2,i)+1,1)==assigned))];
    
    
    %find TP and misses
    TP=0;
    indsTP=[];
    FN=0;
    for j=1:length(origTimestampsOfClass) 
        origValue = origTimestampsOfClass(j);
        ind = find( origValue-tolerance < timestampsOfClass & timestampsOfClass < origValue+tolerance );
        if length (  ind > 0 )
            TP=TP+1;
            indsTP=[indsTP ind(1)];
        else
            FN=FN+1;
        end
    end
    
    %find FP
    indsFP = setdiff(1:length(timestampsOfClass),indsTP);
    
    FPotherClusters=0;

    %split up: which of those belong to an other cluster or are noise?
    for j=1:length(indsFP)
       origValue=timestampsOfClass(indsFP(j));  %point of time this misssorted spike occured
       
       foundInOtherCluster = false;
       for k=1:nrNeurons
           IndAlreadyUsedNeuron=[];
           
           %don't test against own neuron
           if k==i
               continue;
           end

           origTimestampsOfOtherClass = spiketimesSimulated{k};
           
           ind = find( origValue-tolerance < origTimestampsOfOtherClass & origTimestampsOfOtherClass < origValue+tolerance );
           if length (  ind > 0 )
              %assigned to the wrong cluster
              FPotherClusters=FPotherClusters+1; 
              IndAlreadyUsedNeuron = [ IndAlreadyUsedNeuron ind ];
              foundInOtherCluster = true;
              break;
           end
       end
       
       if foundInOtherCluster==false
        %caused by noise  
        indsOfNeuron(indsFP(j));
        
        indsNoiseWaveforms(length(indsNoiseWaveforms)+1)  = indsOfNeuron ( indsFP(j) );
       end

              
    end
    
    FP=length(indsFP);
    FPnoise = FP - FPotherClusters;

        
    missAlignedStat(i)=0;
    
    nrAssignedToCluster = length(find( nrAssigned(end-reorder(2,i)+1,1)==assigned));
    
    perf(i,:)=[size(origTimestampsOfClass,2) detected(i) missAlignedStat(i)  detected(i)-missAlignedStat(i) TP FP FPnoise FPotherClusters detected(i)-TP nrAssignedToCluster];
end

%perf(:,10) = perf(:,5)./perf(:,4);
%mean(perf(:,10))