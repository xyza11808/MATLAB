
% All sorts of summary codes, run in different trunks
% ###################################################################################################
% Summary codes 1: summary of BT_and_Choice AUC values
%
cclr
%
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds);{'Others'}];

%%

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

Areawise_BTANDChoiceAUC = cell(NumUsedSess,NumAllTargetAreas,3);
Areawise_PopuVec = cell(NumUsedSess,NumAllTargetAreas,4);
Areawise_PopuBTChoicePerf = zeros(NumUsedSess,NumAllTargetAreas,2);
% Areawise_PopuSVMCC = cell(NumUsedSess,NumAllTargetAreas,2);
% Areawise_BehavChoiceDiff = cell(NumUsedSess,NumAllTargetAreas);
for cS = 1 :  NumUsedSess
    cSessPath = SessionFolders{cS}; %(2:end-1)
%     cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    
    SessAreaIndexDatafile = fullfile(ksfolder,'SessAreaIndexData.mat');
    SessAreaIndexData = load(SessAreaIndexDatafile);
    BTANDChoiceAUC_file = fullfile(ksfolder,'BTANDChoiceAUC_compPlot','BTANDChoiceAUC_popuVec.mat');
    BTANDChoiceAUCStrc = load(BTANDChoiceAUC_file,'UnitAfterStimAUC','UnitAS_BLSubAUC',...
        'UnitBaselineAUC','SVMDecVecs');
    
    
    AreaNames = BTANDChoiceAUCStrc.SVMDecVecs(:,1);
    NumAreas = length(AreaNames);
    if NumAreas < 1
        warning('There is no target units within following folder:\n %s \n ##################\n',cSessPath);
        continue;
    end
    
    for cAreaInds = 1 : NumAreas % including the 'Others' region at the end
        cAreaStr = AreaNames{cAreaInds};
        if isempty(cAreaStr)
            continue;
        end
        cA_unitInds = SessAreaIndexData.SessAreaIndexStrc.(cAreaStr).MatchedUnitInds;
        AreaMatchInds = matches(BrainAreasStr,cAreaStr);
        
        cA_SVMVec = BTANDChoiceAUCStrc.SVMDecVecs(cAreaInds,2:5);
        cA_SVMPerfs = BTANDChoiceAUCStrc.SVMDecVecs{cAreaInds,6};
        
        Areawise_PopuBTChoicePerf(cS,AreaMatchInds,:) = cA_SVMPerfs; % population decoding performance of choice and BT
        AreaMatchInds = matches(BrainAreasStr,cAreaStr);
        Areawise_BTANDChoiceAUC(cS,AreaMatchInds,:) = {BTANDChoiceAUCStrc.UnitAfterStimAUC(cA_unitInds,:),...
            BTANDChoiceAUCStrc.UnitAS_BLSubAUC(cA_unitInds,:),...
            BTANDChoiceAUCStrc.UnitBaselineAUC(cA_unitInds,:)}; % Behavior, SVMAccuracy, MaxCC,IsCCoefSig
        Areawise_PopuVec(cS,AreaMatchInds,:) = cA_SVMVec;
    end
end

%%
AllArea_TwoVecAngle = squeeze(Areawise_PopuVec(:,:,3));
AllArea_UnitNums = squeeze(Areawise_PopuVec(:,:,4));
AllArea_PopuBTloss = squeeze(Areawise_PopuBTChoicePerf(:,:,2));
AllArea_PopuChoiceloss = squeeze(Areawise_PopuBTChoicePerf(:,:,1));
AllArea_ASAUCs = squeeze(Areawise_BTANDChoiceAUC(:,:,1));
AllArea_BLSAUCs = squeeze(Areawise_BTANDChoiceAUC(:,:,2));
AllArea_BLAUCs = squeeze(Areawise_BTANDChoiceAUC(:,:,3));

NonEmptySessInds = cellfun(@(x) ~isempty(x),AllArea_ASAUCs);

[SessInds, AreaInds] = find(NonEmptySessInds);
AllArea_VecAngle_Vec = cell2mat(AllArea_TwoVecAngle(NonEmptySessInds));
AllArea_UnitNum_Vec = cell2mat(AllArea_UnitNums(NonEmptySessInds));
AllArea_BTloss_Vec = AllArea_PopuBTloss(NonEmptySessInds);
AllArea_Choiceloss_Vec = AllArea_PopuChoiceloss(NonEmptySessInds);

ValidPopuVecInds = AllArea_UnitNum_Vec > 3 & AllArea_BTloss_Vec < 0.5 ...
    & AllArea_Choiceloss_Vec < 0.5;
ValidPopuVecs = AllArea_VecAngle_Vec(ValidPopuVecInds);

AllArea_AS_AUC_CellVec = AllArea_ASAUCs(NonEmptySessInds);
AllArea_BLS_AUC_CellVec = AllArea_BLSAUCs(NonEmptySessInds);
AllArea_BL_AUC_CellVec = AllArea_BLAUCs(NonEmptySessInds);

