%
%main functions for unsupervised sorting. this function is called by 
%either the UI or by a script.
%
%urut/may07
function StandaloneGUI(paths, filesToProcess, thres, normalizationChannels, paramsIn)
starttime=clock;

timeSortingStats=[]; %i time nrSpikesSorted
timeDetectionStats =[];%i time duration(in blocks of 512000 samples)


%set prefix of raw data files and result files
rawFilePrefix = copyFieldIfExists( paramsIn, 'rawFilePrefix', 'A' );
processedFilePrefix = copyFieldIfExists( paramsIn, 'processedFilePrefix', 'A' );

pathOutOrig=paths.pathOut;
for kkk=1:length(filesToProcess)
    i = filesToProcess(kkk);
    currentThresInd=kkk;

    handles=[];
    handles.correctionFactorThreshold=0;  %minimal threshold, >0 makes threshold bigger
    handles.paramExtractionThreshold=thres(currentThresInd);

    handles = copyStructFields( paramsIn, handles, {'minNrSpikes','blockNrRawFig','doGroundNormalization','rawFileVersion','detectionMethod','detectionParams','peakAlignMethod','displayFigures'});
    
    %handles.blockNrRawFig = paramsIn.blockNrRawFig;
    %handles.doGroundNormalization = paramsIn.doGroundNormalization;
    %handles.rawFileVersion=paramsIn.rawFileVersion;
    %handles.detectionMethod=paramsIn.detectionMethod;
    %handles.detectionParams=paramsIn.detectionParams;    
    %handles.peakAlignMethod=paramsIn.peakAlignMethod;
    
    %define file format dependent properties
    [samplingFreq, limit, rawFilePostfix] = defineFileFormat(paramsIn.rawFileVersion, paramsIn.samplingFreq);

    handles.samplingFreq = samplingFreq; %sampling freq of raw data
    handles.limit = limit; %dynamic range

    handles.pathRaw = paths.pathRaw;

    %define include range
    handles.includeFilename=[paths.timestampspath 'timestampsInclude.txt'];
    includeRange=[];
    if exist(handles.includeFilename)==2
        includeRange = dlmread(handles.includeFilename);
        ['include range is set from ' handles.includeFilename]
    else
        warning(['include range is not set! file not found: ' handles.includeFilename]);
    end

    
    %find the channels used for normalization of this electrode
    if paramsIn.doGroundNormalization
        electrodeInd = normalizationChannels( 2, find( normalizationChannels(1,:) == i ) );
	if ~isempty( electrodeInd ) 
		handles.normalizationChannels = setdiff( normalizationChannels(1, find( normalizationChannels(2,:) == electrodeInd ) ), paramsIn.groundChannels);
	else	
		disp(['normalization channel not defined for this channel, dont normalize - ' num2str(i)]);
		handles.normalizationChannels = [];
		handles.doGroundNormalization=0;
	end
   else
        handles.normalizationChannels = [];
    end
    
    paths.pathOut = [ pathOutOrig '/' num2str(handles.paramExtractionThreshold) '/'];

    if exist(paths.pathOut)==0
        ['creating directory ' paths.pathOut]
        mkdir(paths.pathOut);
    end

    handles.rawFilename=[paths.pathRaw rawFilePrefix num2str(i) rawFilePostfix];
    if paramsIn.doDetection

        if exist(handles.rawFilename)==0
            ['file does not exist, skip ' handles.rawFilename]
            continue;
        end
        
        handles.rawFilePrefix = rawFilePrefix;
        handles.rawFilePostfix = rawFilePostfix;

        starttimeDetection=clock;
        handles = StandaloneInit( handles , paramsIn.tillBlocks, paramsIn.prewhiten, paramsIn.alignMethod(kkk),includeRange );
        timeDetection = abs(etime(starttimeDetection,clock))

        timeDetectionStats(size(timeDetectionStats,1)+1,:) = [ i timeDetection handles.blocksProcessedForInit];

        handles.filenamePrefix = [paths.pathOut 'A' num2str(i)];
        storeSortResultFiles( [], handles, 2 , 2 );%2==no figures, 2=noGUI
    end
    
    starttimeSorting=clock;
    
   
    if exist('doFindThreshold')==1
        if doFindThreshold && exist(handles.rawFilename)>0
            handles.prefix=processedFilePrefix;
            handles.from=num2str(i);
            handles.includeRange = includeRange;

            handles = copyStructFields( paramsIn, handles, {'tillBlocks','prewhiten','alignMethod(kkk)'});
            %handles.howManyBlocks = paramsIn.tillBlocks;
            %handles.prewhiten = paramsIn.prewhiten;
            %handles.alignMethod = paramsIn.alignMethod(kkk);
            
            thresholds=[3.5 3.75 4 4.25 4.5 4.75 5 5.25 5.5 5.75 6 ];
            produceThresholdFig(handles, [paths.pathFigs num2str(thres(currentThresInd)) '/'], thresholds);            
        end
    end
    
    if paramsIn.doSorting || paramsIn.doFigures || ~paramsIn.noProjectionTest
        handles.basepath=paths.pathOut;
        handles.prefix=processedFilePrefix;
        handles.from=num2str(i);
        [handles,fileExists] = loadSortResultFiles([],handles, 2);
        handles.filenamePrefix=[paths.pathOut handles.prefix num2str(i)];

        if fileExists==0
            ['File does not exist: ' handles.filenamePrefix];
            continue;
        end

        if paramsIn.doSorting
            if size(handles.newSpikesNegative,1)>0
                starttimeSorting=clock;

                [handles] = sortMain( [], handles, 2, paramsIn.thresholdMethod  ); %2=no GUI

                timeSorting=abs(etime(starttimeSorting,clock))
                timeSortingStats(size(timeSortingStats,1)+1,:) = [i timeSorting length(handles.assignedClusterNegative)];

                storeSortResultFiles(  [], handles, 2, 2  );%2==no figures
            else
                'nothing to sort (0 spikes)'
            end
        end

        handles.label=[ paths.patientID ' ' handles.prefix handles.from ' Th:' num2str(thres(currentThresInd))];
        handles.label = strrep(handles.label,'_',' ');
        disp(['producing figure for ' handles.label]);

        %clusters and PCA figures
        if paramsIn.doFigures
            outputPathFigs=[paths.pathFigs num2str(thres(currentThresInd)) '/'];
            
            produceFigures(handles, outputPathFigs, paramsIn.outputFormat, paramsIn.thresholdMethod);            
            produceOverviewFigure(handles, outputPathFigs, paramsIn.outputFormat, paramsIn.thresholdMethod)            
        end

        %projection test
        if ~paramsIn.noProjectionTest
            produceProjectionFigures(handles,[paths.pathFigs num2str(thres(currentThresInd)) '/'], paramsIn.outputFormat, paramsIn.thresholdMethod);
        end
        
    end

    
    % make raw plots at the end, so that sorting result is included in raw plots as colored spikes (cluster identity)
    if paramsIn.doRawGraphs && exist(handles.rawFilename)>0
        handles.prefix = processedFilePrefix;
        handles.rawFilePrefix = rawFilePrefix;
        handles.rawFilePostfix = rawFilePostfix;
        handles.from=num2str(i);
        handles.basepath=paths.pathOut;
        
        [handles,fileExists] = loadSortResultFiles([],handles, 2);
        produceRawTraceFig(handles, [paths.pathFigs num2str(thres(currentThresInd)) '/'], paramsIn.outputFormat);
    end
end

etime(clock,starttime)
