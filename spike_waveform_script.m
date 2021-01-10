
Datafile_path = 'I:\20210104\xy1_20210104_g0\xy1_20210104_g0_imec0';
File_name = 'xy1_20210104_g0_t0.imec0.ap.bin';

fullpaths = fullfile(Datafile_path,File_name);
fileinfo = dir(fullpaths);
Numchannels = 385;
Datatypes = 'uint16';
NumOfWaveforms = 1000;
WaveWinSamples = [-50,51];

%%
dataTypeNBytes = numel(typecast(cast(0, Datatypes), 'uint8')); % determine number of bytes per sample
Numsamp = fileinfo.bytes/(dataTypeNBytes*Numchannels);

mmf = memmapfile(fullpaths, 'Format', {Datatypes, [Numchannels Numsamp], 'x'});

%%
SpikeClusters = readNPY('spike_clusters.npy');
SpikeTimes = readNPY('spike_times.npy');
channelMap = readNPY('channel_map.npy');
%% if already processed with phy 
cgsFile = 'cluster_info.tsv';
% [cids, cgs] = readClusterGroupsCSV(cgsFile);
[UsedIDs_clus,Channel_idUseds,UsedIDs_inds,raw] = ClusterGroups_Reads(cgsFile);

%%
% ClusterTypes = unique(UsedIDs_clus);
NumGoodClus = length(UsedIDs_clus);

%%
PlotClu = 3;
Clu_index = UsedIDs_clus(PlotClu);
Channel_index = Channel_idUseds(PlotClu);
SpikeTime_Alls = SpikeTimes(SpikeClusters == Clu_index);
NumofSpikes = length(SpikeTime_Alls);
SpikeDataMtx = nan(NumOfWaveforms,diff(WaveWinSamples));
for csp = 1 : min(NumofSpikes,NumOfWaveforms)
    cst = SpikeTime_Alls(csp);
    SpikeDataMtx(csp,:) = mean(double(mmf.Data.x((channelMap+1),(cst+WaveWinSamples(1)):(cst+WaveWinSamples(2)-1))));
end
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
NumofSpikes = length(SpikeTime_Alls);
SpikeDataMtx = nan(NumOfWaveforms,diff(WaveWinSamples));
for csp = 1 : min(NumofSpikes,NumOfWaveforms)
    cst = SpikeTime_Alls(csp);
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
myKsDir_output = 'I:\20210104\xy1_20210104_g0\xy1_20210104_g0_imec0\3b2_outs';
% Rawdatadir = 'I:\20210104\xy1_20210104_g0\xy1_20210104_g0_imec1';
sp = loadKSdir(myKsDir);

gwfparams.dataDir = myKsDir;    % KiloSort/Phy output folder
gwfparams.Rawdatapath = Rawdatadir;
apD = dir(fullfile(Rawdatadir, '*ap*.bin')); % AP band file from spikeGLX specifically
gwfparams.fileName = apD(1).name;         % .dat file containing the raw 
gwfparams.dataType = 'int16';            % Data type of .dat file (this should be BP filtered)
gwfparams.nCh = 385;                      % Number of channels that were streamed to disk in .dat file
gwfparams.wfWin = [-40 41];              % Number of samples before and after spiketime to include in waveform
gwfparams.nWf = 1000;                    % Number of waveforms per unit to pull out
gwfparams.spikeTimes = ceil(sp.st(sp.clu==1)*30000); % Vector of cluster spike times (in samples) same length as .spikeClusters
gwfparams.spikeClusters = sp.clu(sp.clu==1);

%%
wf = getWaveForms(gwfparams);

%%

ChannelWaveforms = squeeze(wf.waveFormsMean);
AllWaveforms = squeeze(wf.waveForms);




