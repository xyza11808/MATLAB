
clearvars AreaChocieDecData ProbNPSess ExistField_ClusIDs
load(fullfile(ksfolder,'NewClassHandle2.mat'));
ProbNPSess = NewNPClusHandle;
ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
if isempty(ProbNPSess.SpikeTimes)
    ProbNPSess.SpikeTimes = double(ProbNPSess.SpikeTimeSample)/30000;
end
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 4],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
NumFrameBins = size(NewBinnedDatas,3);

OnsetBin = OutDataStrc.TriggerStartBin - 1;
BaselineResp = mean(NewBinnedDatas(:,:,1:OnsetBin),3);
BaseLineEndInds = OutDataStrc.TriggerStartBin - 1;
BaseSubData = NewBinnedDatas - repmat(BaselineResp,1,1,NumFrameBins);

%% find target cluster inds and IDs

NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNewAlign2.mat'));
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
        repmat(NewAdd_ExistAreaNames(cA),numel(cA_clus_inds),1)}; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    
end
%%
% USedAreas = cell2mat(ExistField_ClusIDs(:,3)) < 1;
% if sum(USedAreas)
%     ExistField_ClusIDs(USedAreas,:) = [];
%     AreaUnitNumbers(USedAreas) = [];
%     Numfieldnames = Numfieldnames - sum(USedAreas);
%     NewAdd_ExistAreaNames(USedAreas) = [];
% end

BlockSectionInfo = Bev2blockinfoFun(behavResults);

UsedBlockInds = 1 : BlockSectionInfo.BlockTrScales(end,2);
ActionChoices = double(behavResults.Action_choice(:));
TrFreqs = double(behavResults.Stim_toneFreq(:));
TrBlockTypes = double(behavResults.BlockType(:));
TrTrialType = double(behavResults.Trial_Type(:));
TrRewardTime = double(behavResults.Time_reward(:));
TrBlockSWInds = [1;abs(diff(TrBlockTypes))];
TrBlockSeqIndex = cumsum(TrBlockSWInds);

UsedTrInds_Choices = ActionChoices(UsedBlockInds);
UsedTrInds_NMInds = find(UsedTrInds_Choices ~= 2);
UsedTrInds_NMChoice = UsedTrInds_Choices(UsedTrInds_NMInds);
UsedTrInds_NMFreqs = TrFreqs(UsedTrInds_NMInds);
UsedTrInds_NMBTs = TrBlockTypes(UsedTrInds_NMInds);
UsedTrInds_NMRT = TrRewardTime(UsedTrInds_NMInds);
UsedTrInds_NMSeqIndex = TrBlockSeqIndex(UsedTrInds_NMInds);
UsedTrInds_NMTrTtypes = TrTrialType(UsedTrInds_NMInds);

FreqTypes = unique(UsedTrInds_NMFreqs);
FreqTypeNum = length(FreqTypes);
RevFreqs = BlockSectionInfo.BlockFreqTypes(BlockSectionInfo.IsFreq_asReverse > 0);
%

%%
saveFolder = fullfile(ksfolder,'BlockChoiceDecWeight');
if ~isfolder(saveFolder)
    mkdir(saveFolder);
end

%%
AreaChocieDecData = cell(length(NewAdd_ExistAreaNames),2);

