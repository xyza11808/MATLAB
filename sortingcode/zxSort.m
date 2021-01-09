tic
addpath('D:\code\neuropixel-utils')
addpath('D:\code\npy-matlab\npy-matlab\')
addpath(genpath('D:\code\Kilosort2'))
channelMapFile='D:\code\neuropixel-utils\map_files\neuropixPhase3B2_kilosortChanMap.mat';
% lwd=pwd();
% lwd='D:\Data\20200617_g0\20200617_g0_imec0';
% lwd=cd;
cd(lwd);
fn=ls('*.ap.bin');
imec=Neuropixel.ImecDataset(fullfile(lwd,fn),'ChannelMap',channelMapFile);
if cleaned
else
    rmsBadChannels=imec.markBadChannelsByRMS('rmsRange',[3 100]);
    imec.writeModifiedAPMeta();
    fn=replace(fn,'.imec0.','_0.imec.');
    fn=replace(fn,'.imec1.','_1.imec.');
    fn=replace(fn,'.imec2.','_2.imec.');
    fn=replace(fn,'.imec3.','_3.imec.');
    cleanedPath = fullfile([lwd,'_cleaned'],fn);
    extraMeta = struct();
    extraMeta.commonAverageReferenced = true;
    fnList = {@Neuropixel.DataProcessFn.commonAverageReference};
    imec = imec.saveTranformedDataset(cleanedPath, 'transformAP', fnList, 'extraMeta', extraMeta);
end
% imec.inspectAP_timeWindow([1000,1001]);
Neuropixel.runKiloSort2(imec,'workingDir','D:\temp');
toc
%% phy



%% risky, heavy memory load
tic
sync6=imec.readSync();
% save('sync.mat','sync6');
if cleaned
    syncH5=fullfile(lwd,'sync.hdf5');
else
    syncH5=fullfile([lwd,'_cleaned'],'sync.hdf5');
end
h5create(syncH5,'/sync',size(sync6),'Datatype','int8')
h5write(syncH5,'/sync',int8(sync6))

toc


% ks=Neuropixel.KiloSortDataset(pwd(),'channelMap',channelMapFile);
% ks.load();
% ks.computeBasicStats();
% metrics=ks.computeMetrics();
% metrics.plotClusterWaveformAtCenterOfMass();
% savefig('centerOfMass.fig');
% TS=ks.spike_times;
% ids=ks.spike_clusters;
% clusterI = readtable('cluster_info.tsv','FileType','text');
% waveformGood=strcmp(clusterI{:,9},'good');
% freqGood=cellfun(@(x) str2double(regexp(x,'[0-9.]*','match','once'))>=2,table2cell(clusterI(:,8)));
% cluster_ids = table2array(clusterI(waveformGood & freqGood,1));
% save('SPK_TS.mat','TS','ids','clusterI','waveformGood','freqGood','cluster_ids');
% 

