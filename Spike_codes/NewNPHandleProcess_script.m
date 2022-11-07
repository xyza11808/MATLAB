% cclr

% ksfolder = pwd;
clearvars AdjKlClusters NewNPClusHandle waveformdatafile behavResults PassSoundDatas

AdjKlClusters = load(fullfile(ksfolder,'AdjustedClusterInfo.mat'));
% PreNPClusHandle = load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
% PreNPClusHandle.ProbNPSess.SpikeTimes = [];
load(fullfile(ksfolder,'NewClassHandle.mat'));
TotalSampleANDtaskT = load(fullfile(ksfolder,'TrigTimeANDallSampNum.mat'));

% NewNPClusHandle = PreNPClusHandle.ProbNPSess;
NewNPClusHandle.SpikeClus = AdjKlClusters.FinalSPClusters;
NewNPClusHandle.ClusterInfoAll = AdjKlClusters.FinalksLabels;
NewNPClusHandle.SpikeTimes = double(AdjKlClusters.FinalSPTimeSample)/30000;
%% 
waveformdatafile = fullfile(ksfolder,'AdjUnitWaveforms','AdjUnitWaveforms2.mat');
waveDataStrc = load(waveformdatafile);
% % waveformdatafile2 = fullfile(ksfolder,'AdjUnitWaveforms','AdjUnitwaveformDatas.mat');
% if ~exist(waveformdatafile,'file') && ~exist(waveformdatafile2,'file')
%     % the data should have been saved in blockwise format
%     TargetChunkDatafile = dir(fullfile(ksfolder,'AdjUnitWaveforms','TempSavingData*.mat'));
%     if isempty(TargetChunkDatafile)
%         error('No waveform data file have been found, please check current data path.\n');
%     end
%     NumTempFiles = length(TargetChunkDatafile);
%     ChunkLen = 150;
%     UnitDataAll = cell(NumTempFiles,1);
%     UnitFeatures = cell(NumTempFiles,1);
%     for cChunkFileInds = 1 : NumTempFiles
%         cdataStrc = load(fullfile(ksfolder,'AdjUnitWaveforms',TargetChunkDatafile(cChunkFileInds).name));
%         UnitDataAll{cChunkFileInds} = cdataStrc.UnitDatas;
%         UnitFeatures{cChunkFileInds} = cdataStrc.UnitFeatures;
%     end
%     UnitDataAllUnit = cat(1,UnitDataAll{:});
%     UnitFeaturesAllUnit = cat(1,UnitFeatures{:});
%     
%     UnitDatas = UnitDataAllUnit;
%     UnitFeatures = UnitFeaturesAllUnit;
%     
%     AboveThresClusStrc = load(fullfile(ksfolder,'AdjUnitWaveforms','AboveThresClusters.mat'));
%     AboveThresClusIDs = AboveThresClusStrc.AboveThresClusIDs;
%     AboveThresClusMaxChn = AboveThresClusStrc.AboveThresClusMaxChn+1;
%     save(waveformdatafile,'UnitDatas', 'UnitFeatures','AboveThresClusIDs', 'AboveThresClusMaxChn', '-v7.3');
%     fprintf('Saved seperated file into a summary file.\n');
%     clearvars UnitDataAllUnit UnitFeaturesAllUnit
% else
% %     try
%         WaveData = load(waveformdatafile);
% %     catch
% %         WaveData = load(waveformdatafile2);
% %     end
%     if ndims(WaveData.UnitDatas{2}) == 3
%         AllDimDatas = WaveData.UnitDatas{2};
%         WaveData.UnitDatas{2} = squeeze(mean(AllDimDatas,'omitnan'));
%         clearvars AllDimDatas
%     end
%     UnitDatas = WaveData.UnitDatas;
%     UnitFeatures = WaveData.UnitFeatures;
%     AboveThresClusIDs = WaveData.AboveThresClusIDs;
%     AboveThresClusMaxChn = WaveData.AboveThresClusMaxChn+1;
% end

NewNPClusHandle.UnitWaves = waveDataStrc.UnitDatas;
NewNPClusHandle.UnitWaveFeatures = waveDataStrc.UnitFeatures;
AboveThresClusIDs = waveDataStrc.AboveThresClusIDs;
AboveThresClusMaxChn = waveDataStrc.AboveThresClusMaxChn;
%% reassign good cluster IDs and FR values ans so on

% SPClusTypes = unique(AdjKlClusters.FinalSPClusters);
% SPClusLabels = AdjKlClusters.FinalksLabels.KSLabel(SPClusTypes+1);
% SPClusMaxChn = AdjKlClusters.FinalSPMaxChn(SPClusTypes+1);
% SPClusGoodClusInds = cellfun(@(x) strcmpi(x,'good'),SPClusLabels);