for cA = 1 : length(NewAdd_ExistAreaNames)
    UsedUnitInds = ExistField_ClusIDs{cA,2};
    if length(UsedUnitInds) < 5
        continue;
    end
    AreaStr = NewAdd_ExistAreaNames{cA};
    % UsedTrNMDatas = NewBinnedDatas(UsedTrInds_NMInds,UsedUnitInds,:);
    UsedTrNMDatas = BaseSubData(UsedTrInds_NMInds,UsedUnitInds,:);
    UsedTrNMDatas_raw = NewBinnedDatas(UsedTrInds_NMInds,UsedUnitInds,:);
    
    [NumNMTrials, ~, NumTimeBins] = size(UsedTrNMDatas);
    
    RepeatNum = 10;
    RepeatInfo = zeros(RepeatNum,NumTimeBins,2);
    AllRepeatBetas = cell(RepeatNum,NumTimeBins);
    
    for cR = 1 : RepeatNum
        
        cR_TrainIndex = randsample(NumNMTrials,round(NumNMTrials*0.6));
        cR_TrainBaseInds = false(NumNMTrials,1);
        cR_TrainBaseInds(cR_TrainIndex) = true;
        cR_TestInds = ~cR_TrainBaseInds;
        
        TimeBinInfos = zeros(NumTimeBins,2);
        for cBin = 1 : NumTimeBins
            cBinData = UsedTrNMDatas(:,:,cBin);
            
            [InfoScore,~,~,beta] = LDAclassifierFun(cBinData,UsedTrInds_NMChoice,...
                {cR_TrainBaseInds,cR_TestInds});
            TimeBinInfos(cBin,:) = InfoScore;
            AllRepeatBetas(cR,cBin) = {beta};
            
        end
        RepeatInfo(cR,:,:) = TimeBinInfos;
    end
    
    % find maximum choice info frame bin
    InfoRepeatAvgs = squeeze(mean(RepeatInfo));
    [~, MaxInds] = max(InfoRepeatAvgs(:,2));

    RepeatNum = 50;
    baseSubData_maxframe = UsedTrNMDatas(:,:,MaxInds);
    baseSubData_maxframeZS = zscore(baseSubData_maxframe);
    [RepeatInfo_Sub,RepeatAccu_Sub,AllRepeatBetas_Sub,BlockChoiceVecAngleSub,BlockIndsSub,BlockShufDecsSub,BlockDataCSub] = ...
        BlockWiseChoiceDecVec(baseSubData_maxframeZS, UsedTrInds_NMSeqIndex, ...
        UsedTrInds_NMChoice, BlockSectionInfo.NumBlocks, RepeatNum);
    
    RawDataMaxF = UsedTrNMDatas_raw(:,:,MaxInds);
    RawDataMaxF_zs = zscore(RawDataMaxF);
    [RepeatInfo_Raw,RepeatAccu_Raw,AllRepeatBetas_Raw,BlockChoiceVecAngleRaw,BlockIndsRaw,BlockShufDecsRaw,BlockDataCRaw] = ...
        BlockWiseChoiceDecVec(RawDataMaxF_zs, UsedTrInds_NMSeqIndex, ...
        UsedTrInds_NMChoice, BlockSectionInfo.NumBlocks, RepeatNum);
    
    %
    hf = figure('position',[50 50 680 540]);
    axSub = subplot(121);
    [hfSub, BetaValuesAllSub, BetaRespIndsAllSub] = UnitDecWeightPlot(AllRepeatBetas_Sub, BlockShufDecsSub,axSub);
    xlabel(axSub, sprintf('Baseline substracted data (%s)',AreaStr));
    axRaw = subplot(122);
    [hfRaw, BetaValuesAllRaw, BetaRespIndsAllRaw] = UnitDecWeightPlot(AllRepeatBetas_Raw, BlockShufDecsRaw,axRaw);
    xlabel(axRaw,sprintf('Raw data (%s)',AreaStr));
    
    figSavePath = fullfile(saveFolder,sprintf('Area %s Choice decode weight plot',AreaStr));
    saveas(hf,figSavePath);
    print(hf,figSavePath,'-dpng','-r300');
    print(hf,figSavePath,'-dpdf','-bestfit');
    close(hf);
    
    SubDataStrc = struct();
    SubDataStrc.RepeatInfo = RepeatInfo_Sub;
    SubDataStrc.RepeatAccu = RepeatAccu_Sub;
    SubDataStrc.AllRepeatBetas = AllRepeatBetas_Sub;
    SubDataStrc.BlockChoiceVecAngle = BlockChoiceVecAngleSub;
    SubDataStrc.BlockInds = BlockIndsSub;
    SubDataStrc.BlockShufDecs = BlockShufDecsSub;
    SubDataStrc.BetaValuesAll = BetaValuesAllSub;
    SubDataStrc.BetaRespIndsAll = BetaRespIndsAllSub;
    
    RawDataStrc = struct();
    RawDataStrc.RepeatInfo = RepeatInfo_Raw;
    RawDataStrc.RepeatAccu = RepeatAccu_Raw;
    RawDataStrc.AllRepeatBetas = AllRepeatBetas_Raw;
    RawDataStrc.BlockChoiceVecAngle = BlockChoiceVecAngleRaw;
    RawDataStrc.BlockInds = BlockIndsRaw;
    RawDataStrc.BlockShufDecs = BlockShufDecsRaw;
    RawDataStrc.BetaValuesAll = BetaValuesAllRaw;
    RawDataStrc.BetaRespIndsAll = BetaRespIndsAllRaw;
    
    AreaChocieDecData(cA,:) = {SubDataStrc, RawDataStrc};
    
    % cross valid decoding score using beta from one block to another
    CalMtx = ones(BlockSectionInfo.NumBlocks) - eye(BlockSectionInfo.NumBlocks);
    CalMtxAll = cell(BlockSectionInfo.NumBlocks);
    for cB = 1 : BlockSectionInfo.NumBlocks
        for cBTarg = 1 : BlockSectionInfo.NumBlocks
            
            if CalMtx(cB,cBTarg) % not the same block
                RepeatScores = zeros(RepeatNum,2,2);
                for cR = 1 : RepeatNum
                    cR_cB_beta = AllRepeatBetas_Sub{cB, cR};
                    cTargData = BlockDataCSub{cBTarg,1};
                    cTargChoice = BlockDataCSub{cBTarg,2};
                    [shufD_sqr,ShufAccu,~] = ...
                        LDAclassifierFun_Score(cTargData, cTargChoice,cR_cB_beta);
                    RepeatScores(cR,:,1) = [shufD_sqr,ShufAccu];
                    
                    % calculate the raw data
                    cR_cB_betaRaw = AllRepeatBetas_Raw{cB, cR};
                    cTargDataRaw = BlockDataCRaw{cBTarg,1};
                    cTargChoiceRaw = BlockDataCRaw{cBTarg,2};
                    [shufD_sqr,ShufAccu,~] = ...
                        LDAclassifierFun_Score(cTargDataRaw, cTargChoiceRaw,cR_cB_betaRaw);
                    RepeatScores(cR,:,2) = [shufD_sqr,ShufAccu];
                end
                CalMtxAll(cB,cBTarg) = {RepeatScores};
            end
        end
    end
end

datasavepath = fullfile(saveFolder,'ChoiceDecWeights.mat');
save(datasavepath,'AreaChocieDecData',...
    'ExistField_ClusIDs','NewAdd_ExistAreaNames','CalMtxAll','CalMtx','-v7.3');

