
% All sorts of summary codes, run in different trunks
% ###################################################################################################
% Summary codes 1: summary of BT_and_Choice AUC values
%
cclr
%%
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds)];

FullBrainStrC = readcell(AllSessFolderPathfile,'Range','E:E',...
        'Sheet',1);
FullBrainStrCC = FullBrainStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
% EmptyInds2 = cellfun(@(x) isempty(x) ||any(ismissing(x)),FullBrainStrCC);
FullBrainStr = [FullBrainStrCC(~EmptyInds)];


%%

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersRaw = SessionFoldersC(2:end);
EmptyInds2 = cellfun(@(x) isempty(x) ||any( ismissing(x)),SessionFoldersRaw);
SessionFolders = SessionFoldersRaw(~EmptyInds2);

NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

Areawise_BTANDChoiceAUC = cell(NumUsedSess,NumAllTargetAreas,3);
Areawise_PopuVec = cell(NumUsedSess,NumAllTargetAreas,4);
Areawise_PopuBTChoicePerf = zeros(NumUsedSess,NumAllTargetAreas,2);
% Areawise_PopuSVMCC = cell(NumUsedSess,NumAllTargetAreas,2);
% Areawise_BehavChoiceDiff = cell(NumUsedSess,NumAllTargetAreas);
for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS}; %(2:end-1)
%     cSessPath = strrep(SessionFolders{cS},'F:\','E:\NPCCGs\');
    cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    
    SessAreaIndexDatafile = fullfile(ksfolder,'SessAreaIndexDataAligned.mat');
    SessAreaIndexData = load(SessAreaIndexDatafile);
    BTANDChoiceAUC_file = fullfile(ksfolder,'BTANDChoiceAUC_compPlot','BTANDChoiceAUC_popuVec.mat');
    BTANDChoiceAUCStrc = load(BTANDChoiceAUC_file,'UnitAfterStimAUC','UnitAS_BLSubAUC',...
        'UnitBaselineAUC','SVMDecVecs');
    
    
    AreaNames = BTANDChoiceAUCStrc.SVMDecVecs(:,1);
    AreaNames(strcmpi(AreaNames,'Others')) = [];
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
        
        cA_SVMVec = BTANDChoiceAUCStrc.SVMDecVecs(cAreaInds,2:5);
        cA_SVMPerfs = BTANDChoiceAUCStrc.SVMDecVecs{cAreaInds,6};
        
        Areawise_PopuBTChoicePerf(cS,AreaMatchInds,:) = cA_SVMPerfs; % population decoding performance of choice and BT
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
summarySaveFolder1 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\BlockType_ChoiceVecANDAUC';
% summarySaveFolder1 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\BlockType_ChoiceVecANDAUCAdd';
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
       
       annotation('textbox',[0.02 0.01 0.1 0.05],'String',FullBrainStr{cAA},'FitBoxToText','on','Color','r');
       
       fullfileSaveNames = fullfile(summarySaveFolder1,sprintf('Area_%s_UnitAUC_PopultionVecAngle_plot',cAreaStr));
       
       saveas(hf, fullfileSaveNames);
       
       print(hf,fullfileSaveNames,'-dpng','-r0');
       print(hf,fullfileSaveNames,'-dpdf','-bestfit');
       
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
%%
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
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds)];

FullBrainStrC = readcell(AllSessFolderPathfile,'Range','E:E',...
        'Sheet',1);
FullBrainStrCC = FullBrainStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
% EmptyInds2 = cellfun(@(x) isempty(x) ||any(ismissing(x)),FullBrainStrCC);
FullBrainStr = [FullBrainStrCC(~EmptyInds)];

%%

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersRaw = SessionFoldersC(2:end);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),SessionFoldersRaw);
SessionFolders = SessionFoldersRaw(~EmptyInds);

NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

Areawise_BTANDChoiceAUC = cell(NumUsedSess,NumAllTargetAreas,3);
Areawise_PopuBTChoicePerf = cell(NumUsedSess,NumAllTargetAreas,2);
% Areawise_PopuSVMCC = cell(NumUsedSess,NumAllTargetAreas,2);
% Areawise_BehavChoiceDiff = cell(NumUsedSess,NumAllTargetAreas);
for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS}; %(2:end-1)
%     cSessPath = strrep(SessionFolders{cS},'F:\','E:\NPCCGs\');
    cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
        
    SessAreaIndexDatafile = fullfile(ksfolder,'SessAreaIndexDataAligned.mat');
    SessAreaIndexData = load(SessAreaIndexDatafile);
    BTANDChoiceAUC_file = fullfile(ksfolder,'BTANDChoiceAUC_TrWise','BTANDChoiceAUC_TrTypeWise.mat');
    BTANDChoiceAUCStrc = load(BTANDChoiceAUC_file,'UnitAfterStimAUC','UnitAS_BLSubAUC',...
        'UnitBaselineAUC','SVMDecVecs');
    
    
    AreaNames = BTANDChoiceAUCStrc.SVMDecVecs(:,1);
    AreaNames(strcmpi(AreaNames,'Others')) = [];
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
summarySaveFolder2 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\BlockType_ChoiceVecANDAUC';
% summarySaveFolder2 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\Trialwise_BTChoiceAUC';
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
        
        annotation('textbox',[0.02 0.01 0.1 0.05],'String',FullBrainStr{cA},'FitBoxToText','on','Color','r');
       
        savename = fullfile(summarySaveFolder2,sprintf('Area %s trialtype wise AUC compare',cAName));
        saveas(h1f,savename);
        
        print(h1f,savename,'-dpng','-r0');
        print(h1f,savename,'-dpdf','-bestfit'); %print(gcf,'Unit111example','-dpdf','-bestfit');
        close(h1f);
    end
end

%%
filesavename = fullfile(summarySaveFolder2,'TrWiseAUC_popuPerf_summary.mat');
save(filesavename,'Areawise_BTANDChoiceAUC','Areawise_PopuBTChoicePerf','BrainAreasStr','Areawise_AUCCells_all','-v7.3');

%%
% ###################################################################################################
% Summary codes 3: unit task responsive parameters summary

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

FullBrainStrC = readcell(AllSessFolderPathfile,'Range','E:E',...
        'Sheet',1);
FullBrainStrCC = FullBrainStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
% EmptyInds2 = cellfun(@(x) isempty(x) ||any(ismissing(x)),FullBrainStrCC);
FullBrainStr = [FullBrainStrCC(~EmptyInds);{'Others'}];

%%

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersRaw = SessionFoldersC(2:end);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),SessionFoldersRaw);
SessionFolders = SessionFoldersRaw(~EmptyInds);

NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

Areawise_RespUnitAll = cell(NumUsedSess,NumAllTargetAreas,3);
SessTotalUnitNum = zeros(NumUsedSess,1);
for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS}; %(2:end-1)
    cSessPath = strrep(SessionFolders{cS},'F:\','E:\NPCCGs\');
%     cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
%     cSessPath = strrep(SessionFolders{cS},'F:','P:'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
        
    SessAreaIndexDatafile = fullfile(ksfolder,'SessAreaIndexDataNew.mat');
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
IsPlot = 1;
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
       if size(cA_respCoefs_mtx,1) > 3
            IsAreaHaveRespUnit(cA) = 1;
       end
       
       % check whether needs to plot the results
       if IsPlot
          
          
          
       end
   end
   
end

%%
summarySaveFolder3 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\UnitRespFieldSummary';
if ~isfolder(summarySaveFolder3)
    mkdir(summarySaveFolder3);
end
% figsavename3 = fullfile(summarySaveFolder3,'Area_sorted_plots_summary');
% saveas(hs4f,figsavename3);
% saveas(hs4f,figsavename3,'png');
% saveas(hs4f,figsavename3,'pdf');

datasavename3 = fullfile(summarySaveFolder3,'UnitRespfieldDatas.mat');
save(datasavename3,'IsAreaHaveRespUnit', 'AreaSum_respCoefAlls', 'BrainAreasStr','-v7.3');


%%
% ###################################################################################################
% Summary codes 4: summary of sigAUC unit crosscorr peak lags
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
SessionFoldersRaw = SessionFoldersC(2:end);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),SessionFoldersRaw);
SessionFolders = SessionFoldersRaw(~EmptyInds);

NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

AreaWise_ChoiceScoreData = cell(NumUsedSess,NumAllTargetAreas);

for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS}; %(2:end-1)
    cSessPath = strrep(SessionFolders{cS},'F:\','E:\NPCCGs\');
%     cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    
    AreaUnitPeaklag_file = fullfile(ksfolder,'AreaWise_AUCSigUnitlags.mat');
    AreaUnitPeaklag_Strc = load(AreaUnitPeaklag_file,'SessAreaUnitlagDatas');
    
    
    AreaNames = AreaUnitPeaklag_Strc.SessAreaUnitlagDatas(:,1);
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
        
        AreaMatchInds = matches(BrainAreasStr,cAreaStr,'IgnoreCase',true);
        
        AreaWise_ChoiceScoreData(cS,AreaMatchInds) = AreaUnitPeaklag_Strc.SessAreaUnitlagDatas(cAreaInds,2); 
        
    end
end

%%
IsEmptyAreaSess = cellfun(@(x) ~isempty(x), AreaWise_ChoiceScoreData);
[SessInds, AreaInds] = find(IsEmptyAreaSess);

ExistSess_unitSigAUClags = AreaWise_ChoiceScoreData(IsEmptyAreaSess);
Area_AllsigUnitLags = cell(NumAllTargetAreas,2);
IsMultiUnitExists = false(NumAllTargetAreas,1);
for cA = 1 : NumAllTargetAreas
    cA_Inds = AreaInds == cA;
    if sum(cA_Inds)
        cA_summaryDatas = ExistSess_unitSigAUClags(cA_Inds);
        cA_summaryDatas_vec = cat(1,cA_summaryDatas{:});
        Area_AllsigUnitLags(cA,1) = {cell2mat(cA_summaryDatas_vec)};
        if size(Area_AllsigUnitLags{cA,1},1) > 2
            IsMultiUnitExists(cA) = true;
            cData = Area_AllsigUnitLags{cA,1};
            NumUnits = size(cData,1);
            Area_AllsigUnitLags{cA,2} = [mean(cData(:,3)),std(cData(:,3))/sqrt(NumUnits),... % peak lag
                mean(cData(:,2)),std(cData(:,2))/sqrt(NumUnits),... % peak coef value
                mean(cData(:,4)),std(cData(:,4))/sqrt(NumUnits)]; % unit AUC average
            
        end
    end
    
end

UsedArea_AllsigUnitLags = Area_AllsigUnitLags(IsMultiUnitExists,:);
UsedArea_nameStrs = BrainAreasStr(IsMultiUnitExists);

%% plot results
UsedArea_AllAvgs = cell2mat(UsedArea_AllsigUnitLags(:,2));
UsedArea_PeakLagAvg = UsedArea_AllAvgs(:,1:2);
NumofUsedAreas = size(UsedArea_PeakLagAvg,1);

[~, UsedArea_SortInds] = sort(UsedArea_PeakLagAvg(:,1),'descend');
Sorted_peaklagAvg = UsedArea_PeakLagAvg(UsedArea_SortInds,:);

UsedArea_AUCs = UsedArea_AllAvgs(:,5:6);
[~, AUCsortInds] = sort(UsedArea_AUCs(:,1));

hs4f = figure('position',[100 50 1280 820],'paperpositionmode','manual');

ax1 = subplot(141);
errorbar(Sorted_peaklagAvg(:,1),1:NumofUsedAreas,Sorted_peaklagAvg(:,2),'b-o',...
    'horizontal','linewidth',1.5);
set(gca,'ytick',1:NumofUsedAreas,'yticklabel',UsedArea_nameStrs(UsedArea_SortInds));
xlabel('Peakcoef lags');
title('Area units peaklags');


ax2 = subplot(142);
errorbar(UsedArea_AUCs(UsedArea_SortInds,1),1:NumofUsedAreas,UsedArea_AUCs(UsedArea_SortInds,2),...
    'k-o','horizontal','linewidth',1.5);
set(gca,'ytick',1:NumofUsedAreas,'yticklabel',UsedArea_nameStrs(UsedArea_SortInds));
xlabel('AUCavgs ');
title('Area units AUC (sort by ax1)');

ax3 = subplot(144);
errorbar(UsedArea_PeakLagAvg(AUCsortInds,1),1:NumofUsedAreas,UsedArea_PeakLagAvg(AUCsortInds,2),...
    'b-o','horizontal','linewidth',1.5);
set(gca,'ytick',1:NumofUsedAreas,'yticklabel',UsedArea_nameStrs(AUCsortInds));
xlabel('Peakcoef lags');
title('Area units peaklags (sortby ax3)');


ax4 = subplot(143);
errorbar(UsedArea_AUCs(AUCsortInds,1),1:NumofUsedAreas,UsedArea_AUCs(AUCsortInds,2),...
    'k-o','horizontal','linewidth',1.5);
set(gca,'ytick',1:NumofUsedAreas,'yticklabel',UsedArea_nameStrs(AUCsortInds));
xlabel('AUCavgs');
title('Area units AUC');

%%
summarySaveFolder4 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\SingleUnitSigAUC_corrPeakLag';
if ~isfolder(summarySaveFolder4)
    mkdir(summarySaveFolder4);
end
figsavename4 = fullfile(summarySaveFolder4,'Area_sorted_plots_summary');
saveas(hs4f,figsavename4);
saveas(hs4f,figsavename4,'png');
saveas(hs4f,figsavename4,'pdf');

datasavename4 = fullfile(summarySaveFolder4,'UnitFRCrossCoef_peaklagSummary.mat');
save(datasavename4,'Area_AllsigUnitLags', 'BrainAreasStr', 'IsMultiUnitExists','-v7.3')

%% ###################################################################################################
% Summary codes 5: summary of anovan results for each regions
%
cclr
%
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds);{'Others'}];
%
BrainAreasFullStrC = readcell(AllSessFolderPathfile,'Range','E:E',...
        'Sheet',1);
