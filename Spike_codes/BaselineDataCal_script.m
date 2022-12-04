
clearvars behavResults OutDataStrc
load(fullfile(ksfolder,'NewClassHandle2.mat'),'behavResults');
load(fullfile(ksfolder,'SessPSTHdataSaveNew2.mat'),'OutDataStrc');

NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);

OnsetBin = OutDataStrc.TriggerStartBin - 1;
BaselineResp = mean(NewBinnedDatas(:,:,1:OnsetBin),3);

BehavTrInfo = struct();
BehavTrInfo.ActionChoices = double(behavResults.Action_choice(:));
BehavTrInfo.TrFreqs = double(behavResults.Stim_toneFreq(:));
BehavTrInfo.TrBlockTypes = double(behavResults.BlockType(:));
BehavTrInfo.TrRewardTime = double(behavResults.Time_reward(:));

BlockSectionInfo = Bev2blockinfoFun(behavResults);

%% find target cluster inds and IDs

NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNewAlign2.mat'));
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
UnitAreaIndex = zeros(Numfieldnames, 1);
yBase = 0;
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs(cA,:) = {cA_Clus_IDs,cA_clus_inds,numel(cA_clus_inds) > 5,...
        repmat(NewAdd_ExistAreaNames(cA),numel(cA_clus_inds),1)}; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    UnitAreaIndex((yBase+1):(AreaUnitNumbers(cA)+yBase)) = cA;
    yBase = yBase + AreaUnitNumbers(cA);
end
UsedAreaUnitInds = cat(1,ExistField_ClusIDs{:,2});
AllUnitAreaStrs = NewAdd_ExistAreaNames(UnitAreaIndex);


%%
UsedBlockMaxTr = BlockSectionInfo.BlockTrScales(end,2);
UsedBlockTrs = 1:UsedBlockMaxTr;

UsedTrChoices = BehavTrInfo.ActionChoices(UsedBlockTrs);
UsedTrFreqs = BehavTrInfo.TrFreqs(UsedBlockTrs);
UsedTrBlockTypes = BehavTrInfo.TrBlockTypes(UsedBlockTrs);
UsedTrReTime = BehavTrInfo.TrRewardTime(UsedBlockTrs);
UsedTrIsRevTrials = ismember(UsedTrFreqs, BlockSectionInfo.BlockFreqTypes(logical(BlockSectionInfo.IsFreq_asReverse)));
BaselineResp_zs = zscore(BaselineResp(:,UsedAreaUnitInds));

BlockSecIndsDiff = [1;abs(diff(UsedTrBlockTypes(:)))];
BlockIndexVec = cumsum(BlockSecIndsDiff);
TypeStrings = {'CorrRevTrs','CorrNonRevTrs','ErroRevTrs','ErroNonTrs'};
BlockTypeResps = zeros(size(BaselineResp_zs,2),4,BlockSectionInfo.NumBlocks);
BlockTrBaseAll = cell(BlockSectionInfo.NumBlocks, 2);
for cB = 1 : BlockSectionInfo.NumBlocks
    cBInds = BlockIndexVec == cB;
    cB_Choices = UsedTrChoices(cBInds);
    cB_TrReTime = UsedTrReTime(cBInds);
    cB_TrIsRev = UsedTrIsRevTrials(cBInds);
    cB_BaseRespData = BaselineResp_zs(cBInds,:);
    cB_RawBaseData = BaselineResp(cBInds,UsedAreaUnitInds);
    
    BlockTrBaseAll(cB,:) = {cB_BaseRespData(cB_Choices ~= 2,:), cB_RawBaseData(cB_Choices ~= 2,:)};
    
    cB_TrCorrANDRevInds = cB_TrReTime > 0 & cB_TrIsRev & cB_Choices ~= 2;
    cB_TrCorrANDRev_base = mean(cB_BaseRespData(cB_TrCorrANDRevInds,:));
    
    cB_TrCorrANDNonRevInds = cB_TrReTime > 0 & ~cB_TrIsRev & cB_Choices ~= 2;
    cB_TrCorrANDNonRev_base = mean(cB_BaseRespData(cB_TrCorrANDNonRevInds,:));
    
    cB_TrErroANDRevInds = cB_TrReTime == 0 & cB_TrIsRev & cB_Choices ~= 2;
    cB_TrErroANDRev_base = mean(cB_BaseRespData(cB_TrErroANDRevInds,:));
    
    cB_TrErroANDNonRevInds = cB_TrReTime == 0 & ~cB_TrIsRev & cB_Choices ~= 2;
    cB_TrErroANDNonRev_base = mean(cB_BaseRespData(cB_TrErroANDNonRevInds,:));
    
    BlockTypeResps(:,1,cB) = cB_TrCorrANDRev_base;
    BlockTypeResps(:,2,cB) = cB_TrCorrANDNonRev_base;
    BlockTypeResps(:,3,cB) = cB_TrErroANDRev_base;
    BlockTypeResps(:,4,cB) = cB_TrErroANDNonRev_base;
end

% average same block baselines together to generate same dataset across
% sessions
LowBlockInds = BlockSectionInfo.BlockTypes == 0;
if sum(LowBlockInds) == 1
    LowBlockBaseData = BlockTypeResps(:,:,LowBlockInds);
else
    LowBlockBaseData = mean(BlockTypeResps(:,:,LowBlockInds),3,'omitnan');
end

HighBlockInds = BlockSectionInfo.BlockTypes == 1;
if sum(HighBlockInds) == 1
    HighBlockBaseData = BlockTypeResps(:,:,HighBlockInds);
else
    HighBlockBaseData = mean(BlockTypeResps(:,:,HighBlockInds),3,'omitnan');
end

% LowBlockInds = BlockSectionInfo.BlockTypes == 0;
LowBlockAllTrBaseData = cat(1,BlockTrBaseAll{LowBlockInds,2});
HighBlockAllTrBaseData = cat(1,BlockTrBaseAll{HighBlockInds,2});
LHAllTrBaseData = {LowBlockAllTrBaseData, HighBlockAllTrBaseData};
%%

saveMATfile = fullfile(ksfolder,'BaselineRespDataNew2.mat');
save(saveMATfile,'BaselineResp','BlockSectionInfo','BehavTrInfo','BlockTypeResps','TypeStrings',...
    'LowBlockBaseData','HighBlockBaseData','AllUnitAreaStrs','NewAdd_ExistAreaNames','BlockTrBaseAll','LHAllTrBaseData','-v7.3');




