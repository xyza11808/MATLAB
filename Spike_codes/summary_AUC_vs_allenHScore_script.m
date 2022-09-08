
AllenHScoreFullPath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_NoCreConf.xlsx';
% AllenHScoreFullPath = 'K:\Documents\me\projects\NP_reversaltask\AllenBrainHireachy\Results\hierarchy_summary_NoCreConf.xlsx';
AllenRegionStrsCell = readcell(AllenHScoreFullPath,'Range','A:A',...
        'Sheet','hierarchy_all_regions');
AllenRegionStrsUsed = AllenRegionStrsCell(2:end);
AllenRegionStrsModi = strrep(AllenRegionStrsUsed,'-','');

RegionScoresCell = readcell(AllenHScoreFullPath,'Range','H:H',...
        'Sheet','hierarchy_all_regions');
RegionScoresUsed = cell2mat(RegionScoresCell(2:end));

%%
AllSessFolderPathfile = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';
% AllSessFolderPathfile = 'K:\Documents\me\projects\NP_reversaltask\processed_ksfolder_paths_nAdd.xlsx';

BrainAreasStrC = readcell(AllSessFolderPathfile,'Range','B:B',...
        'Sheet',1);
BrainAreasStrCC = BrainAreasStrC(2:end);
% BrainAreasStrCCC = cellfun(@(x) x,BrainAreasStrCC,'UniformOutput',false);
EmptyInds = cellfun(@(x) isempty(x) ||any( ismissing(x)),BrainAreasStrCC);
BrainAreasStr = BrainAreasStrCC(~EmptyInds);

NumBrainAreas = length(BrainAreasStr);

% BrainAreasStr = 
%% load summarized AUC datas
SumAUCDatapath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\BlockType_ChoiceVecANDAUC\UnitAUC_PopuVecAngle_datas.mat';
load(SumAUCDatapath);


%% 

AllArea_PopuBTloss = squeeze(Areawise_PopuBTChoicePerf(:,:,2));
AllArea_PopuChoiceloss = squeeze(Areawise_PopuBTChoicePerf(:,:,1));
AllArea_ASAUCs = squeeze(Areawise_BTANDChoiceAUC(:,:,1));
AllArea_UnitNums = squeeze(Areawise_PopuVec(:,:,4));

NonEmptySessInds = cellfun(@(x) ~isempty(x),AllArea_ASAUCs);

[SessInds, AreaInds] = find(NonEmptySessInds);
AllArea_UnitNum_Vec = cell2mat(AllArea_UnitNums(NonEmptySessInds));
AllArea_BTloss_Vec = AllArea_PopuBTloss(NonEmptySessInds);
AllArea_Choiceloss_Vec = AllArea_PopuChoiceloss(NonEmptySessInds);
AllArea_AS_AUC_CellVec = AllArea_ASAUCs(NonEmptySessInds);

ValidPopuVecInds = AllArea_UnitNum_Vec > 5; %& AllArea_BTloss_Vec < 0.5 ...
%     & AllArea_Choiceloss_Vec < 0.5;

ValidPopu_unitNums = AllArea_UnitNum_Vec(ValidPopuVecInds);
ValidAreaInds = AreaInds(ValidPopuVecInds);
ValidBTloss_vec = AllArea_BTloss_Vec(ValidPopuVecInds);
ValidChoiceloss_Vec = AllArea_Choiceloss_Vec(ValidPopuVecInds);
Valid_AS_AUC_CellVec = AllArea_AS_AUC_CellVec(ValidPopuVecInds);

IsArea_withAllen = nan(NumBrainAreas, 3);
AreaInfoDatas = zeros(NumBrainAreas,6);
for cA = 1 : NumBrainAreas
    cA_Inds = ValidAreaInds == cA;
    cA_Area_Str = BrainAreasStr{cA};
    if sum(cA_Inds)
        IsArea_withAllen(cA,1) = 1; % current area is valid
        cA_AS_AUCs = Valid_AS_AUC_CellVec(cA_Inds);
        cA_AS_AUCsMtx = cell2mat(cA_AS_AUCs);
        cA_AS_BTAUCs = cA_AS_AUCsMtx(:,1:2);
        cA_AS_BTAUC_SigInds = cA_AS_BTAUCs(:,1) > cA_AS_BTAUCs(:,2);
        cA_AS_BTAUC_sigFrac = mean(cA_AS_BTAUC_SigInds);
        cA_AS_BTAUC_sigAvg = mean(cA_AS_BTAUCs(cA_AS_BTAUC_SigInds,1));
        
        cA_AS_ChoiceAUCs = cA_AS_AUCsMtx(:,3:4);
        cA_AS_ChoiceAUC_SigInds = cA_AS_ChoiceAUCs(:,1) > cA_AS_ChoiceAUCs(:,2);
        cA_AS_ChoiceAUC_sigFrac = mean(cA_AS_ChoiceAUC_SigInds);
        cA_AS_ChoiceAUC_sigAvg = mean(cA_AS_ChoiceAUCs(cA_AS_ChoiceAUC_SigInds,1));
        
        cA_BTloss_used = mean(ValidBTloss_vec(cA_Inds));
        cA_Choiceloss_used = mean(ValidChoiceloss_Vec(cA_Inds));
        
        AreaInfoDatas(cA,:) = [cA_AS_BTAUC_sigFrac, cA_AS_BTAUC_sigAvg, cA_AS_ChoiceAUC_sigFrac,...
            cA_AS_ChoiceAUC_sigAvg, cA_BTloss_used, cA_Choiceloss_used];
        
        TF = matches(AllenRegionStrsModi,cA_Area_Str,'IgnoreCase',true);
        if any(TF)
            IsArea_withAllen(cA,2) = 1; % current area is within allen hirerachy score strings
            IsArea_withAllen(cA,3) = find(TF); 
        end
        
    end
end

%%
AreaInfoDatas(isnan(AreaInfoDatas)) = 0;
commonAllenAreaIndex = ~isnan(IsArea_withAllen(:,2));
commonAllenAreaScore = IsArea_withAllen(commonAllenAreaIndex,:);
commonAllenHScore =  RegionScoresUsed(commonAllenAreaScore(:,3));
commonAllenArea_regInfos = AreaInfoDatas(commonAllenAreaIndex,:);
mmds = fitglm(commonAllenArea_regInfos, commonAllenHScore);

AllExistAreaInds = ~isnan(IsArea_withAllen(:,1));
AllExistArea_regInfo = AreaInfoDatas(AllExistAreaInds,:);

PredAllArea_HScore = predict(mmds, AllExistArea_regInfo);

[SortSocre, SortInds] = sort(PredAllArea_HScore);
NEbrainInds = BrainAreasStr(AllExistAreaInds);
Sort_brainAreas = NEbrainInds(SortInds);


