
Datafile_path = 'I:\20210104\xy1_20210104_g0\xy1_20210104_g0_imec1';
File_name = 'xy1_20210104_g0_t0.imec1.ap.bin';

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
%%
cgsFile = 'cluster_info.tsv';
[cids, cgs] = readClusterGroupsCSV(cgsFile);

%%
ClusterTypes = unique(SpikeClusters);
NumGoodClus = length(ClusterTypes);

%%
PlotClu = 1;
Clu_index = ClusterTypes(PlotClu);
SpikeTime_Alls = SpikeTimes(SpikeClusters == Clu_index);
NumofSpikes = length(SpikeTime_Alls);
SpikeDataMtx = nan(NumOfWaveforms,diff(WaveWinSamples));
for csp = 1 : min(NumofSpikes,NumOfWaveforms)
    
    

end


%%




