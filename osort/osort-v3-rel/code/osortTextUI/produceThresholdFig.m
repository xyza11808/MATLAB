%
%produces a figure showing the number spikes found as a function of different thresholds.
%this figure can be used to find the optimal extraction threshold btw the limit between SUA/MUA
%
%urut/nov06
function handles = produceThresholdFig( handles , figPath, thresholds )
if exist(figPath)==0
    mkdir(figPath);
end
disp('producing threshold figure...');

handles = initFilter(handles);

[timestamps,nrBlocks,nrSamples,sampleFreq,isContinous,headerInfo] = getRawCSCTimestamps( handles.rawFilename );
handles.nrSamples=nrSamples;

%display some statistics about this file
headerInfo

paramsRaw.howManyBlocks = handles.howManyBlocks;
paramsRaw.startWithBlock = 1; 
paramsRaw.includeRange = handles.includeRange;
paramsRaw.prewhiten = handles.prewhiten;
paramsRaw.alignMethod = handles.alignMethod;
paramsRaw.doGroundNormalization = handles.doGroundNormalization;
paramsRaw.normalizationChannels = handles.normalizationChannels;
paramsRaw.pathRaw = handles.pathRaw;

nrSpikesFound=[];
for i=1:length(thresholds)
    paramsRaw.extractionThreshold = thresholds(i);

    [allSpikes, allSpikesNoiseFree, allSpikesCorrFree, allSpikesTimestamps, dataSamplesRaw,filteredSignal, rawMean,rawTraceSpikes,runStd2,upperlim,stdEstimates, blocksProcessed, noiseTraces, dataSamplesRawUncorrected ] = processRaw(handles.rawFilename, handles.nrSamples, handles.Hd, paramsRaw);

    nrSpikesFound(i) = size(allSpikes,1);
end

%produce figure
figure(888);
subplot(2,2,1)
plot( thresholds, nrSpikesFound, 'x-');
title([handles.prefix handles.from]);
xlabel('Threshold');
ylabel('nr spikes detected');
subplot(2,2,2)
plot( thresholds(2:end), diff(nrSpikesFound), 'x-');
ylabel('first derivative');
subplot(2,2,3)
plot( thresholds(3:end), diff(diff(nrSpikesFound)), 'x-');
ylabel('second derivative');
subplot(2,2,4)
slopes= (nrSpikesFound(1:end-1)./nrSpikesFound(2:end))-1;
plot( thresholds(2:end), slopes,'rx-');
ylabel('slope of nr spikes');

scaleFigure;
print(gcf,'-dpng',[figPath handles.prefix handles.from '_Thresholds.png' ]);
close(gcf);



