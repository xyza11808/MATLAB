clearvars SessAreaIndexStrc ProbNPSess AreaDecodeDataCell AreaProcessDatas BlockpsyInfo ExistField_ClusIDs NewAdd_ExistAreaNames

load(fullfile(ksfolder,'NewClassHandle2.mat'),'behavResults');
% load(fullfile(ksfolder,'NewClassHandle2.mat')); %,'behavResults'
% ProbNPSess = NewNPClusHandle;
% clearvars NewNPClusHandle
% ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});

DataSavefolder = fullfile(ksfolder,'BlockTypeScores');
if ~isfolder(DataSavefolder)
    mkdir(DataSavefolder);
end
DataSavefileO = fullfile(DataSavefolder,'RepeatBTScores.mat');
load(DataSavefileO,'OutDataStrc');
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);


%% find target cluster inds and IDs
% ksfolder = pwd;

NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNewAlign.mat'));
NewAdd_AllfieldNames = fieldnames(NewSessAreaStrc.SessAreaIndexStrc);
NewAdd_ExistAreasInds = find(NewSessAreaStrc.SessAreaIndexStrc.UsedAbbreviations);
NewAdd_ExistAreaNames = NewAdd_AllfieldNames(NewAdd_ExistAreasInds);
if strcmpi(NewAdd_ExistAreaNames(end),'Others')
    NewAdd_ExistAreaNames(end) = [];
end
NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);

Numfieldnames = length(NewAdd_ExistAreaNames);
ExistField_ClusIDs = cell(Numfieldnames,4);
AreaUnitNumbers = zeros(NewAdd_NumExistAreas,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs(cA,:) = {cA_Clus_IDs,cA_clus_inds,numel(cA_clus_inds) > 5,...
        NewAdd_ExistAreaNames{cA}}; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    
end
%
USedAreas = cell2mat(ExistField_ClusIDs(:,3)) < 1;
if sum(USedAreas)
    ExistField_ClusIDs(USedAreas,:) = [];
    AreaUnitNumbers(USedAreas) = [];
    Numfieldnames = Numfieldnames - sum(USedAreas);
    NewAdd_ExistAreaNames(USedAreas) = [];
end

%% some preprocessing
% NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
OnsetBin = OutDataStrc.TriggerStartBin;

% behavior datas
BlockSectionInfo = Bev2blockinfoFun(behavResults);

ActionInds = double(behavResults.Action_choice(:));
NMTrInds = ActionInds(1:BlockSectionInfo.BlockTrScales(end,2)) ~= 2;
ActTrs = ActionInds(NMTrInds);

NMActionChoices = ActionInds(NMTrInds);
BlockTypeAll = double(behavResults.BlockType(:));
NMBlockTypes = BlockTypeAll(NMTrInds);

NMBlockTypeLabels = NMBlockTypes + 1;
NMActionChoices = NMActionChoices + 1;

NMBlockIndex = cumsum([1;abs(diff(NMBlockTypes))]);

% AllTrInds = {double(behavResults.Action_choice(:)),double(behavResults.BlockType(:))};
TrialFreqsAll = double(behavResults.Stim_toneFreq(:));

RevFreqs = BlockSectionInfo.BlockFreqTypes(BlockSectionInfo.IsFreq_asReverse>0);
RevFreqInds = (ismember(TrialFreqsAll,RevFreqs));
NMRevFreqIndsRaw = RevFreqInds(NMTrInds);
NMTrFreqsAll = TrialFreqsAll(NMTrInds);

FreqTypes = unique(NMTrFreqsAll);
FreqTypeNum = length(FreqTypes);

% find fieldnames
AllNameStrs = NewAdd_ExistAreaNames;
AllAreaUnitInds = ExistField_ClusIDs;
AllAreaUnitNums = cellfun(@numel,AllAreaUnitInds(:,2));
UsedUnitNumsThres = 30; % 10, 15, 25, 30
IncludeAreaInds = AllAreaUnitNums >= UsedUnitNumsThres;

UsedArea_strs = AllNameStrs(IncludeAreaInds);
UsedUnitNums = AllAreaUnitNums(IncludeAreaInds);
UsedUnitInds = AllAreaUnitInds(IncludeAreaInds,:);
NumUsedAreas = length(UsedArea_strs);
%% precalculations
RawResponseData = NewBinnedDatas(NMTrInds,:,:);
[nmTrNum, UnitNums, FrameNum] = size(RawResponseData);
BaselineAvgDatas = mean(RawResponseData(:,:,1:OnsetBin-1),3);
% BaselineSubData = RawResponseData - repmat(BaselineAvgDatas,1,1,FrameNum);
RawResponseData_zs = zeros(size(RawResponseData));
% BaselineSubData_zs = zeros(size(BaselineSubData));
for cU = 1 : UnitNums
    cU_Raw = RawResponseData(:,cU,:);
    RawResponseData_zs(:,cU,:) = (cU_Raw - mean(cU_Raw,'all'))/std(cU_Raw(:));
    
%     cU_Sub = BaselineSubData(:,cU,:);
%     BaselineSubData_zs(:,cU,:) = (cU_Sub - mean(cU_Sub,'all'))/std(cU_Sub(:));
end
FrameBinTime = OutDataStrc.USedbin(2);
BaselineWin = 1:OnsetBin-1;
AfterRespWin = round((0.1:0.1:1)/FrameBinTime)+OnsetBin;
BaselineDataTrace = (reshape(permute(RawResponseData_zs(:,:,BaselineWin),[2,3,1]),UnitNums,[]))';
BaselineLabels = (repmat(NMBlockTypeLabels(:),1,numel(BaselineWin)))';
BaselineLabelsVec = BaselineLabels(:);
%%
NumRepeats = 500;
AreaFixUnitScores = cell(NumUsedAreas, 2);
for cA = 1 : NumUsedAreas
    cA_UnitInds = UsedUnitInds{cA,2};
    cA_UnitNums = numel(cA_UnitInds);
    cA_UnitData = BaselineDataTrace(:,cA_UnitInds);
    
    AllRepeatScores = zeros(NumRepeats, 3,'single');
    AllRepeatPerfs = zeros(NumRepeats, 3,'single');
    parfor cR = 1 : NumRepeats
        cUsedUnitsInds = randsample(cA_UnitNums, UsedUnitNumsThres);
        cRUsedData = cA_UnitData(:,cUsedUnitsInds);
        [cRepeatAvgScores, cRepeatAvgPerfs] = TrEqualSampleinfo(cRUsedData, BaselineLabelsVec, 0.6);
        AllRepeatScores(cR,:) = cRepeatAvgScores;
        AllRepeatPerfs(cR,:) = cRepeatAvgPerfs;
    end
    AreaFixUnitScores(cA,:) = {AllRepeatScores, AllRepeatPerfs};
end

%%
% DataSavefolder = fullfile(ksfolder,'BlockTypeScores');
% if ~isfolder(DataSavefolder)
%     mkdir(DataSavefolder);
% end
DataSavefile = fullfile(DataSavefolder,'RepeatBTScores4.mat');
save(DataSavefile,'AreaFixUnitScores','UsedArea_strs','UsedUnitInds','UsedUnitNums','OutDataStrc','UsedUnitNumsThres','-v7.3');



