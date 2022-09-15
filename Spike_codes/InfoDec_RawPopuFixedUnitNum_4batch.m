
clearvars SessAreaIndexStrc ProbNPSess AreainfosAll InfoCodingStrc ChoiceInfos BTInfos

% load('Chnlocation.mat');

% load(fullfile(ksfolder,'SessAreaIndexDataAligned.mat'));
% if isempty(fieldnames(SessAreaIndexStrc.ACAv)) && isempty(fieldnames(SessAreaIndexStrc.ACAd))...
%          && isempty(fieldnames(SessAreaIndexStrc.ACA))
%     return;
% end
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);


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

CommonUnitNums = 15;

ActionInds = double(behavResults.Action_choice(:));
NMTrInds = ActionInds ~= 2;
ActTrs = ActionInds(NMTrInds);

AreainfosAll = cell(Numfieldnames,2,2);
AllTrInds = {double(behavResults.Action_choice(:)),double(behavResults.BlockType(:))};
for cType = 1 : 2
    TrTypesAll = AllTrInds{cType}; % Action_choice / BlockType
    TrTypes = TrTypesAll(NMTrInds);
    nTrs = length(TrTypes);
    for cArea = 1 : Numfieldnames
        
        cUsedAreas = NewAdd_ExistAreaNames{cArea};
        cAUnits = ExistField_ClusIDs{cArea,2};
        if length(cAUnits) < CommonUnitNums
            continue;
        elseif length(cAUnits) < CommonUnitNums+4
            RepeatNums = 200;
        else
            RepeatNums = 1000;
        end
        
        RespDataUsedMtx = NewBinnedDatas(NMTrInds,cAUnits,OutDataStrc.TriggerStartBin+(1:15));
        RespDataUsedMtx = mean(RespDataUsedMtx,3);
        cAROINum = size(RespDataUsedMtx,2);
        
%         RepeatNums = 50;
        NumCol_infos = zeros(RepeatNums,2);
        SVMLossAll = zeros(RepeatNums,2);
        TrainBaseAll = false(nTrs,1);
        for cR = 1 : RepeatNums
            SampleInds = randsample(cAROINum,CommonUnitNums);
            cc = cvpartition(nTrs,'kFold',2);
            
            FI_training_Inds = TrainBaseAll;
            FI_training_Inds(cc.test(1)) = true;
            
            Final_test_Inds = TrainBaseAll;
            Final_test_Inds(cc.test(2)) = true;
            
            [DisScore,MdPerfs,~,beta] = LDAclassifierFun(RespDataUsedMtx(:,SampleInds), TrTypes, {FI_training_Inds,Final_test_Inds});
            NumCol_infos(cR,:) = DisScore;
            SVMLossAll(cR,:) = MdPerfs;
        end
        AreainfosAll(cArea,cType,:) = {NumCol_infos, SVMLossAll};
        
    end
end

%% performing some post processing
if Numfieldnames == 1
    ChoiceInfos = (squeeze(AreainfosAll(:,1,:)))';
    BTInfos = (squeeze(AreainfosAll(:,2,:)))';
else
    ChoiceInfos = squeeze(AreainfosAll(:,1,:));
    BTInfos = squeeze(AreainfosAll(:,2,:));
end
IsAreaCaled = ~cellfun(@isempty,ChoiceInfos(:,1));
if sum(IsAreaCaled)
    ChoiceInfoAvgs = cellfun(@mean,ChoiceInfos,'un',0);
    ChoiceInfo_train = cellfun(@(x) x(1),ChoiceInfoAvgs(IsAreaCaled,:));
    ChoiceInfo_test = cellfun(@(x) x(2),ChoiceInfoAvgs(IsAreaCaled,:));
    
    
    BTInfoAvgs = cellfun(@mean,BTInfos,'un',0);
    BTInfo_train = cellfun(@(x) x(1),BTInfoAvgs(IsAreaCaled,:));
    BTInfo_test = cellfun(@(x) x(2),BTInfoAvgs(IsAreaCaled,:));

    InfoCodingStrc = struct();
    InfoCodingStrc.ExistField_ClusIDs_used = ExistField_ClusIDs(IsAreaCaled,:);
    InfoCodingStrc.CalAreaInds = IsAreaCaled;
    InfoCodingStrc.ChoiceInfo_train = ChoiceInfo_train;
    InfoCodingStrc.ChoiceInfo_test = ChoiceInfo_test;
    InfoCodingStrc.BTInfo_train = BTInfo_train;
    InfoCodingStrc.BTInfo_test = BTInfo_test;
else
    InfoCodingStrc = [];
end
%%
save(fullfile(fullsavePath,'LDAinfo_fixedSizePopuData.mat'), 'AreainfosAll', 'AllTrInds', ...
    'ExistField_ClusIDs', 'NewAdd_ExistAreaNames','AreaUnitNumbers', 'InfoCodingStrc', '-v7.3');

