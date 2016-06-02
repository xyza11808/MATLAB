%
%produces a figure of the raw data traces and saves it in a file 
%
%urut/feb05
%
function handles = produceRawTraceFig( handles , figPath, outputFormat)
if exist(figPath)==0
    mkdir(figPath);
end

%get timestamps and header info
handles = initFilter(handles);
[timestampsRaw, nrBlocks,nrSamples,sampleFreq,isContinous,headerInfo] = getRawTimestamps( handles.rawFilename, handles.rawFileVersion );
handles.nrSamples=nrSamples;
if length(headerInfo)>0
    %tmp=headerInfo(15);
    %ADbitVolts = str2num(tmp{1}(14:end));
    
    ADbitVolts = str2num(getNumFromCSCHeader(headerInfo, 'ADBitVolts'));
else
    ADbitVolts = 1;
end

%display some statistics about this file
headerInfo

[nrRunsTotal] = determineBlocks( nrSamples );

if min(handles.blockNrRawFig)>nrRunsTotal
	warning('requested block not available - file shorter than block nr');
end

%read raw data
tillBlocks=handles.blockNrRawFig;
for k=1:length(tillBlocks)
    paramsRaw.howManyBlocks = tillBlocks(k);
    paramsRaw.startWithBlock = tillBlocks(k); %only need to read this one block,so start there.
    paramsRaw.includeRange=[];
    %since we arent interested in spikes,following 2 params dont matter for this task
    paramsRaw.prewhiten = 0;
    paramsRaw.alignMethod=1;
    
    paramsRaw = copyStructFields(handles,paramsRaw,{{'paramExtractionThreshold','extractionThreshold'}, ...
        'doGroundNormalization','normalizationChannels', 'pathRaw', 'limit', 'samplingFreq', 'rawFileVersion', 'detectionMethod', 'detectionParams', ...
        'peakAlignMethod'});
    
    if isfield(handles,'rawFilePrefix')
        paramsRaw.prefix=handles.rawFilePrefix;
    end
    paramsRaw.rawFilePostfix = handles.rawFilePostfix;
    [allSpikes, allSpikesNoiseFree, allSpikesCorrFree, allSpikesTimestamps, dataSamplesRaw,filteredSignal, rawMean,rawTraceSpikes,runStd2,upperlim,stdEstimates, blocksProcessed, noiseTraces, dataSamplesRawUncorrected, blockOffsets ] = processRaw(handles.rawFilename, handles.nrSamples, handles.Hd, paramsRaw);

    %scale if ADbitVolts value is available
    if ADbitVolts~=1
        filteredSignal=filteredSignal*ADbitVolts*1e6; %convert to uV
        dataSamplesRaw = dataSamplesRaw *ADbitVolts*1e6;
        rawTraceSpikes = rawTraceSpikes * ADbitVolts*1e6;
    end

    
    % filter raw signal for illustration purposes (if it is full-band). only enable for debugging
    
    enableBroadbandFilt = 0;
    if enableBroadbandFilt
        n = 4;
        Wn = [2]/(handles.samplingFreq/2);
        [b,a] = butter(n,Wn,'high');
        HdNew=[];
        HdNew{1}=b;
        HdNew{2}=a;
        filteredSignal_broadband = filterSignal( HdNew, dataSamplesRaw );
        dataSamplesRaw = filteredSignal_broadband;  %use the filtered version instead (for display purposes only)
    end
    
    figure(888);
    close(gcf);   % make sure its closed if it already exists
    figure(888);
    
    if ~isfield(handles,'plotLimit')
        handles.plotLimit=[1 10]; %in sec
    end
    
    plabel=[handles.prefix handles.from ' B' num2str(tillBlocks(k)) ' T=' num2str(handles.paramExtractionThreshold) ' Fs=' num2str(sampleFreq)];
    
    plotSpikeExtraction(plabel,dataSamplesRaw, dataSamplesRawUncorrected, rawMean, filteredSignal, rawTraceSpikes, runStd2, upperlim, handles.plotLimit, paramsRaw.samplingFreq, handles, allSpikesTimestamps, blockOffsets, ADbitVolts);
    title(['ADBitsPerVolt ' num2str(ADbitVolts)]);

    scaleFigure;
    
    figNameOut=[figPath handles.prefix handles.from '_B' num2str(tillBlocks(k)) '_L' num2str(handles.plotLimit(2)) '_RAW.' outputFormat ];
    try
        if outputFormat=='fig'
            disp(['Export FIG: ' figNameOut]);
            saveas(gcf, figNameOut );
        else
            print(gcf, ['-d' outputFormat], figNameOut );
        end
    catch
        disp('error occured -- see above');
        keyboard;
    end
    
    if isfield(handles,'displayFigures')
        displayFigures=handles.displayFigures;
    else
        %default is close after export to file
        displayFigures=0;
    end
    
    if ~displayFigures
        close(gcf);
    end
end


