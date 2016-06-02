%
%overview figure which plots, for each pair of clusters, the mean/std of
%mean waveform and ISIs on top of each other for easy comparison.
%
function produceOverviewFigure(handles, outputpath, outputFormat, thresholdMethod)
MAX_NR_CLUSTERS=10;
paperPosition=[0 0 16 12];

%% get data and organize
rawWaveforms = handles.newSpikesNegative;

if isfield(handles,'scalingFactor')
    rawWaveforms = rawWaveforms .* handles.scalingFactor*1e6; %convert to uV
end

%order of clusters, first clusters are the biggest clusters
clusters=handles.useNegative;
clusters = flipud( clusters );

nrClusters=length(clusters);

%how many to plot?
if nrClusters > MAX_NR_CLUSTERS
    nrClusters=MAX_NR_CLUSTERS;
end

% only possible if more than 1 cluster is available
if nrClusters<2
    return;
end

[outputEnding,outputOption] = determineFigExportFormat( outputFormat );

pairs=[];
pairsColor=[];
c=0;

%determine the pairs
for i=1:nrClusters
	for j=i+1:nrClusters
		c=c+1;
		pairs(c,1:2)=[clusters(i) clusters(j)];
		pairsColor(c,1:2)=[i j];
	end
end


%% make plots
colors = defineClusterColors;

disp(['figure overview - cluster pairs ' ]);

c=0;
figNrOrig=150;
figNr=figNrOrig;
subPlotNr = [0 0 0];

figure(figNr);
close(gcf);

for i=1:size(pairs,1)
    if c==16
        %reset
        c=0;
        figNr=figNr+1;
        figure(figNr);
        close(gcf);        
    end
    
    if c~=4
        c=c+1;
        subPlotNr(1) = c;
    else
        %if jump to next row
        c=c+9;
        subPlotNr(1)=c;
    end
    
    subPlotNr(2) = c+4;
    subPlotNr(3) = c+8;
     
	figure(figNr)
    for k=1:3
        subplot(6,4,subPlotNr(k));
        plotClusterPairs( handles.newSpikesNegative, handles.assignedClusterNegative, handles.newSpikesTimestampsNegative, handles.allSpikesCorrFree, pairs(i,1), pairs(i,2), k, colors{pairsColor(i,1)}, colors{pairsColor(i,2)}, handles.label );
    end
end

%export all the figs
for k=figNrOrig:figNr
    
    figure(k);
    
    scaleFigure;
    
    set(gcf,'PaperUnits','inches','PaperPosition',paperPosition)
    
    fNameOut=[outputpath handles.prefix handles.from '_WAVES_' num2str(k-figNrOrig+1) '_THM_' num2str(thresholdMethod) outputEnding ];
    disp(['Writing:' fNameOut]);
    print(gcf, outputOption, fNameOut);
    
    if ~handles.displayFigures
        close(gcf);
    end
   
end
