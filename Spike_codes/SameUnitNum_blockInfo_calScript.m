clearvars SessAreaIndexStrc ProbNPSess AreaDecodeDataCell AreaProcessDatas BlockpsyInfo ExistField_ClusIDs NewAdd_ExistAreaNames

load(fullfile(ksfolder,'NewClassHandle2.mat'));
ProbNPSess = NewNPClusHandle;
clearvars NewNPClusHandle
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
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
AllNameStrs = AlreadyCaledDatas.NewAdd_ExistAreaNames;
AllAreaUnitInds = AlreadyCaledDatas.ExistField_ClusIDs;
AllAreaUnitNums = cellfun(@numel,AllAreaUnitInds(:,2));
ExcludeAreaInds = AllAreaUnitNums >= 5;

UsedArea_strs = AllNameStrs(ExcludeAreaInds);
UsedUnitNums = AllAreaUnitNums(ExcludeAreaInds);
UsedUnitInds = AllAreaUnitInds(ExcludeAreaInds,:);
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

BaselineWin = 1:OnsetBin-1;
AfterRespWin = round((0.1:0.1:1)/FrameBinTime)+OnsetBin;

%%