BrainAreasStrFullCC = BrainAreasFullStrC(2:end);

BrainAreasStrFull = [BrainAreasStrFullCC(~EmptyInds);{'Others'}];


%%

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersRaw = SessionFoldersC(2:end);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),SessionFoldersRaw);
SessionFolders = SessionFoldersRaw(~EmptyInds);
NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

Areawise_unitAnovaTrace = cell(NumUsedSess,NumAllTargetAreas,3, 2); % 3 corresponding to three factors, 2 corresponding to real and threshld data
Areawise_BTfreqwiseAnova = cell(NumUsedSess, NumAllTargetAreas, 2, 2);  % 2 corresponding to two condition, 2 corresponding to real and threshld data
Areawise_unitAnovaSigNum = cell(NumUsedSess,NumAllTargetAreas); % units that were defined as significant, used to calculate the fraction
Areawise_unittempAUCTraces = cell(NumUsedSess,NumAllTargetAreas,2, 2); % only two AUC types were calculated
Areawise_unitStimRespAUC = cell(NumUsedSess,NumAllTargetAreas,2); % used to store stim-response AUC, each for one stimuli 
for cS = 1 : NumUsedSess
%     cSessPath = SessionFolders{cS}; %(2:end-1)
%     cSessPath = strrep(SessionFolders{cS},'F:\','E:\NPCCGs\');
    cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
%     try
        AreaUnitAnovaEV_file = fullfile(ksfolder,'AnovanAnA','SigAnovaTracedataSave2.mat');
        AreaUnitAnovaEV_Strc = load(AreaUnitAnovaEV_file); % AreaValidInfoDatas, ExistAreaNames, ExistField_ClusIDs
        AreaUnitTempAUC_file = fullfile(ksfolder,'AnovanAnA','TempAUCTracedata.mat');
        AreaUnitTempAUC_Data = load(AreaUnitTempAUC_file,'AUCValidInfoDatas');
        AreaUnitStimRespAUC_file = fullfile(ksfolder,'AnovanAnA','StimRespAUCdata_AreaWise.mat');
        AreaUnitStimRespAUC = load(AreaUnitStimRespAUC_file,'StimAUCValidInfoDatas');

        AreaNames = AreaUnitAnovaEV_Strc.SeqAreaNames;
        NumAreas = length(AreaNames);
        if NumAreas < 1
            warning('There is no target units within following folder:\n %s \n ##################\n',cSessPath);
            continue;
        end

        for cAreaInds = 1 : NumAreas % excluding the 'Others' region at the end
            cAreaStr = AreaNames{cAreaInds};
            if isempty(cAreaStr)
                continue;
            end

            AreaMatchInds = matches(BrainAreasStr,cAreaStr,'IgnoreCase',true);

            cA_SigUnitTraces = AreaUnitAnovaEV_Strc.AreaValidInfoDatas{cAreaInds,5};
            Areawise_unitAnovaTrace(cS, AreaMatchInds, :, :) = cA_SigUnitTraces; % althrough maybe empty unit exists

            Areawise_unitAnovaSigNum(cS, AreaMatchInds) = AreaUnitAnovaEV_Strc.AreaValidInfoDatas(cAreaInds,1);

            cA_BTfreqwise_anovaTrace = AreaUnitAnovaEV_Strc.AreaWise_BTfreqseqDatas{cAreaInds,3};
            Areawise_BTfreqwiseAnova(cS, AreaMatchInds, :, :) = cA_BTfreqwise_anovaTrace;

            Areawise_unittempAUCTraces(cS, AreaMatchInds, :, :) = AreaUnitTempAUC_Data.AUCValidInfoDatas{cAreaInds,2};

            Areawise_unitStimRespAUC(cS, AreaMatchInds, :) = AreaUnitStimRespAUC.StimAUCValidInfoDatas{cAreaInds,2};
        end
%     catch ME
%        % no target files in session 
%     end
end


%%
% summarySavePath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas2';
summarySavePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\anova_analysis_datas2';
if ~isfolder(summarySavePath)
    mkdir(summarySavePath);
end

% TotalCalcuNumber = size(NSMUnitOmegaSqrData,1);
% CaledStimOnsetBin = 149; % stimonset bin is 151, and the calculation window is 50ms (5 bins)
% winGoesStep = 0.01; % seconds
CaledStimOnsetBin = AreaUnitAnovaEV_Strc.CaledStimOnsetBin;
winGoesStep = AreaUnitAnovaEV_Strc.winGoesStep;
titleStrs = {'Choice','Sound','Blocktypes'};
AUCType2FactorInds = [2, NaN, 1];
FactorNum = 3;
AllArea_anovaEVdatas = cell(NumAllTargetAreas, FactorNum, 3);
AllArea_tempAUC_datas = cell(NumAllTargetAreas, FactorNum, 2);
AllArea_StimRespAUC_datas = cell(NumAllTargetAreas, 2);
AllArea_BTAnova_freqwise = cell(NumAllTargetAreas, 2, 2);
%%
for cA = 1 : NumAllTargetAreas
%     cA = 4;
    cA_nameStr = BrainAreasStr{cA};
    cA_summaryData_real = squeeze(Areawise_unitAnovaTrace(:,cA,:,1));
    cA_summaryData_thres = squeeze(Areawise_unitAnovaTrace(:,cA,:,2));
    
    cA_BTsummaryData_real = squeeze(Areawise_BTfreqwiseAnova(:,cA,:,1));
    cA_BTsummaryData_thres = squeeze(Areawise_BTfreqwiseAnova(:,cA,:,2));
    
    cA_summary_unitNums = Areawise_unitAnovaSigNum(:,cA);
    
    cA_summary_AUC_real = squeeze(Areawise_unittempAUCTraces(:,cA,:,1));
    cA_summary_AUC_thres = squeeze(Areawise_unittempAUCTraces(:,cA,:,2));
    
    cA_summary_StimAUC_real = squeeze(Areawise_unitStimRespAUC(:,cA,1));
    cA_summary_StimAUC_thres = squeeze(Areawise_unitStimRespAUC(:,cA,2));
    
    cF_unitNums = cat(1,cA_summary_unitNums{:});
    if isempty(cF_unitNums) || sum(cF_unitNums,'all') == 0
        continue;
    end
    huf = figure('position',[100 100 1440 600]);
    for cF = 1 : FactorNum
        cx = subplot(2,FactorNum+1,cF);
        hold on
        cF_datas = cat(2,cA_summaryData_real{:,cF});
        cF_ThresDatas = cat(2,cA_summaryData_thres{:,cF});
        if ~isempty(cF_datas)
            cf_unitNumVec = cF_unitNums(:,cF);
            [TotalCalcuNumber, SigUnitNum] = size(cF_datas);
            UnitCalWinTimes = (((1:TotalCalcuNumber)-CaledStimOnsetBin) * winGoesStep)';
            AllArea_anovaEVdatas(cA, cF, :) = {cF_datas, cF_ThresDatas, cf_unitNumVec};
            
            Summary_EV_Avg = mean(cF_datas,2);
            % to remove smooth artifact at the terminal location
            Summary_EV_Avg(1:3) = mean(Summary_EV_Avg(1:5));
            Summary_EV_Avg(end-2:end) = mean(Summary_EV_Avg(end-4:end));
            % ########
            Summary_EV_sem = std(cF_datas,[],2) / sqrt(SigUnitNum);
            Summary_EV_thres = mean(cF_ThresDatas,2);

            cF_sigUnitFrac = mean(cf_unitNumVec);
            sigUnit_NumsFromVec = sum(cf_unitNumVec);
            if sigUnit_NumsFromVec~= SigUnitNum
                error('Something is wrong in significant unit numbers calcualtion.');
            end

            semPatch_x = [UnitCalWinTimes;flipud(UnitCalWinTimes)];
            semPatch_y = [Summary_EV_Avg+Summary_EV_sem;...
                flipud(Summary_EV_Avg-Summary_EV_sem)];
            patch(semPatch_x,semPatch_y,1,'EdgeColor','none','faceColor',[0.8 0.4 0.4],'facealpha',0.6);

            plot(UnitCalWinTimes,Summary_EV_thres,'Color',[.7 .7 .7],'linewidth',1.2);
            plot(UnitCalWinTimes,Summary_EV_Avg,'Color','r','linewidth',1.2);

            yscales = get(gca,'ylim');
            line([0 0],yscales,'Color','c','linewidth',1.0,'linestyle','--');
            set(cx,'ylim',yscales);
            title(sprintf('%s Sigfrac = %.2f(%d/%d)',titleStrs{cF},cF_sigUnitFrac,sigUnit_NumsFromVec,numel(cf_unitNumVec)));
%             text(2, yscales(2)*0.9,sprintf('UnitNum = %d',sigUnit_NumsFromVec));
            xlabel('Time (s)');
            ylabel('EV');
            
            % corrsponded temporal AUC plots
            ax2 = subplot(2,FactorNum+1,cF+FactorNum+1);
            hold on
            cF_2AUCInds = AUCType2FactorInds(cF);
            if ~isnan(cF_2AUCInds)
               cF_AUCdatas = cat(2,cA_summary_AUC_real{:,cF_2AUCInds});
               cF_AUCthres = cat(2,cA_summary_AUC_thres{:,cF_2AUCInds});
               
%                [TotalCalcuNumber, SigUnitNum] = size(cF_datas);
%                UnitCalWinTimes = (((1:TotalCalcuNumber)-CaledStimOnsetBin) * winGoesStep)';
                AllArea_tempAUC_datas(cA, cF, :) = {cF_AUCdatas, cF_AUCthres};

                Summary_TAUC_Avg = mean(cF_AUCdatas,2);
                
                Summary_TAUC_sem = std(cF_AUCdatas,[],2) / sqrt(SigUnitNum);
                Summary_TAUC_thres = mean(cF_AUCthres,2);
                
                semPatch_x = [UnitCalWinTimes;flipud(UnitCalWinTimes)];
                semPatch_y = [Summary_TAUC_Avg+Summary_TAUC_sem;...
                    flipud(Summary_TAUC_Avg-Summary_TAUC_sem)];
                patch(semPatch_x,semPatch_y,1,'EdgeColor','none','faceColor',[0.4 0.4 0.8],'facealpha',0.6);

                plot(UnitCalWinTimes,Summary_TAUC_thres,'Color',[.7 .7 .7],'linewidth',1.2);
                plot(UnitCalWinTimes,Summary_TAUC_Avg,'Color','b','linewidth',1.2);

                yscales = get(ax2,'ylim');
                line([0 0],yscales,'Color','c','linewidth',1.0,'linestyle','--');
                set(ax2,'ylim',yscales);
                xlabel('Time (s)');
                ylabel('TAUC');
               
            else
                ax3 = subplot(2,FactorNum+1,cF+FactorNum+1);
                hold on
                c_stimAUCdatas = cat(1,cA_summary_StimAUC_real{:});
                c_stimAUCthres = cat(1,cA_summary_StimAUC_thres{:});
                AllArea_StimRespAUC_datas(cA,:) = {c_stimAUCdatas, c_stimAUCthres};
                
                [SigUnitNum, FreqTypeNum] = size(c_stimAUCdatas);
                if SigUnitNum == 1
                    Summary_StimAUC_Avg = c_stimAUCdatas;
                    Summary_StimAUC_sem = zeros(size(Summary_StimAUC_Avg));
                    Summary_StimAUC_thres = c_stimAUCthres;
                elseif SigUnitNum ~= 1
                    Summary_StimAUC_Avg = mean(c_stimAUCdatas);
                    Summary_StimAUC_sem = std(c_stimAUCdatas) / sqrt(SigUnitNum);
                    Summary_StimAUC_thres = mean(c_stimAUCthres);
                end
                
                
                errorbar(ax3,1:FreqTypeNum,Summary_StimAUC_Avg,Summary_StimAUC_sem,'k-o',...
                    'linewidth',1.5,'MarkerSize',8);
                plot(ax3,1:FreqTypeNum,Summary_StimAUC_thres,'-o','Color',[.7 .7 .7],'linewidth',1.4);
                set(gca,'xtick',1:FreqTypeNum);
                xlabel('FreqTypes');
                ylabel('StimAUC');
            end
            % plot freqtype wise anova traces
            titleStr = {'NonRevF','RevF'};
            axInds = [FactorNum+1,(FactorNum+1)*2];
            for ccA = 1 : 2
                ax4 = subplot(2,FactorNum+1,axInds(ccA));
                hold on
                
                ccA_anovaEV_real = cat(2,cA_BTsummaryData_real{:,ccA});
                ccA_anovaEV_thres = cat(2,cA_BTsummaryData_thres{:,ccA});
                AllArea_BTAnova_freqwise(cA, ccA,:) = {ccA_anovaEV_real, ccA_anovaEV_thres};
                
                [SigUnitNum, FreqTypeNum] = size(ccA_anovaEV_real);
                Summary_BTEV_Avg = mean(ccA_anovaEV_real,2);
                
                Summary_BTEV_sem = std(ccA_anovaEV_real,[],2) / sqrt(SigUnitNum);
                Summary_BTEV_thres = mean(ccA_anovaEV_thres,2);
                
                semPatch_x = [UnitCalWinTimes;flipud(UnitCalWinTimes)];
                semPatch_y = [Summary_BTEV_Avg+Summary_BTEV_sem;...
                    flipud(Summary_BTEV_Avg-Summary_BTEV_sem)];
                patch(semPatch_x,semPatch_y,1,'EdgeColor','none','faceColor',[0.4 0.4 0.8],'facealpha',0.6);

                plot(UnitCalWinTimes,Summary_BTEV_thres,'Color',[.7 .7 .7],'linewidth',1.2);
                plot(UnitCalWinTimes,Summary_BTEV_Avg,'Color','b','linewidth',1.2);

                yscales = get(ax4,'ylim');
                line([0 0],yscales,'Color','c','linewidth',1.0,'linestyle','--');
                set(ax4,'ylim',yscales);
                xlabel('Time (s)');
                ylabel('BTEV');
                title(titleStr{ccA});
            end
            annotation('textbox',[0.02 0.5 0.1 0.05],'String',cA_nameStr,'Color','b',...
                'FitBoxToText','on','Edgecolor','none');
            annotation('textbox',[0.02 0.25 0.08 0.2],'String',BrainAreasStrFull{cA},'Color','m',...
                'FitBoxToText','off','Edgecolor','none');
            
        end
    end
    
    SaveNames = fullfile(summarySavePath,sprintf('Area_%s anovaEV and TAUC plot save',cA_nameStr));
    saveas(huf,SaveNames);
    
    print(huf,SaveNames,'-dpng','-r0');
    print(huf,SaveNames,'-dpdf','-bestfit');
    close(huf);

end
%%
datasaveName5 = fullfile(summarySavePath,'AllArea_anovaEV_ANDAUC_datas.mat');
save(datasaveName5,'AllArea_anovaEVdatas','Areawise_unitAnovaSigNum',...
    'Areawise_unitAnovaTrace','AllArea_tempAUC_datas','Areawise_unittempAUCTraces',...
    'AllArea_BTAnova_freqwise','AllArea_StimRespAUC_datas','-v7.3');

%% summary analysis 6, regressor analysis summary
cclr

% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds)]; %;{'Others'}