% loop across all areas
NumBrainAreas = length(BrainAreasStr);
AreaWiseCellDatas = cell(NumBrainAreas, 5);
for cA = 1 : NumBrainAreas
    cA_Inds = AreaInds == cA;
    cA_Area_str = BrainAreasStr{cA};
    AreaWiseCellDatas(cA,1) = {cA_Area_str};
    if sum(cA_Inds)
       cA_AS_AUC_Vec = cell2mat(AllArea_AS_AUC_CellVec(cA_Inds));
       cA_BLS_AUC_Vec = cell2mat(AllArea_BLS_AUC_CellVec(cA_Inds));
       cA_BL_AUC_Vec = cell2mat(AllArea_BL_AUC_CellVec(cA_Inds));
       % left to see whether bad performed session should be excluded
       
       cA_BT8Choice_Angles = [AllArea_VecAngle_Vec(cA_Inds),...
           AllArea_UnitNum_Vec(cA_Inds), AllArea_BTloss_Vec(cA_Inds), ...
           AllArea_Choiceloss_Vec(cA_Inds)];
       
       AreaWiseCellDatas(cA,2:end) = {cA_AS_AUC_Vec, cA_BLS_AUC_Vec, ...
           cA_BL_AUC_Vec, cA_BT8Choice_Angles};
       
    end
    
    
end

%%
% summarySaveFolder1 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\BlockType_ChoiceVecANDAUC';
summarySaveFolder1 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\BlockType_ChoiceVecANDAUC';
if ~isfolder(summarySaveFolder1)
    mkdir(summarySaveFolder1);
end

%%
AfterRespSigAUCFracs = nan(NumBrainAreas,3);% only collect the after-stimulus response AUC
AllKinds_sigAUCFracs = nan(NumBrainAreas,5); % AS_BT_frac, AS_Choice_frac,BLS_BT_frac,BLS_choice_frac,BS_BT_frac
for cAA = 1 : NumBrainAreas
    cAreaStr = BrainAreasStr{cAA};
    if ~isempty(AreaWiseCellDatas{cAA,2}) % non-empty area regions
        cA_AS_AUCs = AreaWiseCellDatas{cAA,2};
        cA_BLS_AUCs = AreaWiseCellDatas{cAA,3};
        cA_BL_AUCs = AreaWiseCellDatas{cAA,4};
        cA_BTChoiceAngle = AreaWiseCellDatas{cAA,5};
        
        UsedAngleInds = cA_BTChoiceAngle(:,2) > 3;
        cA_BTChoice_usedAngles = cA_BTChoiceAngle(UsedAngleInds,1);
        cA_BTPerfs_used = 1 - cA_BTChoiceAngle(UsedAngleInds,3);
        cA_ChoicePerfs_used = 1 - cA_BTChoiceAngle(UsedAngleInds,4);
        
        NumTotalUnits = size(cA_AS_AUCs,1);
        if NumTotalUnits < 3
            continue;
        end
        
        hf = figure('position',[100 50 1240 900],'PaperPositionMode', 'manual');
        ax1 = subplot(331);
        hold on
        cA_AS_AUC_SigInds = cA_AS_AUCs(:,1) > cA_AS_AUCs(:,2);
        cA_BLS_AUC_SigInds = cA_BLS_AUCs(:,1) > cA_BLS_AUCs(:,2);
        
        plot(cA_AS_AUCs(~cA_AS_AUC_SigInds & ~cA_BLS_AUC_SigInds,1),cA_BLS_AUCs(~cA_AS_AUC_SigInds & ~cA_BLS_AUC_SigInds,1),...
            'o','Color',[.7 .7 .7]);
        plot(cA_AS_AUCs(cA_AS_AUC_SigInds,1),cA_BLS_AUCs(cA_AS_AUC_SigInds,1),'bo');
        plot(cA_AS_AUCs(cA_BLS_AUC_SigInds,1),cA_BLS_AUCs(cA_BLS_AUC_SigInds,1),'bo');
        
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, BlockType');
        ylabel('baselineSub resp, BlockType');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off','xlim',[0 1],'ylim',[0 1]);
        [~, p_BT] = ttest(cA_AS_AUCs(:,1),cA_BLS_AUCs(:,1));
        title(sprintf('Area %s, p = %.3e',cAreaStr, p_BT));
        text(0.3,0.2,sprintf('n = %d',NumTotalUnits));
        text(0.1,0.7,{'SigFraction:';sprintf('x Frac.: %.3f',mean(cA_AS_AUC_SigInds));...
            sprintf('y Frac.: %.3f',mean(cA_BLS_AUC_SigInds))},'FontSize',6);

        ax2 = subplot(332);
        hold on
        cA_AS_AUCChoiceSig = cA_AS_AUCs(:,3) > cA_AS_AUCs(:,4);
        cA_BLS_AUCChoiceSig = cA_BLS_AUCs(:,3) > cA_BLS_AUCs(:,4);
        
        plot(cA_AS_AUCs(~cA_AS_AUCChoiceSig & ~cA_BLS_AUCChoiceSig,3),...
            cA_BLS_AUCs(~cA_AS_AUCChoiceSig & ~cA_BLS_AUCChoiceSig,3),'o',...
            'Color',[.7 .7 .7]);
        plot(cA_AS_AUCs(cA_AS_AUCChoiceSig,3),cA_BLS_AUCs(cA_AS_AUCChoiceSig,3),'bo');
        plot(cA_AS_AUCs(cA_BLS_AUCChoiceSig,3),cA_BLS_AUCs(cA_BLS_AUCChoiceSig,3),'bo');
        
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, Choice');
        ylabel('baselineSub resp, Choice');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_Choice] = ttest(cA_AS_AUCs(:,3),cA_BLS_AUCs(:,3));
        title(sprintf('p = %.3e',p_Choice));
        text(0.1,0.7,{'SigFraction:';sprintf('x Frac.: %.3f',mean(cA_AS_AUCChoiceSig));...
            sprintf('y Frac.: %.3f',mean(cA_BLS_AUCChoiceSig))},'FontSize',6);
        
        % compare block type decoding with baseline data
