
% ksfolder = pwd;

clearvars ProbNPSess FullRegressorInfosCell
load(fullfile(ksfolder,'NPClassHandleSaved.mat'),'behavResults');

load(fullfile(ksfolder,'Regressor_ANA','RegressorDataAligned.mat'),'FullRegressorInfosCell',...
    'NewExistField_ClusIDs','IsUnitNeedProcessed');
%% check whether extra unit calculation is existed
% if sum(IsUnitNeedProcessed(:,1)) % check whether extra unit calculation is needed
%     if exist(fullfile(ksfolder,'Regressor_ANA','ExtraUnitRegress.mat'),'file')
%         ExtraUnitCalRes = load(fullfile(ksfolder,'Regressor_ANA','ExtraUnitRegress.mat'));
%         
%         load(fullfile(ksfolder,'Regressor_ANA','RegressorDataAligned.mat'));
%         RegressorInfosCell(ExtraUnitCalRes.NeedCalUnitInds,:) = ExtraUnitCalRes.RegressorInfosCell_p;
%         rrr_RegressorInfosCell(ExtraUnitCalRes.NeedCalUnitInds,:) = ExtraUnitCalRes.rrr_RegressorInfosCell_p;
%         FullRegressorInfosCell(ExtraUnitCalRes.NeedCalUnitInds,:) = ExtraUnitCalRes.FullRegressorInfosCell_p;
%         IsUnitNeedProcessed(ExtraUnitCalRes.NeedCalUnitInds,1) = 0;
%         if sum(IsUnitNeedProcessed(:,1))
%             fprintf('Current session still have some units without regression data.\n');
%         end
%         dataSaveNames = fullfile(ksfolder,'Regressor_ANA','RegressorDataAligned.mat');
%         save(dataSaveNames, 'RegressorInfosCell',...
%         'NewExistField_ClusIDs', 'NewAdd_ExistAreaNames','rrr_RegressorInfosCell', 'AreaUnitNumbers','IsUnitNeedProcessed',...
%         'FullRegressorInfosCell','EventDescripStrsFull','EventDescripStrsFirst','TaskEvents_predictor','FullEvents_predictor','-v7.3');
%     else
%        fprintf('Extra unit calculation file is missing.\n');
%        return;
%     end
% end

%%
BlockSectionInfo = Bev2blockinfoFun(behavResults);
AllWithinAreaUnitNums = size(FullRegressorInfosCell,1);

NMFullMDInds = find(~cellfun(@isempty,FullRegressorInfosCell(:,1)));

NMUnitNums = length(NMFullMDInds);
NMUnitRegInfos = FullRegressorInfosCell(NMFullMDInds,:);

if BlockSectionInfo.NumBlocks > 2
    % if multiple switch exists, considering blocktype Index fitting EV 
    % alone model fitting EV
    AloneMD_EV_binaryBT = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var(:,4,2))),NMUnitRegInfos(:,1));
    AloneMD_EV_IndexBT = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var(:,5,2))),NMUnitRegInfos(:,1));
    ResiMD_EV_IndexBT = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var(:,5,3))),NMUnitRegInfos(:,1));
    ResiMD_EV_binaryBT = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var(:,4,3))),NMUnitRegInfos(:,1));
    
    BInaryBTUnit = (AloneMD_EV_binaryBT >= 0.02 & ResiMD_EV_IndexBT < 0.02) | (ResiMD_EV_binaryBT >= 0.02);
    IndexBTUnit = ResiMD_EV_IndexBT >= 0.02 & (ResiMD_EV_binaryBT < 0.02);
    
    BinaryBTEValls_alone = AloneMD_EV_binaryBT(BInaryBTUnit);
    IndexBTEValls_Resi = ResiMD_EV_IndexBT(BInaryBTUnit);
    BinaryBTEValls_Resi = ResiMD_EV_binaryBT(BInaryBTUnit);
    
    UsedBinaryBTEVs = zeros(sum(BInaryBTUnit),1);
    UsedBinaryBTEVs(BinaryBTEValls_Resi >= 0.02) = BinaryBTEValls_Resi(BinaryBTEValls_Resi >= 0.02);
    UsedBinaryBTEVs(BinaryBTEValls_alone >= 0.02 & IndexBTEValls_Resi < 0.02) = ...
        BinaryBTEValls_alone(BinaryBTEValls_alone >= 0.02 & IndexBTEValls_Resi < 0.02);
    