% FullBrainStrC = readcell(AllSessFolderPathfile,'Range','E:E',...
%         'Sheet',1);
% FullBrainStrCC = FullBrainStrC(2:end);
% % BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
% % EmptyInds2 = cellfun(@(x) isempty(x) ||any(ismissing(x)),FullBrainStrCC);
% FullBrainStr = [FullBrainStrCC(~EmptyInds)]; %;{'Others'}

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersRaw = SessionFoldersC(2:end);
EmptyInds2 = cellfun(@(x) isempty(x) ||any( ismissing(x)),SessionFoldersRaw);
SessionFolders = SessionFoldersRaw(~EmptyInds2);

NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

%%
Areawise_RespUnitInds = cell(NumUsedSess,NumAllTargetAreas);
IsColRespTypeExists = 0;
for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS}; %(2:end-1)
%     cSessPath = strrep(SessionFolders{cS},'F:\','E:\NPCCGs\'); % 'E:\NPCCGs\'
    cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    try
        
        NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
        UnitSltFile = fullfile(ksfolder,'Regressor_ANA','UnitSelectiveTypes2.mat');
        UnitSltDataStrc = load(UnitSltFile);
        RegressorDatafile = fullfile(ksfolder,'Regressor_ANA','RegressorDataAligned.mat');
        RegressorDataStrc = load(RegressorDatafile,'AreaUnitNumbers','NewAdd_ExistAreaNames');
    catch ME
        fprintf('Error exists in session %d.\n',cS);
    end
    if ~IsColRespTypeExists
        ColRespTypeStrings = UnitSltDataStrc.ColRespTypeStr;
        IsColRespTypeExists = 1;
    end
    NewAdd_ExistAreaNames = RegressorDataStrc.NewAdd_ExistAreaNames;
%     NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);
    Numfieldnames = length(NewAdd_ExistAreaNames);
    AreaUnitNumbers = RegressorDataStrc.AreaUnitNumbers;
    AreaUnitCountCumsum = cumsum([0;AreaUnitNumbers]); % for matrix indexing
    
    NumAreas = length(NewAdd_ExistAreaNames);
    if NumAreas < 1
        warning('There is no target units within following folder:\n %s \n ##################\n',cSessPath);
        continue;
    end
    %
    for cAreaInds = 1 : NumAreas 
        cAreaStr = NewAdd_ExistAreaNames{cAreaInds};
        AreaMatchInds = matches(BrainAreasStr,cAreaStr,'IgnoreCase',true);
        
        AreaUnitIndsRange = (AreaUnitCountCumsum(cAreaInds)+1):AreaUnitCountCumsum(cAreaInds+1);
        
        cA_unit_respMtx = UnitSltDataStrc.IsUnitGLMResp(AreaUnitIndsRange,:);
        
        Areawise_RespUnitInds(cS,AreaMatchInds) = {cA_unit_respMtx};
        
    end
end

%%
% NumAllTargetAreas = length(BrainAreasStr); % contains all brain region
% names
Areawise_SessCount = cellfun(@isempty,Areawise_RespUnitInds);
AreaSessionNum = sum(~Areawise_SessCount);
ExplainVarsMtx_AllC = cell(NumAllTargetAreas, 1);
IsAreaEmpty = false(NumAllTargetAreas,1);
for cArea = 1 : NumAllTargetAreas
    cA_AllRespMtx = cat(1,Areawise_RespUnitInds{:,cArea});
    if isempty(cA_AllRespMtx) || size(cA_AllRespMtx,1) < 10 || AreaSessionNum(cArea) < 3
        IsAreaEmpty(cArea) = true;
    else
        ExplainVarsMtx_AllC{cArea} = cA_AllRespMtx;
    end
    
end
% ColRespTypeStrings
NESelectMtxCell = ExplainVarsMtx_AllC(~IsAreaEmpty);
NEBrainStrs = BrainAreasStr(~IsAreaEmpty);
NumNEAreas = length(NESelectMtxCell);

% calculate fraction for each NE regions

BrainAreaFracs = zeros(NumNEAreas,5);
FracTypeStrs = {'BinaryBTFraction','AllBTFraction','StimFraction','ChoiceFraction'};
for cA = 1 : NumNEAreas
    cA_Data = NESelectMtxCell{cA};
    NumUnits = size(cA_Data,1);
    cAPureBTFrac = mean(cA_Data(:,1));
    cA_AllBTFrac = mean(cA_Data(:,1) | cA_Data(:,2));
    cA_StimFrac = mean(cA_Data(:,3));
    cA_ChoiceFrac = mean(cA_Data(:,4) | cA_Data(:,5));
    
    BrainAreaFracs(cA,:) = [NumUnits,cAPureBTFrac, cA_AllBTFrac, cA_StimFrac, cA_ChoiceFrac];
end
%
AllAreaFracs = BrainAreaFracs(:,[2,4,5]);
AllAreaFracStr = FracTypeStrs([2,4,5]-1);
% SortIndex = 1; % 1 indicates BT, 2 indicates Stim, 3 indicates choice
% [~,sortInds] = sort(AllAreaFracs(:,SortIndex),'descend');
% TotalUsedAreaNum = length(sortInds);
% figure;
% bar(AllAreaFracs(sortInds,:),'stacked')
% set(gca,'xtick',1:NumNEAreas,'xticklabel',NEBrainStrs(sortInds));
% legend({'BlockType','Stim','Choice'},'box','off');
% set(gca,'box','off');
%%

% allen_atlas_path = 'E:\AllenCCF';
allen_atlas_path = 'E:\MatCode\AllentemplateData';
tv = readNPY([allen_atlas_path filesep 'template_volume_10um.npy']);
av = readNPY([allen_atlas_path filesep 'annotation_volume_10um_by_index.npy']);
st = loadStructureTree([allen_atlas_path filesep 'structure_tree_safe_2017.csv']);

TargetBrainArea_file = 'K:\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';
% TargetBrainArea_file = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\BrainAreaANDIndex.mat';