GoodClusTypes = AboveThresClusIDs; %SPClusTypes(SPClusGoodClusInds);
% GoodClusMaxChn = SPClusMaxChn(SPClusGoodClusInds);
SessDur = TotalSampleANDtaskT.TotalSampleNums/30000;

NumGoodClus = length(GoodClusTypes);
GoodClusFRs = zeros(numel(GoodClusTypes),1);
for cClus = 1 : NumGoodClus
    GoodClusFRs(cClus) = sum(AdjKlClusters.FinalSPClusters == GoodClusTypes(cClus))/SessDur;
end
% AboveThresClusIDs = GoodClusTypes(FRThres);
% AboveThresClusMaxChn = GoodClusMaxChn(FRThres);
% UsedClusInds = ismember(GoodClusTypes, AboveThresClusIDs);
NewNPClusHandle.GoodClusIDs = AboveThresClusIDs;
NewNPClusHandle.GoodClusFRs = GoodClusFRs;
NewNPClusHandle.GoodClusMaxChn = AboveThresClusMaxChn;


ChnAreaStrsStrc = load(fullfile(ksfolder,'Chnlocation.mat'));
NewNPClusHandle.ChannelAreaStrs = ChnAreaStrsStrc.AlignedAreaStrings;


%%
% NewNPClusHandle.ksFolder = ksfolder;
% NewNPClusHandle.CurrentSessInds = strcmpi('Task',NewNPClusHandle.SessTypeStrs);
% if contains(ksfolder,'b103a04_20210408')
%     NewNPClusHandle = NewNPClusHandle.triggerOnsetTime([],[2,6],[]);
% else
%     NewNPClusHandle = NewNPClusHandle.triggerOnsetTime([],[6,2],[]);
% end
% TrStimOnsets = double(PreNPClusHandle.behavResults.Time_stimOnset(:));
% TimeWin = [-1.5,4]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; % time window for smooth psth, in ms format
% % if isempty(ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds})
%     NewNPClusHandle = NewNPClusHandle.TrigPSTH(TimeWin, Smoothbin, TrStimOnsets);
% % end
% %%
% NewNPClusHandle.CurrentSessInds = strcmpi('passive',NewNPClusHandle.SessTypeStrs);
% NewNPClusHandle = NewNPClusHandle.triggerOnsetTime([],4);
% 
% TimeWin = [-0.4,3];
% NewNPClusHandle = NewNPClusHandle.TrigPSTH(TimeWin, []);
% NewNPClusHandle.CurrentSessInds = strcmpi('Task',NewNPClusHandle.SessTypeStrs);

%% check the clusters going to use
NewNPClusHandle.CurrentSessInds = strcmpi('Task',NewNPClusHandle.SessTypeStrs);
NewNPClusHandle.ksFolder = ksfolder;
NewNPClusHandle = NewNPClusHandle.ClusScreeningFun;
fprintf('\nNew cluster screening left units is %d/%d.\n',numel(NewNPClusHandle.UsedClus_IDs),numel(NewNPClusHandle.GoodClusIDs));
% fprintf('\nOld Cluster have %d used unit, while new cluster have %d used unit.\n',...
%     numel(PreNPClusHandle.ProbNPSess.UsedClus_IDs),numel(NewNPClusHandle.UsedClus_IDs));
%% %% plot the rasters
% behavResults = PreNPClusHandle.behavResults;
% AllTrStimOnTime = double(behavResults.Time_stimOnset(:));
% AllTrAnsTime = double(behavResults.Time_answer(:));
% TrActionChoice = double(behavResults.Action_choice(:));
% TrBlockTypes = double(behavResults.BlockType(:));
% TrStimFreqs = double(behavResults.Stim_toneFreq(:));
% 
% NMTrInds = TrActionChoice ~= 2;
% NMTrStimOnTime = AllTrStimOnTime(NMTrInds);
% NMTrAnsTime = AllTrAnsTime(NMTrInds);
% NMTrChoices = TrActionChoice(NMTrInds);
% NMBlockTypes = TrBlockTypes(NMTrInds);
% NMTrFreqs = TrStimFreqs(NMTrInds);
% 
% BlockSectionInfo = Bev2blockinfoFun(behavResults);
% BlockSecEdgeInds = [0.5;BlockSectionInfo.BlockTrScales(:,2)+0.5;numel(NMTrInds)+0.5];
% BlockMissTrCount = histcounts(find(~NMTrInds),BlockSecEdgeInds);
% BlockEndTrInds = BlockSectionInfo.BlockTrScales(:,2) - BlockMissTrCount(1:end-1)';
% 
% EventAignTimes = NMTrAnsTime - NMTrStimOnTime; % time difference between stim-on and answer
% ChoiceTypeColors = {'b','r'};
% BlockTypeColors = {[0.2 0.6 0.2],[0.7 0.4 0.1]};
% ExtraEventStrs = {'Choice'};
% NewNPClusHandle.CurrentSessInds = strcmpi('Task',NewNPClusHandle.SessTypeStrs);
% 
% cFolderChnAreaStrc = load(fullfile(ksfolder,'Chnlocation.mat'),'AlignedAreaStrings');
% ChnAreaStrs = cFolderChnAreaStrc.AlignedAreaStrings{2};
% NewNPClusHandle.ChannelAreaStrs = ChnAreaStrs;
% NewNPClusHandle.RawRasterplot(EventAignTimes,NMTrFreqs,...
%     {NMTrChoices,ChoiceTypeColors}, NMBlockTypes, BlockTypeColors,NMTrInds);

