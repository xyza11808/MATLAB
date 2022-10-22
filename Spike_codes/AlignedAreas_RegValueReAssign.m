% cclr
% ksfolder = pwd;


clearvars RegressorInfosCell rrr_RegressorInfosCell FullRegressorInfosCell NewSessAreaStrc AreaUnitNumbers 

%%

NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));

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
        NewAdd_ExistAreaNames{cA}}; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    
end

%%
OldRegResultFile = fullfile(ksfolder,'Regressor_ANA','RegressorDataAligned.mat');
OldRegResultStrc = load(OldRegResultFile);

%%
NewExistField_ClusIDs = [cat(1,ExistField_ClusIDs{:,1}),cat(1,ExistField_ClusIDs{:,2})];
NumofUnits = size(NewExistField_ClusIDs,1);
RegressorInfosCell = cell(NumofUnits,3);
FullRegressorInfosCell = cell(NumofUnits,3);
rrr_RegressorInfosCell = cell(NumofUnits,3);
IsUnitNeedProcessed = zeros(NumofUnits,2);
for cU = 1 : NumofUnits
    cU_2Old_inds = find(OldRegResultStrc.NewExistField_ClusIDs(:,1) == NewExistField_ClusIDs(cU,1));
    if numel(cU_2Old_inds) ~= 1
        IsUnitNeedProcessed(cU,1) = 1;
        IsUnitNeedProcessed(cU,2) = nan;
        continue;
    end
    IsUnitNeedProcessed(cU,2) = cU_2Old_inds;
    RegressorInfosCell(cU,:) = OldRegResultStrc.RegressorInfosCell(cU_2Old_inds,:);
    rrr_RegressorInfosCell(cU,:) = OldRegResultStrc.rrr_RegressorInfosCell(cU_2Old_inds,:);
    FullRegressorInfosCell(cU,:) = OldRegResultStrc.FullRegressorInfosCell(cU_2Old_inds,:);
end

% ExistField_ClusIDs = NewExistField_ClusIDs;
if sum(IsUnitNeedProcessed(:,1))
    fprintf('Session: %s\nhave some units do not have existed calculations.\n',ksfolder);
end
%%
EventDescripStrsFirst = OldRegResultStrc.EventDescripStrsFirst;
EventDescripStrsFull = OldRegResultStrc.EventDescripStrsFull;
FullEvents_predictor = OldRegResultStrc.FullEvents_predictor;
TaskEvents_predictor = OldRegResultStrc.TaskEvents_predictor;

dataSaveNames = fullfile(ksfolder,'Regressor_ANA','RegressorDataAligned.mat');
save(dataSaveNames, 'RegressorInfosCell',...
    'NewExistField_ClusIDs', 'NewAdd_ExistAreaNames','rrr_RegressorInfosCell', 'AreaUnitNumbers',...
    'FullRegressorInfosCell','EventDescripStrsFull','EventDescripStrsFirst','TaskEvents_predictor',...
    'FullEvents_predictor','IsUnitNeedProcessed','-v7.3');




