%
%sweep a parameter and calculate spike detection performance for simulated
%datasets.
%
%inputs:
%data: raw data where spikes are to be detected
%Hd: filter to be applied
%params: parameters for spike detection
%spiketimesSimulated: ground truth, as simulated
%tollerance: nr samples of tollerance to match spikes
%
%uses parfor to automatically spawn in parallel using parallel computing
%toolbox.
%
%
%urut/aug11
function [TPs,FPs, nrSpikesFound, nrSpikesExist] = benchmarkSpikedetection_sweepParams ( data, Hd, tollerance, params, spiketimesSimulated, paramNr, paramValues )

TPs=[];
FPs=[];

%pool all spikes
spiketimesAll = [];
for k=1:length(spiketimesSimulated)
    spiketimesAll = [ spiketimesAll spiketimesSimulated{k} ];
end

tstart1=tic;
parfor k=1:length( paramValues)
    
    paramsNew=[];
    paramsNew = benchmarkSpikedetection_sweepParams_assignParam( params, paramNr, paramValues(k) );
    disp(['running: ' num2str(paramValues(k)) ]);

    disp(['Running param value ' num2str(paramValues(k))]);
    
    [rawMean, filteredSignal, rawTraceSpikes,spikeWaveforms, spikeTimestamps, runStd2, upperlim, noiseTraces] = extractSpikes( data, Hd, paramsNew );
    
    
    nrSpikesFound(k) = length( spikeTimestamps );
    nrSpikesExist(k) = length(spiketimesAll);
    
    [trueDetections, falseDetections, misses, hits] = evalSimulatedPerfDetection( spiketimesSimulated, spikeTimestamps, tollerance );
    
    TPs(k) = sum(trueDetections)/length(spiketimesAll);
    FPs(k) = falseDetections / length(spikeTimestamps);

end

tocWithMsg( 'time for _sweepParams: ', tstart1);

