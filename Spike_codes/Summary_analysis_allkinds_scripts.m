
% All sorts of summary codes, run in different trunks
% ###################################################################################################
% Summary codes 1: summary of BT_and_Choice AUC values
%
cclr

% AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';
AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
BrainAreasStrCCC = cellfun(@(x) x(2:end-1),BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@isempty,BrainAreasStrCCC);
BrainAreasStr = [BrainAreasStrCCC(~EmptyInds);{'Others'}];

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
%     cSessPath = SessionFolders{cS}(2:end-1);
    cSessPath = strrep(SessionFolders{cS}(2:end-1),'F:','I:\ksOutput_backup');
    
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
AllArea_PopuBTloss = squeeze(Areawise_PopuBTChoicePerf(:,:,1));
AllArea_PopuChoiceloss = squeeze(Areawise_PopuBTChoicePerf(:,:,2));
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
if ~isfolder(summarySaveFolder1)
    mkdir(summarySaveFolder1);
end

%%
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
        plot(cA_AS_AUCs(:,1),cA_BLS_AUCs(:,1),'ro')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, BlockType');
        ylabel('baselineSub resp, BlockType');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off','xlim',[0 1],'ylim',[0 1]);
        [~, p_BT] = ttest(cA_AS_AUCs(:,1),cA_BLS_AUCs(:,1));
        title(sprintf('Area %s, p = %.3e',cAreaStr, p_BT));
        text(0.3,0.2,sprintf('n = %d',NumTotalUnits));

        ax2 = subplot(332);
        plot(cA_AS_AUCs(:,3),cA_BLS_AUCs(:,3),'bo')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, Choice');
        ylabel('baselineSub resp, Choice');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_Choice] = ttest(cA_AS_AUCs(:,3),cA_BLS_AUCs(:,3));
        title(sprintf('p = %.3e',p_Choice));
        
        % compare block type decoding with baseline data
%         h2f = figure('position',[100 100 920 360]);
        ax3 = subplot(334);
        plot(cA_AS_AUCs(:,1),cA_BL_AUCs(:,1),'ro')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, BlockType');
        ylabel('baseline, BlockType');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [~, p_BT] = ttest(cA_AS_AUCs(:,1),cA_BL_AUCs(:,1));
        title(sprintf('p = %.3e',p_BT));
%         text(0.3,0.2,sprintf('n = %d',NumUsedUnits));

        ax4 = subplot(335);
        plot(cA_BLS_AUCs(:,1),cA_BL_AUCs(:,1),'ro')
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
        plot(cA_AS_AUCs(:,1),cA_AS_AUCs(:,3),'mo')
        line([0 1],[0 1],'Color','k','linestyle','--','linewidth',1.4);
        xlabel('AfterStim resp, BlockType');
        ylabel('AfterStim resp, Choice');
        set(gca,'xtick',0:0.5:1,'ytick',0:0.5:1,'box','off');
        [r1, p3] = corrcoef(cA_AS_AUCs(:,1),cA_AS_AUCs(:,3));
        title(sprintf('p = %.3e, r = %.3f',p3(1,2),r1(1,2)));
%         text(0.3,0.2,sprintf('n = %d',NumUsedUnits));

        ax6 = subplot(338);
        plot(cA_BLS_AUCs(:,1),cA_BLS_AUCs(:,3),'mo')
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
       title(ax7,sprintf('TwodecodeVecAngle = %.2f',mean(cA_BTChoice_usedAngles)));
       
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
       title(ax9,sprintf('BlockType decodePerf = %.2f',mean(cA_ChoicePerfs_used)));
       
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
    'Areawise_BTANDChoiceAUC', 'Areawise_PopuBTChoicePerf','-v7.3');

%%
% ###################################################################################################
% Summary codes 2: summary of BT_and_Choice AUC values
%






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


