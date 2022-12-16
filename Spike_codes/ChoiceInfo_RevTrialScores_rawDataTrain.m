
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

USedAreas = cell2mat(ExistField_ClusIDs(:,3)) < 1;
if sum(USedAreas)
    ExistField_ClusIDs(USedAreas,:) = [];
    AreaUnitNumbers(USedAreas) = [];
    Numfieldnames = Numfieldnames - sum(USedAreas);
    NewAdd_ExistAreaNames(USedAreas) = [];
end

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

%%
savePath = fullfile(ksfolder,'BlockChoiceDecWeight');
% construct behavior datas 
BehavDataStrs = struct();
BehavDataStrs.BlockIndex = UsedTrInds_NMSeqIndex;
BehavDataStrs.TrFreqs = UsedTrInds_NMFreqs;
BehavDataStrs.TrChoices = UsedTrInds_NMChoice;
BehavDataStrs.TrTypes = UsedTrInds_NMTrTtypes;
BehavDataStrs.BlockInfo = BlockSectionInfo;


%%
% cA = 1;
DataStr = {'RawDsqrScore','RawPerf','RawScoresAll','SubDsqrScore','SubPerf','SubScoresAll'};
NumAreas = size(ExistField_ClusIDs,1);
ChoiceANDBT_beta = cell(NumAreas,2);
ChoiceANDBT_Scores = cell(NumAreas,2);
RevFreqChoiceScores = cell(NumAreas,4);
for cA = 1 : NumAreas
    UsedUnitInds = ExistField_ClusIDs{cA,2};
    AreaPopuSize = numel(UsedUnitInds);
    AreaStrs = NewAdd_ExistAreaNames{cA};
    % UsedTrNMDatas = NewBinnedDatas(UsedTrInds_NMInds,UsedUnitInds,:);