BrainRegionStrc = load(TargetBrainArea_file); % BrainRegions
BrainRegionIndex = BrainRegionStrc.BrainRegions;

%%
% plot sagital and topdown plots
% UsedTypeInds = 3;
savePathfolder = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary';
% savePathfolder = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary';
for UsedTypeInds = 1 : length(AllAreaFracStr)
    UsedTypeFracStr = AllAreaFracStr{UsedTypeInds};
    UsedAreaFracs = AllAreaFracs(:,UsedTypeInds);
    Value2Colors = linearValue2colorFun(UsedAreaFracs);

%     NEBrainStrs = AreaNameCorrection(NEBrainStrs, st);

    %
    % SliceName = 'sagittal';
    h6f = figure('position',[100 100 900 380]);
    sagAx = subplot(131);
    topdownAx = subplot(132);
%     sagAx2 = subplot(223);
    % plotRecLocsMapByColor(sagAx,topdownAx,{'AUD'},[1 0 0],st,av); % color should have same rows as number of brain regions
    OverAllNotshow = plotRecLocsMapByColor(sagAx,topdownAx,NEBrainStrs,Value2Colors,st,av,BrainRegionIndex);  % BrainRegionIndex % color should have same rows as number of brain regions
    
    [~,ValueInds] = sort(UsedAreaFracs);
    set(gca,'CLim',[min(UsedAreaFracs) max(UsedAreaFracs)])
    colormap(Value2Colors(ValueInds,:))
    hbar = colorbar;
    set(get(hbar,'title'),'String',UsedTypeFracStr);
%
    if sum(OverAllNotshow)
        % extra areas showing in text color
       ax3 = subplot(133);
       hold on
       ExtraAreasIndex = find(OverAllNotshow);
       ExtraAreaNames = NEBrainStrs(ExtraAreasIndex);
       ExtraAreaColors = Value2Colors(ExtraAreasIndex,:);
       NumEA = length(ExtraAreasIndex);
       for cA = 1 : NumEA
           xInds = floor(cA/10)+1;
           yInds = mod(cA,10);
           if yInds == 0
               yInds = 10;
               xInds = xInds - 1;
           end
           text(ax3,xInds,yInds,ExtraAreaNames{cA},'Color',ExtraAreaColors(cA,:),'FontSize',16);
       end
        set(ax3,'xlim',[0 xInds+1],'ylim',[0 11]);
        set(ax3,'xtick',[],'ytick',[],'xColor','none','yColor','none')
    end
    
    SaveNames = fullfile(savePathfolder,sprintf('%s summary slice plot',UsedTypeFracStr));
    saveas(h6f,SaveNames);

    print(h6f,SaveNames,'-dpng','-r500');
    print(h6f,SaveNames,'-dpdf','-bestfit');
    close(h6f);
end
%%
dataSavepath = fullfile(savePathfolder,'RegAreawiseFrac.mat');
save(dataSavepath, 'AllAreaFracStr','NEBrainStrs','AllAreaFracs',...
    'BrainAreaFracs','FracTypeStrs','Areawise_RespUnitInds','BrainAreasStr','-v7.3');

%% load allen score
% AllenHScoreFullPath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_CreConf.xlsx';
AllenHScoreFullPath = 'K:\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_CreConf.xlsx';
AllenRegionStrsCell = readcell(AllenHScoreFullPath,'Range','A:A',...
        'Sheet','hierarchy_all_regions');
AllenRegionStrsUsed = AllenRegionStrsCell(2:end);
AllenRegionStrsModi = strrep(AllenRegionStrsUsed,'-','');

RegionScoresCell = readcell(AllenHScoreFullPath,'Range','H:H',...
        'Sheet','hierarchy_all_regions');
% RegionScoresCell = readcell(AllenHScoreFullPath,'Range','F:F',...
%     'Sheet','hierarchy_all_regions');
IsCellMissing = cellfun(@(x) any(ismissing(x)),RegionScoresCell);
RegionScoresCell(IsCellMissing) = {NaN};
RegionScoresUsed = cell2mat(RegionScoresCell(2:end));

NanInds = isnan(RegionScoresUsed);
if any(NanInds)
    RegionScoresUsed(NanInds) = [];
    AllenRegionStrsModi(NanInds) = [];
end

%% find areas matched with allen area names
SelfBrainInds2Allen = nan(NumNEAreas,3);

for cA = 1 : NumNEAreas
    cA_brain_str = NEBrainStrs{cA};
    TF = matches(AllenRegionStrsModi,cA_brain_str,'IgnoreCase',true);
    if any(TF)
        AllenRegionInds = find(TF);
        if length(AllenRegionInds) > 1
            fprintf('Multiple fits exist for area <%s>.\n',cA_brain_str);
            continue;
        end
        SelfBrainInds2Allen(cA,:) = [cA, AllenRegionInds, RegionScoresUsed(AllenRegionInds)];
    elseif strcmpi(cA_brain_str,'RSP')
        SelfBrainInds2Allen(cA,:) = [cA, 37, -0.0175]; % averaged of dosal and ventral part
    end
end

NonexistedAreaInds = isnan(SelfBrainInds2Allen(:,1));
%%
hhu1f = figure('position',[100 100 580 400]);
hold on
plot(AllAreaFracs(NonexistedAreaInds,1),AllAreaFracs(NonexistedAreaInds,2),'d','MarkerSize',6,...
    'Color',[.7 .7 .7],'linewidth',1.5);
scatter(AllAreaFracs(~NonexistedAreaInds,1),AllAreaFracs(~NonexistedAreaInds,2),20,SelfBrainInds2Allen(~NonexistedAreaInds,3),...
    'filled');
colormap cool
UpperDataInds = AllAreaFracs(:,1) > AllAreaFracs(:,2);
up_txt_h = labelpoints(AllAreaFracs(~UpperDataInds,1),AllAreaFracs(~UpperDataInds,2),...
    NEBrainStrs(~UpperDataInds),'W',0.05,1,'Color','k','FontSize', 8); %,'stacked','down'
down_txt_h = labelpoints(AllAreaFracs(UpperDataInds,1),AllAreaFracs(UpperDataInds,2),...
    NEBrainStrs(UpperDataInds),'E',0.05,1,'Color','k','FontSize', 8); %,'stacked','down'
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
CommonScales = [min(xscales(1),yscales(1)),max(xscales(2),yscales(2))];
line(CommonScales,CommonScales,'Color',[.5 .5 .5],'linestyle','--','linewidth',1);
xlabel('BlockType selective fraction','FontSize',10);
ylabel('Stimulus selective fraction','FontSize',10);
title('Selective unit fraction');
colorbar;
%
% NEBrainStrs
hhu2f = figure('position',[100 100 580 400]);
hold on
plot(AllAreaFracs(NonexistedAreaInds,1),AllAreaFracs(NonexistedAreaInds,3),'d','MarkerSize',6,...
    'Color',[.7 .7 .7],'linewidth',1.5);
scatter(AllAreaFracs(~NonexistedAreaInds,1),AllAreaFracs(~NonexistedAreaInds,3),20,SelfBrainInds2Allen(~NonexistedAreaInds,3),...
    'filled');
colormap cool
UpperDataInds = AllAreaFracs(:,1) > AllAreaFracs(:,3);
up_txt_h = labelpoints(AllAreaFracs(~UpperDataInds,1),AllAreaFracs(~UpperDataInds,3),...
    NEBrainStrs(~UpperDataInds),'W',0.05,1,'Color','k','FontSize', 8); %,'stacked','down'
down_txt_h = labelpoints(AllAreaFracs(UpperDataInds,1),AllAreaFracs(UpperDataInds,3),...
    NEBrainStrs(UpperDataInds),'E',0.05,1,'Color','k','FontSize', 8); %,'stacked','down'
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
CommonScales = [min(xscales(1),yscales(1)),max(xscales(2),yscales(2))];
line(CommonScales,CommonScales,'Color',[.5 .5 .5],'linestyle','--','linewidth',1);
xlabel('BlockType selective fraction','FontSize',10);
ylabel('Choice selective fraction','FontSize',10);
title('Selective unit fraction');
colorbar;
%%
SaveNames1 = fullfile(savePathfolder,'AreaFraction scatter plot save StimANDBT2 addline');
saveas(hhu1f,SaveNames1);

print(hhu1f,SaveNames1,'-dpng','-r500');
print(hhu1f,SaveNames1,'-dpdf','-bestfit');


SaveNames2 = fullfile(savePathfolder,'AreaFraction scatter plot save ChoiceANDBT2 addline');
saveas(hhu2f,SaveNames2);

print(hhu2f,SaveNames2,'-dpng','-r500');
print(hhu2f,SaveNames2,'-dpdf','-bestfit');

%%
ANames = AreaNameCorrection(NEBrainStrs, st);
objFilePath = 'K:\AllenCCF_areaDatas\structure_meshes';
hf = brainRegionsMesh(st,ANames,objFilePath, Value2Colors, 0.6);

% RankDatas = [1-UsedAreaFracsAll(:,2),UsedAreaFracsAll(:,3),UsedAreaFracsAll(:,5)];
% CenterLoc = mean(RankDatas);
% MeanSubDatas = RankDatas - CenterLoc;
% [U,S,V] = svd(MeanSubDatas);
% 
% linevals = [-1 1];
% linedirection = V(:,1);
% linePoints = linevals .* linedirection + CenterLoc';
% Online_points = U(:,1) * S(1,1) * (V(:,1))' + CenterLoc;
% hf6 = figure;
% hold on
% plot3(RankDatas(:,1),RankDatas(:,2),RankDatas(:,3),'ro')
% line(linePoints(1,:),linePoints(2,:),linePoints(3,:),'Color','k','linewidth',1.5);
% plot3(Online_points(:,1),Online_points(:,2),Online_points(:,3),'ko')
% xlabel('Sensory');
% ylabel('Choice');
% zlabel('BT')
% set(gca,'ylim',[0 0.8])


%% summary analysis 7, canonical correlation value
% cclr

% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_new.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds);{'Others'}];

FullBrainStrC = readcell(AllSessFolderPathfile,'Range','E:E',...
        'Sheet',1);
FullBrainStrCC = FullBrainStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
% EmptyInds2 = cellfun(@(x) isempty(x) ||any(ismissing(x)),FullBrainStrCC);
FullBrainStr = [FullBrainStrCC(~EmptyInds);{'Others'}];

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersRaw = SessionFoldersC(2:end);
EmptyInds2 = cellfun(@(x) isempty(x) ||any( ismissing(x)),SessionFoldersRaw);
SessionFolders = SessionFoldersRaw(~EmptyInds2);

NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

%%
Sess_CCAdatasAll = cell(NumUsedSess,5);