%         h2f = figure('position',[100 100 920 360]);
        ax3 = subplot(334);
        hold on
        cA_BL_AUCSig = cA_BL_AUCs(:,1) > cA_BL_AUCs(:,2);
        
        plot(cA_AS_AUCs(~cA_AS_AUC_SigInds & ~cA_BL_AUCSig,1),...
            cA_BL_AUCs(~cA_AS_AUC_SigInds & ~cA_BL_AUCSig,1),'o','Color',[.7 .7 .7]);
        plot(cA_AS_AUCs(cA_BL_AUCSig,1),cA_BL_AUCs(cA_BL_AUCSig,1),'ro');
        plot(cA_AS_AUCs(cA_AS_AUC_SigInds,1),cA_BL_AUCs(cA_AS_AUC_SigInds,1),'ro');
        
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, BlockType');
        ylabel('baseline, BlockType');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BT] = ttest(cA_AS_AUCs(:,1),cA_BL_AUCs(:,1));
        title(sprintf('p = %.3e',p_BT));
        text(0.1,0.7,{'SigFraction:';...
            sprintf('y Frac.: %.3f',mean(cA_BL_AUCSig))},'FontSize',6);
%         text(0.3,0.2,sprintf('n = %d',NumUsedUnits));

        ax4 = subplot(335);
        hold on
        plot(cA_BLS_AUCs(~cA_BLS_AUC_SigInds & ~cA_BL_AUCSig,1),...
            cA_BL_AUCs(~cA_BLS_AUC_SigInds & ~cA_BL_AUCSig,1),'o','Color',[.7 .7 .7]);
        plot(cA_BLS_AUCs(cA_BL_AUCSig,1),cA_BL_AUCs(cA_BL_AUCSig,1),'ro');
        plot(cA_BLS_AUCs(cA_BLS_AUC_SigInds,1),cA_BL_AUCs(cA_BLS_AUC_SigInds,1),'ro');
        
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('baselineSub resp, BlockType');
        ylabel('baseline, BlockType');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_Choice] = ttest(cA_BLS_AUCs(:,1),cA_BL_AUCs(:,1));
        tb10 = fitlm(cA_BLS_AUCs(:,1),cA_BL_AUCs(:,1));
        SlopeValue0 = tb10.Coefficients.Estimate(2);
        
        title(sprintf('p = %.3e, slope = %.4f',p_Choice,SlopeValue0));
        
        % is there correlation between choice decoding and blocktype decoding
        ax5 = subplot(337);
        hold on
        plot(cA_AS_AUCs(~cA_AS_AUCChoiceSig & ~cA_AS_AUC_SigInds,1),...
            cA_AS_AUCs(~cA_AS_AUCChoiceSig & ~cA_AS_AUC_SigInds,3),'o','Color',[.7 .7 .7]);
        plot(cA_AS_AUCs(cA_AS_AUC_SigInds,1),cA_AS_AUCs(cA_AS_AUC_SigInds,3),'mo');
        plot(cA_AS_AUCs(cA_AS_AUCChoiceSig,1),cA_AS_AUCs(cA_AS_AUCChoiceSig,3),'mo');
        
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, BlockType');
        ylabel('AfterStim resp, Choice');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [r1, p3] = corrcoef(cA_AS_AUCs(:,1),cA_AS_AUCs(:,3));
        title(sprintf('p = %.3e, r = %.3f',p3(1,2),r1(1,2)));
%         text(0.3,0.2,sprintf('n = %d',NumUsedUnits));
        
        AfterRespSigAUCFracs(cAA,1:2) = [mean(cA_AS_AUCChoiceSig), mean(cA_AS_AUC_SigInds)];
        AfterRespSigAUCFracs(cAA,3) = (AfterRespSigAUCFracs(cAA,2) - AfterRespSigAUCFracs(cAA,1))/...
            (AfterRespSigAUCFracs(cAA,1) + AfterRespSigAUCFracs(cAA,2)); % 1 indicates pure rule info
        % -1 indicates pure choice info
        
        AllKinds_sigAUCFracs(cAA,:) = [mean(cA_AS_AUC_SigInds),mean(cA_AS_AUCChoiceSig),...
            mean(cA_BLS_AUC_SigInds),mean(cA_BLS_AUCChoiceSig),mean(cA_BL_AUCSig)];
        
        
        ax6 = subplot(338);
        hold on
        plot(cA_BLS_AUCs(~cA_BLS_AUCChoiceSig & ~cA_BLS_AUC_SigInds,1),...
            cA_BLS_AUCs(~cA_BLS_AUCChoiceSig & ~cA_BLS_AUC_SigInds,3),'o','Color',[.7 .7 .7]);
        plot(cA_BLS_AUCs(cA_BLS_AUC_SigInds,1),cA_BLS_AUCs(cA_BLS_AUC_SigInds,3),'mo');
        plot(cA_BLS_AUCs(cA_BLS_AUCChoiceSig,1),cA_BLS_AUCs(cA_BLS_AUCChoiceSig,3),'mo');
        
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('baselineSub resp, BlockType');
        ylabel('baselineSub resp, Choice');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_Choice3] = corrcoef(cA_BLS_AUCs(:,1),cA_BLS_AUCs(:,3));
        tb1 = fitlm(cA_BLS_AUCs(:,1),cA_BLS_AUCs(:,3));
        SlopeValue = tb1.Coefficients.Estimate(2);
        title(sprintf('p = %.3e, Slope = %.3f',p_Choice3(1,2),SlopeValue));
        
       ax7 = subplot(333);