%     UsedTrNMDatas = BaseSubData(UsedTrInds_NMInds,UsedUnitInds,:);
    UsedTrNMDatas_raw = NewBinnedDatas(UsedTrInds_NMInds,UsedUnitInds,:);
    UsedTrNMDatas = UsedTrNMDatas_raw;
    %
    [NumNMTrials, ~, NumTimeBins] = size(UsedTrNMDatas);
    
    RepeatNum = 10;
    RepeatInfo = zeros(RepeatNum,NumTimeBins,2);
    RepeatAccu = zeros(RepeatNum,NumTimeBins,2);
    AllRepeatBetas = cell(RepeatNum,NumTimeBins);
    
    for cR = 1 : RepeatNum
        
        cR_TrainIndex = randsample(NumNMTrials,round(NumNMTrials*0.6));
        cR_TrainBaseInds = false(NumNMTrials,1);
        cR_TrainBaseInds(cR_TrainIndex) = true;
        cR_TestInds = ~cR_TrainBaseInds;
        
        TimeBinInfos = zeros(NumTimeBins,2);
        TimeBinAccu = zeros(NumTimeBins,2);
        for cBin = 1 : NumTimeBins
            cBinData = UsedTrNMDatas(:,:,cBin);
            
            [InfoScore,LDAAccu,~,beta] = LDAclassifierFun(cBinData,UsedTrInds_NMChoice,...
                {cR_TrainBaseInds,cR_TestInds});
            TimeBinInfos(cBin,:) = InfoScore;
            TimeBinAccu(cBin,:) = LDAAccu;
            AllRepeatBetas(cR,cBin) = {beta};
            
        end
        
        RepeatInfo(cR,:,:) = TimeBinInfos;
        RepeatAccu(cR,:,:) = TimeBinAccu;
    end
    
    % find maximum choice info frame bin
    InfoRepeatAvgs = squeeze(mean(RepeatInfo));
    [~, MaxInds] = max(InfoRepeatAvgs(:,2));
    % BTinfoRepeatAvgs = squeeze(mean(BTRepeatInfo));
    
    %
    AllRepeatBetasUsed = cell(RepeatNum,1);
    for cR = 1 : RepeatNum
        cR_TrainIndex = randsample(NumNMTrials,round(NumNMTrials*0.9));
        cR_TrainBaseInds = false(NumNMTrials,1);
        cR_TrainBaseInds(cR_TrainIndex) = true;
        cR_TestInds = ~cR_TrainBaseInds;
        
        cBinData = UsedTrNMDatas(:,:,MaxInds);
        [~,~,~,beta] = LDAclassifierFun(cBinData,UsedTrInds_NMChoice,...
            {cR_TrainBaseInds,cR_TestInds});
        AllRepeatBetasUsed(cR,cBin) = {beta};
    end
    
    ReMaxIndsBetaCell = AllRepeatBetasUsed';
    ReMaxIndsBetaMtx = cat(2,ReMaxIndsBetaCell{:});
    FinalChoiceInfoBeta = median(ReMaxIndsBetaMtx,2);
    
    % using baseline data for Blocktype decoding analysis
    
    BaselineRespNMdata = BaselineResp(UsedTrInds_NMInds,UsedUnitInds);
    RepeatNum = 10;
    
    BaseDataInfo = zeros(RepeatNum,2);
    BaseDataAccu = zeros(RepeatNum,2);
    BaseDataBeta = cell(1,RepeatNum);
    for cRe = 1 : RepeatNum
        cR_TrainIndex = randsample(NumNMTrials,round(NumNMTrials*0.9));
        cR_TrainBaseInds = false(NumNMTrials,1);
        cR_TrainBaseInds(cR_TrainIndex) = true;
        cR_TestInds = ~cR_TrainBaseInds;
        
        [BTInfoScore,BTLDAAccu,~,BTbeta] = LDAclassifierFun(BaselineRespNMdata,UsedTrInds_NMBTs,...
            {cR_TrainBaseInds,cR_TestInds});
        BaseDataInfo(cRe,:) = BTInfoScore;
        BaseDataAccu(cRe,:) = BTLDAAccu;
        BaseDataBeta(cRe) = {BTbeta};
        
    end
    
    BTBetaMtx = cat(2,BaseDataBeta{:});
    FinalBTInfoBeta = median(BTBetaMtx,2);
    ChoiceANDBT_beta(cA,:) = {FinalChoiceInfoBeta, FinalBTInfoBeta};
    % recalculate choice and BT score for all time bins using raw datas
    BinDsqr_Choice = zeros(NumTimeBins,1);
    BinPerf_Choice = zeros(NumTimeBins,1);
    BinChoiceScores = zeros(NumNMTrials,NumTimeBins);
    
    BinDsqr_BT = zeros(NumTimeBins,1);
    BinPerf_BT = zeros(NumTimeBins,1);
    BinBTScores = zeros(NumNMTrials,NumTimeBins);
    
    SubBinDsqr_Choice = zeros(NumTimeBins,1);
    SubBinPerf_Choice = zeros(NumTimeBins,1);
    SubBinChoiceScores = zeros(NumNMTrials,NumTimeBins);
    
    SubBinDsqr_BT = zeros(NumTimeBins,1);
    SubBinPerf_BT = zeros(NumTimeBins,1);
    SubBinBTScores = zeros(NumNMTrials,NumTimeBins);
    
    for cBin = 1 : NumTimeBins
        cBinData = UsedTrNMDatas_raw(:,:,cBin);
        % choice info
        [Dsqr, PerfAccu, TrScores] = LDAclassifierFun_Score(cBinData, ...
            UsedTrInds_NMChoice, FinalChoiceInfoBeta);
        
        BinDsqr_Choice(cBin) = Dsqr;
        BinPerf_Choice(cBin) = PerfAccu;
        BinChoiceScores(:,cBin) = TrScores;
        
        %blocktype info
        [DsqrBT, PerfAccuBT, TrScoresBT] = LDAclassifierFun_Score(cBinData, ...
            UsedTrInds_NMBTs, FinalBTInfoBeta);
        
        BinDsqr_BT(cBin) = DsqrBT;
        BinPerf_BT(cBin) = PerfAccuBT;
        BinBTScores(:,cBin) = TrScoresBT;
        
        cBinData_sub = UsedTrNMDatas(:,:,cBin);
        % choice info using sub data
        [Dsqr, PerfAccu, TrScores] = LDAclassifierFun_Score(cBinData_sub, ...
            UsedTrInds_NMChoice, FinalChoiceInfoBeta);
        
        SubBinDsqr_Choice(cBin) = Dsqr;
        SubBinPerf_Choice(cBin) = PerfAccu;
        SubBinChoiceScores(:,cBin) = TrScores;
        
        %blocktype info using sub data
        [DsqrBT, PerfAccuBT, TrScoresBT] = LDAclassifierFun_Score(cBinData_sub, ...
            UsedTrInds_NMBTs, FinalBTInfoBeta);
        
        SubBinDsqr_BT(cBin) = DsqrBT;
        SubBinPerf_BT(cBin) = PerfAccuBT;
        SubBinBTScores(:,cBin) = TrScoresBT;
        
    end
    
    MaxBinTempScores_choice = {BinDsqr_Choice,BinPerf_Choice,BinChoiceScores,SubBinDsqr_Choice,SubBinPerf_Choice,SubBinChoiceScores};
    MaxBinTempScores_BT = {BinDsqr_BT,BinPerf_BT,BinBTScores,SubBinDsqr_BT,SubBinPerf_BT,SubBinBTScores};
    ChoiceANDBT_Scores(cA,:) = {MaxBinTempScores_choice,MaxBinTempScores_BT};
    % %%
    % figure;plot(BinPerf_Choice,'k')
    % hold on
    % plot(SubBinPerf_Choice,'r')
    
    %
    
    AllFreqTypes = unique(UsedTrInds_NMFreqs);
    NumFreqTypes = numel(AllFreqTypes);
    RevFreqIndex = find(BlockSectionInfo.IsFreq_asReverse);
    NumRevFreqs = length(RevFreqIndex); % usually should be 3
    BlockNum = BlockSectionInfo.NumBlocks;
    
    
    figSize = [280*BlockNum, 720];
    hf = figure('position',[50 50 figSize]);
    IsLegendHasPlot = 0;
    
    ChoiceInfoDatas = cell(BlockNum,NumRevFreqs+1,4);
    PopuUnitSizes = zeros(BlockNum,NumRevFreqs+1,2);
    RevTrChoiceScores = cell(BlockNum,2,3); % the second dimension is left and right choice, the third dimension is before and after score
    RevTrBTScores = cell(BlockNum,2,3); % the second dimension is left and right choice, the third dimension is before and after score
    for cB = 1 : BlockNum
        
        cB_TrInds = UsedTrInds_NMSeqIndex == cB;
        cB_TrFreqs = UsedTrInds_NMFreqs(cB_TrInds);
        cB_TrChoice = UsedTrInds_NMChoice(cB_TrInds);
        cB_TrTypes = UsedTrInds_NMTrTtypes(cB_TrInds);
        cB_TrIsCorrect = cB_TrChoice == cB_TrTypes;
        cB_TrIsRev = ismember(cB_TrFreqs,RevFreqs);
        
        cB_TrBin_choiceScores = BinChoiceScores(cB_TrInds,:);
        cB_TrBin_BTScores = BinBTScores(cB_TrInds,:);
        
        cB_TrBin_ChoiceScoresSM = conv2(1,ones(1,5)/5,cB_TrBin_choiceScores,'same');