for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS}; %(2:end-1)
    cSessPath = strrep(SessionFolders{cS},'F:\','P:\'); % 'E:\NPCCGs\'
%     cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    try
        CCADatafile = fullfile(ksfolder,'jeccAnA','JeccData.mat');
        CCADataStrc = load(CCADatafile);
        
    catch ME
        fprintf('Error exists in session %d.\n',cS);
    end
    
    CCA_pairsData = CCADataStrc.CalResults;
    if isempty(CCA_pairsData)
        continue;
    end
    UsedAreaNames = CCADataStrc.NewAdd_ExistAreaNames;
    CCA_timeBin = CCADataStrc.OutDataStrc.BinCenters;
    
    Sess_CCAdatasAll(cS,:) = {CCA_pairsData};
    
    
end

%%
SessCCAData_2rows = cat(1,Sess_CCAdatasAll{:});
PairStrings = cellfun(@(x,y) [x,'-',y],SessCCAData_2rows(:,3),SessCCAData_2rows(:,4),'un',0);
[UniPairStrs,~,UniPairTyppes] = unique(PairStrings);
SessPairCounts = accumarray(UniPairTyppes,1);

%% 2d plot of the correlation
close;
cT = 150;
TypeInds = UniPairTyppes == cT;
cTypeDatas = SessCCAData_2rows(TypeInds,[1,5]);
cTypeDataAll = cat(3,cTypeDatas{:,1});

AvgCCAMtx = mean(cTypeDataAll, 3);
axisTimeScale = [min(CCA_timeBin), max(CCA_timeBin)];

SMData = imgaussfilt(AvgCCAMtx,'FilterSize',5);
figure('position',[100 200 560 420]);
hold on
imagesc(CCA_timeBin, CCA_timeBin, SMData); %,[-0.05 0.4]
line([0 0],axisTimeScale,'Color', 'r','linewidth',1.8);
line(axisTimeScale,[0 0],'Color', 'r','linewidth',1.8);
line(axisTimeScale,axisTimeScale,'Color', 'c','linewidth',1.8);
hb = colorbar;

TypeAreasSep = strsplit(UniPairStrs{cT},'-');
xlabel(sprintf('(%s) Time (s)',TypeAreasSep{1}));
ylabel(sprintf('(%s) Time (s)',TypeAreasSep{2}));

title(sprintf('Regions %s (%d sessions)',UniPairStrs{cT}, SessPairCounts(cT)));



%% 3d plot of the correlation
cT = 2;
TypeInds = UniPairTyppes == cT;
cTypeDatas = SessCCAData_2rows(TypeInds,[1,5]);
cTypeDataAll = cat(3,cTypeDatas{:,1});

AvgCCAMtx = mean(cTypeDataAll, 3);
Zerosdatas = zeros(size(AvgCCAMtx,1),1);

%
% [xx,yy] = meshgrid(OutDataStrc.BinCenters);
[xx,yy] = meshgrid(CCA_timeBin);

SMData = imgaussfilt(AvgCCAMtx,'FilterSize',5);
figure('position',[100 200 660 440]);
hold on
surf(xx,yy,SMData,SMData,'facealpha',0.8,'FaceColor','interp','LineStyle','none');
plot3(Zerosdatas, CCA_timeBin, SMData(CCADataStrc.OutDataStrc.TriggerStartBin,:),'r','linewidth',1.8);
plot3(CCA_timeBin, Zerosdatas, SMData(:,CCADataStrc.OutDataStrc.TriggerStartBin),'r','linewidth',1.8);
hb = colorbar;

xlabel('(From) Time (s)');
ylabel('(To) Time (s)');
zlabel('Canonical Correlation');
view([-15 75])

title(sprintf('Regions %s',UniPairStrs{cT}))

%% summary analysis 8, regressor analysis summary part 2
cclr

% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds)]; %;{'Others'}

% FullBrainStrC = readcell(AllSessFolderPathfile,'Range','E:E',...
%         'Sheet',1);
% FullBrainStrCC = FullBrainStrC(2:end);
% % BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
% % EmptyInds2 = cellfun(@(x) isempty(x) ||any(ismissing(x)),FullBrainStrCC);
% FullBrainStr = [FullBrainStrCC(~EmptyInds)]; %;{'Others'}

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersRaw = SessionFoldersC(2:end);
EmptyInds2 = cellfun(@(x) isempty(x) ||any( ismissing(x)),SessionFoldersRaw);
SessionFolders = SessionFoldersRaw(~EmptyInds2);

NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);

%%
Areawise_RespUnitEVars = cell(NumUsedSess,NumAllTargetAreas);
Areawise_RespUnitRespField = cell(NumUsedSess,NumAllTargetAreas);
for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS}; %(2:end-1)
%     cSessPath = strrep(SessionFolders{cS},'F:\','P:\'); % 'E:\NPCCGs\'
    cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    try
        
        UnitSltFile = fullfile(ksfolder,'Regressor_ANA','UnitSelectiveTypes2.mat');
        UnitSltDataStrc = load(UnitSltFile);
        RegressorDatafile = fullfile(ksfolder,'Regressor_ANA','RegressorDataAligned.mat');
        RegressorDataStrc = load(RegressorDatafile,'AreaUnitNumbers','NewAdd_ExistAreaNames','FullRegressorInfosCell');
    catch ME
        fprintf('Error exists in session %d.\n',cS);
    end
    
    NewAdd_ExistAreaNames = RegressorDataStrc.NewAdd_ExistAreaNames;
	RegressorEVAlls = RegressorDataStrc.FullRegressorInfosCell;
    IsUnitRespMtx = UnitSltDataStrc.IsUnitGLMResp;
    
    Numfieldnames = length(NewAdd_ExistAreaNames);
    AreaUnitNumbers = RegressorDataStrc.AreaUnitNumbers;
    AreaUnitCountCumsum = cumsum([0;AreaUnitNumbers]); % for matrix indexing
    AreaIndexVec = zeros(sum(AreaUnitNumbers),1);
    AreaIndexVec(AreaUnitCountCumsum(2:end)+1) = 1;
    AreaIndexVec(1) = 1;
    AreaIndexVec = cumsum(AreaIndexVec);
    AreaIndexVec(end) = [];
    
    % check and recording each selective ROIs 
    IsUnitRespVec = sum(IsUnitRespMtx(:,[1,3,4,5]),2);
    RespUnitVec_index = find(IsUnitRespVec);
    RespUnit_respMtx = IsUnitRespMtx(:,[1,3,4,5]); 
    RespUnit_ColStr = UnitSltDataStrc.ColRespTypeStr([1,3,4,5]);
    RespUnitEVarAlls = UnitSltDataStrc.GLMRespUnitEVs; % each column is BT, stim, Lchoice,Rchoice
    RespUnitEVarAlls(:,3) = sum(RespUnitEVarAlls(:,3:4),2);
    
%     NumRespUnits = length(IsUnitRespVec);
%     RespUnitEVarAlls = zeros(NumRespUnits,4);
%     for cU = 1 : length(RespUnitVec_index)
%         cSigUnitInds = RespUnitVec_index(cU);
%         cU_partMD_EVar = squeeze(mean(RegressorEVAlls{cSigUnitInds,1}.PartialMd_explain_var)); %7*3
%         cBT_AloneEVar = cU_partMD_EVar(4,2);
%         cBT_ResiEVar = cU_partMD_EVar(4,3);
%         if ~RespUnit_respMtx(cSigUnitInds,1)
%             cBT_EVar = cBT_ResiEVar;
%         else
%             if cBT_ResiEVar >= 0.02
%                 cBT_EVar = cBT_ResiEVar;
%             else
%                 cBT_EVar = cBT_AloneEVar;
%             end
%         end
%         
%         cStim_ResiEVar = cU_partMD_EVar(1,3);
%         cChoice_ResiEVar = sum(cU_partMD_EVar(2:3,3));
%         
%         RespUnitEVarAlls(cSigUnitInds,1:3) = [cBT_EVar, cStim_ResiEVar, cChoice_ResiEVar];        
%     end
%     RespUnitEVarAlls(:,4) = AreaIndexVec;
    RespUnitEVarAlls(:,4) = IsUnitRespVec;
    for cArea_Index = 1 : length(NewAdd_ExistAreaNames)
        cArea_str = NewAdd_ExistAreaNames{cArea_Index};
        cArea_UnitInds = AreaIndexVec == cArea_Index;
        
        AreaMatchInds = matches(BrainAreasStr,cArea_str,'IgnoreCase',true);
        Areawise_RespUnitEVars(cS,AreaMatchInds) = {RespUnitEVarAlls(cArea_UnitInds,:)};
        Areawise_RespUnitRespField(cS,AreaMatchInds) = {RespUnit_respMtx(cArea_UnitInds,:)};
    end
%     NumAreas = length(NewAdd_ExistAreaNames);
%     
%     for cAreaInds = 1 : NumAreas 
%         cAreaStr = NewAdd_ExistAreaNames{cAreaInds};
%         AreaMatchInds = matches(BrainAreasStr,cAreaStr,'IgnoreCase',true);
%         
%         AreaUnitIndsRange = (AreaUnitCountCumsum(cAreaInds)+1):AreaUnitCountCumsum(cAreaInds+1);
%         
%         cA_unit_respMtx = UnitSltDataStrc.IsUnitGLMResp(AreaUnitIndsRange,:);
%         
%         Areawise_RespUnitInds(cS,AreaMatchInds) = {cA_unit_respMtx};
%         
%     end
end

%% plot area explained variance for each areas

Area_RespMtxAll = cell(NumAllTargetAreas,4);

for cA = 1 : NumAllTargetAreas
    cA_EvarCellData = Areawise_RespUnitEVars(:,cA);
    cA_SessNums = sum(~cellfun(@isempty,cA_EvarCellData));
    cA_EvarMtxAll = cat(1,cA_EvarCellData{:});
    if ~isempty(cA_EvarMtxAll)
        cA_RespUnitInds = cA_EvarMtxAll(:,4) > 0;
        cA_RespUnitEVarMtx = cA_EvarMtxAll(cA_RespUnitInds,1:3); % each col is blocktype, stimulus and choice
        cA_fullUnitEVarMtx = cA_EvarMtxAll(:,1:3);
        cA_RespUnitEVarMtx(cA_RespUnitEVarMtx < 1e-5) = 0;
        cA_fullUnitEVarMtx(cA_fullUnitEVarMtx < 1e-5) = 0;
        
        
        UnitIsRespMtx = cat(1,Areawise_RespUnitRespField{:,cA});
        UnitIsRespMtx(:,3) = UnitIsRespMtx(:,3) | UnitIsRespMtx(:,4);
        UnitIsRespMtx(:,4) = [];
        
        Area_RespMtxAll(cA,:) = {cA_fullUnitEVarMtx, cA_RespUnitEVarMtx, cA_SessNums, UnitIsRespMtx};
    end
end

%% plot and save some figures

savePathfolder = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot';
% savePathfolder = 'E:\sycDatas\\Documents\me\projects\NP_reversaltask\summaryDatas\RegressionSummary\UnitEVscatterPlot';
if ~isfolder(savePathfolder)
    mkdir(savePathfolder)
end

% AllAreaIsEmpty = ~cellfun(@isempty,Area_RespMtxAll(:,1));
AreaSigUnit_TypeRespEV = cell(NumAllTargetAreas,4);

for cA = 1 : NumAllTargetAreas
    %
    cA_data  = Area_RespMtxAll(cA,:);
    if ~isempty(cA_data{2}) && cA_data{3} >= 3
        cA_AllUnitEV = cA_data{1};
        cA_SigRespUnit_EV = cA_data{2};
        cA_SigRespUnit_inds = logical(cA_data{4}); % Blocktype, stimulus, Choices
        RespTypeNum = sum(cA_SigRespUnit_inds);
        TotalUnitNum = size(cA_SigRespUnit_inds,1);
        
        BT_sigUnitEVAlls = cA_AllUnitEV(cA_SigRespUnit_inds(:,1),1);
        Stim_sigUnitEVAlls = cA_AllUnitEV(cA_SigRespUnit_inds(:,2),2);
        Choice_sigUnitEVAlls = cA_AllUnitEV(cA_SigRespUnit_inds(:,3),3);
        AreaSigUnit_TypeRespEV(cA,:) = {BT_sigUnitEVAlls,Stim_sigUnitEVAlls,Choice_sigUnitEVAlls,1};
        
        h8f = figure('position',[100 100 680 280]);
        StimAx = subplot(121);
        plot(cA_SigRespUnit_EV(:,1),cA_SigRespUnit_EV(:,2),'ko','MarkerSize',6,'linewidth',1.5);
        xscale = get(StimAx,'xlim');
        yscale = get(StimAx,'ylim');
        CommonScale = [min(xscale(1),yscale(1))-0.05,max(xscale(2),yscale(2))+0.02];
        set(StimAx,'xlim',CommonScale,'ylim',CommonScale);
        line(CommonScale,CommonScale,'Color',[.7 .7 .7],'linewidth',1.2,'linestyle','--');
        text(CommonScale(2)*0.1,CommonScale(2)*0.9,sprintf('BT: %d/%d (%.2f)',...
            RespTypeNum(1),TotalUnitNum,RespTypeNum(1)/TotalUnitNum),'Color','m','FontSize',10);
        if length(BT_sigUnitEVAlls) > 3
            text(CommonScale(2)*0.15,CommonScale(2)*0.8,sprintf('BTEV: %.2f+%.2f',...
                mean(BT_sigUnitEVAlls),std(BT_sigUnitEVAlls)/sqrt(numel(BT_sigUnitEVAlls))),'Color','r','FontSize',10);
        end
        text(CommonScale(2)*0.1,CommonScale(2)*0.7,sprintf('Stim: %d/%d (%.2f)',...
            RespTypeNum(2),TotalUnitNum,RespTypeNum(2)/TotalUnitNum),'Color','c','FontSize',10);
        if length(Stim_sigUnitEVAlls) > 3
            text(CommonScale(2)*0.15,CommonScale(2)*0.6,sprintf('StimEV: %.2f+%.2f',...
                mean(Stim_sigUnitEVAlls),std(Stim_sigUnitEVAlls)/sqrt(numel(Stim_sigUnitEVAlls))),'Color','r','FontSize',10);
        end
        
        xlabel('BlockType Explained Variance','FontSize',10);
        ylabel('Stimulus Explained Variance','FontSize',10);
        
        ChoiceAx = subplot(122);
        plot(cA_SigRespUnit_EV(:,1),cA_SigRespUnit_EV(:,3),'bo','MarkerSize',6,'linewidth',1.5);
        xscale = get(ChoiceAx,'xlim');
        yscale = get(ChoiceAx,'ylim');
        CommonScale = [min(xscale(1),yscale(1))-0.05,max(xscale(2),yscale(2))+0.02];
        set(ChoiceAx,'xlim',CommonScale,'ylim',CommonScale);
        line(CommonScale,CommonScale,'Color',[.7 .7 .7],'linewidth',1.2,'linestyle','--');
        text(CommonScale(2)*0.1,CommonScale(2)*0.9,sprintf('Choice: %d/%d (%.2f)',...
            RespTypeNum(3),TotalUnitNum,RespTypeNum(3)/TotalUnitNum),'Color',[.9 0.6 0.1],'FontSize',10);
        if length(Choice_sigUnitEVAlls) > 3
            text(CommonScale(2)*0.15,CommonScale(2)*0.8,sprintf('ChoiceEV: %.2f+%.2f',...
                mean(Choice_sigUnitEVAlls),std(Choice_sigUnitEVAlls)/sqrt(numel(Choice_sigUnitEVAlls))),'Color','r','FontSize',10);
        end
        xlabel('BlockType Explained Variance','FontSize',10);
        ylabel('Choice Explained Variance','FontSize',10);
        
        cAreaStr = BrainAreasStr{cA};
        annotation('textbox',[0.02 0.1 0.1 0.05],'String',cAreaStr,'FitBoxToText','on','Color','r');
        
        cASaveName = fullfile(savePathfolder,sprintf('%s_sigUnit_EV_scatter_plot',cAreaStr));
        saveas(h8f,cASaveName);
        print(h8f,cASaveName,'-dpng','-r400');
        print(h8f,cASaveName,'-dpdf','-bestfit');
        close(h8f);
        
    else
        AreaSigUnit_TypeRespEV(cA,4) = {0};
        
    end
    
end

%%
summaryDatapath8 = fullfile(savePathfolder,'SigUnit_EVsummaryData.mat');
save(summaryDatapath8,'Area_RespMtxAll','Areawise_RespUnitEVars','Areawise_RespUnitRespField',...
    'RespUnit_ColStr','BrainAreasStr','AreaSigUnit_TypeRespEV','-v7.3');

%%
%%
% ###################################################################################################
% Summary codes 9: summary of choice decoding score analysis
%
cclr
%
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds)];