%     UsedIndexBTEVs = zeros(sum(IndexBTUnit),1);
    UsedIndexBTEVs = ResiMD_EV_binaryBT(ResiMD_EV_IndexBT >= 0.02 & (ResiMD_EV_binaryBT < 0.02));
    
    BTEVAlls = zeros(numel(BInaryBTUnit),1);
    BTEVAlls(BInaryBTUnit) = UsedBinaryBTEVs;
    BTEVAlls(IndexBTUnit) = UsedIndexBTEVs;
    
elseif BlockSectionInfo.NumBlocks == 2
    load(fullfile(ksfolder,'NPClassHandleSaved.mat'),'ProbNPSess');
    
    ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
    % if only two block exist, using baseline response to check whether the
    % response type is binary or linear ramping
    AloneMD_EV_BinaryBT = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var(:,4,2))),NMUnitRegInfos(:,1));
    ResiMD_EV_BinaryBT = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var(:,4,3))),NMUnitRegInfos(:,1));
    AllBTUnit = AloneMD_EV_BinaryBT >= 0.02;
    
    BTUnitIndex = find(AllBTUnit); % real index of all index significant units
    
    AllBTUnit_DataInds = NMFullMDInds(AllBTUnit);
    UnitCriterias = BinaryRespCheck(ProbNPSess,AllBTUnit_DataInds);
    BTUnitBase = false(length(BTUnitIndex),1);
    
    BInaryBTUnit1 = BTUnitBase;
    BInaryBTUnit1(logical(UnitCriterias(:,1))) = true;
    IndexBTUnit1 = ~BInaryBTUnit1;
    
    NMFullIndsAll = false(numel(AllBTUnit),1);
    BInaryBTUnit = NMFullIndsAll;
    BInaryBTUnit(BTUnitIndex(BInaryBTUnit1)) = true;
    IndexBTUnit = NMFullIndsAll;
    IndexBTUnit(BTUnitIndex(IndexBTUnit1)) = true;
    
    UsedBinaryBTEVs = AloneMD_EV_BinaryBT(BInaryBTUnit);
    UsedIndexBTEVs = ResiMD_EV_BinaryBT(IndexBTUnit);
    
    BTEVAlls = zeros(numel(AllBTUnit),1);
    BTEVAlls(BInaryBTUnit) = UsedBinaryBTEVs;
    BTEVAlls(IndexBTUnit) = UsedIndexBTEVs;
    
end
    
ResiMD_EV_Stim = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var(:,1,3))),NMUnitRegInfos(:,1));
StimRespUnit = ResiMD_EV_Stim >= 0.02;

ResiMD_EV_ChoiceL = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var(:,2,3))),NMUnitRegInfos(:,1));
ResiMD_EV_ChoiceR = cellfun(@(x) squeeze(mean(x.PartialMd_explain_var(:,3,3))),NMUnitRegInfos(:,1));
% ChoiceRespUnit = AloneMD_EV_ChoiceL >= 0.02 | AloneMD_EV_ChoiceR >= 0.02;


IsUnitGLMResp = false(AllWithinAreaUnitNums,5);
IsUnitGLMResp(NMFullMDInds(BInaryBTUnit), 1) = true; % binary BT
IsUnitGLMResp(NMFullMDInds(IndexBTUnit), 2) = true; % ramping BT, Or pure ramping
IsUnitGLMResp(NMFullMDInds(StimRespUnit), 3) = true; % Stim selective
IsUnitGLMResp(NMFullMDInds(ResiMD_EV_ChoiceL >= 0.02), 4) = true; % Left choice selective
IsUnitGLMResp(NMFullMDInds(ResiMD_EV_ChoiceR >= 0.02), 5) = true; % right selective

GLMRespUnitEVs = zeros(AllWithinAreaUnitNums,4);
GLMRespUnitEVs(NMFullMDInds,1) = BTEVAlls;
GLMRespUnitEVs(NMFullMDInds,2) = ResiMD_EV_Stim;

GLMRespUnitEVs(NMFullMDInds,3) = ResiMD_EV_ChoiceL;
GLMRespUnitEVs(NMFullMDInds,4) = ResiMD_EV_ChoiceR;

ColRespTypeStr = {'BinaryBT','Ramping','Stimulus','ChoiceL','ChoiceR'};

%%
saveName = fullfile(ksfolder,'Regressor_ANA','UnitSelectiveTypes2.mat');

save(saveName,'NewExistField_ClusIDs','IsUnitGLMResp','ColRespTypeStr','GLMRespUnitEVs','-v7.3');





