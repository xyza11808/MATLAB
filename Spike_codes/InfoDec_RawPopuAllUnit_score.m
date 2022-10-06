
clearvars SessAreaIndexStrc ProbNPSess AreaDecodeDataCell AreaProcessDatas BlockpsyInfo ExistField_ClusIDs NewAdd_ExistAreaNames

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

SavedFolderPathName = 'ChoiceANDBT_LDAinfo_ana';
fullsavePath = fullfile(ksfolder, SavedFolderPathName);

% load(fullfile(fullsavePath,'LDAinfo_ChoiceScores.mat'));
% save(fullfile(fullsavePath,'LDAinfo_ChoiceScores.mat'), 'AreaDecodeDataCell', 'BlockpsyInfo',...
%     'ExistField_ClusIDs', 'NewAdd_ExistAreaNames','AreaUnitNumbers', 'AreaProcessDatas','OutDataStrc','-v7.3');
% 
% return;

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
%% Use this section to perform some extra data processing
RegRawDataSavePath = fullfile(ksfolder,'Regressor_ANA');
RegRawDatafilePath = fullfile(RegRawDataSavePath,'RegRespDataANDTrIndex.mat');

[BinnedSPdatas,FinalUsedBinTrInds] = BinnedRespDataCalFun(ProbNPSess, NewSessAreaStrc,behavResults);

save(RegRawDatafilePath,'BinnedSPdatas','FinalUsedBinTrInds','-v7.3');


%%

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
BlockpsyInfo = behav2blockcurve(behavResults);

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
NMRevFreqIndsRaw = RevFreqInds(NMTrInds);
NMTrFreqsAll = TrialFreqsAll(NMTrInds);

FreqTypes = unique(NMTrFreqsAll);
FreqTypeNum = length(FreqTypes);

AreaDecodeDataCell = cell(Numfieldnames,5);
AreaProcessDatas = cell(Numfieldnames,4);
AreaFreqwiseScores = cell(Numfieldnames,3);
for cArea = 1 : Numfieldnames

    cUsedAreas = NewAdd_ExistAreaNames{cArea};
    cAUnits = ExistField_ClusIDs{cArea,2};
%     if length(cAUnits) < CommonUnitNums
%         continue;
%     elseif length(cAUnits) < CommonUnitNums+4
        RepeatNums = 200;
%     else
%         RepeatNums = 1000;
%     end
    
    BaselineData = mean(NewBinnedDatas(NMTrInds,cAUnits,1:(OutDataStrc.TriggerStartBin-1)),3);
    
    RespDataUsedMtxAll = NewBinnedDatas(NMTrInds,cAUnits,OutDataStrc.TriggerStartBin+(1:15));
    RespDataUsedMtx = mean(RespDataUsedMtxAll,3);
    cAROINum = size(RespDataUsedMtx,2);
    
    BaseSubRespData = RespDataUsedMtx - BaselineData;
    
    RepeatData = cell(RepeatNums,1);
    sampleScoreMtx = zeros(RepeatNums,8);
    BlockScoreMtx = zeros(RepeatNums,5);
    dSqrANDperfMtx = zeros(RepeatNums,8,2);
    BaseBTLDAscore = zeros(RepeatNums,4);
    
    BaseSub_freqwiseScore = zeros(RepeatNums,FreqTypeNum,2);
    RawResp_freqwiseScore = zeros(RepeatNums,FreqTypeNum,2);
    BaseData_freqwiseScore = zeros(RepeatNums,FreqTypeNum,2);
    
    for cR = 1 : RepeatNums
        SampleInds = true(cAROINum,1); %randsample
        NMRevTrNum = sum(NMRevFreqIndsRaw);
        NonRevTrNum = sum(~NMRevFreqIndsRaw);
        if NMRevTrNum < NonRevTrNum
            NMRevFreqInds = NMRevFreqIndsRaw; 
            NonRevTrIndex = find(~NMRevFreqIndsRaw);
            sampleInds = randsample(NonRevTrNum, NonRevTrNum - NMRevTrNum);
            NonRevFreqInds = ~NMRevFreqIndsRaw;
            NonRevFreqInds(NonRevTrIndex(sampleInds)) = false;
        else
            NonRevFreqInds = ~NMRevFreqIndsRaw;
            RevTrIndex = find(NMRevFreqIndsRaw);
            sampleInds = randsample(NMRevTrNum, NMRevTrNum - NonRevTrNum);
            NMRevFreqInds = NMRevFreqIndsRaw;
            NMRevFreqInds(RevTrIndex(sampleInds)) = false;
        end
        AllUsedTrInds = (NMRevFreqInds | NonRevFreqInds);
        [DisScore,MdPerfs,SampleScores,beta] = LDAclassifierFun(BaseSubRespData(:,SampleInds), ...
            NMActionChoices, {NonRevFreqInds,NMRevFreqInds});
        NRevTr_baseSubPointScore = SampleScores{1};
        NRevTrChoices = NMActionChoices(NonRevFreqInds);
        RevTr_baseSubPointScore = SampleScores{2};
        RevTrChoices = NMActionChoices(NMRevFreqInds);
        
        [DisScoreRawResp,MdPerfsRawResp,~,betaRawResp] = LDAclassifierFun(RespDataUsedMtx(:,SampleInds), ...
            NMActionChoices, {NonRevFreqInds,NMRevFreqInds});
        
        
