
%
%mode==1:store figures
%mode==2:store no figures
%
%displayMode==1: with GUI, 2: without GUI
%
%
function handles = storeSortResultFiles(  hObject, handles, mode, displayMode  )
versionCreated = 300;

filenamePrefix='';
if displayMode==1
	filenamePrefix = [handles.basepath handles.prefix get(handles.labelCurrentBlock,'String')];
else
	filenamePrefix=handles.filenamePrefix;
end

filenameOut = [filenamePrefix '_sorted_new.mat'];

scalingFactor = handles.scalingFactor;   %ADBitVolts or similar; to convert from raw units to volt

newSpikesPositive=handles.newSpikesPositive;
newSpikesNegative=handles.newSpikesNegative;
newTimestampsPositive=handles.newSpikesTimestampsPositive;
newTimestampsNegative=handles.newSpikesTimestampsNegative;
allSpikesNoiseFree=handles.allSpikesNoiseFree;
allSpikesCorrFree=[];
if isfield(handles,'allSpikesCorrFree')
    allSpikesCorrFree=handles.allSpikesCorrFree;
end

assignedPositive=[];

assignedNegative=[];
if isfield(handles,'assignedClusterNegative')
	assignedNegative=handles.assignedClusterNegative;
end

noiseTraces=handles.noiseTraces;

stdEstimateOrig=handles.stdEstimateOrig;
stdEstimate=handles.stdEstimate;

paramsUsed=[];
if displayMode==1
	paramsUsed=[handles.correctionFactorThreshold handles.paramEnvelopeSize handles.paramMaxDistance handles.paramExtractionThreshold handles.paramMinClustSize handles.paramUseOnly];
else
	paramsUsed=[handles.correctionFactorThreshold handles.paramExtractionThreshold];
end

savedTime=clock;

usePositive=[];
useNegative=[];
useMUA=[];

if isfield(handles,'useMUA') && displayMode==2
	useMUA=handles.useMUA;
end

if isfield(handles,'useNegative') && displayMode==2
	useNegative=handles.useNegative;
end

if displayMode==1
    toUsePositive=get(handles.editUsePos,'String');
    toUseNegative=get(handles.editUseNeg,'String');
    
    useMUA=str2num(get(handles.editUseMUA,'String'));
    
    counter=0;
    while length(toUsePositive)>0
        [token,toUsePositive] = strtok(toUsePositive,',')
        counter=counter+1;
        clusterNr = str2num(token);
        usePositive(counter) = clusterNr;	
        
        if mode==1
            %store this figure
            figure(100+clusterNr);
            eval(['print -djpeg ' filenamePrefix '_fig_P_' token]);
        end
    end
    
    
    counter=0;
    while length(toUseNegative)>0
        [token,toUseNegative] = strtok(toUseNegative,',')
        counter=counter+1;
        
        clusterNr = str2num(token);
        useNegative(counter) = clusterNr;	
        
        if mode==1
            %store this figure
            figure(200+clusterNr);
            eval(['print -djpeg ' filenamePrefix '_fig_N_' token]);
        end
    end
    
    if length(usePositive)>0 && mode==1
        figure(876);
        eval(['print -djpeg ' filenamePrefix '_fig_P_SUM_' token]);
    end
    
    if length(useNegative)>0 && mode==1
        figure(877);
        eval(['print -djpeg ' filenamePrefix '_fig_N_SUM_' token]);
    end
end


filenameOut
%save(filenameOut, 'useMUA', 'versionCreated', 'noiseTraces','allSpikesNoiseFree','allSpikesCorrFree','newSpikesPositive', 'newSpikesNegative', 'newTimestampsPositive', 'newTimestampsNegative','assignedPositive','assignedNegative', 'usePositive', 'useNegative','stdEstimateOrig','stdEstimate','paramsUsed','savedTime','-v6');

save(filenameOut, 'useMUA', 'versionCreated', 'noiseTraces','allSpikesNoiseFree','allSpikesCorrFree','newSpikesPositive', 'newSpikesNegative', 'newTimestampsPositive', 'newTimestampsNegative','assignedPositive','assignedNegative', 'usePositive', 'useNegative','stdEstimateOrig','stdEstimate','paramsUsed','savedTime', 'scalingFactor');

'stored finished'