%        PerfEdges = 0:0.05:1;
       nBins = 10;
       hh = histogram(ax7,cA_BTChoice_usedAngles,nBins);
       yscales = get(gca,'ylim')+[0 0.5];
       line([mean(cA_BTChoice_usedAngles) mean(cA_BTChoice_usedAngles)],yscales,...
           'Color','m','linewidth',1.8);
       set(gca,'box','off','ylim',yscales);
       title(ax7,sprintf('DecodeVecAngle = %.2f (n=%d)',mean(cA_BTChoice_usedAngles),numel(cA_BTChoice_usedAngles)));
       
       ax8 = subplot(336);
       PerfEdges = 0:0.05:1;
       hh2 = histogram(ax8,cA_BTPerfs_used,PerfEdges);
       yscales = get(gca,'ylim')+[0 0.5];
       line([mean(cA_BTPerfs_used) mean(cA_BTPerfs_used)],yscales,...
           'Color','m','linewidth',1.8);
       set(gca,'box','off','ylim',yscales);
       title(ax8,sprintf('BlockType decodePerf = %.2f',mean(cA_BTPerfs_used)));
       
       ax9 = subplot(339);
       PerfEdges = 0:0.05:1;
       hh3 = histogram(ax9,cA_ChoicePerfs_used,PerfEdges);
       yscales = get(gca,'ylim')+[0 0.5];
       line([mean(cA_ChoicePerfs_used) mean(cA_ChoicePerfs_used)],yscales,...
           'Color','m','linewidth',1.8);
       set(gca,'box','off','ylim',yscales);
       title(ax9,sprintf('Choice decodePerf = %.2f',mean(cA_ChoicePerfs_used)));
       
       fullfileSaveNames = fullfile(summarySaveFolder1,sprintf('Area_%s_UnitAUC_PopultionVecAngle_plot',cAreaStr));
       
       saveas(hf, fullfileSaveNames);
       saveas(hf, fullfileSaveNames, 'png');
       saveas(hf, fullfileSaveNames, 'pdf');
       close(hf);
    end

end

%%
dataFullSaveNames1 = fullfile(summarySaveFolder1,'UnitAUC_PopuVecAngle_datas.mat');
save(dataFullSaveNames1,'AreaWiseCellDatas', 'BrainAreasStr', 'Areawise_PopuVec',...
    'Areawise_BTANDChoiceAUC', 'Areawise_PopuBTChoicePerf','AfterRespSigAUCFracs','AllKinds_sigAUCFracs','-v7.3');
%%
nanInds = isnan(AfterRespSigAUCFracs(:,3));
UsedAreaInds = find(~nanInds);
UsedArea_index = AfterRespSigAUCFracs(UsedAreaInds,3);
UsedAreaStrs = BrainAreasStr(UsedAreaInds);
UsedAreaNumber = length(UsedAreaStrs);
[SortIndex, SortInds] = sort(UsedArea_index);
h2f = figure('position',[100 100 420 800]);
plot(SortIndex,1:UsedAreaNumber, 'ko','linewidth',1.5,'MarkerSize',10);
line([0 0],[0.5,UsedAreaNumber+0.5],'linewidth',1,'Color',[.7 .7 .7],'linestyle','--');
set(gca,'ytick', 1:UsedAreaNumber,'yticklabel',UsedAreaStrs(:),'xlim',[-1.05 1.05],'xtick',[-1 1],...
    'xticklabel',{'Choice','Rule'},'ylim',[0 UsedAreaNumber+1]);

ylabel('Areas');
xlabel('Rule/Choice Index');

saveName2 = fullfile(summarySaveFolder1,'Rule and choice index area sort plot');
saveas(h2f,saveName2);
saveas(h2f,saveName2,'png');
saveas(h2f,saveName2,'pdf');


%%
% ###################################################################################################
% Summary codes 2: summary of BT_and_Choice AUC values, which was seperately
% calculated using revfreq trials and non-revfreq trials
%
cclr
%
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds);{'Others'}];

%%

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

Areawise_BTANDChoiceAUC = cell(NumUsedSess,NumAllTargetAreas,3);
Areawise_PopuBTChoicePerf = cell(NumUsedSess,NumAllTargetAreas,2);
% Areawise_PopuSVMCC = cell(NumUsedSess,NumAllTargetAreas,2);
% Areawise_BehavChoiceDiff = cell(NumUsedSess,NumAllTargetAreas);
for cS = 1 :  NumUsedSess
    cSessPath = SessionFolders{cS}; %(2:end-1)
