
% Datafile_path = 'I:\20210104\xy1_20210104_g0\xy1_20210104_g0_imec2\3b2_output';
Datafile_path = pwd;
% File_name = 'AuD_PASSIVE_TEST_g0_t0.imec0.ap.bin';

% fullpaths = fullfile(Datafile_path,File_name);
% fullpaths = 'N:\NPDatas\b103a04_20210408_NPSess01_g0\b103a04_20210408_NPSess01_g0_imec0\temp\temp_wh.dat';
fullpaths = 'N:\NPDatas\b103a04_20210408_NPSess01_g0\b103a04_20210408_NPSess01_g0_imec0\b103a04_20210408_NPSess01_g0_t0.imec0.ap.bin';
fileinfo = dir(fullpaths);
Numchannels = 385;
Datatypes = 'int16';
NumOfWaveforms = 2000;
WaveWinSamples = [-30,51];
spikeStruct = loadParamsPy(fullfile(Datafile_path, 'params.py'));

%%
dataTypeNBytes = numel(typecast(cast(0, Datatypes), 'uint8')); % determine number of bytes per sample
Numsamp = fileinfo.bytes/(dataTypeNBytes*Numchannels);

mmf = memmapfile(fullpaths, 'Format', {Datatypes, [Numchannels Numsamp], 'x'});

%%
SpikeClusters = readNPY('spike_clusters.npy');
SpikeTimeSample = readNPY('spike_times.npy');
SpikeTimes = double(SpikeTimeSample)/spikeStruct.sample_rate;
channelMap = readNPY('channel_map.npy');
%% if already processed with phy 
cgsFile = 'cluster_info.tsv';
% [cids, cgs] = readClusterGroupsCSV(cgsFile);
% cluster include criteria: good, not noise, fr >=1
[UsedIDs_clus,Channel_idUseds,UsedIDs_inds,raw] = ClusterGroups_Reads(cgsFile);

ChannelDepth = cell2mat(raw(2:end,7));
UsedChannelDepth = ChannelDepth(UsedIDs_inds);
%%
% ClusterTypes = unique(UsedIDs_clus);
NumGoodClus = length(UsedIDs_clus);
fprintf('Totally %d number of good units were find.\n',NumGoodClus);

%%
ftempid = fopen(fullpaths);
% startTime = 15000;
% offsets = 385*startTime*2;
% status = fseek(ftempid,offsets,bof);
% AsNew= fread(ftempid,[385 15000],'int16');
NumofUnit = length(UsedIDs_clus);
UnitDatas = cell(NumofUnit,1);
UnitFeatures = cell(NumofUnit,3);
for cUnit = 1 : NumofUnit
% cUnit = 137;
% close;
    cClusInds = UsedIDs_clus(cUnit);
    cClusChannel = Channel_idUseds(cUnit);
    cClus_Sptimes = SpikeTimeSample(SpikeClusters == cClusInds);
    if numel(cClus_Sptimes) < 2000
        UsedSptimes = cClus_Sptimes;
        SPNums = length(UsedSptimes);
    else
        UsedSptimes = cClus_Sptimes(randsample(numel(cClus_Sptimes),2000));
        SPNums = 2000;
    end
    cspWaveform = nan(SPNums,diff(WaveWinSamples));
    for csp = 1 : SPNums
        cspTime = UsedSptimes(csp);
        cspStartInds = cspTime+WaveWinSamples(1);
        cspEndInds = cspTime+WaveWinSamples(2);
        offsetTimeSample = cspStartInds - 1;
        if offsetTimeSample < 0 || cspEndInds > Numsamp
            continue;
        end
        offsets = 385*(cspStartInds-1)*2; 
        status = fseek(ftempid,offsets,'bof');
        if ~status
           % correct offset value is set
           AllChnDatas = fread(ftempid,[385 diff(WaveWinSamples)],'int16');
           cspWaveform(csp,:) = AllChnDatas(cClusChannel,:);
    %        cspWaveform(csp,:) = mean(AllChnDatas);
        end
    end

    huf = figure('visible','off');
    AvgWaves = mean(cspWaveform);
    UnitDatas{cUnit} = cspWaveform;
    
    plot(AvgWaves);
    [isabnorm,isUsedVec] = iswaveformatypical(AvgWaves,WaveWinSamples,false);
    title([num2str(cClusChannel,'chn=%d'),'  ',num2str(1-isabnorm,'Ispass = %d')]);
    wavefeature = SPwavefeature(AvgWaves,WaveWinSamples);
    text(6,0.8*max(AvgWaves),{sprintf('tough2peak = %d',wavefeature.tough2peakT);...
        sprintf('posthyper = %d',wavefeature.postHyperT)},'FontSize',8);

    if wavefeature.IsPrePosPeak
        text(50,0.5*max(AvgWaves),{sprintf('pre2postpospeakratio = %.3f',wavefeature.pre2post_peakratio)},'color','r','FontSize',8);
    end
    UnitFeatures(cUnit,:) = {wavefeature,isabnorm,isUsedVec};
    %
    saveName = sprintf('Unit%d waveform plot save',cUnit);
    saveas(huf,saveName);
    saveas(huf,saveName,'png');
    
    close(huf);
    
