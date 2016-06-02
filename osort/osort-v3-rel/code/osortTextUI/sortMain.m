%
%
%mode: 1=with GUI; 2=no GUI (textmode
%
%thresholdMethod: 1=approximation (std), 2=exact (whitened data)
%
function handles = sortMain( hObject, handles, mode, thresholdMethod  )
defineSortingConstants;

handles.correctionFactorThreshold

stdEstimate = handles.stdEstimateOrig + handles.correctionFactorThreshold * handles.stdEstimateOrig;

if thresholdMethod==1
	Cinv=[];
	transformedSpikes=[];
    sortInput = handles.newSpikesNegative;
else
	Cinv = eye(256);

	v = 256;
	alpha=0.05;	
	thres = chi2inv( 1-alpha,v);
	stdEstimate=thres;
    
    sortInput = handles.allSpikesCorrFree;
    transformedSpikes = handles.allSpikesCorrFree;
   
end

[assigned, nrAssigned, baseSpikes, baseSpikesID] = sortSpikesOnline( sortInput, stdEstimate, size(handles.newSpikesNegative,1), thresholdMethod, Cinv,transformedSpikes );

[stdEstimate handles.stdEstimateOrig]
nrAssigned

minNrSpikes=handles.minNrSpikes;
cluNoise=nrAssigned(find(nrAssigned(:,2)<=minNrSpikes),1);
for i=1:length(cluNoise)
    assigned(find(assigned==cluNoise(i)))=CLUSTERID_NOISE_CLUSTER;
end

cluUse=nrAssigned(find(nrAssigned(:,2)>minNrSpikes),1);
neg='';
for i=1:length(cluUse)
    neg=[neg ',' num2str(cluUse(i))];
end


if mode==1
    set(handles.editUseNeg,'String',neg);
end

handles.useNegative=cluUse;


handles.assignedClusterNegative=assigned;

if mode==1
	guidata(hObject,handles);
end

