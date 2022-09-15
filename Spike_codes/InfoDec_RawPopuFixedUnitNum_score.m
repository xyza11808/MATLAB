
clearvars SessAreaIndexStrc ProbNPSess AreainfosAll InfoCodingStrc ChoiceInfos BTInfos

% load('Chnlocation.mat');

% load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
% if isempty(fieldnames(SessAreaIndexStrc.ACAv)) && isempty(fieldnames(SessAreaIndexStrc.ACAd))...
%          && isempty(fieldnames(SessAreaIndexStrc.ACA))
%     return;
% end
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);


%% find target cluster inds and IDs
% ksfolder = pwd;

NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
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

BlockTypesAll = double(behavResults.BlockType(:));
%%
SavedFolderPathName = 'ChoiceANDBT_LDAinfo_ana';

fullsavePath = fullfile(ksfolder, SavedFolderPathName);
% if isfolder(fullsavePath)
%     rmdir(fullsavePath,'s');
% end
% 
% mkdir(fullsavePath);
if ~isfolder(fullsavePath)
    mkdir(fullsavePath);
end
%%
CommonUnitNums = 15;

ActionInds = double(behavResults.Action_choice(:));
NMTrInds = ActionInds ~= 2;
ActTrs = ActionInds(NMTrInds);

NMActionChoices = ActionInds(NMTrInds);
BlockTypeAll = double(behavResults.BlockType(:));
NMBlockTypes = BlockTypeAll(NMTrInds);
% AllTrInds = {double(behavResults.Action_choice(:)),double(behavResults.BlockType(:))};
LowBoundBlockInds = NMBlockTypes == 0;
HighBoundBlockInds = NMBlockTypes == 1;

TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
BlockSectionInfo = Bev2blockinfoFun(behavResults);
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
RevFreqInds = (ismember(TrialFreqsAll,RevFreqs));
NMRevFreqInds = RevFreqInds(NMTrInds);

AreaDecodeDataCell = cell(Numfieldnames,4);
for cArea = 1 : Numfieldnames

    cUsedAreas = NewAdd_ExistAreaNames{cArea};
    cAUnits = ExistField_ClusIDs{cArea,2};
    if length(cAUnits) < CommonUnitNums
        continue;
    elseif length(cAUnits) < CommonUnitNums+4
        RepeatNums = 200;
    else
        RepeatNums = 1000;
    end
    
    BaselineData = mean(NewBinnedDatas(NMTrInds,cAUnits,1:(OutDataStrc.TriggerStartBin-1)),3);
    
    RespDataUsedMtxAll = NewBinnedDatas(NMTrInds,cAUnits,OutDataStrc.TriggerStartBin+(1:15));
    RespDataUsedMtx = mean(RespDataUsedMtxAll,3);
    cAROINum = size(RespDataUsedMtx,2);
    
    BaseSubRespData = RespDataUsedMtx - BaselineData;
    RepeatData = cell(RepeatNums,1);
    sampleScoreMtx = zeros(RepeatNums,8);
    BlockScoreMtx = zeros(RepeatNums,3);
    dSqrANDperfMtx = zeros(RepeatNums,5,2);
    for cR = 1 : RepeatNums
        SampleInds = randsample(cAROINum,CommonUnitNums);
        cc = cvpartition(size(BaseSubRespData,1),'kFold',2);

        FI_training_Inds = TrainBaseAll;
        FI_training_Inds(cc.test(1)) = true;

        Final_test_Inds = TrainBaseAll;
        Final_test_Inds(cc.test(2)) = true;
        % start with low block training
