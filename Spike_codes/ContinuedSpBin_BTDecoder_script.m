% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
ksfolder = pwd;
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

%% find target cluster inds and IDs
NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNew.mat'));
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

UsedAreaInds = cell2mat(ExistField_ClusIDs(:,3)) > 0;
ExistField_ClusIDs = ExistField_ClusIDs(UsedAreaInds,:);
AreaUnitNumbers = AreaUnitNumbers(UsedAreaInds);
NewAdd_ExistAreaNames = NewAdd_ExistAreaNames(UsedAreaInds);
Numfieldnames = sum(UsedAreaInds);
%%

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

TaskTrigOnTimes = ProbNPSess.UsedTrigOnTime{ProbNPSess.CurrentSessInds};

BeforeFirstTrigLen = 10; % seconds
AfterLastTrigLen = 30; % seconds
TaskUsedTimeScale = [TaskTrigOnTimes(1) - BeforeFirstTrigLen,...
    TaskTrigOnTimes(end) + AfterLastTrigLen];
TotalBinSpikeLen = diff(TaskUsedTimeScale);
TaskTrigTimeAligns = TaskTrigOnTimes - TaskTrigOnTimes(1) + BeforeFirstTrigLen;
TotalTrialNum = length(TaskTrigTimeAligns); % number of trials in total

UsedUnitIDs_All = cell2mat(ExistField_ClusIDs(:,1));
UsedClusInds = ismember(ProbNPSess.SpikeClus, UsedUnitIDs_All);
UsedSpTimes = ProbNPSess.SpikeTimes > TaskUsedTimeScale(1) & ...
    ProbNPSess.SpikeTimes < TaskUsedTimeScale(2);

UsedClusPos = ProbNPSess.SpikeClus(UsedClusInds & UsedSpTimes);
UsedSPTimes = ProbNPSess.SpikeTimes(UsedClusInds & UsedSpTimes) - ...
    TaskTrigOnTimes(1) + BeforeFirstTrigLen; % realigned to first trigger on time

% ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]);
% if ~isempty(ProbNPSess.SurviveInds)
%     SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
% end
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[200 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
NewBin_StimOnset = OutDataStrc.TriggerStartBin;
% SMBinDataMtxRaw = SMBinDataMtx;
clearvars ProbNPSess

%% define center block trInds for training
CenterTrUsedWins = [-70,70]; % block center used trial windows

[TotalTrialNums, ~, FrameBinNum] = size(NewBinnedDatas);
TrainTrInds = false(TotalTrialNums,1);
for cB = 1 : length(BlockSectionInfo.BlockTypes)
    cBlockTrialScales = BlockSectionInfo.BlockTrScales(cB,:);
    BlockCenterInds = round(mean(cBlockTrialScales));
    TrainWinTrs = BlockCenterInds + CenterTrUsedWins;
    
    TrainTrInds(TrainWinTrs(1):TrainWinTrs(2)) = true;
    
end
TestTrInds = ~TrainTrInds;
TrBlocktypes = uint16(behavResults.BlockType);

% SVM loop through each time bin for each area population
for cA = 1 : Numfieldnames
    
    for cBin = 1 : FrameBinNum
        cA_cBin_datas = NewBinnedDatas(:, ExistField_ClusIDs{cA,2},cBin);
        
        TrainDataFits = fitcsvm(cA_cBin_datas(TrainTrInds,:), TrBlocktypes(TrainTrInds));
        
        [TestDataPred, TestDataPredScore] = predict(TrainDataFits,cA_cBin_datas(TestTrInds,:));
        TestDataRealBT = TrBlocktypes(TestTrInds);
        
        % not finished
        
    end
end
        
        
        

%%
% % TimeBinSize = single(0.1);
% % 
% % % unique and binned cluster spikes through the whole session
% % UsedClusNum = size(UsedUnitIDs_All,1);
% % BinEdges = 0:TimeBinSize:TotalBinSpikeLen;
% % BinCenters = BinEdges(1:end-1) + TimeBinSize/2;
% % NumofSPcounts = numel(BinCenters);
% % BinnedSPdatas = zeros(UsedClusNum,NumofSPcounts,'single');
% % for cClus = 1 : UsedClusNum
% %     cClusSPCounts = histcounts(UsedSPTimes(UsedClusPos == UsedUnitIDs_All(cClus,1)),...
% %         BinEdges);
% %     BinnedSPdatas(cClus, :) = cClusSPCounts;
% % end
% % BinnedSPdatas = BinnedSPdatas./nanstd(BinnedSPdatas,[],2);
% % 
% % %% extract blocktypes to tiral times info
% % BlockSectionInfo = Bev2blockinfoFun(behavResults);
% % % TotalTrialNum
% % BTDataBin = zeros(1, NumofSPcounts,'single');
% % for cB = 1 : length(BlockSectionInfo.BlockTypes)
% %     cBlockTrialInds = BlockSectionInfo.BlockTrScales(cB,:);
% %     if cB == 1
% %         cB_startTrTime = 0;
% %     else
% %         cB_startTrTime = TaskTrigTimeAligns(cBlockTrialInds(1));
% %     end
% %     cB_endTrTime = TaskTrigTimeAligns(cBlockTrialInds(2)+1) - TimeBinSize;
% %     BTDataBin(1,BinEdges(1:end-1) >= cB_startTrTime & BinEdges(1:end-1) < cB_endTrTime) = ...
% %         BlockSectionInfo.BlockTypes(cB);
% % end
% % if BlockSectionInfo.BlockTrScales(end,2) < TotalTrialNum
% %     % extra block trial exists, but not longer longer enough to be included
% %     % as another block
% %     UsedBlockEndInds = TaskTrigTimeAligns(BlockSectionInfo.BlockTrScales(end,2)+1);
% %     BTDataBin(1,BinEdges(1:end-1) > UsedBlockEndInds) = 1 - BlockSectionInfo.BlockTypes(end);
% % end
% % % BTDataBin(2,:) = 1 - BTDataBin(1,:);
% % Behav_stimOnset = single(behavResults.Time_stimOnset(:))/1000; % seconds
% % Behav_SessStimOnTime = Behav_stimOnset + TaskTrigTimeAligns(:);
% % 
% % %% define center block trInds for training
% % CenterTrUsedWins = [-60,60]; % block center used trial windows
% % SessBin_trainInds = false(NumofSPcounts,2);
% % for cB = 1 : length(BlockSectionInfo.BlockTypes)
% %     cBlockTrialScales = BlockSectionInfo.BlockTrScales(cB,:);
% %     BlockCenterInds = round(mean(cBlockTrialScales));
% %     TrainWinTrs = BlockCenterInds + CenterTrUsedWins;
% %     TrainTr_trigTimes = TaskTrigTimeAligns([TrainWinTrs(1),(TrainWinTrs(2)+1)]) - [0;TimeBinSize]; % using whole time win datas as training inds
% %     TrainTr_2Bin = round((TrainTr_trigTimes/TimeBinSize));
% %     SessBin_trainInds(TrainTr_2Bin(1):TrainTr_2Bin(2),1) = true;
% %     
% %     % using only baseline bins for training
% %     TrainTr_TrigBinAll = round(TaskTrigTimeAligns(TrainWinTrs(1):TrainWinTrs(2))/TimeBinSize);
% %     TrainTr_StimOnTimeAll = round(Behav_SessStimOnTime(TrainWinTrs(1):TrainWinTrs(2))/TimeBinSize);
% %     for cTT = 1 : numel(TrainTr_TrigBinAll)
% %         SessBin_trainInds((TrainTr_TrigBinAll(cTT)+1):TrainTr_StimOnTimeAll(cTT),2) = true;
% %     end
% % end
% % 
% % %% population decoding for each group units within same area
% % % BinCenters
% % UnitInds_perPopu = cellfun(@numel,ExistField_ClusIDs(:,2));
% % AreaUnitScaleInds = cumsum([1;UnitInds_perPopu]);
% % UsedTrainDataType = 1;
% % for cA = 1 : 1%Numfieldnames
% %     cAInds = AreaUnitScaleInds(cA):(AreaUnitScaleInds(cA+1)-1);
% % %     cA_UnitDatas = BinnedSPdatas(cAInds,:);
% %     cA_UnitResp_training = BinnedSPdatas(cAInds,SessBin_trainInds(:,UsedTrainDataType));
% %     cA_TrBT_training = BTDataBin(1,SessBin_trainInds(:,UsedTrainDataType));
% %     
% %     fitMD = fitcsvm(cA_UnitResp_training',cA_TrBT_training');
% %     cA_UnitResp_test = BinnedSPdatas(cAInds,~SessBin_trainInds(:,UsedTrainDataType));
% %     cA_TrBT_test = BTDataBin(1,~SessBin_trainInds(:,UsedTrainDataType));
% %     [PredBT, PredBTScore] = predict(fitMD, cA_UnitResp_test');
% % %     Score2Prob = 1./(1 + exp(-PredBTScore));
% %     Score2Prob = PredBTScore;
% %     disp(kfoldLoss(crossval(fitMD)));
% % end