%             cf_Bin_BTScoresSM = conv2(1,ones(1,5)/5,cf_Bin_BTScores,'same');
            
        cB_RevTr_CorrInds = cB_TrIsCorrect & cB_TrIsRev;
        cB_RevTr_ErroInds = ~cB_TrIsCorrect & cB_TrIsRev;
        cBType = BlockSectionInfo.BlockTypes(cB);
        for TestFreq = 1 : NumRevFreqs
            cFreq = AllFreqTypes(RevFreqIndex(TestFreq));
            cf_inds = cB_TrFreqs == cFreq;
            cf_Bin_ChoiceScores = cB_TrBin_choiceScores(cf_inds,:);
            cf_Bin_ChoiceScoresSM = cB_TrBin_ChoiceScoresSM(cf_inds,:);
            cf_Bin_BTScores = cB_TrBin_BTScores(cf_inds,:);
            cf_Choice = cB_TrChoice(cf_inds);
            cf_ChoiceIsCorr = cB_TrIsCorrect(cf_inds);
            
            ChoiceInfoDatas(cB,TestFreq,:) = {cf_Bin_ChoiceScores(cf_Choice==0,:),cf_Bin_ChoiceScores(cf_Choice==1,:),...
                cf_Bin_BTScores(cf_Choice==0,:),cf_Bin_BTScores(cf_Choice==1,:)};
            PopuUnitSizes(cB,TestFreq,:) = [sum(cf_Choice==0),sum(cf_Choice)];
            %         cf_IsleftChoiceType = mean(cf_ChoiceIsCorr(cf_Choice == 0));
            
            SubAxIndex = (TestFreq - 1) * BlockNum + cB;
            Choiceax = subplot(NumRevFreqs+1,BlockNum, SubAxIndex);
            %         figure;
            hold on
            if sum(cf_Choice==0) > 0
                [~,~,hl1] = MeanSemPlot(cf_Bin_ChoiceScoresSM(cf_Choice==0,:),OutDataStrc.BinCenters,Choiceax,1,[.7 .7 .7],...
                    'Color','b','linewidth',1.6);
                hltr1 = {'Left'};
            else
                hl1 = [];
                hltr1 = [];
            end
            if sum(cf_Choice==1) > 0
                [~,~,hl2] = MeanSemPlot(cf_Bin_ChoiceScoresSM(cf_Choice==1,:),OutDataStrc.BinCenters,Choiceax,1,[.7 .7 .7],...
                    'Color','r','linewidth',1.6);
                hltr2 = {'Right'};
            else
                hl2 = [];
                hltr2 = [];
            end
            lgHandle = [hl1,hl2];
            if ~IsLegendHasPlot && length(lgHandle) == 2
                lgStrs = [hltr1,hltr2];
                legend(Choiceax,lgHandle,lgStrs,'Location','Southeast','box','off','autoupdate','off');
                IsLegendHasPlot = 1;
            end
            
            xTimeScales = [round(OutDataStrc.BinCenters(1)),round(OutDataStrc.BinCenters(end))];
            line(Choiceax,xTimeScales,[0 0],'Color','k','linewidth',1,'linestyle','--')
            yscale_C = get(Choiceax,'ylim');
            line(Choiceax,[0 0],yscale_C,'Color','c','linewidth',1.2,'linestyle','--');