%     cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
        
    SessAreaIndexDatafile = fullfile(ksfolder,'SessAreaIndexData.mat');
    SessAreaIndexData = load(SessAreaIndexDatafile);
    BTANDChoiceAUC_file = fullfile(ksfolder,'BTANDChoiceAUC_TrWise','BTANDChoiceAUC_TrTypeWise.mat');
    BTANDChoiceAUCStrc = load(BTANDChoiceAUC_file,'UnitAfterStimAUC','UnitAS_BLSubAUC',...
        'UnitBaselineAUC','SVMDecVecs');
    
    
    AreaNames = BTANDChoiceAUCStrc.SVMDecVecs(:,1);
    NumAreas = length(AreaNames);
    if NumAreas < 1
        warning('There is no target units within following folder:\n %s \n ##################\n',cSessPath);
        continue;
    end
    
    for cAreaInds = 1 : NumAreas % including the 'Others' region at the end
        cAreaStr = AreaNames{cAreaInds};
        if isempty(cAreaStr)
            continue;
        end
        cA_unitInds = SessAreaIndexData.SessAreaIndexStrc.(cAreaStr).MatchedUnitInds;
        AreaMatchInds = matches(BrainAreasStr,cAreaStr,'IgnoreCase',true);
        
        cA_SVMPerfs = BTANDChoiceAUCStrc.SVMDecVecs{cAreaInds,6};
        cA_unitNums = BTANDChoiceAUCStrc.SVMDecVecs{cAreaInds,5};
        
        Areawise_PopuBTChoicePerf(cS,AreaMatchInds,:) = {cA_SVMPerfs,cA_unitNums}; % population decoding performance of choice and BT
        
        Areawise_BTANDChoiceAUC(cS,AreaMatchInds,:) = {BTANDChoiceAUCStrc.UnitAfterStimAUC(:,cA_unitInds,:),...
            BTANDChoiceAUCStrc.UnitAS_BLSubAUC(:,cA_unitInds,:),...
            BTANDChoiceAUCStrc.UnitBaselineAUC(:,cA_unitInds,:)};
        
    end
end

%%
AS_Areawise_AUC_Alls = squeeze(Areawise_BTANDChoiceAUC(:,:,1));
BLS_Areawise_AUC_Alls = squeeze(Areawise_BTANDChoiceAUC(:,:,2));
BS_Areawise_AUC_Alls = squeeze(Areawise_BTANDChoiceAUC(:,:,3));

IsEmptyAreaSess = cellfun(@(x) ~isempty(x), AS_Areawise_AUC_Alls);
[SessInds, AreaInds] = find(IsEmptyAreaSess);

AS_Areawise_AUC_cellVec = AS_Areawise_AUC_Alls(IsEmptyAreaSess);
BLS_Areawise_AUC_cellVec = BLS_Areawise_AUC_Alls(IsEmptyAreaSess);
BS_Areawise_AUC_cellVec = BS_Areawise_AUC_Alls(IsEmptyAreaSess);

Areawise_PopuBTChoicePerf_cellvec = squeeze(Areawise_PopuBTChoicePerf(:,:,1));
Areawise_PopuBTChoicePerf_size = squeeze(Areawise_PopuBTChoicePerf(:,:,2));
Area_popuBTChoicePerfs = Areawise_PopuBTChoicePerf_cellvec(IsEmptyAreaSess);
Area_popuBTChoicePerfs_row = cellfun(@(x) [x(1,:),x(2,:)],Area_popuBTChoicePerfs,'UniformOutput',false);
Area_popuBTChoicePerfs_size = cell2mat(Areawise_PopuBTChoicePerf_size(IsEmptyAreaSess));

%%
% summarySaveFolder2 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\BlockType_ChoiceVecANDAUC';
summarySaveFolder2 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\Trialwise_BTChoiceAUC';
if ~isfolder(summarySaveFolder2)
    mkdir(summarySaveFolder2);
end

