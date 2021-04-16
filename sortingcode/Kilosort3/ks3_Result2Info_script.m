
chnMaps = readNPY(fullfile(FolderPath, 'channel_map.npy'));
chnposition = readNPY(fullfile(FolderPath, 'channel_positions.npy'));
sptemplate = readNPY(fullfile(FolderPath, 'spike_templates.npy'));
templates = readNPY(fullfile(FolderPath, 'templates.npy'));
temInds = readNPY(fullfile(FolderPath, 'templates_ind.npy'));
SpikeClus = readNPY(fullfile(FolderPath, 'spike_clusters.npy'));
SpikeTimeSample = readNPY(fullfile(FolderPath, 'spike_times.npy'));
tempMaxChn = readNPY(fullfile(FolderPath, 'templates_maxChn.npy'));

%% load cluster channel data
ClusMaxChnData = load('ClusterTypeANDchn.mat');
ClusIndex = ClusMaxChnData.ClusterTypes;
ClusBestChn = ClusMaxChnData.ClusterBestChn;
% ClusterTypes = unique(SpikeClus);
% NumberClusters = length(ClusterTypes);
% ClusChannel = zeros(NumberClusters,1);
% for Clus = 1:NumberClusters
%     Clus_SPIds = (SpikeClus == ClusterTypes(Clus));
%     clus_sp_templates = sptemplate(Clus_SPIds);
%     [temps,tempcount] = uniAndcount(clus_sp_templates);
%     if length(tempcount) > 1
%         [~,maxCountInds] = max(tempcount);
%         UsedTemplate = temps(maxCountInds)+1;
%     else
%         UsedTemplate = temps+1;
%     end
%     ClusChannel(Clus) = tempMaxChn(UsedTemplate)-1;
%     
% end

%% load kslabel data
ksLabelCells = readcell('cluster_group.tsv','FileType','text');
ksLabelInds = cell2mat(ksLabelCells);







