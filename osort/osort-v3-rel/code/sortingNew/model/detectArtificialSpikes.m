%
%detect spikes from simulated spiketrain
%
%params: fields detectionMethod/detectionParams/peakAlignMethod -> see header of extractSpikes.m for explanation
%
%initial:
%urut/dec05
%updates:
%urut/april07, updated for new calling syntax of extractSpikes
%
function [filteredSignal, rawTraceSpikes,spikeWaveforms, spikeTimestamps, runStd2,upperlim,noiseTraces] = detectArtificialSpikes( spiketrainDown, params ) 
filteredSignal=[];
rawTraceSpikes=[];
spikeWaveforms=[];
runStd2=[];
upperlim=[];
noiseTraces=[];

rawSignal = spiketrainDown';

%setup filter
n = 4;  %order of filter
Wn = params.bandPass/(params.samplingFreq/2);
[b,a] = butter(n,Wn);
HdNew=[];
HdNew{1}=b;
HdNew{2}=a;

%process the raw data in blocks
blockSize=100*params.samplingFreq; %100s
nrBlocks=ceil(length(rawSignal)/blockSize);

spikeTimestamps=[];
spikeWaveforms=[];
for i=1:nrBlocks
    disp(['processing block ' num2str(i)]);
    tic
    
    from=(i-1)*blockSize+1;
    to=i*blockSize;
    
    if to>length(rawSignal)
        to=length(rawSignal);
    end
    if to-from<params.samplingFreq/2  %dont process if too short block (half second)
        continue;
    end
    
    [rawMean, filteredSignal, rawTraceSpikes,spikeWaveformsTmp, spikeTimestampsTmp, runStd2, upperlim, noiseTraces] = extractSpikes(rawSignal(from:to), HdNew, params);

    spikeWaveforms = [ spikeWaveforms; spikeWaveformsTmp ];
    spikeTimestamps = [ spikeTimestamps spikeTimestampsTmp+(i-1)*blockSize ];
    
    toc
end