%%
Areawise_AUCCells_all = cell(NumAllTargetAreas,7);
for cA = 1 : NumAllTargetAreas
    cA_Inds = AreaInds == cA;
    cAName = BrainAreasStr{cA};
    if any(cA_Inds)
       % in case not empty
       % AS AUCs
       cA_AS_AreawiseAUC_cellvec = AS_Areawise_AUC_cellVec(cA_Inds);
       cA_AS_AreawiseAUC_RT_cellvec = cellfun(@(x) squeeze(x(1,:,:)),cA_AS_AreawiseAUC_cellvec,'UniformOutput',false);
       cA_AS_AreawiseAUC_NRT_cellvec = cellfun(@(x) squeeze(x(2,:,:)),cA_AS_AreawiseAUC_cellvec,'UniformOutput',false);
       cA_AS_AreawiseAUC_RT_Vec = cell2mat(cA_AS_AreawiseAUC_RT_cellvec);
       cA_AS_AreawiseAUC_NRT_Vec = cell2mat(cA_AS_AreawiseAUC_NRT_cellvec);
       NumUsedUnits = size(cA_AS_AreawiseAUC_RT_Vec,1);
       
       % BLS AUCs
       cA_BLS_AreawiseAUC_cellvec = BLS_Areawise_AUC_cellVec(cA_Inds);
       cA_BLS_AreawiseAUC_RT_cellvec = cellfun(@(x) squeeze(x(1,:,:)),cA_BLS_AreawiseAUC_cellvec,'UniformOutput',false);
       cA_BLS_AreawiseAUC_NRT_cellvec = cellfun(@(x) squeeze(x(2,:,:)),cA_BLS_AreawiseAUC_cellvec,'UniformOutput',false);
       cA_BLS_AreawiseAUC_RT_Vec = cell2mat(cA_BLS_AreawiseAUC_RT_cellvec);
       cA_BLS_AreawiseAUC_NRT_Vec = cell2mat(cA_BLS_AreawiseAUC_NRT_cellvec);
       
       % BS AUCs
       cA_BS_AreawiseAUC_cellvec = BS_Areawise_AUC_cellVec(cA_Inds);
       cA_BS_AreawiseAUC_RT_cellvec = cellfun(@(x) squeeze(x(1,:,:)),cA_BS_AreawiseAUC_cellvec,'UniformOutput',false);
       cA_BS_AreawiseAUC_NRT_cellvec = cellfun(@(x) squeeze(x(2,:,:)),cA_BS_AreawiseAUC_cellvec,'UniformOutput',false);
       cA_BS_AreawiseAUC_RT_Vec = cell2mat(cA_BS_AreawiseAUC_RT_cellvec);
       cA_BS_AreawiseAUC_NRT_Vec = cell2mat(cA_BS_AreawiseAUC_NRT_cellvec);
       
       % population decoding performance
       cA_popuSize = Area_popuBTChoicePerfs_size(cA_Inds);
       cA_popuPerfs = Area_popuBTChoicePerfs_row(cA_Inds);
       cA_Used_popuPerfs = cell2mat(cA_popuPerfs(cA_popuSize > 2));
       
       Areawise_AUCCells_all(cA,:) = {cA_AS_AreawiseAUC_RT_Vec,cA_AS_AreawiseAUC_NRT_Vec,...
           cA_BLS_AreawiseAUC_RT_Vec,cA_BLS_AreawiseAUC_NRT_Vec,cA_BS_AreawiseAUC_RT_Vec,...
           cA_BS_AreawiseAUC_NRT_Vec,cA_Used_popuPerfs};
       
       % plot the comparison
       h1f = figure('position',[100 50 720 850],'paperpositionmode','manual');
        ax1 = subplot(321);
        hold on
        AS_BT_RevTrs = cA_AS_AreawiseAUC_RT_Vec(:,1);
        AS_BT_NonRevTrs = cA_AS_AreawiseAUC_NRT_Vec(:,1);
        SigInds1 = cA_AS_AreawiseAUC_RT_Vec(:,1) > cA_AS_AreawiseAUC_RT_Vec(:,2) | ...
            cA_AS_AreawiseAUC_NRT_Vec(:,1) > cA_AS_AreawiseAUC_NRT_Vec(:,2);
        plot(AS_BT_RevTrs(~SigInds1),AS_BT_NonRevTrs(~SigInds1),'o','Color',[.7 .7 .7]);
        plot(AS_BT_RevTrs(SigInds1),AS_BT_NonRevTrs(SigInds1),'ro','linewidth',1);
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, RevTrs');
        ylabel('AfterStim resp, NonRevTrs');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off','xlim',[0 1],'ylim',[0 1]);
        [~, p_AS_BT] = ttest(AS_BT_RevTrs,AS_BT_NonRevTrs);
        title(sprintf('Area %s, BT AUC, p = %.3e',cAName, p_AS_BT));
        text(0.3,0.2,sprintf('n = %d',NumUsedUnits));

        ax2 = subplot(322);
        hold on
        AS_Choice_RevTrs = cA_AS_AreawiseAUC_RT_Vec(:,3);
        AS_Choice_NonRevTrs = cA_AS_AreawiseAUC_NRT_Vec(:,3);
        SigInds2 = cA_AS_AreawiseAUC_RT_Vec(:,3) > cA_AS_AreawiseAUC_RT_Vec(:,4) | ...
            cA_AS_AreawiseAUC_NRT_Vec(:,3) > cA_AS_AreawiseAUC_NRT_Vec(:,4);
        plot(AS_Choice_RevTrs(~SigInds2),AS_Choice_NonRevTrs(~SigInds2),'o','Color',[.7 .7 .7]);
        plot(AS_Choice_RevTrs(SigInds2),AS_Choice_NonRevTrs(SigInds2),'bo','linewidth',1);
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, RevTrs');
        ylabel('AfterStim resp, NonRevTrs');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BLS_BT] = ttest(AS_Choice_RevTrs,AS_Choice_NonRevTrs);
        title(sprintf('Choice AUC, p = %.3e',p_BLS_BT));


        % compare block type decoding with baseline data
        ax3 = subplot(323);
        hold on
        BL_BT_RevTrs = cA_BS_AreawiseAUC_RT_Vec(:,1);
        BL_BT_NonRevTrs = cA_BS_AreawiseAUC_NRT_Vec(:,1);
        SigInds3 = cA_BS_AreawiseAUC_RT_Vec(:,1) > cA_BS_AreawiseAUC_RT_Vec(:,2) | ...
            cA_BS_AreawiseAUC_NRT_Vec(:,1) > cA_BS_AreawiseAUC_NRT_Vec(:,2);
        plot(BL_BT_RevTrs(~SigInds3),BL_BT_NonRevTrs(~SigInds3),'o','Color',[.7 .7 .7]);
        plot(BL_BT_RevTrs(SigInds3),BL_BT_NonRevTrs(SigInds3),'ro','linewidth',1);
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('baseline, RevTrs');
        ylabel('baseline, NonRevTrs');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BL_BT] = ttest(BL_BT_RevTrs,BL_BT_NonRevTrs);
        title(sprintf('BT AUC, p = %.3e',p_BL_BT));

        ax4 = subplot(325);
        hold on
        BLS_BT_RevTrs = cA_BLS_AreawiseAUC_RT_Vec(:,1);
        BLS_BT_NonRevTrs = cA_BLS_AreawiseAUC_NRT_Vec(:,1);
        SigInds4 = cA_BLS_AreawiseAUC_RT_Vec(:,1) > cA_BLS_AreawiseAUC_RT_Vec(:,2) | ...
            cA_BLS_AreawiseAUC_NRT_Vec(:,1) > cA_BLS_AreawiseAUC_NRT_Vec(:,2);
        plot(BLS_BT_RevTrs(~SigInds4),BLS_BT_NonRevTrs(~SigInds4),'o','Color',[.7 .7 .7]);
        plot(BLS_BT_RevTrs(SigInds4),BLS_BT_NonRevTrs(SigInds4),'ro','linewidth',1);
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('baselineSub resp, RevTrs');
        ylabel('baselineSub resp, NonRevTrs');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BLS_BT] = ttest(BLS_BT_RevTrs,BLS_BT_NonRevTrs);
        title(sprintf('BT AUC, p = %.3e',p_BLS_BT));

        % is there correlation between choice decoding and blocktype decoding
        ax5 = subplot(326);
        hold on
        BLS_Choice_RevTrs = cA_BLS_AreawiseAUC_RT_Vec(:,3);
        BLS_Choice_NonRevTrs = cA_BLS_AreawiseAUC_NRT_Vec(:,3);
        SigInds5 = cA_BLS_AreawiseAUC_RT_Vec(:,3) > cA_BLS_AreawiseAUC_RT_Vec(:,4) | ...
            cA_BLS_AreawiseAUC_NRT_Vec(:,3) > cA_BLS_AreawiseAUC_NRT_Vec(:,4);
        plot(BLS_Choice_RevTrs(~SigInds5),BLS_Choice_NonRevTrs(~SigInds5),'o','Color',[.7 .7 .7]);
        plot(BLS_Choice_RevTrs(SigInds5),BLS_Choice_NonRevTrs(SigInds5),'bo','linewidth',1);
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('baselineSub resp, RevTrs');
        ylabel('baselineSub resp, NonRevTrs');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BLS_Chioce] = ttest(BLS_Choice_RevTrs,BLS_Choice_NonRevTrs);

        title(sprintf('Choice AUC, p = %.3e',p_BLS_Chioce));
        
        % compare the population decoding performance, for choice and BT
        % both, plot in one figure
        NumSess = size(cA_Used_popuPerfs,1);
        if NumSess > 1
            cA_Used_popuPerfs = 1 - cA_Used_popuPerfs;
            ax6 = subplot(324);
            hold on
            hl1 = plot(cA_Used_popuPerfs(:,1),cA_Used_popuPerfs(:,3),'bo','linewidth',1.4);
            hl2 = plot(cA_Used_popuPerfs(:,2),cA_Used_popuPerfs(:,4),'ro','linewidth',1.4);
            line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
            xlabel('PopuAccuracy, RevTrs');
            ylabel('PopuAccuracy, NonRevTrs');
            set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
            legend([hl1,hl2],{'Choice','BlockType'},'location','northwest','box','off');
            text(0.3,0.3,sprintf('N = %d',NumSess));
            
            if NumSess > 3
                [~,p_perfs] = ttest(cA_Used_popuPerfs(:,1),cA_Used_popuPerfs(:,3));
                [~,p_perfs2] = ttest(cA_Used_popuPerfs(:,2),cA_Used_popuPerfs(:,4));
                title(sprintf('ChoiceP %.3e, BTP %.2e', p_perfs,p_perfs2));
            end
        end
        savename = fullfile(summarySaveFolder2,sprintf('Area %s trialtype wise AUC compare',cAName));
        saveas(h1f,savename);
        saveas(h1f,savename,'png');
        saveas(h1f,savename,'pdf');
        close(h1f);
    end