%         ClassBound = SampleScores{3};
        % just used as a control of score calculation, compared with the
        % second term in the DisScore and MdPerfs data
        [BSRevTrChoiceD_sqr,BSRevTrChoiceAccu,~] = ...
            LDAclassifierFun_Score(BaseSubRespData(NMRevFreqInds,SampleInds), NMActionChoices(NMRevFreqInds),beta);
        
        [RevTrChoiceD_sqr,RevTrChoiceAccu,RevTrChoiceScores] = ...
            LDAclassifierFun_Score(RespDataUsedMtx(NMRevFreqInds,SampleInds), NMActionChoices(NMRevFreqInds),beta);
        [NRevTrChoiceD_sqr,NRevTrChoiceAccu,NRevTrChoiceScores] = ...
            LDAclassifierFun_Score(RespDataUsedMtx(NonRevFreqInds,SampleInds), NMActionChoices(NonRevFreqInds),beta);
        
        [TrBaseD_sqr,TrBaseAccu,TrBaseScores] = ...
            LDAclassifierFun_Score(BaselineData(:,SampleInds), NMBlockTypes,beta);
        
        OutPutFreqwiseScores = TrScore2Octwise(NMTrFreqsAll,{NMRevFreqInds,NonRevFreqInds},...
            NMBlockTypes,TrBaseScores,SampleScores,{RevTrChoiceScores,NRevTrChoiceScores});
        BaseSub_freqwiseScore(cR,:,:) = squeeze(OutPutFreqwiseScores{2}(:,1,:));
        RawResp_freqwiseScore(cR,:,:) = squeeze(OutPutFreqwiseScores{3}(:,1,:));
        BaseData_freqwiseScore(cR,:,:) = squeeze(OutPutFreqwiseScores{4}(:,1,:));
        
        ChoiceScoresSum = struct();
        ChoiceScoresSum.BS_NRevTr_score = [mean(NRevTr_baseSubPointScore(NRevTrChoices == 0)),...
            mean(NRevTr_baseSubPointScore(NRevTrChoices == 1))];
        ChoiceScoresSum.BS_RevTr_score = [mean(RevTr_baseSubPointScore(RevTrChoices == 0)),...
            mean(RevTr_baseSubPointScore(RevTrChoices == 1))];
        
        ChoiceScoresSum.RespData_NRT_score = [mean(NRevTrChoiceScores(NMActionChoices(NonRevFreqInds) == 0)),...
            mean(NRevTrChoiceScores(NMActionChoices(NonRevFreqInds) == 1))];
        ChoiceScoresSum.RespData_RT_score = [mean(RevTrChoiceScores(NMActionChoices(NMRevFreqInds) == 0)),...
            mean(RevTrChoiceScores(NMActionChoices(NMRevFreqInds) == 1))];
        
        ChoiceScoresSum.Base_LHBound_score = [mean(TrBaseScores(NMBlockTypes == 0)),mean(TrBaseScores(NMBlockTypes == 1))];
        
        ChoiceScoresSum.All_dsqrs = [DisScore,RevTrChoiceD_sqr,NRevTrChoiceD_sqr,TrBaseD_sqr,...
            BSRevTrChoiceD_sqr,DisScoreRawResp]; 
        ChoiceScoresSum.All_perfs = [MdPerfs,RevTrChoiceAccu,NRevTrChoiceAccu,TrBaseAccu,...
            BSRevTrChoiceAccu,MdPerfsRawResp];
        
        % calculate block type decoding vector
        [DisScore_BT,MdPerfs_BT,SampleScores_BT,beta_BT] = ...
            LDAclassifierFun(BaselineData(:,SampleInds), NMBlockTypes,{NonRevFreqInds,NMRevFreqInds});
        ChoiceScoresSum.Base_BT_dsqr = DisScore_BT;
        ChoiceScoresSum.Base_BT_perf = MdPerfs_BT;
        ChoiceScoresSum.Base_SampleScoreAll = SampleScores_BT;
        ChoiceScoresSum.Choice_BT_Vec = {beta,beta_BT,betaRawResp};
        
        RepeatData{cR} = ChoiceScoresSum;
        
        sampleScoreMtx(cR,:) = [ChoiceScoresSum.BS_NRevTr_score,ChoiceScoresSum.BS_RevTr_score,...
            ChoiceScoresSum.RespData_NRT_score,ChoiceScoresSum.RespData_RT_score];
        BlockScoreMtx(cR,:) = [ChoiceScoresSum.Base_LHBound_score,VecAnglesFun(beta,beta_BT),...
            VecAnglesFun(beta,betaRawResp),VecAnglesFun(betaRawResp,beta_BT)];
        dSqrANDperfMtx(cR,:,1) = ChoiceScoresSum.All_dsqrs;
        dSqrANDperfMtx(cR,:,2) = ChoiceScoresSum.All_perfs;
        BaseBTLDAscore(cR,:) = [DisScore_BT,MdPerfs_BT];
    end
    
    AreaDecodeDataCell(cArea,:) = {RepeatData,sampleScoreMtx,BlockScoreMtx,dSqrANDperfMtx,BaseBTLDAscore};
    AreaProcessDatas(cArea,:) = {mean(sampleScoreMtx),mean(BlockScoreMtx),squeeze(mean(dSqrANDperfMtx)),mean(BaseBTLDAscore)};
    AreaFreqwiseScores(cArea,:) = {BaseSub_freqwiseScore,RawResp_freqwiseScore,BaseData_freqwiseScore};
end


%%
save(fullfile(fullsavePath,'LDAinfo_FreqwiseScoresAllUnit.mat'), 'AreaDecodeDataCell', 'BlockpsyInfo',...
    'ExistField_ClusIDs', 'NewAdd_ExistAreaNames','AreaUnitNumbers', 'AreaProcessDatas',...
    'OutDataStrc','AreaFreqwiseScores','FreqTypes','-v7.3');

% figure;hold on
% plot(BlockpsyInfo.lowfitmd.curve(:,1),BlockpsyInfo.lowfitmd.curve(:,2),'k');
% plot(BlockpsyInfo.highfitmd.curve(:,1),BlockpsyInfo.highfitmd.curve(:,2),'r');