%

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersRaw = SessionFoldersC(2:end);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),SessionFoldersRaw);
SessionFolders = SessionFoldersRaw(~EmptyInds);

NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);
%%
FreqTypes = [4000,5040,6350,8000,10079,12699,16000];
AreaWise_ChoiceScoreData = cell(NumUsedSess,NumAllTargetAreas,4);
AreaWise_ChoiceScoreDiffData = cell(NumUsedSess,NumAllTargetAreas);
AreaWise_dsqrSummaryData = cell(NumUsedSess,NumAllTargetAreas,3);
AreaWise_FreqwiseScoreData = cell(NumUsedSess,NumAllTargetAreas,3,2);
for cS = 1 :  NumUsedSess
%     cSessPath = SessionFolders{cS}; %(2:end-1)
%     cSessPath = strrep(SessionFolders{cS},'F:\','E:\NPCCGs\');
    cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    
    cS_ChoiceScoreDatafile = fullfile(ksfolder,'ChoiceANDBT_LDAinfo_ana','LDAinfo_FreqwiseScoresAllUnit.mat');
    cS_ChoiceScoreData_Strc = load(cS_ChoiceScoreDatafile,'AreaProcessDatas','ExistField_ClusIDs',...
        'NewAdd_ExistAreaNames','AreaUnitNumbers','AreaFreqwiseScores');
    
    
    AreaNames = cS_ChoiceScoreData_Strc.NewAdd_ExistAreaNames;
    NumAreas = length(AreaNames);
    
    for cAreaInds = 1 : NumAreas
        cAreaStr = AreaNames{cAreaInds};
        if ~isempty(cS_ChoiceScoreData_Strc.AreaProcessDatas{cAreaInds,1})
            AreaMatchInds = matches(BrainAreasStr,cAreaStr,'IgnoreCase',true);
            cA_ChoiceScoresData = cS_ChoiceScoreData_Strc.AreaProcessDatas{cAreaInds,1};
            cA_BT2ChoiceScore = cS_ChoiceScoreData_Strc.AreaProcessDatas{cAreaInds,2};
            cA_dsqrANDperf = cS_ChoiceScoreData_Strc.AreaProcessDatas{cAreaInds,3};
            cA_BTscore = cS_ChoiceScoreData_Strc.AreaProcessDatas{cAreaInds,4};
            % ChoiceScore, difference between baselineSub. NRevTrs and
            % RawResp NRevTrs
            NRevTr_choiceScoreDiff = cA_ChoiceScoresData(1) - cA_ChoiceScoresData(5);
            % ChoiceScore, difference between baselineSub. RevTrs and
            % RawResp RevTrs
            RevTr_choiceScoreDiff = [cA_ChoiceScoresData(3) - cA_ChoiceScoresData(7),...
                cA_ChoiceScoresData(4) - cA_ChoiceScoresData(8)];
            
            cA_RevTrDsqrAndPerf = [cA_dsqrANDperf(2,:),cA_dsqrANDperf(3,:),cA_dsqrANDperf(6,:)]; % the last two is the score calculation control
            cA_NonRevTrDsqrAndPerf = [cA_dsqrANDperf(1,:),cA_dsqrANDperf(4,:)];
            cA_BaseDataDsqr = [cA_dsqrANDperf(5,:),cA_BT2ChoiceScore(3),cA_BT2ChoiceScore(4)];
            
            AreaWise_ChoiceScoreData(cS,AreaMatchInds,:) = {cA_ChoiceScoresData,cA_BT2ChoiceScore,cA_dsqrANDperf,cA_BTscore}; 
            AreaWise_ChoiceScoreDiffData{cS,AreaMatchInds} = [NRevTr_choiceScoreDiff,RevTr_choiceScoreDiff,...
                cA_BT2ChoiceScore([1,3])];
            AreaWise_dsqrSummaryData(cS,AreaMatchInds,:) = {cA_RevTrDsqrAndPerf,cA_NonRevTrDsqrAndPerf,cA_BaseDataDsqr};
        end
        if cS_ChoiceScoreData_Strc.AreaUnitNumbers(cAreaInds) > 10
            % calculate the frequency wise datas
            BaseSub_freqwiseScore = cS_ChoiceScoreData_Strc.AreaFreqwiseScores{cAreaInds,1};
            BaseSub_freqwiseAvgScore = squeeze(mean(BaseSub_freqwiseScore,1,'omitnan'));
            BaseSub_freqwiseSTDScore = squeeze(std(BaseSub_freqwiseScore,1,'omitnan'))/sqrt(size(BaseSub_freqwiseScore,1));
%             if any(isnan(BaseSub_freqwiseAvgScore))
%                 fprintf('NaN value for session %d Area %d.\n',cS,cAreaInds);
%                 return;
%             end
            RawResp_freqwiseScore = cS_ChoiceScoreData_Strc.AreaFreqwiseScores{cAreaInds,2};
            RawResp_freqwiseAvgScore = squeeze(mean(RawResp_freqwiseScore,1,'omitnan'));
            RawResp_freqwiseSTDScore = squeeze(std(RawResp_freqwiseScore,1,'omitnan'))/sqrt(size(RawResp_freqwiseScore,1));
%             if any(isnan(RawResp_freqwiseAvgScore))
%                 fprintf('NaN value for session %d Area %d.\n',cS,cAreaInds);
%             end
            BaseData_freqwiseScore = cS_ChoiceScoreData_Strc.AreaFreqwiseScores{cAreaInds,3};
            BaseData_freqwiseAvgScore = squeeze(mean(BaseData_freqwiseScore,1,'omitnan'));
            BaseData_freqwiseSTDScore = squeeze(std(BaseData_freqwiseScore,1,'omitnan'))/sqrt(size(BaseData_freqwiseScore,1));

            AreaWise_FreqwiseScoreData(cS,AreaMatchInds,:,1) = {BaseSub_freqwiseAvgScore,RawResp_freqwiseAvgScore,BaseData_freqwiseAvgScore};
            AreaWise_FreqwiseScoreData(cS,AreaMatchInds,:,2) = {BaseSub_freqwiseSTDScore,RawResp_freqwiseSTDScore,BaseData_freqwiseSTDScore};
        end
    end
end

%%
AreaWise_RevTrDataMtx = AreaWise_dsqrSummaryData(:,:,1);
AreaWise_NonRevTrDataMtx = AreaWise_dsqrSummaryData(:,:,2);
AreaWise_AllTrDataMtx = AreaWise_dsqrSummaryData(:,:,3);

ColTypeStrsRev = {'BS_RevTrdsqr','RevTrdsqr','BS_RevTrChoicePerf','RevTrChoicePerf','RevTrdsqrRatio'};
ColTypeStrsNRev = {'BS_NRevTrdsqr','NRevTrdsqr','BS_NRevTrChoicePerf','NRevTrChoicePerf','NRevTrdsqrRatio'};
BaseColStrAllTr = {'BaseDataChoiceScore','BaseDataChoicePerf','ChoiceDecisionBound','ChoiceANDBTVecAngle'};
RevTrdSqrANDperf = cell(NumAllTargetAreas,1);
NRevTrdSqrANDperf = cell(NumAllTargetAreas,1);
BaseData_AllTrDatas = cell(NumAllTargetAreas,1);
for cA = 1 : NumAllTargetAreas
    cA_data_RevTr = cat(1,AreaWise_RevTrDataMtx{:,cA});
    if ~isempty(cA_data_RevTr)
        cA_sessNum = size(cA_data_RevTr,1); 
        cA_data_NRevTr = cat(1,AreaWise_NonRevTrDataMtx{:,cA});
        BaseData_AllTrDatas{cA,1} = cat(1,AreaWise_AllTrDataMtx{:,cA});
        
        RevTrdSqrANDperf{cA,1} = [cA_data_RevTr(:,[1,3,2,4]),cA_data_RevTr(:,3)./cA_data_RevTr(:,1)];
        NRevTrdSqrANDperf{cA,1} = [cA_data_NRevTr(:,[1,3,2,4]),cA_data_NRevTr(:,3)./cA_data_NRevTr(:,1)];
        
    end
end

%% freq-wise Choice scores
SummarySavePath9 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary';
% SummarySavePath9 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\ChoiceScoreSummary';

OctTypes = log2(FreqTypes/FreqTypes(1));
AreaWise_freqwise_avgScore = AreaWise_FreqwiseScoreData(:,:,:,1);
AreaBoundCurveFits = cell(NumAllTargetAreas,3);
AreaFitDataStrc = cell(NumAllTargetAreas,2);
% BaseSub_freqwiseAvgScore,RawResp_freqwiseAvgScore,BaseData_freqwiseAvgScore
for cA = 1 : NumAllTargetAreas
%     cA = 104;
    
    cA_Basesub_Avgscore = AreaWise_freqwise_avgScore(:,cA,1);
    cA_Basesub_scoreMtx = cat(3,cA_Basesub_Avgscore{:});
    if isempty(cA_Basesub_scoreMtx)
        continue;
    end
    
    cA_RawResp_Avgscore = AreaWise_freqwise_avgScore(:,cA,2);
    cA_BaseData_Avgscore = AreaWise_freqwise_avgScore(:,cA,3);
    
    cA_RawResp_scoreMtx = cat(3,cA_RawResp_Avgscore{:});
    cA_BaseData_scoreMtx = cat(3,cA_BaseData_Avgscore{:});
    
    NumSess = size(cA_Basesub_scoreMtx,3);
    cA_Basesub_ZS_score = zeros(size(cA_Basesub_scoreMtx));
    cA_RawResp_ZS_score = zeros(size(cA_RawResp_scoreMtx));
    cA_BaseData_ZS_score = zeros(size(cA_BaseData_scoreMtx));
    for cS = 1 : NumSess
        cA_Basesub_ZS_score(:,:,cS) = (cA_Basesub_scoreMtx(:,:,cS) - mean(cA_Basesub_scoreMtx(:,:,cS),'all'))/...
            std(cA_Basesub_scoreMtx(:,:,cS),[],'all');
        cA_RawResp_ZS_score(:,:,cS) = (cA_RawResp_scoreMtx(:,:,cS) - mean(cA_RawResp_scoreMtx(:,:,cS),'all'))/...
            std(cA_RawResp_scoreMtx(:,:,cS),[],'all');
        cA_BaseData_ZS_score(:,:,cS) = (cA_BaseData_scoreMtx(:,:,cS) - mean(cA_BaseData_scoreMtx(:,:,cS),'all'))/...
            std(cA_BaseData_scoreMtx(:,:,cS),[],'all');
    end
%     cA_Basesub_ZS_score = (cA_Basesub_scoreMtx - mean(cA_Basesub_scoreMtx,'all'))/std(cA_Basesub_scoreMtx,[],'all');
%     cA_RawResp_ZS_score = (cA_RawResp_scoreMtx - mean(cA_RawResp_scoreMtx,'all'))/std(cA_RawResp_scoreMtx,[],'all');
%     cA_BaseData_ZS_score = (cA_BaseData_scoreMtx - mean(cA_BaseData_scoreMtx,'all'))/std(cA_BaseData_scoreMtx,[],'all');
    
    % calculate the fitted curve
    if NumSess >= 3
        BaseSubOutDataStrc = FreqScore2psyCurve(-cA_Basesub_ZS_score, OctTypes);
        RawRespOutDataStrc = FreqScore2psyCurve(-cA_RawResp_ZS_score, OctTypes);
        AreaBoundCurveFits(cA,:) = {BaseSubOutDataStrc, RawRespOutDataStrc,NumSess};
        AreaFitDataStrc(cA,:) = {BaseSubOutDataStrc, RawRespOutDataStrc};
    end
    
    cA_Basesub_scoreAvg = -mean(cA_Basesub_scoreMtx,3);
    cA_Basesub_ZSscoreAvg = -mean(cA_Basesub_ZS_score,3);
    
    cA_RawResp_scoreAvg = -mean(cA_RawResp_scoreMtx,3);
    cA_RawResp_ZSscoreAvg = -mean(cA_RawResp_ZS_score,3);
    
    cA_BaseData_scoreAvg = -mean(cA_BaseData_scoreMtx,3);
    cA_BaseData_ZSscoreAvg = -mean(cA_BaseData_ZS_score,3);
    
    if NumSess >= 3
        hf9 = figure('position',[80 450 1080 320]);
        ax1 = subplot(131);
        ax2 = subplot(132);
    else
        hf9 = figure('position',[80 450 760 320]);
        ax1 = subplot(121);
        ax2 = subplot(122);
    end
    
    axes(ax1);
    hold on
    plot(OctTypes,cA_Basesub_scoreAvg(:,1),'b','linewidth',1);
    plot(OctTypes,cA_Basesub_scoreAvg(:,2),'r','linewidth',1);
    
    plot(OctTypes,cA_RawResp_scoreAvg(:,1),'b','linewidth',1,'linestyle','--');
    plot(OctTypes,cA_RawResp_scoreAvg(:,2),'r','linewidth',1,'linestyle','--');
    
    plot(OctTypes,cA_BaseData_scoreAvg(:,1),'g','linewidth',1);
    plot(OctTypes,cA_BaseData_scoreAvg(:,2),'y','linewidth',1);
    title(sprintf('NumUsed Sess = %d',NumSess))
    line([OctTypes(1) OctTypes(end)],[0 0],'Color','k','linewidth',0.8,'linestyle','--');
    ylabel('Averaged Score');
    set(ax1,'xtick',OctTypes,'xticklabel',cellstr(num2str(FreqTypes(:)/1000,'%.2f')));
    xlabel('Frequency (Hz)');
    
    axes(ax2);
    hold on
    plot(OctTypes,cA_Basesub_ZSscoreAvg(:,1),'b','linewidth',1);
    plot(OctTypes,cA_Basesub_ZSscoreAvg(:,2),'r','linewidth',1);
    
    plot(OctTypes,cA_RawResp_ZSscoreAvg(:,1),'b','linewidth',1,'linestyle','--');
    plot(OctTypes,cA_RawResp_ZSscoreAvg(:,2),'r','linewidth',1,'linestyle','--');
    
    plot(OctTypes,cA_BaseData_ZSscoreAvg(:,1),'g','linewidth',1);
    plot(OctTypes,cA_BaseData_ZSscoreAvg(:,2),'y','linewidth',1);
    title(sprintf('Area %s',BrainAreasStr{cA}));
    line([OctTypes(1) OctTypes(end)],[0 0],'Color','k','linewidth',0.8,'linestyle','--');
    ylabel('Averaged Zscored Score');
    set(ax2,'xtick',OctTypes,'xticklabel',cellstr(num2str(FreqTypes(:)/1000,'%.2f')));
    xlabel('Frequency (Hz)');

    if NumSess >= 3
        % add fitting curve plots
        cax = subplot(133);
        hold on
        plot(BaseSubOutDataStrc.LowFitCurve(:,1),BaseSubOutDataStrc.LowFitCurve(:,2),'b')
        plot(BaseSubOutDataStrc.HighFitCurve(:,1),BaseSubOutDataStrc.HighFitCurve(:,2),'r')

        plot(RawRespOutDataStrc.HighFitCurve(:,1),RawRespOutDataStrc.HighFitCurve(:,2),'r','linestyle','--')
        plot(RawRespOutDataStrc.LowFitCurve(:,1),RawRespOutDataStrc.LowFitCurve(:,2),'b','linestyle','--')
        
        plot(OctTypes,cA_Basesub_ZSscoreAvg(:,1),'bo','linewidth',1,'MarkerSize',12);
        plot(OctTypes,cA_Basesub_ZSscoreAvg(:,2),'ro','linewidth',1,'MarkerSize',12);

        plot(OctTypes,cA_RawResp_ZSscoreAvg(:,1),'b*','linewidth',1,'MarkerSize',8);
        plot(OctTypes,cA_RawResp_ZSscoreAvg(:,2),'r*','linewidth',1,'MarkerSize',8);
        
        title('Fitted Curve');
        line([OctTypes(1) OctTypes(end)],[0 0],'Color','k','linewidth',0.8,'linestyle','--');
        ylabel('Averaged Zscored Score');
        set(cax,'xtick',OctTypes,'xticklabel',cellstr(num2str(FreqTypes(:)/1000,'%.2f')));
        xlabel('Frequency (Hz)');
    end
    
    filesavePath = fullfile(SummarySavePath9,sprintf('Area_%s freqwise choice score plots',BrainAreasStr{cA}));
    saveas(hf9, filesavePath);
    print(hf9,filesavePath,'-dpng','-r400');
    print(hf9,filesavePath,'-dpdf','-bestfit');
%       pause(5);
    close(hf9);
    
end
%%
summaryDatapath9 = fullfile(SummarySavePath9,'SessFreqwiseScoreData.mat');
save(summaryDatapath9,'AreaWise_FreqwiseScoreData','AreaBoundCurveFits','BrainAreasStr',...
    'OctTypes','AreaFitDataStrc','-v7.3');

%%
IsEmptySess = cellfun(@isempty,AreaBoundCurveFits(:,1));
UsedSessData = AreaBoundCurveFits(~IsEmptySess,:);

BaseSub_dataBound = cellfun(@(x) x.BoundAll,UsedSessData(:,1),'un',0);
BaseSub_BoundMtx = cat(1,BaseSub_dataBound{:});

RawResp_dataBound = cellfun(@(x) x.BoundAll,UsedSessData(:,2),'un',0);
RawResp_BoundMtx = cat(1,RawResp_dataBound{:});
UsedSessNums = cat(1,UsedSessData{:,3});

BaseSub_BoundDiff = BaseSub_BoundMtx(:,2) - BaseSub_BoundMtx(:,1);
RawResp_BoundDiff = RawResp_BoundMtx(:,2) - RawResp_BoundMtx(:,1);

BoundData = [BaseSub_BoundDiff, RawResp_BoundDiff];
UsedSessInds = UsedSessNums > 4;
[~,p] = ttest(BaseSub_BoundDiff(UsedSessInds), RawResp_BoundDiff(UsedSessInds));

% sum(UsedSessNums > 5);
UpperThresData = max(BoundData(UsedSessInds,:),[],'all')+0.1;

h99f = figure('position',[100 100 330 280]);
hold on
plot([1,2],BoundData(UsedSessInds,:)','Color',[.7 .7 .7],'linewidth',1.2);
plot([1,2],mean(BoundData(UsedSessInds,:)),'Color','k','linewidth',1.5);
line([1,2],[UpperThresData UpperThresData],'Color','c','linewidth',1.5);
text(1.5,UpperThresData+0.2,num2str(p,'p = %.4f'),'HorizontalAlignment','center');
text(0.7,UpperThresData+0.4,num2str(sum(UsedSessInds),'N = %d'));
set(gca,'xlim',[0.5 2.5],'xtick',1:2,'xticklabel',{'BaseSub','RawResp'},'ylim',[0 1.6]);%
ylabel(gca,'Boundary shiftment in octave');

filesavePath99 = fullfile(SummarySavePath9,'BaseSubAndRawResp_boundShiftData');
saveas(h99f, filesavePath99);
print(h99f,filesavePath99,'-dpng','-r400');
print(h99f,filesavePath99,'-dpdf','-bestfit');


%% ###################################################################################################
% Summary codes 10: single unit PSTH data summary
%
cclr
%
% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = [BrainAreasStrCC(~EmptyInds)];

%

SessionFoldersC = readcell(AllSessFolderPathfile,'Range','A:A',...
        'Sheet',1);
SessionFoldersRaw = SessionFoldersC(2:end);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),SessionFoldersRaw);
SessionFolders = SessionFoldersRaw(~EmptyInds);

