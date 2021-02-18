function Results = KiloWaveformExtractFun(DataPath,NumSpikes)
% function used for spike wave extraction
FileDatapatt = '*.imec*.ap.bin';
fileinfo = dir(fullfile(DataPath,FileDatapatt));
FileRealName = fileinfo(1).name;
fullpaths = fullfile(DataPath,FileRealName);
Numchannels = 385;
Datatypes = 'int16';
NumOfWaveforms = NumSpikes;
WaveWinSamples = [-30,51];
spikeStruct = loadParamsPy(fullfile(DataPath, 'params.py'));

%%
dataTypeNBytes = numel(typecast(cast(0, Datatypes), 'uint8')); % determine number of bytes per sample
Numsamp = fileinfo.bytes/(dataTypeNBytes*Numchannels);

mmf = memmapfile(fullpaths, 'Format', {Datatypes, [Numchannels Numsamp], 'x'});

%%
SpikeClusters = readNPY(fullfile(DataPath,'spike_clusters.npy'));
SpikeTimeSample = readNPY(fullfile(DataPath,'spike_times.npy'));
% SpikeTimes = double(SpikeTimeSample)/spikeStruct.sample_rate;
channelMap = readNPY(fullfile(DataPath,'channel_map.npy'));

cgsFile = fullfile('cluster_info.tsv');
% [cids, cgs] = readClusterGroupsCSV(cgsFile);
% cluster include criteria: good, not noise, fr >=1
[UsedIDs_clus,Channel_idUseds,UsedIDs_inds,raw] = ClusterGroups_Reads(cgsFile);

ChannelDepth = cell2mat(raw(2:end,7));
UsedChannelDepth = ChannelDepth(UsedIDs_inds);

%%
NumGoodClus = length(UsedIDs_clus);
Clus_waves_datacell = cell(NumGoodClus,5);
fprintf('Totally %d number of clusters were selected from outputs\n',NumGoodClus);
% PlotClu = 62;
for PlotClu = 200 : NumGoodClus
    Clu_index = UsedIDs_clus(PlotClu);
    Channel_index = Channel_idUseds(PlotClu);
    SpikeTime_Alls = SpikeTimeSample(SpikeClusters == Clu_index);
    SpikeTime_shuf = Vshuffle(SpikeTime_Alls);
    NumofSpikes = length(SpikeTime_Alls);
    SpikeDataMtx = nan(NumOfWaveforms,length(channelMap),diff(WaveWinSamples));
    IsRealInds = false(NumOfWaveforms,1);
    UsedSpikeTimes = sort(SpikeTime_shuf(1 : min(NumofSpikes,NumOfWaveforms)));
    for csp = 1 : min(NumofSpikes,NumOfWaveforms)
        cst = UsedSpikeTimes(csp);
        if (cst+WaveWinSamples(1)) < 1 || (cst+WaveWinSamples(2)) > Numsamp
            continue;
        end
        SpikeDataMtx(csp,:,:) = double(mmf.Data.x((channelMap+1),(cst+WaveWinSamples(1)):(cst+WaveWinSamples(2)-1)));
        IsRealInds(csp) = true;
    %     SpikeDataMtx(csp,:,:) = double(mmf.Data.x(:,(cst+WaveWinSamples(1)):(cst+WaveWinSamples(2)-1)));
    end
    %
    Usedchannel_range = [-6,6];
    ChannelMap_Index = find(channelMap == Channel_index-1);
    Usedchn_realInds = [max(1,ChannelMap_Index+Usedchannel_range(1)),min(numel(channelMap),ChannelMap_Index+Usedchannel_range(2))];
    MapChannels = channelMap(Usedchn_realInds(1):Usedchn_realInds(2));
    
    SpikeDataMtx(~IsRealInds,:,:) = [];
    Clu_channle_data = SpikeDataMtx(:,Usedchn_realInds(1):Usedchn_realInds(2),:);
    CenterChannelData = squeeze(SpikeDataMtx(:,ChannelMap_Index,:));

    % AvgSpikes = (zscore(squeeze(mean(Clu_channle_data))'))';
    AvgSpikes = squeeze(mean(Clu_channle_data));
%     Avg_centerchannelwave = mean(CenterChannelData);

%     ybase = 0;
%     yBaseAlls = zeros(length(MapChannels),1);
    CenterChannel_tempinds = ChannelMap_Index - Usedchn_realInds(1) + 1;
%     NumSamples = size(AvgSpikes,2);

%     figure;
%     hold on
%     for chn = 1 : length(MapChannels)
%         plot(1:NumSamples,ybase+AvgSpikes(chn,:),'Color',[.7 .7 .7],'linewidth',0.6);
%         WaveHeight = max(AvgSpikes(chn,:))-min(AvgSpikes(chn,:));
%         text(NumSamples+5,ybase+WaveHeight,num2str(MapChannels(chn),'chn=%d'),'Color','m','FontSize',8);
%         yBaseAlls(chn) = ybase;
%         ybase = ybase + WaveHeight + 30;
%     end
%     plot((1:NumSamples),yBaseAlls(CenterChannel_tempinds)+AvgSpikes(CenterChannel_tempinds,:),'Color','k','linewidth',1.2);
%     line([1,spikeStruct.sample_rate*1e-3],[yBaseAlls(1)- 15,yBaseAlls(1)- 15],'Color','k','linewidth',1.5);
%     text(NumSamples+5,yBaseAlls(CenterChannel_tempinds+1)-30,num2str(MapChannels(CenterChannel_tempinds),'chn=%d'),'Color','c','FontSize',8);
%     text(1,yBaseAlls(1)-30,'1 ms','Color','k','FontSize',8);
%     % axis off;
%     title(sprintf('Clu = %d',Clu_index));
    Clus_waves_datacell(PlotClu,:) = {Clu_channle_data,CenterChannelData,AvgSpikes,...
        MapChannels,CenterChannel_tempinds};
    if mod(PlotClu,50) == 0 
        fprintf('Finished with %d number of total %d clusters.\n',PlotClu,NumGoodClus);
    end
end

Results.channelmaps = channelMap;
Results.SelectClus = UsedIDs_clus;
Results.SelectChannels = Channel_idUseds;
Results.WaveformDatas = Clus_waves_datacell;
Results.Spikeops = spikeStruct;
Results.ChannelDepth = UsedChannelDepth;
