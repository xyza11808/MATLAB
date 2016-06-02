%spiketimes is ground truth (from simulation)
%spikeTimestamps is what the algorithm detected
%hits: which waveforms were TPs
%
%returns: alignErrors -> has one entry for each hit. difference in timesteps between detected and ground truth timestamp.
%
%
%urut/april06
function alignErrors = evalSimulatedAlignPerf( spiketimes, spikeTimestamps, hits )
alignErrors=[];

for j=1:size(hits,1)
    indFound=hits(j,1);
    indClass=hits(j,2);
    indSpike=hits(j,3);
    
    orig = spiketimes{indClass}(indSpike);
    found = spikeTimestamps( indFound );
    
    alignErrors(j) = orig-found;
end