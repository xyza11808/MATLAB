

if ~exist('FolderPath','var')
    FolderPath = pwd;
%     binfilepath = fullfile(FolderPath,'..');
    SR = 30000;
end
%%
NumofChannels = 385; % last channel is the trigger channel data
% fnames = dir(fullfile(binfilepath,'*.ap.bin'));
% fullbinfile = fullpaths; %fullfile(binfilepath,fnames(1).name);
% bytes       = get_file_size(fullbinfile); % size in bytes of raw binary
TotalTimes = rez.ops.sampsToRead/SR;  % total recording times
%%
chnMaps = readNPY(fullfile(FolderPath, 'channel_map.npy'));
chnposition = readNPY(fullfile(FolderPath, 'channel_positions.npy'));
sptemplate = readNPY(fullfile(FolderPath, 'spike_templates.npy'));
templates = readNPY(fullfile(FolderPath, 'templates.npy'));
temInds = readNPY(fullfile(FolderPath, 'templates_ind.npy'));
SpikeClus = readNPY(fullfile(FolderPath, 'spike_clusters.npy'));
SpikeTimeSample = readNPY(fullfile(FolderPath, 'spike_times.npy'));
tempMaxChn = readNPY(fullfile(FolderPath, 'templates_maxChn.npy'));

%% load cluster channel data
ClusMaxChnData = load(fullfile(FolderPath,'ClusterTypeANDchn.mat'));
ClusIndex = ClusMaxChnData.ClusterTypes;
ClusBestChn = ClusMaxChnData.ClusterBestChn;
% ClusterTypes = unique(SpikeClus);
NumberClusters = length(ClusIndex);
% ClusAvgAmps = zeros(NumberClusters,1); % amplitude for each cluster
ClusFRs = zeros(NumberClusters,1); % overall firing rate for each clusters
for Clus = 1:NumberClusters
    Clus_SPIds = (SpikeClus == ClusIndex(Clus));
%     clus_sp_amplitude = tempAmplitudes(Clus_SPIds);
%     ClusAvgAmps(Clus) = mean(clus_sp_amplitude);
    
    ClusFRs(Clus) = sum(Clus_SPIds)/TotalTimes; % over spike rate
%     [temps,tempcount] = uniAndcount(clus_sp_templates);
%     if length(tempcount) > 1
%         [~,maxCountInds] = max(tempcount);
%         UsedTemplate = temps(maxCountInds)+1;
%     else
%         UsedTemplate = temps+1;
%     end
%     ClusChannel(Clus) = tempMaxChn(UsedTemplate)-1;
%     
end

try
    TemplateAmps = readNPY(fullfile(FolderPath, 'ampUnscaled.npy'));
catch
    TemplateAmps = zeros(NumberClusters,1);
end

%% load kslabel data
ksLabels = readtable(fullfile(FolderPath,'cluster_group.tsv'),'FileType','text',...
    'ReadVariableNames',true,'Format','%d%s');
% ksLabelInds = cell2mat(ksLabelCells);
ks_contampcts = readtable(fullfile(FolderPath,'cluster_ContamPct.tsv'),'FileType','text',...
    'ReadVariableNames',true,'Format','%d%f');

ks_clusAmplitude = readtable(fullfile(FolderPath,'cluster_Amplitude.tsv'),'FileType','text',...
    'ReadVariableNames',true,'Format','%d%f');

ClusChnDpth = chnposition(ClusBestChn+1,2);

clus_Amplitudes = ks_clusAmplitude.Amplitude(ClusIndex+1);
clus_kslabels = ksLabels.KSLabel(ClusIndex+1);
clus_cotampcts = ks_contampcts.ContamPct(ClusIndex+1);
clus_spNums = ClusFRs * TotalTimes;

%% write data into cluster_info.tsv files
% 
% id	Amplitude	ContamPct	KSLabel	amp	          ch	depth	fr	       group 	n_spikes	sh
% 0	    6804.9	     100	    good	110.2760696	   2	40	  1.05573393		     4442	     0

fileIDInfo = fopen(fullfile(FolderPath, 'cluster_info.tsv'),'w');
if fileIDInfo < 0
    error('Unable to create clusterinfo file, please check whether there is an exist file that have been opened.');
end
fprintf(fileIDInfo, 'id%sAmplitude%sContamPct%sKSLabel%samp%sch%sdepth%sfr%sgroup%sn_spikes%ssh', char(9),...
    char(9),char(9),char(9),char(9),char(9),char(9),char(9),char(9),char(9));
fprintf(fileIDInfo, char([13 10])); % wrap around to next line

for cClus = 1 : NumberClusters
    
    % add cluster index values
    fprintf(fileIDInfo,'%d%s',ClusIndex(cClus), char(9)); % each column should be seperated by char(9), a '  ' character
    
    % add Amplitudes
    fprintf(fileIDInfo,'%.1f%s',clus_Amplitudes(cClus), char(9));  % each column should be seperated by char(9), a '  ' character
    
    % add contamPct
    fprintf(fileIDInfo,'%d%s',clus_cotampcts(cClus), char(9)); 
    
    % add ksLabel
    fprintf(fileIDInfo,'%s%s',clus_kslabels{cClus}, char(9)); 
    
    % add amps
    fprintf(fileIDInfo,'%.4f%s',TemplateAmps(cClus), char(9)); 
    
    % add ch Index
    fprintf(fileIDInfo,'%d%s',ClusBestChn(cClus), char(9)); 
    
    % add channel depth
    fprintf(fileIDInfo,'%d%s',ClusChnDpth(cClus), char(9)); 
    
    % add firing rate
    fprintf(fileIDInfo,'%.6f%s',ClusFRs(cClus), char(9)); 
    
    % add group label (empty if not processed with phy)
    fprintf(fileIDInfo,'%s%s',' ', char(9)); 
    
    % add spike count number
    fprintf(fileIDInfo,'%d%s',clus_spNums(cClus), char(9)); 
    
    % add sh value, all zeros, dont know why
    fprintf(fileIDInfo,'%d%s',0, char(9)); 
    
    fprintf(fileIDInfo, char([13 10])); % wrap around to next line
end

fclose(fileIDInfo);