NumUsedSess = length(SessionFolders);
NumAllTargetAreas = length(BrainAreasStr);
%%

PSTHColStrs = {'cUCorrectTrace','cUCorrectSEM','cUErrorTrace','cUErrorSEM','TrialNumMtx','UnitIDs',...
    'UnitAreas','AreaIndex','SessIndex','RespMtxTypes'};

AllSessUnitPSTH = cell(NumUsedSess,1);

UsedFolderPath = cell(NumUsedSess,1);
SessTrialTypeNums = cell(NumUsedSess,2);
for cS = 1 : NumUsedSess
    
%     cSessPath = strrep(SessionFolders{cS},'F:\','E:\NPCCGs\');
    cSessPath = strrep(SessionFolders{cS},'F:','I:\ksOutput_backup'); %(2:end-1)
    
    ksfolder = fullfile(cSessPath,'ks2_5');
    UsedFolderPath{cS} = ksfolder;
    
    cSessPSTHDatafile = fullfile(ksfolder,'SessPSTHdataSave.mat');
    cSessPSTHDataStrc = load(cSessPSTHDatafile,'ExpendTraceAll');
    UnitTypefile = fullfile(ksfolder,'Regressor_ANA','UnitSelectiveTypes2.mat');
    SessUnitTypeMtxStrc = load(UnitTypefile,'IsUnitGLMResp');
    
    cSessCorrTrNum = cSessPSTHDataStrc.ExpendTraceAll{1,5};
    cSessCorrTrNumVec = cSessCorrTrNum(:);
    cSessAllAreaStrs = cSessPSTHDataStrc.ExpendTraceAll(:,7);
    [AreaTypes, ~, AreaInds] = unique(cSessAllAreaStrs);
    
    UsedUnitNums = length(AreaInds);
    NumAreas = length(AreaTypes);
    Match2AllAreaInds = zeros(UsedUnitNums,1);
    for cA = 1 : NumAreas
        cA_Str = AreaTypes{cA};
        cA_matchinds = find(matches(BrainAreasStr,cA_Str,'IgnoreCase',true));
        Match2AllAreaInds(AreaInds == cA) = cA_matchinds;
    end
    AllTypeTrNums = cSessPSTHDataStrc.ExpendTraceAll{1,5};
    SessTrialTypeNums(cS,:) = {([AllTypeTrNums(:,1);AllTypeTrNums(:,3)])',...
        ([AllTypeTrNums(:,2);AllTypeTrNums(:,4)])'};
    
    FolderPathIndex = cS * ones(UsedUnitNums,1);
    
    TypeMtx = mat2cell(SessUnitTypeMtxStrc.IsUnitGLMResp,ones(UsedUnitNums,1),size(SessUnitTypeMtxStrc.IsUnitGLMResp,2));
    
    SessMergedUnitPSTH = [cSessPSTHDataStrc.ExpendTraceAll,num2cell(Match2AllAreaInds),...
        num2cell(FolderPathIndex),TypeMtx];
    
    AllSessUnitPSTH(cS) = {SessMergedUnitPSTH};
    
end

AllUnitPSTHExpends = cat(1,AllSessUnitPSTH{:});

%%
SummarySavePath10 = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';
% SummarySavePath10 = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';
if ~isfolder(SummarySavePath10)
    mkdir(SummarySavePath10);
end

SumDataSavefile = fullfile(SummarySavePath10,'UnitPSTHDatas.mat');
save(SumDataSavefile,'AllUnitPSTHExpends','SessTrialTypeNums','UsedFolderPath','PSTHColStrs','BrainAreasStr','-v7.3');

%%
SessTrTypeNumMtx = cat(1,SessTrialTypeNums{:,1});
TrTypeLessInds = sum(SessTrTypeNumMtx < 3,2);
ExcludedSessInds = find(TrTypeLessInds);

AllUnitSessIndex = cat(1,AllUnitPSTHExpends{:,9});
TotalUnitSess_excluInds = ismember(AllUnitSessIndex,ExcludedSessInds);

UsedUnitCellDatasAll = AllUnitPSTHExpends(~TotalUnitSess_excluInds,:);
UsedAreaTypes = cat(1,UsedUnitCellDatasAll{:,8});
[ExistAreas,~,UsedAreaNewIndex] = unique(UsedAreaTypes);
NumExistArea = length(ExistAreas);

ExistAreaUnitPSTHAll = cell(NumExistArea,8);
for cA = 1 : NumExistArea
    cA_UnitInds = UsedAreaTypes == ExistAreas(cA);
    cA_UnitNums = sum(cA_UnitInds);
    cA_UnitDatas = UsedUnitCellDatasAll(cA_UnitInds,:);
    cA_UnitPSTHMtx = cat(1,cA_UnitDatas{:,1});
    cA_UnitPSTHSEM = cat(1,cA_UnitDatas{:,2});
    cA_UnitRespTypeMtx = cat(1,cA_UnitDatas{:,10});
    
    cA_UnitErrorPSTHMtx = cat(1,cA_UnitDatas{:,3});
    cA_UnitErrorPSTHSEM = cat(1,cA_UnitDatas{:,4});
    
    cA_strs = BrainAreasStr{ExistAreas(cA)};
    
    ExistAreaUnitPSTHAll(cA,:) = {cA_strs, cA_UnitPSTHMtx, cA_UnitPSTHSEM, ...
        cA_UnitNums,UsedAreaNewIndex(cA_UnitInds),cA_UnitRespTypeMtx,cA_UnitErrorPSTHMtx,cA_UnitErrorPSTHSEM};
end

%%
ExistAreaPSTHDataAll = cat(1,ExistAreaUnitPSTHAll{:,2});
ExistAreaErrorPSTHData = cat(1,ExistAreaUnitPSTHAll{:,7});
ExistAreaPSTHAreaInds = cat(1,ExistAreaUnitPSTHAll{:,5});
ExistAreaPSTHUnitRespType = cat(1,ExistAreaUnitPSTHAll{:,6});

[ExistAreaPSTHData_zs, mu, sigma] = zscore(ExistAreaPSTHDataAll,0,2);
ExistAreaErrorPSTHData_zs = ((ExistAreaErrorPSTHData' - mu')./sigma')';
%% Unit response type matrix
NonRespUnits = ~sum(ExistAreaPSTHUnitRespType,2);
ChoiceRespType = ExistAreaPSTHUnitRespType(:,4) | ExistAreaPSTHUnitRespType(:,5);
NewRespTypeMtx = [ExistAreaPSTHUnitRespType(:,1:3),ChoiceRespType];

TrialIndexOnlyUnit = NewRespTypeMtx(:,2) & ~sum(NewRespTypeMtx(:,[1,3,4]),2);
BTOnlyUnit = NewRespTypeMtx(:,1) & ~sum(NewRespTypeMtx(:,2:4),2);
StimOnlyUnit = NewRespTypeMtx(:,3) & ~sum(NewRespTypeMtx(:,[1,2,4]),2);
ChoiceOnlyUnit = NewRespTypeMtx(:,4) & ~sum(NewRespTypeMtx(:,1:3),2);
BTANDStim_unit = (NewRespTypeMtx(:,1) & NewRespTypeMtx(:,3)) &  ~sum(NewRespTypeMtx(:,[2,4]),2);
BTANDChoice_unit = (NewRespTypeMtx(:,1) & NewRespTypeMtx(:,4)) &  ~sum(NewRespTypeMtx(:,[2,3]),2);
StimANDChoice_unit = (NewRespTypeMtx(:,3) & NewRespTypeMtx(:,4)) &  ~sum(NewRespTypeMtx(:,[2,1]),2);
TrialIndexANDstim_unit = (NewRespTypeMtx(:,2) & NewRespTypeMtx(:,3)) & ~sum(NewRespTypeMtx(:,[4,1]),2);
TrialIndexANDchoice_unit = (NewRespTypeMtx(:,2) & NewRespTypeMtx(:,4)) & ~sum(NewRespTypeMtx(:,[3,1]),2);
TrialIndexANDAllOther_unit = NewRespTypeMtx(:,2) & NewRespTypeMtx(:,3) & NewRespTypeMtx(:,4);

RespTypeGrInds = nan(size(ExistAreaPSTHUnitRespType,1),1);

RespTypeGrInds(TrialIndexOnlyUnit) = 1;
RespTypeGrInds(BTOnlyUnit) = 2;
RespTypeGrInds(StimOnlyUnit) = 3;
RespTypeGrInds(ChoiceOnlyUnit) = 4;
RespTypeGrInds(BTANDStim_unit) = 5;
RespTypeGrInds(BTANDChoice_unit) = 6;
RespTypeGrInds(StimANDChoice_unit) = 7;
RespTypeGrInds(TrialIndexANDstim_unit) = 8;
RespTypeGrInds(TrialIndexANDchoice_unit) = 9;
RespTypeGrInds(TrialIndexANDAllOther_unit) = 10;
RespTypeGrInds(isnan(RespTypeGrInds)) = 11;

%% test with tsne clustering
% figure('position',[100 100 1200 840])
% figure;
Perplexitys = 60;
nPCs = 100;
Algorithm = 'barneshut'; %'barneshut' for N > 1000 % 'exact' for small N
Exag = 12;
UnitPSTHzs = ExistAreaPSTHData_zs;
% UnitPSTHzs = ExistAreaPSTHData_zsSM;
AreaStrs = ExistAreaPSTHAreaInds;

% rng('shuffle') % for fair comparison
% Y = tsne(UnitPSTHzs,'Algorithm',Algorithm,'Distance','correlation','Perplexity',Perplexitys,...
%     'NumPCAComponents',nPCs,'Exaggeration',Exag);
% subplot(2,2,1)
% gscatter(Y(:,1),Y(:,2),AreaStrs)
% title('correlation')
AllYs = cell(5,2);
% UsedYInds = UnitInterROI ~= 21;
% ClusColors = linspecer(20);
% UsedYInds = RespTypeGrInds ~= 11 & RespTypeGrInds ~= 1;
for cR = 1 : 5
    figure
%     hold on
    
    rng('shuffle') % for fair comparison
    [Y,loss] = tsne(UnitPSTHzs,'Algorithm',Algorithm,'Distance','cosine','Perplexity',Perplexitys,...
        'NumPCAComponents',nPCs,'Exaggeration',Exag);
    
%     scatter(Y(~UsedYInds,1),Y(~UsedYInds,2),6,'o','MarkerFaceColor',[.7 .7 .7],'MarkerEdgeColor','none')
    % subplot(2,2,2)
%     gscatter(Y(UsedYInds,1),Y(UsedYInds,2),RespTypeGrInds(UsedYInds));
    
%     gscatter(Y(UsedYInds,1),Y(UsedYInds,2),UnitInterROI(UsedYInds));
    scatter(Y(:,1),Y(:,2),'ko');
    title('Cosine')
    AllYs(cR,:) = {Y,loss};
end
% rng('shuffle') % for fair comparison
% Y = tsne(UnitPSTHzs,'Algorithm',Algorithm,'Distance','chebychev','Perplexity',Perplexitys,...
%     'NumPCAComponents',nPCs,'Exaggeration',Exag);
% subplot(2,2,3)
% gscatter(Y(:,1),Y(:,2),AreaStrs)
% title('Chebychev')
% 
% rng('shuffle') % for fair comparison
% Y = tsne(UnitPSTHzs,'Algorithm',Algorithm,'Distance','euclidean','Perplexity',Perplexitys,...
%     'NumPCAComponents',nPCs,'Exaggeration',Exag);
% subplot(2,2,4)
% gscatter(Y(:,1),Y(:,2),AreaStrs)
% title('Euclidean')



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


