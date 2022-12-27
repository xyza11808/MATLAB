SavedFolderPathName = 'jeccAnA';
fullsavePath = fullfile(ksfolder, SavedFolderPathName);
AlreadyCaledDatas = load(fullfile(fullsavePath,'CCA_TypeSubCal.mat'),'ExistField_ClusIDs',...
    'NewAdd_ExistAreaNames', 'OutDataStrc');
AreaUnitNumbers = cellfun(@numel,AlreadyCaledDatas.ExistField_ClusIDs(:,2));
load(fullfile(ksfolder,'NewClassHandle2.mat'),'behavResults');
%% some preprocessing
NewBinnedDatas = permute(cat(3,AlreadyCaledDatas.OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
OnsetBin = AlreadyCaledDatas.OutDataStrc.TriggerStartBin;

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
FrameBinTime = AlreadyCaledDatas.OutDataStrc.USedbin(2);
BaselineWin = 1:OnsetBin-1;
AfterRespWin = (0:0.1:1.9)/FrameBinTime+OnsetBin;

ValidWin = 1:(OnsetBin+2/FrameBinTime);
% AfterRespWin = [0:0.1:1.4]/FrameBinTime+OnsetBin;
AllTimeCents = AlreadyCaledDatas.OutDataStrc.BinCenters;
AllTimeWins = {AllTimeCents(BaselineWin),AllTimeCents(AfterRespWin),AllTimeCents(ValidWin)};
%%
PairedAreNums = (NumUsedAreas-1)*NumUsedAreas/2;
PairedAreaCorrs = cell(PairedAreNums, 3);
PairedAreaAvgs = cell(PairedAreNums, 3);
AllPairInfos = cell(PairedAreNums, 7);
AllPairStrs = cell(PairedAreNums, 2);
ks = 1;
for cA1 = 1 : NumUsedAreas
    for cA2 = cA1+1 : NumUsedAreas
        AllPairStrs(ks,:) = {UsedArea_strs{cA1}, UsedArea_strs{cA2}};
        cA1_Data_base = RawResponseData_zs(2:end,UsedUnitInds{cA1,2},BaselineWin);
        cA2_Data_base = RawResponseData_zs(2:end,UsedUnitInds{cA2,2},BaselineWin);
        
        cA1_Data_valid = RawResponseData_zs(2:end,UsedUnitInds{cA1,2},ValidWin);
        cA2_Data_valid = RawResponseData_zs(2:end,UsedUnitInds{cA2,2},ValidWin);
        
        % BVarBaseInfos: BT_A1, BT_A2, choice_A1, choice_A2,prechoice_A1, prechoice_A2
        [BVar_basecorrData, BVar_baseAvgs, BVarBaseInfos] = crossValCCA_SepData_proj_xnInfo(cA1_Data_base,cA1_Data_valid,...
            cA2_Data_base,cA2_Data_valid,0.5, {NMBlockTypeLabels(2:end), NMActionChoices(2:end),NMActionChoices(1:end-1)});
        
        cA1_Data_Af = RawResponseData_zs(2:end,UsedUnitInds{cA1,2},AfterRespWin);
        cA2_Data_Af = RawResponseData_zs(2:end,UsedUnitInds{cA2,2},AfterRespWin);
        
        [BVar_AfcorrData, BVar_AfAvgs, BVarAfInfos] = crossValCCA_SepData_proj_xnInfo(cA1_Data_Af,cA1_Data_valid,...
            cA2_Data_Af,cA2_Data_valid,0.5, {NMBlockTypeLabels(2:end), NMActionChoices(2:end),NMActionChoices(1:end-1)});
        
        PairedAreaCorrs(ks,:) = {BVar_basecorrData, BVar_AfcorrData, sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr),...
            [numel(cf1AreaInds),numel(cf2AreaInds)]};
        PairedAreaAvgs(ks,:) = {BVar_baseAvgs,BVar_AfAvgs};

        TypeDataCalInfo_Choice_A1 = [BVarBaseInfos(3),BVarAfInfos(3)];
        TypeDataCalInfo_BT_A1 = [BVarBaseInfos(1),BVarAfInfos(1)];
        TypeDataCalInfo_Choice_A2 = [BVarBaseInfos(4),BVarAfInfos(4)];
        TypeDataCalInfo_BT_A2 = [BVarBaseInfos(2),BVarAfInfos(2)];
        TypeDataCalInfo_preCh_A1 = [BVarBaseInfos(5),BVarAfInfos(5)];
        TypeDataCalInfo_preCh_A2 = [BVarBaseInfos(6),BVarAfInfos(6)];
        
        AllPairInfos(ks,:) = {TypeDataCalInfo_BT_A1,TypeDataCalInfo_BT_A2...
            TypeDataCalInfo_Choice_A1,TypeDataCalInfo_Choice_A2,...
            TypeDataCalInfo_preCh_A1,TypeDataCalInfo_preCh_A2,sprintf('%s-%s',cf1AreaNameStr,cf2AreaNameStr)};
        
    end
end

%%
dataSavefolder = fullfile(ksfolder, SavedFolderPathName,'RawDataInfo');
if ~isfolder(dataSavefolder)
    mkdir(dataSavefolder);
end
dataSavefile = fullfile(dataSavefolder,'RawData_CCACorr_AllInfo.mat');
save(dataSavefile,'PairedAreaCorrs','PairedAreaAvgs','AllPairInfos','AllPairStrs','AllTimeWins','-v7.3')