%             if TestFreq == NumRevFreqs
%                 xlabel(Choiceax,sprintf('Time (s), BlockSeq %d', cB));
%             end
            if cB == 1
                ylabel(Choiceax,{'Choice scores';sprintf('%d Hz, Block %d',cFreq,cBType)});
            else
                ylabel(Choiceax,sprintf('Block %d',cBType));
            end
            title(Choiceax,sprintf('Choice L(%d) R(%d) (%.2f%%)',sum(cf_Choice==0),sum(cf_Choice==1),mean(cf_Choice)*100));
            if cBType
                text(2.5,yscale_C(2)*0.8,'Left reward','Color',[0.2 0.5 0.2]);
            else
                text(2.5,yscale_C(2)*0.8,'Right reward','Color',[0.2 0.5 0.2]);
            end
            set(Choiceax,'FontSize',10,'xlim',xTimeScales);
            
        end
        % #####################################################
        % plot all reverse frequency together for left and right choices
        SumChoiceax = subplot(NumRevFreqs+1,BlockNum, NumRevFreqs*BlockNum+cB);
        hold on
        cB_RevTrInds = ismember(cB_TrFreqs, RevFreqs);
        cRevTr_ChoiceScores = cB_TrBin_choiceScores(cB_RevTrInds,:);
        cf_Bin_ChoiceScoresSM = cB_TrBin_ChoiceScoresSM(cB_RevTrInds,:);
        cRevTr_BTScores = cB_TrBin_BTScores(cB_RevTrInds,:);
        cRevTr_Choice = cB_TrChoice(cB_RevTrInds);
        cRevTr_ChoiceIsCorr = cB_TrIsCorrect(cB_RevTrInds);
        
        ChoiceInfoDatas(cB,TestFreq+1,:) = {cRevTr_ChoiceScores(cRevTr_Choice==0,:),cRevTr_ChoiceScores(cRevTr_Choice==1,:),...
            cRevTr_BTScores(cRevTr_Choice==0,:),cRevTr_BTScores(cRevTr_Choice==1,:)};
        PopuUnitSizes(cB,TestFreq+1,:) = [sum(cRevTr_Choice==0),sum(cRevTr_Choice)];
        %         cf_IsleftChoiceType = mean(cf_ChoiceIsCorr(cf_Choice == 0));

        [~,~,hl1] = MeanSemPlot(cf_Bin_ChoiceScoresSM(cRevTr_Choice==0,:),OutDataStrc.BinCenters,SumChoiceax,1,[.7 .7 .7],...
            'Color','b','linewidth',1.6);
        [~,~,hl2] = MeanSemPlot(cf_Bin_ChoiceScoresSM(cRevTr_Choice==1,:),OutDataStrc.BinCenters,SumChoiceax,1,[.7 .7 .7],...
            'Color','r','linewidth',1.6);
        
        xTimeScales = [round(OutDataStrc.BinCenters(1)),round(OutDataStrc.BinCenters(end))];
        line(SumChoiceax,xTimeScales,[0 0],'Color','k','linewidth',1,'linestyle','--')
        yscale_C = get(SumChoiceax,'ylim');
        line(SumChoiceax,[0 0],yscale_C,'Color','c','linewidth',1.2,'linestyle','--');

        xlabel(SumChoiceax,sprintf('Time (s), BlockSeq %d', cB));

        if cB == 1
            ylabel(SumChoiceax,{'Choice scores';sprintf('RevTrials, Block %d',cBType)});
        else
            ylabel(SumChoiceax,sprintf('Block %d',cBType));
        end
        title(SumChoiceax,sprintf('Choice L(%d) R(%d) (%.2f%%)',sum(cRevTr_Choice==0),sum(cRevTr_Choice==1),mean(cRevTr_Choice)*100));
        if cBType
            text(2.5,yscale_C(2)*0.8,'Left reward','Color',[0.2 0.5 0.2]);
        else
            text(2.5,yscale_C(2)*0.8,'Right reward','Color',[0.2 0.5 0.2]);
        end
        set(SumChoiceax,'FontSize',10,'xlim',xTimeScales);
        
        % calculate the choice score for before and after stim onsets
        BeforeWin1 = OutDataStrc.BinCenters >= -1 & OutDataStrc.BinCenters < -0.5;
        BeforeWin2 = OutDataStrc.BinCenters >= -0.5 & OutDataStrc.BinCenters < 0;
        AfterWin = OutDataStrc.BinCenters >= 0 & OutDataStrc.BinCenters < 1;
        UsedWins = {BeforeWin1,BeforeWin2,AfterWin};
        
        for cWin = 1 : 3
            cWinInds = UsedWins{cWin};
            RevTrChoiceScores(cB,:,cWin) = {mean(cRevTr_ChoiceScores(cRevTr_Choice==0,cWinInds),2),...
                mean(cRevTr_ChoiceScores(cRevTr_Choice==1,cWinInds),2)};
            RevTrBTScores(cB,:,cWin) = {mean(cRevTr_BTScores(cRevTr_Choice==0,cWinInds),2),...
                mean(cRevTr_BTScores(cRevTr_Choice==1,cWinInds),2)};
        end
        % ###############
        % end of block loop
    end
    
    annotation('textbox',[0.02 0.01 0.1 0.05],'String',{sprintf('Area %s',AreaStrs),sprintf('UnitNum: %d',AreaPopuSize)},...
        'FitBoxToText','on','Color','m','FontSize',8);
    
    figSaveName = fullfile(savePath,sprintf('Area %s temporal choice scores for Revfreqs',AreaStrs));
    saveas(hf,figSaveName);
    print(hf,figSaveName,'-dpng','-r300');
    print(hf,figSaveName,'-dpdf','-bestfit');
    close(hf);
    
    RevFreqChoiceScores(cA,:) = {ChoiceInfoDatas,PopuUnitSizes,RevTrChoiceScores,RevTrBTScores};