end

%%
filesavename = fullfile(summarySaveFolder2,'TrWiseAUC_popuPerf_summary.mat');
save(filesavename,'Areawise_BTANDChoiceAUC','Areawise_PopuBTChoicePerf','BrainAreasStr','Areawise_AUCCells_all','-v7.3');

%%
% ###################################################################################################
% Summary codes 3: 

cclr
%
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds);{'Others'}];

%%

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFolders = SessionFoldersC(2:end);
NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

Areawise_RespUnitAll = cell(NumUsedSess,NumAllTargetAreas,3);
SessTotalUnitNum = zeros(NumUsedSess,1);
for cS = 1 :  NumUsedSess
    cSessPath = SessionFolders{cS}; %(2:end-1)
%     cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
        
    SessAreaIndexDatafile = fullfile(ksfolder,'SessAreaIndexData.mat');
    SessAreaIndexData = load(SessAreaIndexDatafile);
    UnitRespCoef_file = fullfile(ksfolder,'UnitRespTypeCoefNew.mat');
    UnitRespCoefStrc = load(UnitRespCoef_file,'UnitUsedCoefs','AboveThresUnit',...
        'UsedUnitMDRs_WithShuf');
    UnitAUCfilePath = fullfile(ksfolder,'BaselinePredofBlocktype','SingleUnitAUC.mat');
    UnitAUCstrc = load(UnitAUCfilePath,'AUCValuesAll');
    TotalUnitNumbers = size(UnitAUCstrc.AUCValuesAll,1);
    SessTotalUnitNum(cS) = TotalUnitNumbers;
    
    SessFieldNames = fieldnames(SessAreaIndexData.SessAreaIndexStrc);
    ExistFieldNames = SessFieldNames(SessAreaIndexData.SessAreaIndexStrc.UsedAbbreviations);
    
    RespUnitInds = UnitRespCoefStrc.AboveThresUnit; % unit inds that shows significant response to tasks
    IsUnitwithinTarget = false(numel(RespUnitInds),1);
    
    NumAreas = length(ExistFieldNames);
    if NumAreas < 1
        warning('There is no target units within following folder:\n %s \n ##################\n',cSessPath);
        continue;
    end
    
    for cAreaInds = 1 : NumAreas+1 % extra region for "others" storage
        if cAreaInds > NumAreas
            cAreaStr = 'Others';
            cA_unit_IswithincA = ~IsUnitwithinTarget;
        else
            cAreaStr = ExistFieldNames{cAreaInds};
            if isempty(cAreaStr)
                continue;
            end
            cA_unitInds = SessAreaIndexData.SessAreaIndexStrc.(cAreaStr).MatchedUnitInds;
            cA_unit_IswithincA = ismember(RespUnitInds, cA_unitInds);
        end
        
        
        if any(cA_unit_IswithincA)
            cA_RespUnit = RespUnitInds(cA_unit_IswithincA);
            
            AreaMatchInds = matches(BrainAreasStr,cAreaStr,'IgnoreCase',true);
            
            Areawise_RespUnitAll(cS,AreaMatchInds,:) = {cA_RespUnit, ...
                UnitRespCoefStrc.UnitUsedCoefs(cA_unit_IswithincA,:),...
                UnitRespCoefStrc.UsedUnitMDRs_WithShuf(cA_unit_IswithincA,:)};
            
            IsUnitwithinTarget(cA_unit_IswithincA) = true;
        end

    end
    
