%
%plots and exports projection test figures
%
function produceProjectionFigures(handles, outputpath,outputFormat, thresholdMethod)
paperPosition=[0 0 16 12];

%make dir to store the figures
if exist(outputpath)==0
	mkdir(outputpath);
end

colors = defineClusterColors;
rawWaveforms = handles.newSpikesNegative;

%order of clusters
%first clusters are the biggest clusters
clusters=handles.useNegative;
clusters = flipud( clusters );

%if there are more than we have color definitions,crop.
if length(clusters)>length(colors)
    clusters=clusters(1:length(colors));
end

nrClusters=length(clusters);




[outputEnding,outputOption] = determineFigExportFormat( outputFormat );

%--
%--- significance test between all clusters
pairs=[];
pairsColor=[];
c=0;

%only for the 7 biggest to avoid lots of useless plots
if nrClusters>7
    nrClusters=7;
end

for i=1:nrClusters
	for j=i+1:nrClusters
		c=c+1;
		pairs(c,1:2)=[clusters(i) clusters(j)];
		pairsColor(c,1:2)=[i j];
	end
end

for i=1:size(pairs,1)
	figure(123)
	disp(['figure cluster pair ' num2str(i) ' ' num2str(pairs(i,:))]);
	figureClusterOverlap( handles.allSpikesCorrFree, rawWaveforms, handles.assignedClusterNegative, pairs(i,1),pairs(i,2), handles.label,1,{colors{pairsColor(i,1)}, colors{pairsColor(i,2)}} );
	scaleFigure;
    set(gcf,'PaperUnits','inches','PaperPosition',paperPosition)
	print(gcf, outputOption, [outputpath handles.prefix handles.from '_SepTest_' num2str(pairs(i,1)) '_' num2str(pairs(i,2)) '_THM_' num2str(thresholdMethod) outputEnding ]);
	close(gcf);
end

%if there is only one: print distribution in any case
if size(pairs,1)==0 && length(clusters)==1
	figure(123);
	figureClusterOverlap( handles.allSpikesCorrFree, rawWaveforms, handles.assignedClusterNegative, clusters(1), 0, handles.label,1, {colors{1}, colors{2}} );
	scaleFigure;
	set(gcf,'PaperUnits','inches','PaperPosition',paperPosition)
    print(gcf, outputOption, [outputpath handles.prefix handles.from '_SepTest_' num2str(clusters(1)) '_' num2str(clusters(1)) '_THM_' num2str(thresholdMethod) outputEnding ]);
	close(gcf);
end


