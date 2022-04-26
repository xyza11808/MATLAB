ksfolder = pwd;
clearvars UnitAfterStimAUC UnitAS_BLSubAUC UnitBaselineAUC SVMDecVecs SMBinDataMtx ProbNPSess
% calculate AUC for each unit in distinguish choice and block type
load(fullfile(ksfolder,'NPClassHandleSaved.mat'))
% load('Chnlocation.mat');
load(fullfile(ksfolder,'SessAreaIndexData.mat'));
% if isempty(ProbNPSess.ChannelAreaStrs)
%     ProbNPSess.ChannelAreaStrs = {ChnArea_indexes,ChnArea_Strings(:,3)};
% end
%%
figSaveFolder = fullfile(ksfolder,'BTANDChoiceAUC_compPlot');
if ~isfolder(figSaveFolder)
    mkdir(figSaveFolder);
end

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% TimeWin = [-1,5]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [50,10]; %
% ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, Smoothbin, double(behavResults.Time_stimOnset(:)));
% save(fullfile(pwd,'ks2_5','NPClassHandleSaved.mat'),'ProbNPSess', 'PassSoundDatas', 'behavResults', '-v7.3');

SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]); % transfromed into trial-by-units-by-bin matrix


if ~isempty(ProbNPSess.SurviveInds)
    SMBinDataMtx = SMBinDataMtx(:,ProbNPSess.SurviveInds,:);
end
SMBinDataMtxRaw = SMBinDataMtx;
% SMBinDataMtxRaw = SMBinDataMtx(:,:,:);

Allfieldnames = fieldnames(SessAreaIndexStrc);
ExistAreas_Indexes = find(SessAreaIndexStrc.UsedAbbreviations);
ExistAreas_Names = Allfieldnames(SessAreaIndexStrc.UsedAbbreviations);
NumExistAreas = length(ExistAreas_Names);
% if NumExistAreas< 1
%     return;
% end
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

