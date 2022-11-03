
clearvars UnitDatas UnitFeatures
%% 
waveformdatafile = fullfile(ksfolder,'AdjUnitWaveforms','AdjUnitWaveforms.mat');
waveformdatafile2 = fullfile(ksfolder,'AdjUnitWaveforms','AdjUnitwaveformDatas.mat');
if ~exist(waveformdatafile,'file') && ~exist(waveformdatafile2,'file')
    % the data should have been saved in blockwise format
    TargetChunkDatafile = dir(fullfile(ksfolder,'AdjUnitWaveforms','TempSavingData*.mat'));
    if isempty(TargetChunkDatafile)
        error('No waveform data file have been found, please check current data path.\n');
    end
    NumTempFiles = length(TargetChunkDatafile);
    ChunkLen = 150;
    UnitDataAll = cell(NumTempFiles,1);
%     UnitFeatures = cell(NumTempFiles,1);
    for cChunkFileInds = 1 : NumTempFiles
        cdataStrc = load(fullfile(ksfolder,'AdjUnitWaveforms',TargetChunkDatafile(cChunkFileInds).name));
        UnitDataAll{cChunkFileInds} = cdataStrc.UnitDatas;
%         UnitFeatures{cChunkFileInds} = cdataStrc.UnitFeatures;
    end
    UnitDataAllUnit = cat(1,UnitDataAll{:});
%     UnitFeaturesAllUnit = cat(1,UnitFeatures{:});
    
    UnitDatas = UnitDataAllUnit;
%     UnitFeatures = UnitFeaturesAllUnit;
    
    AboveThresClusStrc = load(fullfile(ksfolder,'AdjUnitWaveforms','AboveThresClusters.mat'));
    AboveThresClusIDs = AboveThresClusStrc.AboveThresClusIDs;
    AboveThresClusMaxChn = AboveThresClusStrc.AboveThresClusMaxChn+1;
%     save(waveformdatafile,'UnitDatas', 'UnitFeatures','AboveThresClusIDs', 'AboveThresClusMaxChn', '-v7.3');
%     fprintf('Saved seperated file into a summary file.\n');
%     clearvars UnitDataAllUnit UnitFeaturesAllUnit
else
    try
        WaveData = load(waveformdatafile);
    catch
        WaveData = load(waveformdatafile2);
    end
    if ndims(WaveData.UnitDatas{2}) == 3
        AllDimDatas = WaveData.UnitDatas{2};
        WaveData.UnitDatas{2} = squeeze(mean(AllDimDatas,'omitnan'));
        clearvars AllDimDatas
    end
    UnitDatas = WaveData.UnitDatas;
%     UnitFeatures = WaveData.UnitFeatures;
    AboveThresClusIDs = WaveData.AboveThresClusIDs;
    AboveThresClusMaxChn = WaveData.AboveThresClusMaxChn+1;
end
%%

NumOfUnit = size(UnitDatas,1);
UnitFeatures = cell(NumOfUnit,5);
for cU = 1 : NumOfUnit
    cU_data = mean(UnitDatas{cU,1},'omitnan');
    WaveWinSamples = [-30,51];
    try
        [isabnorm,isUsedVec,waveAmplitude,toughPeakInds] = iswaveformatypical(cU_data,WaveWinSamples,false);
    catch ME
        fprintf('Errors');
    end
    if waveAmplitude < 5
        wavefeature = [];
    else
        try
            wavefeature = SPwavefeature(cU_data,WaveWinSamples,toughPeakInds);
        catch
            wavefeature = [];
        end
    end
    UnitFeatures(cU,:) = {wavefeature,isabnorm,isUsedVec,waveAmplitude,toughPeakInds};
end
%%
AllAbNorm = cat(1,UnitFeatures{:,2});
fprintf('Abnormal waveform fraction is %d/%d.\n',sum(AllAbNorm),numel(AllAbNorm));
save(waveformdatafile,'UnitDatas', 'UnitFeatures','AboveThresClusIDs', 'AboveThresClusMaxChn', '-v7.3');