end
%%
close;
PlotClu = 2;
Clu_index = UsedIDs_clus(PlotClu);
Channel_index = Channel_idUseds(PlotClu);
SpikeTime_Alls = SpikeTimeSample(SpikeClusters == Clu_index);
SpikeTime_shuf = Vshuffle(SpikeTime_Alls);
NumofSpikes = length(SpikeTime_Alls);
SpikeDataMtx = nan(NumOfWaveforms,length(channelMap),diff(WaveWinSamples));
UsedSpikeTimes = sort(SpikeTime_shuf(1 : min(NumofSpikes,NumOfWaveforms)));
for csp = 1 : min(NumofSpikes,NumOfWaveforms)
    cst = UsedSpikeTimes(csp);
    SpikeDataMtx(csp,:,:) = double(mmf.Data.x((channelMap+1),(cst+WaveWinSamples(1)):(cst+WaveWinSamples(2)-1)));
%     SpikeDataMtx(csp,:,:) = double(mmf.Data.x(:,(cst+WaveWinSamples(1)):(cst+WaveWinSamples(2)-1)));
end
%
Usedchannel_range = [-6,6];
ChannelMap_Index = find(channelMap == Channel_index-1);
Usedchn_realInds = [max(1,ChannelMap_Index+Usedchannel_range(1)),min(Numchannels,ChannelMap_Index+Usedchannel_range(2))];
MapChannels = channelMap(Usedchn_realInds(1):Usedchn_realInds(2));

Clu_channle_data = SpikeDataMtx(:,Usedchn_realInds(1):Usedchn_realInds(2),:);
CenterChannelData = squeeze(SpikeDataMtx(:,ChannelMap_Index,:));