%%
TotalUnitNumbers = size(SMBinDataMtx,2);
% DataSaveName = fullfile(figSaveFolder,'BTANDChoiceAUC_popuVec.mat');
% load(DataSaveName);
UnitAfterStimAUC = zeros(TotalUnitNumbers,4); % for after-stim response: AUC4Block, Threshold,AUC4Choice,Threshold
UnitAS_BLSubAUC = zeros(TotalUnitNumbers,4); % for baseline-sub after-stim response: AUC4Block, Threshold,AUC4Choice,Threshold
UnitBaselineAUC = zeros(TotalUnitNumbers,2); % for baseline response: AUC4Block, Threshold
for cU = 1 : TotalUnitNumbers
    cUData_afterStim = NMAfterStimResp_dataAll(:,cU);
    cUData_Baseline = NMBaselneResp_dataAll(:,cU);
    cU_baselineSubData = cUData_afterStim - cUData_Baseline;
    
    [AUC_AS_BT, IsMeanRev_AS_BT] = AUC_fast_utest(cUData_afterStim, NMTrial_blockTypesAll); % block type decoding, after stim response
    [~,~,SigValues_AS_BT] = ROCSiglevelGeneNew([cUData_afterStim, NMTrial_blockTypesAll],1000,1,0.001);
    
    [AUC_AS_Choice, IsMeanRev_AS_Choice] = AUC_fast_utest(cUData_afterStim, NMTrial_ChoiceAll); % Choice decoding, after stim response
    [~,~,SigValues_AS_Choice] = ROCSiglevelGeneNew([cUData_afterStim, NMTrial_ChoiceAll],1000,1,0.001);
    
    [AUC_BS_BT, IsMeanRev_BS_BT] = AUC_fast_utest(cU_baselineSubData, NMTrial_blockTypesAll); % block type decoding, baseline substraction response
    [~,~,SigValues_BS_BT] = ROCSiglevelGeneNew([cU_baselineSubData, NMTrial_blockTypesAll],1000,1,0.001);
    
    [AUC_BS_Choice, IsMeanRev_BS_Choice] = AUC_fast_utest(cU_baselineSubData, NMTrial_ChoiceAll); % Choice decoding, baseline substraction  response
    [~,~,SigValues_BS_Choice] = ROCSiglevelGeneNew([cU_baselineSubData, NMTrial_ChoiceAll],1000,1,0.001);
    
    [AUC_BL_BT, IsMeanRev_BL_BT] = AUC_fast_utest(cUData_Baseline, NMTrial_blockTypesAll); % block type decoding, baseline response
    [~,~,SigValues_BL_BT] = ROCSiglevelGeneNew([cUData_Baseline, NMTrial_blockTypesAll],1000,1,0.001);
    
    
    UnitAfterStimAUC(cU,:) = [AUC_AS_BT, SigValues_AS_BT, AUC_AS_Choice, SigValues_AS_Choice];
    UnitBaselineAUC(cU,:)  = [AUC_BL_BT, SigValues_BL_BT];
    UnitAS_BLSubAUC(cU,:) = [AUC_BS_BT, SigValues_BS_BT,AUC_BS_Choice, SigValues_BS_Choice];
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
        h1f = figure('position',[100 100 920 360]);
        ax1 = subplot(121);
        plot(UnitAfterStimAUC(UsedUnitInds,1),UnitAS_BLSubAUC(UsedUnitInds,1),'ro')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, BlockType');
        ylabel('baselineSub resp, BlockType');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off','xlim',[0 1],'ylim',[0 1]);
        [~, p_BT] = ttest(UnitAfterStimAUC(UsedUnitInds,1),UnitAS_BLSubAUC(UsedUnitInds,1));
        title(sprintf('p = %.3e',p_BT));
        text(0.3,0.2,sprintf('n = %d',NumUsedUnits));

        ax2 = subplot(122);
        plot(UnitAfterStimAUC(UsedUnitInds,3),UnitAS_BLSubAUC(UsedUnitInds,3),'bo')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, Choice');
        ylabel('baselineSub resp, Choice');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_Choice] = ttest(UnitAfterStimAUC(UsedUnitInds,3),UnitAS_BLSubAUC(UsedUnitInds,3));
        title(sprintf('p = %.3e',p_Choice));


        % compare block type decoding with baseline data

        h2f = figure('position',[100 100 920 360]);
        ax3 = subplot(121);
        plot(UnitAfterStimAUC(UsedUnitInds,1),UnitBaselineAUC(UsedUnitInds,1),'ro')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, BlockType');
        ylabel('baseline, BlockType');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BT] = ttest(UnitAfterStimAUC(UsedUnitInds,1),UnitBaselineAUC(UsedUnitInds,1));
        title(sprintf('p = %.3e',p_BT));
        text(0.3,0.2,sprintf('n = %d',NumUsedUnits));

        ax4 = subplot(122);
        plot(UnitAS_BLSubAUC(UsedUnitInds,1),UnitBaselineAUC(UsedUnitInds,1),'ro')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('baselineSub resp, BlockType');
        ylabel('baseline, BlockType');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_Choice] = ttest(UnitAS_BLSubAUC(UsedUnitInds,1),UnitBaselineAUC(UsedUnitInds,1));
        title(sprintf('p = %.3e',p_Choice));

        % is there correlation between choice decoding and blocktype decoding
        h3f = figure('position',[100 100 920 360]);
        ax5 = subplot(121);
        plot(UnitAfterStimAUC(UsedUnitInds,1),UnitAfterStimAUC(UsedUnitInds,3),'mo')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, BlockType');
        ylabel('AfterStim resp, Choice');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [r1, p3] = corrcoef(UnitAfterStimAUC(UsedUnitInds,1),UnitAfterStimAUC(UsedUnitInds,3));
        title(sprintf('p = %.3e, r = %.3f',p3(1,2),r1(1,2)));
        text(0.3,0.2,sprintf('n = %d',NumUsedUnits));

        ax6 = subplot(122);
        plot(UnitAS_BLSubAUC(UsedUnitInds,1),UnitAS_BLSubAUC(UsedUnitInds,3),'mo')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('baselineSub resp, BlockType');
        ylabel('baselineSub resp, Choice');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [r2, p_Choice3] = corrcoef(UnitAS_BLSubAUC(UsedUnitInds,1),UnitAS_BLSubAUC(UsedUnitInds,3));
        title(sprintf('p = %.3e, r = %.3f',p_Choice3(1,2),r2(1,2)));

        %
        h1fSaveNAme = fullfile(figSaveFolder,sprintf('%s_After8BS_BT8Choice_AUC',cAName));
        saveas(h1f,h1fSaveNAme);
        saveas(h1f,h1fSaveNAme,'png');
        close(h1f);

        h2fSaveNAme = fullfile(figSaveFolder,sprintf('%s_Base8AS_BS_BT_AUC',cAName));
        saveas(h2f,h2fSaveNAme);
        saveas(h2f,h2fSaveNAme,'png');
        close(h2f);

        h3fSaveNAme = fullfile(figSaveFolder,sprintf('%s_AS8BS_BT_VS_choice_AUC',cAName));
        saveas(h3f,h3fSaveNAme);
        saveas(h3f,h3fSaveNAme,'png');
        close(h3f);
    end
    % used after stim response value to decode choice and block type, and then calculate the projection vector angle
    cA_unitsData = NMAfterStimResp_dataAll(:, UsedUnitInds);
    UsedUnitNum = size(cA_unitsData,2);
    md_choice = fitcsvm(cA_unitsData, NMTrial_ChoiceAll);
    ChoiceMDLoss = kfoldLoss(crossval(md_choice));
    md_BT = fitcsvm(cA_unitsData, NMTrial_blockTypesAll);
    BTMDLoss = kfoldLoss(crossval(md_BT));

    ChoiceVec = md_choice.Beta;
    BT_Vec = md_BT.Beta;
    DecodeVecAngle = VecAnglesFun(ChoiceVec,BT_Vec);

    SVMDecVecs(cArea,:) = {cAName, ChoiceVec, BT_Vec, DecodeVecAngle, UsedUnitNum, [ChoiceMDLoss,BTMDLoss]};

