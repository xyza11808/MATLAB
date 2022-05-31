
clearvars NSMUnitOmegaSqrData AUCValidInfoDatas
ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
%%
figSavefolder = fullfile(ksfolder, 'AnovanAnA');

% if exist(fullfile(figSavefolder,'SigAnovaTracedataSave.mat'),'file')
%     return;
% end

AnovaDatafile = fullfile(figSavefolder,'SigAnovaTracedataSave.mat');
load(AnovaDatafile,'AreaValidInfoDatas','SeqAreaNames','AccumedUnitNums','SeqAreaUnitNums','SeqFieldClusIDs');
load(fullfile(figSavefolder,'StimrespAUCdataSave.mat'),'StimRespAUC');

% AreaIndexStrc = load(fullfile(ksfolder,'SessAreaIndexData.mat'));
% AllFieldNames = fieldnames(AreaIndexStrc.SessAreaIndexStrc);
% UsedNames = AllFieldNames(1:end-1);
% ExistAreaNames = UsedNames(AreaIndexStrc.SessAreaIndexStrc.UsedAbbreviations);
% 
% if strcmpi(ExistAreaNames(end),'Others')
%     ExistAreaNames(end) = [];
% end
% %%
% Numfieldnames = length(ExistAreaNames);
% ExistField_ClusIDs = [];
% AreaUnitNumbers = zeros(Numfieldnames,1);
% for cA = 1 : Numfieldnames
%     cA_Clus_IDs = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchUnitRealIndex;
%     cA_clus_inds = AreaIndexStrc.SessAreaIndexStrc.(ExistAreaNames{cA}).MatchedUnitInds;
%     ExistField_ClusIDs = [ExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
%     AreaUnitNumbers(cA) = numel(cA_clus_inds);
% end

%%
% AccumedUnitNums = [1;cumsum(AreaUnitNumbers)];
% AreaInds = 6;

NumofExistAreas = length(SeqAreaNames);
AUCLabelTypeStrs = {'Blocktype','Choice'};
AUC2AnovaFactorInds = [3,1]; % firsgt AUC correponded to the third factor in anova, second correponded to the fisrt factor


StimAUCValidInfoDatas = cell(NumofExistAreas,2);
for AreaInds = 1 : NumofExistAreas

    cAreaNames = SeqAreaNames{AreaInds};
    cA_UnitInds = (AccumedUnitNums(AreaInds)+1):AccumedUnitNums(AreaInds+1);
    cA_UnitDatas = StimRespAUC(cA_UnitInds); % in third dimension, first is blocktype, second is choice decoding 
    
    cA_unitNums = length(cA_UnitDatas);
    AllFactorAbove = AreaValidInfoDatas{AreaInds, 1};
    IsUnitHaveNaN= AreaValidInfoDatas{AreaInds, 2};
    
    cA_UnitAUC_cells = cellfun(@(x) (mean(x(:,[1,4]),2))',cA_UnitDatas,'un',0);
    cA_UnitAUC_Thres_cells = cellfun(@(x) (mean(x(:,[3,6]),2))',cA_UnitDatas,'un',0);
    cA_UnitAUC_Mtx = cell2mat(cA_UnitAUC_cells);
    cA_UnitAUC_Thres_Mtx = cell2mat(cA_UnitAUC_Thres_cells);
    
        cfUsedUnitInds = logical(AllFactorAbove(:,2)) & ~IsUnitHaveNaN;

        cfUsedAllDatas = cA_UnitAUC_Mtx(cfUsedUnitInds,:);
        cfThresholdData = cA_UnitAUC_Thres_Mtx(cfUsedUnitInds,:);
        
        ValidUnitNumbers = size(cfUsedAllDatas,1);
        if ValidUnitNumbers ~= 1
            cf_avgTraces = mean(cfUsedAllDatas);
            cf_Trace_sem = std(cfUsedAllDatas)/sqrt(ValidUnitNumbers);
            ThresholdMeanTrace = mean(cfThresholdData);
        elseif ValidUnitNumbers == 1
            cf_avgTraces = cfUsedAllDatas;
            cf_Trace_sem = zeros(size(cf_avgTraces));
            ThresholdMeanTrace = cfThresholdData;
        end
        
        FactorTracesAll = {cf_avgTraces, cf_Trace_sem, ThresholdMeanTrace, cfUsedUnitInds, ...
            numel(cfUsedUnitInds) ,mean(cfUsedUnitInds)};
        
        SigUnitDatasAll = {cfUsedAllDatas, cfThresholdData};

    StimAUCValidInfoDatas(AreaInds,:) = {FactorTracesAll, SigUnitDatasAll};
    %
    
end
%%
ExistAreaNames = SeqAreaNames;
AreaUnitNumbers = SeqAreaUnitNums;
ExistField_ClusIDs = SeqFieldClusIDs;

dataSavePath = fullfile(figSavefolder,'StimRespAUCdata_AreaWise.mat');
save(dataSavePath,'ExistAreaNames','StimAUCValidInfoDatas','AreaUnitNumbers','ExistField_ClusIDs','-v7.3')

