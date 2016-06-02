%
%finds all timestamps that belong to a specific neuron,based on ground
%truth.
%
%
function inds = findAllOrigTimestamps ( origTimestampsOfClass,spikeTimestamps)
tollerance=30;  %allow 15 datasamples jitter due to re-sampling,re-alignment etc

inds=[];


for j=1:length(origTimestampsOfClass) 
    origValue = origTimestampsOfClass(j);
    ind = find( origValue-tollerance < spikeTimestamps & spikeTimestamps < origValue+tollerance );
    if length (  ind )  == 1
        inds=[inds ind(1)];
    else
        if length(ind)>1
        %[ind origValue spikeTimestamps(ind)]    
        end
    end
end