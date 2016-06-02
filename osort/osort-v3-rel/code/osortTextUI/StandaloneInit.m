
%
%does detection standalone
%prewhiten: 0/1. prewhiten of the raw signal,before extraction of spikes.
%alignMethod: 1 (pos), 2 (neg), 3 (mixed)
%
%
function handles = StandaloneInit( handles , tillBlocks, prewhiten, alignMethod,includeRange )

handles = initFilter(handles);
%read timestamps
[timestamps,nrBlocks,nrSamples,~,~,headerInfo] = getRawTimestamps( handles.rawFilename, handles.rawFileVersion );
handles.nrSamples=nrSamples;

if length(headerInfo)>0
    ADbitVolts = str2num(getNumFromCSCHeader(headerInfo, 'ADBitVolts'));
else
    ADbitVolts = nan;  %undefined
end
    

%old ret params: sampleFreq,isContinous,headerInfo
%sessionDuration=(timestamps(end)-timestamps(1))/1000;

%detection
paramsRaw.howManyBlocks = tillBlocks;
paramsRaw.startWithBlock = 1;
paramsRaw.includeRange = includeRange;
paramsRaw.prewhiten = prewhiten;
paramsRaw.alignMethod = alignMethod;

paramsRaw = copyStructFields(handles,paramsRaw, { {'paramExtractionThreshold','extractionThreshold'}, ...
    'rawFilePrefix','rawFilePostfix', 'doGroundNormalization', 'normalizationChannels', 'pathRaw', 'limit', 'samplingFreq', 'rawFileVersion', 'detectionMethod', 'detectionParams', 'peakAlignMethod'});

if isfield(handles,'rawFilePrefix')
    paramsRaw.prefix = handles.rawFilePrefix;
end
%paramsRaw.extractionThreshold = handles.paramExtractionThreshold;
%paramsRaw.doGroundNormalization = handles.doGroundNormalization;
%paramsRaw.normalizationChannels = handles.normalizationChannels;
%paramsRaw.pathRaw = handles.pathRaw;
%paramsRaw.limit = handles.limit;
%paramsRaw.samplingFreq = handles.samplingFreq;
%paramsRaw.rawFileVersion = handles.rawFileVersion;
%paramsRaw.detectionMethod=handles.detectionMethod;
%paramsRaw.detectionParams=handles.detectionParams;
%paramsRaw.peakAlignMethod=handles.peakAlignMethod;

[allSpikes, allSpikesNoiseFree, allSpikesCorrFree, allSpikesTimestamps, dataSamplesRaw,filteredSignal, rawMean,rawTraceSpikes,runStd2,upperlim, ...
    stdEstimates, blocksProcessed, noiseTraces] = processRaw(handles.rawFilename, handles.nrSamples, handles.Hd, paramsRaw );

%save returned values
handles.blocksProcessedForInit=blocksProcessed;
handles.dataSamplesRaw=dataSamplesRaw;
handles.rawMean=rawMean;
handles.rawTraceSpikes=rawTraceSpikes;
handles.runStd2=runStd2;
handles.upperlim=upperlim;
handles.filteredSignal=filteredSignal;
handles.noiseTraces=noiseTraces;

%estimate s.d. of raw signal
handles.stdEstimateOrig = calculateStdEstimate(stdEstimates); %mean(stdEstimates);
['std estimate is ' num2str(handles.stdEstimateOrig)]

handles.allSpikesNegative=allSpikes;
handles.allSpikesTimestampsNegative=allSpikesTimestamps;
handles.newSpikesNegative=allSpikes;
handles.newSpikesTimestampsNegative=allSpikesTimestamps;
handles.spikesSolvedNegative=allSpikes;
handles.allSpikesNoiseFree=allSpikesNoiseFree;
handles.allSpikesCorrFree=allSpikesCorrFree;

%for compatibility reasons
handles.allSpikesPositive=[];
handles.allSpikesTimestampsPositive=[];
handles.newSpikesPositive=[];
handles.newSpikesTimestampsPositive=[];
handles.spikesSolvedPositive=[];

%New: also store the scaling factor
handles.scalingFactor = ADbitVolts;

handles.stdEstimate = handles.stdEstimateOrig*handles.correctionFactorThreshold;
['std estimate corrected is ' num2str(handles.stdEstimate)]

'init finished'