% AvgSpikes = (zscore(squeeze(mean(Clu_channle_data))'))';
AvgSpikes = squeeze(mean(Clu_channle_data));
Avg_centerchannelwave = mean(CenterChannelData);

ybase = 0;
yBaseAlls = zeros(length(MapChannels),1);
CenterChannel_tempinds = ChannelMap_Index - Usedchn_realInds(1) + 1;
NumSamples = size(AvgSpikes,2);

figure;
hold on
for chn = 1 : length(MapChannels)
    plot(1:NumSamples,ybase+AvgSpikes(chn,:),'Color',[.7 .7 .7],'linewidth',0.6);
    WaveHeight = max(AvgSpikes(chn,:))-min(AvgSpikes(chn,:));
    text(NumSamples+5,ybase+WaveHeight,num2str(MapChannels(chn),'chn=%d'),'Color','m','FontSize',8);
    yBaseAlls(chn) = ybase;
    ybase = ybase + WaveHeight + 30;
end
plot((1:NumSamples),yBaseAlls(CenterChannel_tempinds)+AvgSpikes(CenterChannel_tempinds,:),'Color','k','linewidth',1.2);
line([1,spikeStruct.sample_rate*1e-3],[yBaseAlls(1)- 15,yBaseAlls(1)- 15],'Color','k','linewidth',1.5);
text(NumSamples+5,yBaseAlls(CenterChannel_tempinds+1)-30,num2str(MapChannels(CenterChannel_tempinds),'chn=%d'),'Color','c','FontSize',8);
text(1,yBaseAlls(1)-30,'1 ms','Color','k','FontSize',8);
% axis off;
title(sprintf('Clu = %d',Clu_index));

%%
UsedSpikeDataMtx = SpikeDataMtx(1:min(NumofSpikes,NumOfWaveforms),:);

figure;
hold on
plot(UsedSpikeDataMtx','Color',[.7 .7 .7]);
yyaxis right
plot(mean(UsedSpikeDataMtx),'Color','k','linewidth',1.6);


%% ############################################################################
% if no phy process was performed
ClusterTypes = unique(SpikeClusters);
NumGoodClus = length(ClusterTypes);

%%
close
PlotClu = 3;
Clu_index = ClusterTypes(PlotClu);
% Channel_index = Channel_idUseds(PlotClu);
SpikeTime_Alls = SpikeTimes(SpikeClusters == Clu_index);
SpikeTime_shuf = Vshuffle(SpikeTime_Alls);
NumofSpikes = length(SpikeTime_Alls);
SpikeDataMtx = nan(NumOfWaveforms,diff(WaveWinSamples));
for csp = 1 : min(NumofSpikes,NumOfWaveforms)
    cst = SpikeTime_shuf(csp);
    SpikeDataMtx(csp,:) = mean(double(mmf.Data.x((channelMap+1),(cst+WaveWinSamples(1)):(cst+WaveWinSamples(2)-1))));
end
UsedSpikeDataMtx = SpikeDataMtx(1:min(NumofSpikes,NumOfWaveforms),:);

figure;
hold on
plot(UsedSpikeDataMtx','Color',[.7 .7 .7]);
yyaxis right
plot(mean(UsedSpikeDataMtx),'Color','k','linewidth',1.6);



%%
UsedSpikeDatas = SpikeDataMtx(1:min(NumofSpikes,NumOfWaveforms),:);
[Waves, Lens] = size(UsedSpikeDatas);
Trace = reshape(UsedSpikeDatas',[],1);
ZsTrace = zscore(Trace);
zsMtx = (reshape(ZsTrace,Lens,Waves))';

figure;
hold on
plot(zsMtx','Color',[.6 .6 .6]);
plot(mean(zsMtx),'Color','k','linewidth',1.5);
title(sprintf('clu=%d, channel=%d',Clu_index,Channel_index));

%% #########################################################################
% website methods for wave plots
myKsDir_output = 'N:\NPDatas\b103a04_20210408_NPSess01_g0\b103a04_20210408_NPSess01_g0_imec0\kilosort3';
% Rawdatadir = 'I:\20210104\xy1_20210104_g0\xy1_20210104_g0_imec1';
sp = loadKSdir(myKsDir_output);
%%
gwfparams.dataDir = myKsDir_output;    % KiloSort/Phy output folder
% gwfparams.Rawdatapath = Rawdatadir;
apD = dir(fullfile(myKsDir_output,'..', '*ap*.bin')); % AP band file from spikeGLX specifically
gwfparams.fileName = apD(1).name;         % .dat file containing the raw 
gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
gwfparams.nCh = 385;                      % Number of channels that were streamed to disk in .dat file
gwfparams.wfWin = [-30 51];              % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 1000;                    % Number of waveforms per unit to pull out
ClusIns = 0;
gwfparams.spikeTimes = ceil(sp.st(sp.clu==ClusIns)*30000); % Vector of cluster spike times (in samples) same length as .spikeClusters
gwfparams.spikeClusters = sp.clu(sp.clu==ClusIns);

%%
wf = getWaveForms(gwfparams);

%%

ChannelWaveforms = squeeze(wf.waveFormsMean);
AllWaveforms = squeeze(wf.waveForms);

%% spike time plots  ###########################################################
% sp = loadKSdir(myKsDir);
% 
% %%
% UsedIDs_clus = unique(sp.clu);
TotalTimeLen = Numsamp/spikeStruct.sample_rate;
Num_sp_inds = length(UsedIDs_clus);
SingleUnit_st = cell(Num_sp_inds,4);
for cInds = 1 : Num_sp_inds
    c_clu_inds = SpikeClusters == UsedIDs_clus(cInds);
    c_clu_sp = SpikeTimes(c_clu_inds);
    [psth_center,psth_data] = st2binfun(c_clu_sp,10,50,TotalTimeLen);
    psth_dataHz = psth_data/(10/1000); % in Hz format
    SingleUnit_st(cInds,:) = {c_clu_sp,numel(c_clu_sp)/TotalTimeLen,psth_dataHz,psth_center};
    
end

%% calculate the correlation matrix
FrDataMtx = cell2mat((SingleUnit_st(:,3))');
figure;
imagesc(Num_sp_inds,psth_center,FrDataMtx',[0 40])

%%
ChannelCorrCoef = corrcoef(FrDataMtx);
ChannelCorrCoef = ChannelCorrCoef - diag(diag(ChannelCorrCoef));
figure;
imagesc(ChannelCorrCoef,[-0.5 0.5])
colorbar

%%
% plot the first 1s firings
huf = figure;
hold on
for cInds = 1 : 10%Num_sp_inds
    UsedSt = SingleUnit_st{cInds,1}(SingleUnit_st{cInds,1} <= 1);
    plot(UsedSt,cInds*ones(numel(UsedSt),1),'ko','markersize',1);
end

%% raw channel waveform plot aligned to trigger times
% plot trigger time wavefrom of all raw channel datas
% UsedSPTime = 6;
TriggerWins = spikeStruct.sample_rate*2/1000;
TrigVarValues = zeros(length(NPprocess.UsedTrigOnTime),3);
for UsedSPTime = 1 : length(NPprocess.UsedTrigOnTime)
    SpikeTimeInds = round(NPprocess.UsedTrigOnTime(UsedSPTime)*spikeStruct.sample_rate);
    BeforeAfInds = [-0.02,0.05]*spikeStruct.sample_rate;
    UsedTimeWin = SpikeTimeInds+BeforeAfInds;
    
    PlotData = mmf.Data.x(:,UsedTimeWin(1):UsedTimeWin(2));
     
    TrigWinIndex = abs(BeforeAfInds(1))+[1,TriggerWins];
    TrigData = mean(PlotData(1:384,TrigWinIndex(1):TrigWinIndex(2)));
    
    BefTrigData = mean(PlotData(1:384,1:(abs(BeforeAfInds(1))-5)));
    AfTrigData = mean(PlotData(1:384,(TrigWinIndex(2)+5):end));
    
    TrigVarValues(UsedSPTime,:) = [var(TrigData),var(BefTrigData),var(AfTrigData)];
end
%%     
UsedSPTime = 352;
SpikeTimeInds = round(NPprocess.UsedTrigOnTime(UsedSPTime)*spikeStruct.sample_rate);
    BeforeAfInds = [-0.02,0.05]*spikeStruct.sample_rate;
    UsedTimeWin = SpikeTimeInds+BeforeAfInds;
    
    PlotData = mmf.Data.x(:,UsedTimeWin(1):UsedTimeWin(2));

    figure;
    hold on
    plot(PlotData','Color',[.7 .7 .7])
    yscales = get(gca,'ylim');
    line([abs(BeforeAfInds(1)) abs(BeforeAfInds(1))],yscales,'Color','m','linewidth',1)

    %

    plot(mean(PlotData(1:384,:)),'k','linewidth',1.8)




