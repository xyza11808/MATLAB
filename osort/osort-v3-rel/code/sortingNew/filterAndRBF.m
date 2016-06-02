%
%does realignment at maximum, performs various tests before/after filtering
%to exclude spurious waveforms and converts to RBF representation.
%
%allSpikes: waveforms
%allTimestamps: timestamps for this waveforms
%stdEstimate: estimate of std of raw signal
%
%type 1(positive), 2(negative)
function [spikesSolved, newSpikes, newTimestamps] = filterAndRBF(allSpikes,allTimestamps,stdEstimate,type)


[newSpikes,newTimestamps,didntPass] = postDetectionFilter( allSpikes, allTimestamps);
[newSpikes,newTimestamps] = realigneSpikes(newSpikes, newTimestamps,type);


%--> uncomment following lines to activate RBF convertion (for very noisy
%data)
%'convert to RBF'
%[spikesRBF, spikesSolved] = RBFconv( newSpikes );
%'realign'
%newTimestampsOrig=newTimestamps;
%[spikesSolved,newTimestamps] = realigneSpikes(spikesSolved, newTimestamps);


%if following two lines are uncommented --> RBF usage is DEACTIVATED
spikesSolved=newSpikes;
%newTimestamps=newTimestampsOrig;

%remove spikes which are still not max-realigned and once which start not
%at 0


toKeep=zeros(1,size(spikesSolved,1));
for i=1:size(spikesSolved,1)
    if max(abs(spikesSolved(i,1:10)))<4*stdEstimate 
        toKeep(i)=1;
    end
end
['post-RBF filter removing # waveforms : ' num2str(length(find(toKeep==0)))]

spikesSolved=spikesSolved( find(toKeep==1), :);

newSpikes=newSpikes( find(toKeep==1), :);

newTimestamps=newTimestamps(find(toKeep==1));
