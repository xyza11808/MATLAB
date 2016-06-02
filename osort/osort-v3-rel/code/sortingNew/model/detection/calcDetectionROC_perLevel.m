%loops over extraction thresholds; all other values are constant.
%calculate TP/FP of detection for a particular noise levels and all provided thresholds
%
%inputs:
%simNr -> simulation number
%levelNr -> noise level
%thresholds -> array of all thresholds to use
%
%returns:
%all (see below); one row per threshold
%TPall/FPall : normalized TP/FP
%waveforms/times: all detected waveforms and their time of occurence
%hits: which of the detected waveforms are hits (TPs)
%alignErrors: time estimation errors for all hits
%
function [all, TPall, FPall, waveforms,hits, times, alignErrors] = calcDetectionROC_perLevel(simNr, levelNr, thresholds, params )
waveforms=[];
all=[]; %TP FP misses spikestotal spikesfound threshold
for i=1:length(thresholds)
    params.extractionThreshold = thresholds(i);
    
    [TP,FP,misses, nrSpikesTotal, nrSpikesFound, spikeWaveformsTmp, hitsTmp, timesTmp,alignErrorsTmp] = evalDetectionSimulated( simNr, levelNr,  params);
    
    waveforms{i} = spikeWaveformsTmp;
    hits{i}=hitsTmp;
    times{i}=timesTmp;
    alignErrors{i}=alignErrorsTmp;
    
    all(i,:) = [ TP FP misses nrSpikesTotal nrSpikesFound params.extractionThreshold];
end

%normalize
TPall = all(:,1) ./ all(:,4); %relative to theoretically inserted spikes
FPall = all(:,2) ./ all(:,5); %relative to all spikes found
