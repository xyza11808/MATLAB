
function [UsedClus_IDs,ChannelUseds_id] = SpikeWaveFeature_single(rez,IsKsCall)
% function used to analysis single unit waveform features
% the wave form features may includes firerate, peak-to-trough
% width, refraction peak and so on

% from "Nuo Li et al, 2016", trough-to-peak interval  less than
% 0.35ms were defined as fast-spiking neuron and spike width
% larger than 0.45ms as putative pyramidal neurons


% if isempty(obj.binfilePath) || isempty(obj.RawDataFilename)
%     if ~isempty(varargin) && ~isempty(varargin{1})
%         obj.binfilePath = varargin{1};
%         possbinfilestrc = dir(fullfile(obj.binfilePath,'*.ap.bin'));
%         if isempty(possbinfilestrc)
%             error('target bin file doesnt exists.');
%         end
%         obj.RawDataFilename = possbinfilestrc(1).name;
%     else
%         error('Bin file location is needed for spikewave extraction.');
%     end
% end
%             if isempty(obj.mmf) && eixst(fullfile(obj.binfilePath,obj.RawDataFilename))
%                 fullpaths = fullfile(obj.binfilePath, obj.RawDataFilename);
% %                 dataNBytes = get_file_size(fullpaths); % determine number of bytes per sample
% %                 obj.Numsamp = dataNBytes/(2*obj.NumChn);
% %                 obj.mmf = memmapfile(fullpaths, 'Format', {obj.Datatype, [obj.NumChn obj.Numsamp], 'x'});
% %
%             end
% fullpaths = fullfile(obj.binfilePath, obj.RawDataFilename);
if ~exist('IsKsCall','var')
    IsKsCall = 1;
end

if IsKsCall
    fullpaths = rez.ops.fbinary; % bin file path

    ksfolder = fullfile(rez.ops.ksFolderPath,'ks2_5');
    if ~isfolder(ksfolder)
        ksfolder = fullfile(rez.ops.ksFolderPath,'kilosort3');
    end
    TotalSamples = rez.ops.sampsToRead;
else
    fullpaths = fullfile(rez.binfilePath, rez.RawDataFilename);
    ksfolder = rez.ksFolder;
    TotalSamples = rez.Numsamp;
end
ftempid = fopen(fullpaths);

if ~isfolder(fullfile(ksfolder,'UnitWaveforms'))
    mkdir(fullfile(ksfolder,'UnitWaveforms'));
end
% startTime = 15000;
% offsets = 385*startTime*2;
% status = fseek(ftempid,offsets,bof);
% AsNew= fread(ftempid,[385 15000],'int16');

% read clusters info from cluster_info.tsv file
cgsFile = fullfile(ksfolder,'cluster_info.tsv');
[UsedClus_IDs,ChannelUseds_id,~,...
    ~,~] = ClusterGroups_Reads(cgsFile);
SpikeTimeSample = readNPY(fullfile(ksfolder,'spike_times.npy'));
SpikeClus = readNPY(fullfile(ksfolder,'spike_clusters.npy'));

WaveWinSamples = [-30,51];
NumofUnit = length(UsedClus_IDs);
UnitDatas = cell(NumofUnit,2);
UnitFeatures = cell(NumofUnit,5);
for cUnit = 1 : NumofUnit
    % cUnit = 137;
    %% close;
    cClusInds = UsedClus_IDs(cUnit);
    cClusChannel = ChannelUseds_id(cUnit);
    cClus_Sptimes = SpikeTimeSample(SpikeClus == cClusInds);
    if numel(cClus_Sptimes) < 2000
        UsedSptimes = cClus_Sptimes;
        SPNums = length(UsedSptimes);
    else
        UsedSptimes = cClus_Sptimes(randsample(numel(cClus_Sptimes),2000));
        SPNums = 2000;
    end
    cspWaveform = nan(SPNums,diff(WaveWinSamples));
    AllChannelWaveData = nan(SPNums,384,diff(WaveWinSamples));
    for csp = 1 : SPNums
        cspTime = UsedSptimes(csp);
        cspStartInds = cspTime+WaveWinSamples(1);
        cspEndInds = cspTime+WaveWinSamples(2);
        offsetTimeSample = cspStartInds - 1;
        if offsetTimeSample < 0 || cspEndInds > TotalSamples
            continue;
        end
        offsets = 385*(cspStartInds-1)*2;
        status = fseek(ftempid,offsets,'bof');
        if ~status
            % correct offset value is set
            AllChnDatas = fread(ftempid,[385 diff(WaveWinSamples)],'int16');
            cspWaveform(csp,:) = AllChnDatas(cClusChannel,:);
            AllChannelWaveData(csp,:,:) = AllChnDatas(1:384,:); % for waveform spread calculation
            %        cspWaveform(csp,:) = mean(AllChnDatas);
        end
    end
    
    huf = figure('visible','off');
    if size(cspWaveform,1) == 1
        AvgWaves = cspWaveform;
        UnitDatas{cUnit,2} = squeeze(AllChannelWaveData);
    else
        AvgWaves = mean(cspWaveform,'omitnan');
        UnitDatas{cUnit,2} = squeeze(mean(AllChannelWaveData,'omitnan'));
    end
    UnitDatas{cUnit,1} = cspWaveform;
    
    %%
    plot(AvgWaves);
    try
        [isabnorm,isUsedVec,waveAmplitude,toughPeakInds] = iswaveformatypical(AvgWaves,WaveWinSamples,false);
    catch ME
        fprintf('Errors');
    end
    title([num2str(cClusChannel,'chn=%d'),'  ',num2str(1-isabnorm,'Ispass = %d')]);
%     if length(AvgWaves) == 1
%         fprintf('Too few spikes for calculation.\n');
%     end
    wavefeature = SPwavefeature(AvgWaves,WaveWinSamples);
    text(6,0.8*max(AvgWaves),{sprintf('tough2peak = %d',wavefeature.tough2peakT);...
        sprintf('posthyper = %d',wavefeature.postHyperT)},'FontSize',8);
    
    if wavefeature.IsPrePosPeak
        text(50,0.5*max(AvgWaves),{sprintf('pre2postpospeakratio = %.3f',wavefeature.pre2post_peakratio)},'color','r','FontSize',8);
    end
    UnitFeatures(cUnit,:) = {wavefeature,isabnorm,isUsedVec,waveAmplitude,toughPeakInds};
    %
    
    saveName = fullfile(ksfolder,'UnitWaveforms',sprintf('Unit%d waveform plot save',cUnit));
    saveas(huf,saveName);
    saveas(huf,saveName,'png');
    
    close(huf);
    
end
% obj.UnitWaves = UnitDatas;
% obj.UnitWaveFeatures = UnitFeatures;
save(fullfile(ksfolder,'UnitwaveformDatas.mat'), 'UnitDatas', 'UnitFeatures', '-v7.3');