%%
NewNPClusHandle.SpikeTimes = [];
% behavResults = PreNPClusHandle.behavResults;
% PassSoundDatas = PreNPClusHandle.PassSoundDatas;
save(fullfile(ksfolder,'NewClassHandle2.mat'),'NewNPClusHandle','behavResults','PassSoundDatas','-v7.3');

SessAreaIndexReCal(ksfolder, NewNPClusHandle,BrainRegionStrc);

return;
%% find target cluster inds and IDs
NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNewAlign.mat'));
NewAdd_AllfieldNames = fieldnames(NewSessAreaStrc.SessAreaIndexStrc);
NewAdd_ExistAreasInds = find(NewSessAreaStrc.SessAreaIndexStrc.UsedAbbreviations);
NewAdd_ExistAreaNames = NewAdd_AllfieldNames(NewAdd_ExistAreasInds);
if strcmpi(NewAdd_ExistAreaNames(end),'Others')
    NewAdd_ExistAreaNames(end) = [];
end
NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);

Numfieldnames = length(NewAdd_ExistAreaNames);
ExistField_ClusIDsCell = cell(Numfieldnames,1);
AreaUnitNumbers = zeros(NewAdd_NumExistAreas,1);
AreaNameIndex = cell(Numfieldnames,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDsCell(cA,:) = {[cA_Clus_IDs,cA_clus_inds]}; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    AreaNameIndex(cA) = {cA*ones(AreaUnitNumbers(cA),1)};
end
%
ExistField_ClusIDs = cat(1,ExistField_ClusIDsCell{:});
%%

OldRegFile = fullfile(ksfolder,'Regressor_ANA','RegressorDataAligned.mat');
OldRegData = load(OldRegFile);

%%
[OldExistedClusIDInds, OldMapInds] = ismember(ExistField_ClusIDs(:,1),OldRegData.NewExistField_ClusIDs(:,1));
fprintf('Num of processed clusters is %d/%d.\n',sum(OldExistedClusIDInds),numel(OldExistedClusIDInds));
NewAddedClusIDs = ExistField_ClusIDs(~OldExistedClusIDInds,:);

%%

[RegressorInfosCell,FullRegressorInfosCell,PredictorStrc] = ...
    linear_regressor_calFun(ksfolder,NewNPClusHandle,NewAddedClusIDs,behavResults);
AddedClusterBackup = struct();
AddedClusterBackup.ExtraIDs = NewAddedClusIDs;
AddedClusterBackup.RegressorInfosCell = RegressorInfosCell;
AddedClusterBackup.FullRegressorInfosCell = FullRegressorInfosCell;
% AddedClusterBackup.PredictorStrc = PredictorStrc;

%%
TotalNumofUnit = size(ExistField_ClusIDs,1);
NewRregressorCell = cell(TotalNumofUnit,3);
NewFullRegressorCell = cell(TotalNumofUnit,3);

oldmap2NewIndex = OldMapInds(OldExistedClusIDInds);
NewRregressorCell(OldExistedClusIDInds,:) = OldRegData.RegressorInfosCell(oldmap2NewIndex,:);
NewFullRegressorCell(OldExistedClusIDInds,:) = OldRegData.FullRegressorInfosCell(oldmap2NewIndex,:);

NewRregressorCell(~OldExistedClusIDInds,:) = RegressorInfosCell;
NewFullRegressorCell(~OldExistedClusIDInds,:) = FullRegressorInfosCell;

RegressorInfosCellRaw = RegressorInfosCell;
FullRegressorInfosCellRaw = FullRegressorInfosCell;

RegressorInfosCell = NewRregressorCell;
FullRegressorInfosCell = NewFullRegressorCell;

%% save new regressor datas
dataSaveNames = fullfile(ksfolder,'Regressor_ANA','REgressorDataSave5.mat');
save(dataSaveNames, 'RegressorInfosCell',...
    'ExistField_ClusIDs', 'NewAdd_ExistAreaNames', 'AreaUnitNumbers',...
    'FullRegressorInfosCell','PredictorStrc','AddedClusterBackup','-v7.3');

%% cehck anova data
AnovafilePath = fullfile(ksfolder,'AnovanAnA','OmegaSqrDatas.mat');
OldClusIDfile = fullfile(ksfolder,'AnovanAnA','SigAnovaTracedataSave.mat');
OldAnovaDataStrc = load(AnovafilePath);
OldClusIDs = load(OldClusIDfile,'SeqFieldClusIDs');
%%
[OldExistedClusIDInds, OldMapInds] = ismember(ExistField_ClusIDs(:,1),OldClusIDs.SeqFieldClusIDs(:,1));
fprintf('Num of processed clusters is %d/%d.\n',sum(OldExistedClusIDInds),numel(OldExistedClusIDInds));
NewAddedClusIDs = ExistField_ClusIDs(~OldExistedClusIDInds,:);

TotalNumofUnit = size(ExistField_ClusIDs,1);
[CaledBinNum,~,FactorNum] = size(OldAnovaDataStrc.AllNullThres_Mtx);
NewAllNullThres_Mtx = zeros(CaledBinNum,TotalNumofUnit,FactorNum,'single');
NewCalWinUnitOmegaSqrs = cell(CaledBinNum,TotalNumofUnit,FactorNum);
NewNSMUnitOmegaSqrData = zeros(CaledBinNum,TotalNumofUnit,FactorNum,'single');
NewNullOmegaSqrDatas = cell(CaledBinNum,1);
%%
[AddAllNullThres_Mtx, AddNSMUnitOmegaSqrData, AddCalWinUnitOmegaSqrs, AddNullOmegaSqrDatas] = ...
    AnovanInfoCalFun(ksfolder,NewNPClusHandle,NewAddedClusIDs,behavResults);
%%
oldmap2NewIndex = OldMapInds(OldExistedClusIDInds);

% value assignments
NewAllNullThres_Mtx(:,OldExistedClusIDInds,:) = single(OldAnovaDataStrc.AllNullThres_Mtx(:,oldmap2NewIndex,:));
NewAllNullThres_Mtx(:,~OldExistedClusIDInds,:) = single(AddAllNullThres_Mtx);

NewNSMUnitOmegaSqrData(:,OldExistedClusIDInds,:) = single(OldAnovaDataStrc.NSMUnitOmegaSqrData(:,oldmap2NewIndex,:));
NewNSMUnitOmegaSqrData(:,~OldExistedClusIDInds,:) = single(AddNSMUnitOmegaSqrData);

NewCalWinUnitOmegaSqrs(:,OldExistedClusIDInds,:) = OldAnovaDataStrc.CalWinUnitOmegaSqrs(:,oldmap2NewIndex,:);
NewCalWinUnitOmegaSqrs(:,~OldExistedClusIDInds,:) = AddCalWinUnitOmegaSqrs;
NewCalWinUnitOmegaSqrs = cellfun(@single,NewCalWinUnitOmegaSqrs,'un',0);

[nRepeat,~,cFactor] = size(OldAnovaDataStrc.NullOmegaSqrDatas{1});
NewAddNullOmegaSqrDatas = cell(CaledBinNum,1);
for cCalbin = 1 : CaledBinNum
    cBinCal = zeros(nRepeat,TotalNumofUnit,cFactor);
    cBinCal(:,OldExistedClusIDInds,:) = OldAnovaDataStrc.NullOmegaSqrDatas{cCalbin}(:,oldmap2NewIndex,:);
    cBinCal(:,~OldExistedClusIDInds,:) = AddNullOmegaSqrDatas{cCalbin};
    NewAddNullOmegaSqrDatas{cCalbin} = single(cBinCal); 
end
%%

save(fullfile(ksfolder,'AnovanAnA','OmegaSqrDatasNew.mat'),'NewAllNullThres_Mtx',...
    'NewCalWinUnitOmegaSqrs','NewNSMUnitOmegaSqrData','NewNullOmegaSqrDatas','-v7.3');


