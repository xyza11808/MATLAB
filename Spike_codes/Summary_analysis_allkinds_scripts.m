
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