end

%% 
Areawise_respCoef_Cells = squeeze(Areawise_RespUnitAll(:,:,2));
Areawise_MDRs_Cells = squeeze(Areawise_RespUnitAll(:,:,3));
EmptySessInds = cellfun(@(x) ~isempty(x),Areawise_respCoef_Cells);
[SessInds, AreaInds] = find(EmptySessInds);

Areawise_respCoef_CellVec = Areawise_respCoef_Cells(EmptySessInds);
Areawise_MDRs_CellVec = Areawise_MDRs_Cells(EmptySessInds);

% Areawise_respCoef_Vecs = cat(1,Areawise_respCoef_CellVec);
% Areawise_MDRs_Vecs = cat(1,Areawise_MDRs_CellVec); % real Rs and shuf Rs
AreaSum_respCoefAlls = cell(NumAllTargetAreas, 4);
IsAreaHaveRespUnit = zeros(NumAllTargetAreas,1);
for cA = 1 : NumAllTargetAreas
   cA_inds = AreaInds == cA;
   if any(cA_inds)
       % if current area inds is not empty
       cA_respCoef_CellVec = Areawise_respCoef_CellVec(cA_inds);
       cA_respCoef_Vecs = cat(1,cA_respCoef_CellVec{:});
       cA_respCoefs_mtx = cell2mat(cA_respCoef_Vecs(:,1));
       cA_respCoef_RepeatAvg = cell2mat(cellfun(@mean, cA_respCoef_Vecs(:,2),'UniformOutput', false));
       cA_Sess_totalUnitsNum = SessTotalUnitNum(SessInds(cA_inds));
       
       cA_MDRs_CellVec = Areawise_MDRs_CellVec(cA_inds);
       cA_MDRs_Vecs = cell2mat(cat(1, cA_MDRs_CellVec{:}));
       
       AreaSum_respCoefAlls(cA,:) = {cA_respCoefs_mtx, cA_respCoef_RepeatAvg, cA_Sess_totalUnitsNum, cA_MDRs_Vecs};
       
       IsAreaHaveRespUnit(cA) = 1;
   end
    
    
end

%%
% cclr
% 
% AllSessFolderPathfile = 'H:\file_from_N\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
% % AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
% 
% SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
%         'Sheet',1);
% SessionFolders = SessionFoldersC(2:end);
% NumUsedSess = length(SessionFolders);
% 
% 
% %%
% 
% 
% for cSess = 1 : NumUsedSess
%     
% %     cSessFolder = fullfile(SessionFolders{cSess}(2:end-1),'ks2_5');
%     cSessFolder = fullfile(strrep(SessionFolders{cSess}(2:end-1),'F:','I:\ksOutput_backup'),'ks2_5');
%     
%     EventResp_avg_codes;
% 
%     saveName = fullfile(cSessFolder,'ks2_5','UnitRespTypeCoef.mat');
%     save(saveName,'UnitUsedCoefs', 'AboveThresUnit', 'UnitFitmds_All', 'overAllTerms_mtx', 'DevThreshold','-v7.3');
%     
% end
% 
% %%
% 
% for cSess = 1 : NumUsedSess
%     
% %     cSessFolder = fullfile(SessionFolders{cSess}(2:end-1),'ks2_5');
%     ksfolder = fullfile(strrep(SessionFolders{cSess}(2:end-1),'F:','I:\ksOutput_backup'),'ks2_5');
%     
% %     baselineSpikePredBlocktypes_SVMProb;
%     BlockType_Choice_decodingScript;
% %     baselineSpikePredBlocktypes_4batch;
% 
% %     saveName = fullfile(cSessFolder,'ks2_5','UnitRespTypeCoef.mat');
% %     save(saveName,'UnitUsedCoefs', 'AboveThresUnit', 'UnitFitmds_All', 'overAllTerms_mtx', 'DevThreshold','-v7.3');
%     
% end


