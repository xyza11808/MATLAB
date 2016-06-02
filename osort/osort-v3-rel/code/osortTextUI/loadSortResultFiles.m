%loads results of sorting/detection (if already done)
%
%1=GUI (TODO: not supported right now, wont work.)
%2=without GUI
%
%fileexists: is 0 if the file did not exist
%
function [handles,fexists] = loadSortResultFiles(hObject,handles,mode)

if mode==1
	handles.from=get(handles.fieldFrom,'String');
	[handles] = GUIInitialize( hObject, handles, 2);
end

filenameIn = [handles.basepath handles.prefix handles.from '_sorted_new.mat'];

if exist(filenameIn)==0
    fexists=0;
    ['file not found' filenameIn]
    return;
end

load(filenameIn);

fexists=1;

handles.newSpikesPositive=newSpikesPositive;
handles.newSpikesNegative=newSpikesNegative;
handles.newSpikesTimestampsPositive=newTimestampsPositive;
handles.newSpikesTimestampsNegative=newTimestampsNegative;

handles.allSpikesPositive=newSpikesPositive;
handles.allSpikesNegative=newSpikesNegative;
handles.allSpikesTimestampsPositive=newTimestampsPositive;
handles.allSpikesTimestampsNegative=newTimestampsNegative;

handles.spikesSolvedPositive=newSpikesPositive;
handles.allSpikesTimestampsPositive=newTimestampsPositive;
handles.spikesSolvedNegative=newSpikesNegative;
handles.allSpikesTimestampsNegative=newTimestampsNegative;

if exist('allSpikesCorrFree')
    handles.allSpikesCorrFree=allSpikesCorrFree;
end

if exist('scalingFactor')     %only version >=3.0 has this
    handles.scalingFactor = scalingFactor;
end

handles.allSpikesNoiseFree=allSpikesNoiseFree;
handles.noiseTraces=noiseTraces;

handles.assignedClusterPositive=assignedPositive;
handles.assignedClusterNegative=assignedNegative;
handles.usePositive=usePositive;
handles.useNegative=useNegative;

if exist('stdEstimate')
    handles.stdEstimateOrig=stdEstimateOrig;
    handles.stdEstimate=stdEstimate;
end

if size(useNegative,1)>1
    useNegative=useNegative';
end

usePosStr=strrep(num2str(usePositive),'  ',',');
useNegStr=strrep(num2str(useNegative),'  ',',');

if exist('paramsUsed')==1
    disp(['params used during processing of this file: ' num2str(paramsUsed)])
end


if exist('useMUA')==1
	handles.useMUA=useMUA;
end

if mode==1
	if exist('useMUA')
		set( handles.editUseMUA,'String', useMUA);
	else
   		set( handles.editUseMUA,'String', '');
	end

	set(handles.editUsePos,'String', usePosStr );
	set(handles.editUseNeg,'String', useNegStr );

	set(handles.labelNrPositive, 'String', num2str( size(handles.newSpikesPositive,1)));
	set(handles.labelNrNegative, 'String', num2str( size(handles.newSpikesNegative,1)));

	guidata(hObject,handles);
end
