
ksfolder = pwd;

AdjKlClusters = load(fullfile(ksfolder,'AdjustedClusterInfo.mat'),'FinalSPClusters','FinalSPTimeSample');
PreNPClusHandle = load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
PreNPClusHandle.ProbNPSess.SpikeTimes = [];
TotalSampleANDtaskT = load(fullfile(ksfolder,'TrigTimeANDallSampNum.mat'));

NewNPClusHandle = PreNPClusHandle.ProbNPSess;
NewNPClusHandle.SpikeClus = AdjKlClusters.FinalSPClusters;

%% 
waveformdatafile = fullfile(ksfolder,'AdjUnitWaveforms','AdjUnitWaveforms.mat');
if ~exist(waveformdatafile,'file')
    % the data should have been saved in blockwise format
    TargetChunkDatafile = dir(fullfile(ksfolder,'AdjUnitWaveforms','TempSavingData*.mat'));
    if isempty(TargetChunkDatafile)
        error('No waveform data file have been found, please check current data path.\n');
    end
    NumTempFiles = length(TargetChunkDatafile);
    ChunkLen = 150;
    UnitDataAll = cell(NumTempFiles,1);
    UnitFeatures = cell(NumTempFiles,1);
    for cChunkFileInds = 1 : NumTempFiles
        cdataStrc = load(fullfile(ksfolder,'AdjUnitWaveforms',TargetChunkDatafile(cChunkFileInds).name));
        UnitDataAll{cChunkFileInds} = cdataStrc.UnitDatas;
        UnitFeatures{cChunkFileInds} = cdataStrc.UnitFeatures;
    end
    UnitDataAllUnit = cat(1,UnitDataAll{:});
    UnitFeaturesAllUnit = cat(1,UnitFeatures{:});
    
    UnitDatas = UnitDataAllUnit;
    UnitFeatures = UnitFeaturesAllUnit;
    save(waveformdatafile,'UnitDatas', 'UnitFeatures', '-v7.3');
    clearvars UnitDataAllUnit UnitFeaturesAllUnit
else
    WaveData = load(waveformdatafile);
    
    if ndims(WaveData.UnitDatas{2}) == 3
        AllDimDatas = WaveData.UnitDatas{2};
        WaveData.UnitDatas{2} = squeeze(mean(AllDimDatas,'omitnan'));
        clearvars AllDimDatas
    end
    UnitDatas = WaveData.UnitDatas;
    UnitFeatures = WaveData.UnitFeatures;

end

NewNPClusHandle.UnitWaves = UnitDatas;
NewNPClusHandle.UnitWaveFeatures = UnitFeatures;