end

save(DataSaveName, 'UnitAfterStimAUC','UnitAS_BLSubAUC','UnitBaselineAUC','SVMDecVecs','-v7.3');


%%
% 
% % batched through all used sessions
% cclr
% 
% % AllSessFolderPathfile = 'K\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% sortingcode_string = 'ks2_5';
% 
% SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
%         'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
% NumprocessedNPSess = length(SessionFolders);
% 
% %%
% for cfff = 1 : NumprocessedNPSess
%     
%     ksfolder = fullfile(SessionFolders{cfff},sortingcode_string);
%     cSessFolder = ksfolder;
% %     ksfolder = fullfile(strrep(SessionFolders{cfff},'F:','I:\ksOutput_backup'),sortingcode_string);
%     fprintf('Processing session %d...\n', cfff);
% % % %     OldFolderName = fullfile(cSessFolder,'BaselinePredofBlocktype');
% % % %     if isfolder(OldFolderName)
% % % % %         stats = rmdir(OldFolderName,'s');
% % % %         
% % % %         stats = movefile(OldFolderName,fullfile(cSessFolder,'Old_BaselinePredofBT'),'f');
% % % %         if ~stats
% % % %             error('Unable to delete folder in Session %d.',cfff);
% % % %         end
% % % % 
% % % %     end
% %     baselineSpikePredBlocktypes_SVMProb;
% %     BlockType_Choice_decodingScript;
% %     baselineSpikePredBlocktypes_4batch;
%     BT_Choice_decodingScript_trialtypeWise;
% %     EventResp_avg_codes;
% end




