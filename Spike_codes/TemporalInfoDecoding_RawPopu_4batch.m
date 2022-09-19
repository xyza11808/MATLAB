
clearvars SessAreaIndexStrc AreaTypeDecTrainsets  AreainfosAll

% load('Chnlocation.mat');

% load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
% if isempty(fieldnames(SessAreaIndexStrc.ACAv)) && isempty(fieldnames(SessAreaIndexStrc.ACAd))...
%          && isempty(fieldnames(SessAreaIndexStrc.ACA))
%     return;
% end
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 4],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
NumFrameBins = size(NewBinnedDatas,3);

%% find target cluster inds and IDs
% ksfolder = pwd;

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
%
USedAreas = cell2mat(ExistField_ClusIDs(:,3)) < 1;
if sum(USedAreas)
    ExistField_ClusIDs(USedAreas,:) = [];
    AreaUnitNumbers(USedAreas) = [];
    Numfieldnames = Numfieldnames - sum(USedAreas);
    NewAdd_ExistAreaNames(USedAreas) = [];
end

BlockTypesAll = double(behavResults.BlockType(:));
%%
SavedFolderPathName = 'ChoiceANDBT_LDAinfo_ana';

fullsavePath = fullfile(ksfolder, SavedFolderPathName);
% if isfolder(fullsavePath)
%     rmdir(fullsavePath,'s');
% end
% 
% mkdir(fullsavePath);
if ~isfolder(fullsavePath)
    mkdir(fullsavePath);
end

ActionInds = double(behavResults.Action_choice(:));
NMTrInds = ActionInds ~= 2;
ActTrs = ActionInds(NMTrInds);
NumNMTrs = sum(NMTrInds);

ChoiceRespData = mean(NewBinnedDatas(NMTrInds,:,OutDataStrc.TriggerStartBin+(1:15)),3);
BaselineData = mean(NewBinnedDatas(NMTrInds,:,1:(OutDataStrc.TriggerStartBin-1)),3);

AreainfosAll = cell(Numfieldnames,2);
ShufAreainfosAll = cell(Numfieldnames,2);
AreaTypeDecTrainsets = cell(Numfieldnames,2,4);
AllTrInds = {double(behavResults.Action_choice(:)),double(behavResults.BlockType(:))};
for cType = 1 : 2
    TrTypesAll = AllTrInds{cType}; % Action_choice / BlockType
    TrTypes = TrTypesAll(NMTrInds);
    nTrs = length(TrTypes);
    for cArea = 1 : Numfieldnames
        
        cUsedAreas = NewAdd_ExistAreaNames{cArea};
        cAUnitInds = NewSessAreaStrc.SessAreaIndexStrc.(cUsedAreas).MatchedUnitInds;
        
        cAUnits = ExistField_ClusIDs{cArea,2};
        
        if cType == 1
            CaledRespData = ChoiceRespData;
        elseif cType == 2
            CaledRespData = BaselineData;
        end
        
        Repeat = 200;
        TypeRepeatDatas = cell(Repeat,4);
        TrainBaseAll = false(nTrs,1);
        for cR = 1 : Repeat
            cc = cvpartition(nTrs,'kFold',2);
            FI_training_Inds = TrainBaseAll;
            FI_training_Inds(cc.test(1)) = true;

            Final_test_Inds = TrainBaseAll;
            Final_test_Inds(cc.test(2)) = true;
            % calculate type specific kernal
            
            [DisScore,MdPerfs,SampleScore,beta] = LDAclassifierFun(CaledRespData(:,cAUnits), ...
                 TrTypes, {FI_training_Inds,Final_test_Inds});
            TypeRepeatDatas(cR,:) = {DisScore,MdPerfs,SampleScore{3},beta'};
        end
        TypeDsqr_Mtx = cat(1,TypeRepeatDatas{:,1});
        TypeDsqr_Avg = mean(TypeDsqr_Mtx);
        TypePref_Mtx = cat(1,TypeRepeatDatas{:,2});
        TypePref_Avg = mean(TypePref_Mtx);
        TypeBoundScore = mean(cat(1,TypeRepeatDatas{:,3}));
        Type_beta_mtx = cat(1,TypeRepeatDatas{:,4});
        Type_beta_Avg = (mean(Type_beta_mtx))';
        
        AreaTypeDecTrainsets(cArea,cType,:) = {TypeDsqr_Avg,TypePref_Avg,TypeBoundScore,Type_beta_Avg};
        
        ShufRepeat = 1000;
        FrameBin_infos = zeros(2,NumFrameBins);
        ShufFrameBin_infos = zeros(NumFrameBins,ShufRepeat,2);
        for cframe = 1 : NumFrameBins
            RespDataUsedMtx = NewBinnedDatas(NMTrInds,cAUnits,cframe);
            
            [cType_dsqr,cType_perfs,~] = LDAclassifierFun_Score(RespDataUsedMtx, TrTypes, Type_beta_Avg);
            FrameBin_infos(:,cframe) = [cType_dsqr,cType_perfs];
            rng('shuffle'); %NumNMTrs
%             cRshufData = zeros(ShufRepeat,2);
            for ccR = 1 : ShufRepeat
                [shuf_dsqr,shuf_perfs,~] = LDAclassifierFun_Score(RespDataUsedMtx, TrTypes(randperm(NumNMTrs)), Type_beta_Avg);
                ShufFrameBin_infos(cframe,ccR,:) = [shuf_dsqr,shuf_perfs];
            end
            
        end
        AreainfosAll(cArea,cType) = {FrameBin_infos};
        ShufAreainfosAll(cArea,cType) = {ShufFrameBin_infos};
    end
end
%%
save(fullfile(fullsavePath,'LDAinfo_temporalinfo_Data.mat'), 'AreainfosAll', 'AllTrInds', ...
    'ExistField_ClusIDs', 'NewAdd_ExistAreaNames','AreaUnitNumbers','OutDataStrc', 'AreaTypeDecTrainsets','ShufAreainfosAll','-v7.3');

