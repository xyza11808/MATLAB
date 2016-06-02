%
%evaluates a spike detection method for a particular noise level and extraction threshold of the simulated data.
%
%returns:
%TP: true positives rate
%FP: false positives rate
%misses: how many were not found
%spikeWaveforms/spikeTimestamps: all detected waveforms and their time of occurence
%hits: which of the detected waveforms are hits (TPs)
%alignErrors: time estimation errors for all hits
%
%urut/april07
function [TP,FP,misses, nrSpikesTotal, nrSpikesFound, spikeWaveforms, hits, spikeTimestamps, alignErrors] = evalDetectionSimulated( simNr, levelNr,  params )

%load raw data
loadSimulationFiles;

%detect spikes
spiketrainDown=spiketrains{levelNr};
noiseStd=noiseStds(levelNr);

if simNr==4
    lengthLim=25000*100; %Xs
    %cut length
    spiketrainDown=spiketrainDown(1:lengthLim);
    for i=1:length(spiketimes)
       tmp=spiketimes{i};
       spiketimes{i}=  tmp( find(tmp<lengthLim));
    end
end

%add some white noise
whiteNoise=0; %noiseStd/10;
spiketrainDown=spiketrainDown + randn(1,length(spiketrainDown))*whiteNoise;

[filteredSignal, rawTraceSpikes,spikeWaveforms, spikeTimestamps, runStd2,upperlim,noiseTraces] = detectArtificialSpikes( spiketrainDown, params ) ;

%evaluate how well the extraction was done
nrSpikesFound = length( spikeTimestamps );
nrSpikesTotal=0;
for i=1:length(spiketimes)
    nrSpikesTotal=nrSpikesTotal+length(spiketimes{i});
end

tollerance=30;  %allow jitter due to re-sampling,re-alignment etc
[trueDetections, falseDetections, misses, hits] = evalSimulatedPerfDetection( spiketimes, spikeTimestamps, tollerance );

TP=sum(trueDetections);
FP=falseDetections;

%determine alignment errors made
alignErrors = evalSimulatedAlignPerf( spiketimes, spikeTimestamps, hits );