%         LowBoundChoices = NMActionChoices(LowBoundBlockInds);
        [DisScore,MdPerfs,SampleScores,beta] = LDAclassifierFun(BaseSubRespData(:,SampleInds), ...
            NMActionChoices, {~NMRevFreqInds,NMRevFreqInds});
        NRevTr_baseSubPointScore = SampleScores{1};
        NRevTrChoices = NMActionChoices(~NMRevFreqInds);
        RevTr_baseSubPointScore = SampleScores{2};
        RevTrChoices = NMActionChoices(NMRevFreqInds);
        
        ClassBound = SampleScores{3};
        
        [RevTrChoiceD_sqr,RevTrChoiceAccu,RevTrChoiceScores] = ...
            LDAclassifierFun_Score(RespDataUsedMtx(NMRevFreqInds,SampleInds), NMActionChoices(NMRevFreqInds),beta,SampleScores{3});
        [NRevTrChoiceD_sqr,NRevTrChoiceAccu,NRevTrChoiceScores] = ...
            LDAclassifierFun_Score(RespDataUsedMtx(~NMRevFreqInds,SampleInds), NMActionChoices(~NMRevFreqInds),beta,SampleScores{3});
        
        [TrBaseD_sqr,TrBaseAccu,TrBaseScores] = ...
            LDAclassifierFun_Score(BaselineData(:,SampleInds), NMBlockTypes,beta,SampleScores{3});
        
        ChoiceScoresSum = struct();
        ChoiceScoresSum.BS_NRevTr_score = [mean(NRevTr_baseSubPointScore(NRevTrChoices == 0)),...
            mean(NRevTr_baseSubPointScore(NRevTrChoices == 1))];
        ChoiceScoresSum.BS_RevTr_score = [mean(RevTr_baseSubPointScore(RevTrChoices == 0)),...
            mean(RevTr_baseSubPointScore(RevTrChoices == 1))];
        
        ChoiceScoresSum.RespData_NRT_score = [mean(NRevTrChoiceScores(NMActionChoices(~NMRevFreqInds) == 0)),...
            mean(NRevTrChoiceScores(NMActionChoices(~NMRevFreqInds) == 1))];
        ChoiceScoresSum.RespData_RT_score = [mean(RevTrChoiceScores(NMActionChoices(NMRevFreqInds) == 0)),...
            mean(RevTrChoiceScores(NMActionChoices(NMRevFreqInds) == 1))];
        
        ChoiceScoresSum.Base_LHBound_score = [mean(TrBaseScores(NMBlockTypes == 0)),mean(TrBaseScores(NMBlockTypes == 1))];
        
        ChoiceScoresSum.All_dsqrs = [DisScore,RevTrChoiceD_sqr,NRevTrChoiceD_sqr,TrBaseD_sqr];
        ChoiceScoresSum.All_perfs = [MdPerfs,RevTrChoiceAccu,NRevTrChoiceAccu,TrBaseAccu];
        
        % calculate block type decoding vector
        [DisScore_BT,MdPerfs_BT,SampleScores_BT,beta_BT] = ...
            LDAclassifierFun(BaselineData(:,SampleInds), NMBlockTypes,{~NMRevFreqInds,NMRevFreqInds});
        ChoiceScoresSum.Base_BT_dsqr = DisScore_BT;
        ChoiceScoresSum.Base_BT_perf = MdPerfs_BT;
        ChoiceScoresSum.Base_SampleScore = SampleScores_BT;
        ChoiceScoresSum.Choice_BT_Vec = {beta,beta_BT};
        
        RepeatData{cR} = ChoiceScoresSum;
        
        sampleScoreMtx(cR,:) = [ChoiceScoresSum.BS_NRevTr_score,ChoiceScoresSum.BS_RevTr_score,...
            ChoiceScoresSum.RespData_NRT_score,ChoiceScoresSum.RespData_RT_score];
        BlockScoreMtx(cR,:) = [ChoiceScoresSum.Base_LHBound_score,VecAnglesFun(beta,beta_BT)];
        dSqrANDperfMtx(cR,:,1) = ChoiceScoresSum.All_dsqrs;
        dSqrANDperfMtx(cR,:,2) = ChoiceScoresSum.All_perfs;
    end
    
    AreaDecodeDataCell(cArea,:) = {RepeatData,sampleScoreMtx,BlockScoreMtx,dSqrANDperfMtx};
end


%% performing some post processing
if Numfieldnames == 1
    ChoiceInfos = (squeeze(AreainfosAll(:,1,:)))';
    BTInfos = (squeeze(AreainfosAll(:,2,:)))';
else
    ChoiceInfos = squeeze(AreainfosAll(:,1,:));
    BTInfos = squeeze(AreainfosAll(:,2,:));
end
IsAreaCaled = ~cellfun(@isempty,ChoiceInfos(:,1));
if sum(IsAreaCaled)
    ChoiceInfoAvgs = cellfun(@mean,ChoiceInfos,'un',0);
    ChoiceInfo_train = cellfun(@(x) x(1),ChoiceInfoAvgs(IsAreaCaled,:));
    ChoiceInfo_test = cellfun(@(x) x(2),ChoiceInfoAvgs(IsAreaCaled,:));
    
    
    BTInfoAvgs = cellfun(@mean,BTInfos,'un',0);
    BTInfo_train = cellfun(@(x) x(1),BTInfoAvgs(IsAreaCaled,:));
    BTInfo_test = cellfun(@(x) x(2),BTInfoAvgs(IsAreaCaled,:));

    InfoCodingStrc = struct();
    InfoCodingStrc.ExistField_ClusIDs_used = ExistField_ClusIDs(IsAreaCaled,:);
    InfoCodingStrc.CalAreaInds = IsAreaCaled;
    InfoCodingStrc.ChoiceInfo_train = ChoiceInfo_train;
    InfoCodingStrc.ChoiceInfo_test = ChoiceInfo_test;
    InfoCodingStrc.BTInfo_train = BTInfo_train;
    InfoCodingStrc.BTInfo_test = BTInfo_test;
else
    InfoCodingStrc = [];
end
%%
save(fullfile(fullsavePath,'LDAinfo_fixedSizePopuData.mat'), 'AreainfosAll', 'AllTrInds', ...
    'ExistField_ClusIDs', 'NewAdd_ExistAreaNames','AreaUnitNumbers', 'InfoCodingStrc', '-v7.3');