end

%%

DataSaveName = fullfile(savePath,'ChoiceInfoDataSummaryRawPred.mat');
save(DataSaveName,'ExistField_ClusIDs','NewAdd_ExistAreaNames','ChoiceANDBT_beta','ChoiceANDBT_Scores','RevFreqChoiceScores','-v7.3');

%%
% freq5Inds = cB_TrFreqs == FreqTypes(3);
% freq5ChoiceScore = cB_TrBin_choiceScores(freq5Inds,:);
% freq5Choices = cB_TrChoice(freq5Inds);
% figure;
% hold on
% plot(freq5ChoiceScore(freq5Choices == 0,:)','Color',[0.2 0.2 1]);
% plot(freq5ChoiceScore(freq5Choices == 1,:)','Color',[1 0.2 0.2]);
% mean(cB_TrIsCorrect(freq5Inds))


% %% calcualte the choice decoding vector for each block and then calculate the angle between them
% % UsedTrNMDatas_raw
% % UsedTrNMDatas
% % IsRawDataUsed = 0;
% RepeatNum = 50;
%
% % if ~IsRawDataUsed
% %     UsedTrNMDatas_maxBin = UsedTrNMDatas(:,:,MaxInds);
% % else
% %     UsedTrNMDatas_maxBin = UsedTrNMDatas_raw(:,:,MaxInds);
% % end
% baseSubData_maxframe = UsedTrNMDatas(:,:,MaxInds);
% baseSubData_maxframeZS = zscore(baseSubData_maxframe);
% [RepeatInfo_Sub,RepeatAccu_Sub,AllRepeatBetas_Sub,BlockChoiceVecAngleSub,BlockIndsSub,BlockShufDecsSub] = ...
%     BlockWiseChoiceDecVec(baseSubData_maxframeZS, UsedTrInds_NMSeqIndex, ...
%     UsedTrInds_NMChoice, BlockSectionInfo.NumBlocks, RepeatNum);
%
% RawDataMaxF = UsedTrNMDatas_raw(:,:,MaxInds);
% RawDataMaxF_zs = zscore(RawDataMaxF);
% [RepeatInfo_Raw,RepeatAccu_Raw,AllRepeatBetas_Raw,BlockChoiceVecAngleRaw,BlockIndsRaw,BlockShufDecsRaw] = ...
%     BlockWiseChoiceDecVec(RawDataMaxF_zs, UsedTrInds_NMSeqIndex, ...
%     UsedTrInds_NMChoice, BlockSectionInfo.NumBlocks, RepeatNum);
%
% %%
% % figure;
% %
% % for cB = 1 : BlockSectionInfo.NumBlocks
% %     subplot(BlockSectionInfo.NumBlocks,1,cB);
% %     hold on
% % % cB = 1;
% %     betaVecMtx = cat(2,AllRepeatBetas_Sub{cB,:});
% %     plot(betaVecMtx,'Color',[.7 .7 .7],'linewidth',1.4,'linestyle','-')
% %     plot(BlockShufDecsSub{cB,3},'Color','m','linewidth',1,'linestyle','--')
% %     plot(mean(betaVecMtx,2),'Color','r','linewidth',1.6,'linestyle','-')
% % end
% [hfSub, BetaValuesAllSub, BetaRespIndsAllSub] = UnitDecWeightPlot(AllRepeatBetas_Sub, BlockShufDecsSub);
% figure(hfSub);
% xlabel('Baseline substracted data');
% [hfRaw, BetaValuesAllRaw, BetaRespIndsAllRaw] = UnitDecWeightPlot(AllRepeatBetas_Raw, BlockShufDecsRaw);
% figure(hfRaw);
% xlabel('Raw data');
% % %%
% % RepeatInfo_check = zeros(BlockSectionInfo.NumBlocks,RepeatNum,2);
% % RepeatAccu_check = zeros(BlockSectionInfo.NumBlocks,RepeatNum,2);
% % AllRepeatBetas_check = cell(BlockSectionInfo.NumBlocks,RepeatNum);
% %
% % for cB = 1:BlockSectionInfo.NumBlocks
% %     cB_TrInds = UsedTrInds_NMSeqIndex == cB;
% %     cBNMTrNums = sum(cB_TrInds);
% %
% %     for cR = 1 : RepeatNum
% %
% %         cR_TrainIndex = randsample(cBNMTrNums,round(cBNMTrNums*0.8));
% %         cR_TrainBaseInds = false(cBNMTrNums,1);
% %         cR_TrainBaseInds(cR_TrainIndex) = true;
% %         cR_TestInds = ~cR_TrainBaseInds;
% %
% %         [InfoScore,LDAAccu,~,beta] = LDAclassifierFun(UsedTrNMDatas_maxBin(cB_TrInds,:),...
% %             UsedTrInds_NMChoice(cB_TrInds),...
% %             {cR_TrainBaseInds,cR_TestInds});
% %         AllRepeatBetas_check(cB,cR) = {beta};
% %         RepeatInfo_check(cB,cR,:) = InfoScore;
% %         RepeatAccu_check(cB,cR,:) = LDAAccu;
% %     end
% %
% % end
% % %
% % BlockCombineNum = BlockSectionInfo.NumBlocks*(BlockSectionInfo.NumBlocks-1)/2;
% % BlockChoiceVec = zeros(RepeatNum,BlockCombineNum);
% % BlockInds = zeros(2,BlockCombineNum);
% % k = 1;
% % for cB1 = 1 : BlockSectionInfo.NumBlocks
% %     for cB2 = cB1+1 : BlockSectionInfo.NumBlocks
% %
% %         for cR = 1 : RepeatNum
% %             BlockChoiceVec(cR,k) = VecAnglesFun(AllRepeatBetas_check{cB1,cR},AllRepeatBetas_check{cB2,cR});
% %         end
% %         BlockInds(:,k) = [cB1,cB2];
% %         k = k + 1;
% %     end
% % end
% % if ~IsRawDataUsed
% %     BlockChoiceVecSub = BlockChoiceVec;
% % else
% %     BlockChoiceVecRaw = BlockChoiceVec;
% % end