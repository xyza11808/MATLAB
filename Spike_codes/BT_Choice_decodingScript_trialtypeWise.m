
clearvars UnitAfterStimAUC UnitAS_BLSubAUC UnitBaselineAUC SVMDecVecs
% ksfolder = strrep(ksfolder,'F:\','E:\NPCCGs\');

% % % calculate AUC for each unit in distinguish choice and block type
% % load(fullfile(ksfolder,'NPClassHandleSaved.mat'))
% % % load('Chnlocation.mat');
% % load(fullfile(ksfolder,'SessAreaIndexDataNew.mat'));
% % % if isempty(ProbNPSess.ChannelAreaStrs)
% % %     ProbNPSess.ChannelAreaStrs = {ChnArea_indexes,ChnArea_Strings(:,3)};
% % % end

load(fullfile(ksfolder,'SessAreaIndexDataNewAlign.mat'));
load(fullfile(ksfolder,'NewClassHandle2.mat'))
ProbNPSess = NewNPClusHandle;
clearvars NewNPClusHandle
%%
figSaveFolder = fullfile(ksfolder,'BTANDChoiceAUC_TrWise');
if isfolder(figSaveFolder)
    rmdir(figSaveFolder,'s');
end

mkdir(figSaveFolder);


ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TimeWin = [-1.5,8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; %
% ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');
fullData = cellfun(@full,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds},'un',0);
SMBinDataMtx = permute(cat(3,fullData{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix


if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;

Allfieldnames = fieldnames(SessAreaIndexStrc);
ExistAreas_Indexes = find(SessAreaIndexStrc.UsedAbbreviations);
ExistAreas_Names = Allfieldnames(SessAreaIndexStrc.UsedAbbreviations);
NumExistAreas = length(ExistAreas_Names);
if NumExistAreas< 1
    return;
end
%%
TriggerAlignBin = ProbNPSess.TriggerStartBin{ProbNPSess.CurrentSessInds};
BaselineResp_All = mean(SMBinDataMtx(:,:,1:TriggerAlignBin-1),3);
UsedRespWin = 1; % seconds after stim onset
UsedRespSPWin = round(UsedRespWin/ProbNPSess.USedbin(2));
AfterStimRespData = mean(SMBinDataMtx(:,:,(TriggerAlignBin+1):(TriggerAlignBin+UsedRespSPWin)),3);

BlockSectionInfo = Bev2blockinfoFun(behavResults);
BlockTypesAll = double(behavResults.BlockType(:));
RevFreqs = BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse));
TrialFreqsAll = double(behavResults.Stim_toneFreq(:));
TrialAnmChoice = double(behavResults.Action_choice(:));
NMTrialIndex = find(TrialAnmChoice ~= 2);

NMBaselneResp_dataAll = BaselineResp_All(NMTrialIndex,:);
NMAfterStimResp_dataAll = AfterStimRespData(NMTrialIndex,:);
NMTrial_ChoiceAll = TrialAnmChoice(NMTrialIndex);
NMTrial_blockTypesAll = BlockTypesAll(NMTrialIndex);
NMTrial_FreqsAll = TrialFreqsAll(NMTrialIndex);
NMTrial_IsRevFreqs = ismember(NMTrial_FreqsAll,RevFreqs);

%%
TotalUnitNumbers = size(SMBinDataMtx,2);

DataSaveName = fullfile(figSaveFolder,'BTANDChoiceAUC_TrTypeWise.mat');
% load(DataSaveName);

UnitAfterStimAUC = zeros(2,TotalUnitNumbers,4); % for after-stim response: AUC4Block, Threshold,AUC4Choice,Threshold
UnitAS_BLSubAUC = zeros(2,TotalUnitNumbers,4); % for baseline-sub after-stim response: AUC4Block, Threshold,AUC4Choice,Threshold
UnitBaselineAUC = zeros(2,TotalUnitNumbers,2); % for baseline response: AUC4Block, Threshold
for cU = 1 : TotalUnitNumbers
    % reverse-frequency trials AUCs
    cUData_afterStim = NMAfterStimResp_dataAll(NMTrial_IsRevFreqs,cU);
    cUData_Baseline = NMBaselneResp_dataAll(NMTrial_IsRevFreqs,cU);
    cU_baselineSubData = cUData_afterStim - cUData_Baseline;
    
    [AUC_AS_BT, IsMeanRev_AS_BT] = AUC_fast_utest(cUData_afterStim, NMTrial_blockTypesAll(NMTrial_IsRevFreqs)); % block type decoding, after stim response
    [~,~,SigValues_AS_BT] = ROCSiglevelGeneNew([cUData_afterStim, NMTrial_blockTypesAll(NMTrial_IsRevFreqs)],500,1,0.001);
    
    [AUC_AS_Choice, IsMeanRev_AS_Choice] = AUC_fast_utest(cUData_afterStim, NMTrial_ChoiceAll(NMTrial_IsRevFreqs)); % Choice decoding, after stim response
    [~,~,SigValues_AS_Choice] = ROCSiglevelGeneNew([cUData_afterStim, NMTrial_ChoiceAll(NMTrial_IsRevFreqs)],500,1,0.001);
    
    [AUC_BS_BT, IsMeanRev_BS_BT] = AUC_fast_utest(cU_baselineSubData, NMTrial_blockTypesAll(NMTrial_IsRevFreqs)); % block type decoding, baseline substraction response
    [~,~,SigValues_BS_BT] = ROCSiglevelGeneNew([cU_baselineSubData, NMTrial_blockTypesAll(NMTrial_IsRevFreqs)],500,1,0.001);
    
    [AUC_BS_Choice, IsMeanRev_BS_Choice] = AUC_fast_utest(cU_baselineSubData, NMTrial_ChoiceAll(NMTrial_IsRevFreqs)); % Choice decoding, baseline substraction  response
    [~,~,SigValues_BS_Choice] = ROCSiglevelGeneNew([cU_baselineSubData, NMTrial_ChoiceAll(NMTrial_IsRevFreqs)],500,1,0.001);
    
    [AUC_BL_BT, IsMeanRev_BL_BT] = AUC_fast_utest(cUData_Baseline, NMTrial_blockTypesAll(NMTrial_IsRevFreqs)); % block type decoding, baseline response
    [~,~,SigValues_BL_BT] = ROCSiglevelGeneNew([cUData_Baseline, NMTrial_blockTypesAll(NMTrial_IsRevFreqs)],500,1,0.001);
    
    
    UnitAfterStimAUC(1,cU,:) = [AUC_AS_BT, SigValues_AS_BT, AUC_AS_Choice, SigValues_AS_Choice];
    UnitBaselineAUC(1,cU,:)  = [AUC_BL_BT, SigValues_BL_BT];
    UnitAS_BLSubAUC(1,cU,:) = [AUC_BS_BT, SigValues_BS_BT,AUC_BS_Choice, SigValues_BS_Choice];
    
    % non-reverse-frequency trials AUCs
    cUData_afterStim = NMAfterStimResp_dataAll(~NMTrial_IsRevFreqs,cU);
    cUData_Baseline = NMBaselneResp_dataAll(~NMTrial_IsRevFreqs,cU);
    cU_baselineSubData = cUData_afterStim - cUData_Baseline;
    
    [AUC_AS_BT, IsMeanRev_AS_BT] = AUC_fast_utest(cUData_afterStim, NMTrial_blockTypesAll(~NMTrial_IsRevFreqs)); % block type decoding, after stim response
    [~,~,SigValues_AS_BT] = ROCSiglevelGeneNew([cUData_afterStim, NMTrial_blockTypesAll(~NMTrial_IsRevFreqs)],500,1,0.001);
    
    [AUC_AS_Choice, IsMeanRev_AS_Choice] = AUC_fast_utest(cUData_afterStim, NMTrial_ChoiceAll(~NMTrial_IsRevFreqs)); % Choice decoding, after stim response
    [~,~,SigValues_AS_Choice] = ROCSiglevelGeneNew([cUData_afterStim, NMTrial_ChoiceAll(~NMTrial_IsRevFreqs)],500,1,0.001);
    
    [AUC_BS_BT, IsMeanRev_BS_BT] = AUC_fast_utest(cU_baselineSubData, NMTrial_blockTypesAll(~NMTrial_IsRevFreqs)); % block type decoding, baseline substraction response
    [~,~,SigValues_BS_BT] = ROCSiglevelGeneNew([cU_baselineSubData, NMTrial_blockTypesAll(~NMTrial_IsRevFreqs)],500,1,0.001);
    
    [AUC_BS_Choice, IsMeanRev_BS_Choice] = AUC_fast_utest(cU_baselineSubData, NMTrial_ChoiceAll(~NMTrial_IsRevFreqs)); % Choice decoding, baseline substraction  response
    [~,~,SigValues_BS_Choice] = ROCSiglevelGeneNew([cU_baselineSubData, NMTrial_ChoiceAll(~NMTrial_IsRevFreqs)],500,1,0.001);
    
    [AUC_BL_BT, IsMeanRev_BL_BT] = AUC_fast_utest(cUData_Baseline, NMTrial_blockTypesAll(~NMTrial_IsRevFreqs)); % block type decoding, baseline response
    [~,~,SigValues_BL_BT] = ROCSiglevelGeneNew([cUData_Baseline, NMTrial_blockTypesAll(~NMTrial_IsRevFreqs)],500,1,0.001);
    
    
    UnitAfterStimAUC(2,cU,:) = [AUC_AS_BT, SigValues_AS_BT, AUC_AS_Choice, SigValues_AS_Choice];
    UnitBaselineAUC(2,cU,:)  = [AUC_BL_BT, SigValues_BL_BT];
    UnitAS_BLSubAUC(2,cU,:) = [AUC_BS_BT, SigValues_BS_BT,AUC_BS_Choice, SigValues_BS_Choice];
    
    
end

% linear regression to substract choice fitting values and use the residues
% to calculate block type differences

%% 
SVMDecVecs = cell(NumExistAreas,6);
AllUsedUnitInds = false(TotalUnitNumbers,1);
for cArea = 1 : NumExistAreas

    cAName = ExistAreas_Names{cArea};
    UsedUnitInds = SessAreaIndexStrc.(cAName).MatchedUnitInds;
    AllUsedUnitInds(UsedUnitInds) = true;

    NumUsedUnits = length(UsedUnitInds);
    
    if NumUsedUnits == 0
        warning('No unit exits for area %s in cureent session',cAName);
        continue;
    end
    
    if NumUsedUnits > 2
        h1f = figure('position',[100 50 980 900]);
        ax1 = subplot(321);
        AS_BT_RevTrs = squeeze(UnitAfterStimAUC(1,UsedUnitInds,1));
        AS_BT_NonRevTrs = squeeze(UnitAfterStimAUC(2,UsedUnitInds,1));
        plot(AS_BT_RevTrs,AS_BT_NonRevTrs,'ro');
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, BT, RevTrs');
        ylabel('baselineSub resp, BT, NonRevTrs');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off','xlim',[0 1],'ylim',[0 1]);
        [~, p_AS_BT] = ttest(AS_BT_RevTrs,AS_BT_NonRevTrs);
        title(sprintf('Area %s, p = %.3e',cAName, p_AS_BT));
        text(0.3,0.2,sprintf('n = %d',NumUsedUnits));

        ax2 = subplot(322);
        AS_Choice_RevTrs = squeeze(UnitAfterStimAUC(1,UsedUnitInds,2));
        AS_Choice_NonRevTrs = squeeze(UnitAfterStimAUC(2,UsedUnitInds,2));
        plot(AS_Choice_RevTrs,AS_Choice_NonRevTrs,'bo')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, Choice, RevTrs');
        ylabel('baselineSub resp, Choice, NonRevTrs');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BLS_BT] = ttest(AS_Choice_RevTrs,AS_Choice_NonRevTrs);
        title(sprintf('p = %.3e',p_BLS_BT));


        % compare block type decoding with baseline data
        
        ax3 = subplot(323);
        BL_BT_RevTrs = squeeze(UnitBaselineAUC(1,UsedUnitInds,1));
        BL_BT_NonRevTrs = squeeze(UnitBaselineAUC(2,UsedUnitInds,1));
        plot(BL_BT_RevTrs,BL_BT_NonRevTrs,'ro')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('baseline, BT, RevTrs');
        ylabel('baseline, BT, NonRevTrs');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BL_BT] = ttest(BL_BT_RevTrs,BL_BT_NonRevTrs);
        title(sprintf('p = %.3e',p_BL_BT));

        ax4 = subplot(325);
        BLS_BT_RevTrs = squeeze(UnitAS_BLSubAUC(1,UsedUnitInds,1));
        BLS_BT_NonRevTrs = squeeze(UnitAS_BLSubAUC(2,UsedUnitInds,1));
        plot(BLS_BT_RevTrs,BLS_BT_NonRevTrs,'ro')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('baselineSub resp, BT, RevTrs');
        ylabel('baselineSub resp, BT, NonRevTrs');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BLS_BT] = ttest(BLS_BT_RevTrs,BLS_BT_NonRevTrs);
        title(sprintf('p = %.3e',p_BLS_BT));

        % is there correlation between choice decoding and blocktype decoding
        ax5 = subplot(326);
        BLS_Choice_RevTrs = squeeze(UnitAS_BLSubAUC(1,UsedUnitInds,3));
        BLS_Choice_NonRevTrs = squeeze(UnitAS_BLSubAUC(2,UsedUnitInds,3));
        plot(BLS_Choice_RevTrs,BLS_Choice_NonRevTrs,'mo')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('baselineSub resp, Choice, RevTrs');
        ylabel('baselineSub resp, Choice, NonRevTrs');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BLS_Chioce] = ttest(BLS_Choice_RevTrs,BLS_Choice_NonRevTrs);

        title(sprintf('p = %.3e',p_BLS_Chioce));
        
    
        % used after stim response value to decode choice and block type, and then calculate the projection vector angle
        cA_unitsData_RevTr = NMAfterStimResp_dataAll(NMTrial_IsRevFreqs, UsedUnitInds);
        UsedUnitNum = size(cA_unitsData_RevTr,2);
        md_choice = fitcsvm(cA_unitsData_RevTr, NMTrial_ChoiceAll(NMTrial_IsRevFreqs));
        ChoiceMDLoss = kfoldLoss(crossval(md_choice));
        md_BT = fitcsvm(cA_unitsData_RevTr, NMTrial_blockTypesAll(NMTrial_IsRevFreqs));
        BTMDLoss = kfoldLoss(crossval(md_BT));

        ChoiceVec = md_choice.Beta;
        BT_Vec = md_BT.Beta;
        DecodeVecAngle = VecAnglesFun(ChoiceVec,BT_Vec);

        % for non-reverse trials
        cA_unitsData_NonRevTr = NMAfterStimResp_dataAll(~NMTrial_IsRevFreqs, UsedUnitInds);
        md_choiceNRT = fitcsvm(cA_unitsData_NonRevTr, NMTrial_ChoiceAll(~NMTrial_IsRevFreqs));
        ChoiceMDLossNRT = kfoldLoss(crossval(md_choiceNRT));
        md_BTNRT = fitcsvm(cA_unitsData_NonRevTr, NMTrial_blockTypesAll(~NMTrial_IsRevFreqs));
        BTMDLossNRT = kfoldLoss(crossval(md_BTNRT));

        ChoiceVecNRT = md_choiceNRT.Beta;
        BT_VecNRT = md_BTNRT.Beta;
        DecodeVecAngle_NRT = VecAnglesFun(ChoiceVecNRT,BT_VecNRT);

        SVMDecVecs(cArea,:) = {cAName, {ChoiceVec,ChoiceVecNRT}, {BT_Vec,BT_VecNRT}, {DecodeVecAngle,DecodeVecAngle_NRT},...
            UsedUnitNum, [ChoiceMDLoss,BTMDLoss;ChoiceMDLossNRT,BTMDLossNRT]};
        
        ax6 = subplot(324);
        text(0.5,0.5,sprintf('RTChoiceLoss = %.3f, RTBTLoss = %.3f',ChoiceMDLoss,BTMDLoss));
        text(0.5,0.4,sprintf('NRTChoiceLoss = %.3f, NRTBTLoss = %.3f',ChoiceMDLossNRT,BTMDLossNRT));
        set(gca,'xlim',[0 4]);
        title('Popu decoding loss');
        h1fSaveNAme = fullfile(figSaveFolder,sprintf('%s_TrialTypeAUC_comp',cAName));
        saveas(h1f,h1fSaveNAme);
        saveas(h1f,h1fSaveNAme,'png');
        close(h1f);
    end
    
    
end

save(DataSaveName, 'UnitAfterStimAUC','UnitAS_BLSubAUC','UnitBaselineAUC','SVMDecVecs','ExistAreas_Names','-v7.3');





