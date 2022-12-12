clearvars TypeRespCalResults TypeRespCalAvgs TypeAreaPairInfo OutDataStrc ExistField_ClusIDs

% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
% ksfolder = pwd;
load(fullfile(ksfolder,'NewClassHandle2.mat'),'behavResults');
% ProbNPSess = NewNPClusHandle;
% clearvars NewNPClusHandle
% ProbNPSess.SpikeTimes = double(ProbNPSess.SpikeTimeSample)/30000;
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
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs(cA,:) = {cA_Clus_IDs,cA_clus_inds,numel(cA_clus_inds) > 5,...
        NewAdd_ExistAreaNames{cA}}; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    
end

USedAreas = cell2mat(ExistField_ClusIDs(:,3)) < 1;
if sum(USedAreas)
    ExistField_ClusIDs(USedAreas,:) = [];
    AreaUnitNumbers(USedAreas) = [];
    Numfieldnames = Numfieldnames - sum(USedAreas);
    NewAdd_ExistAreaNames(USedAreas) = [];
end
%%

% ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
% 
% OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[300 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
Savepath = fullfile(ksfolder,'jeccAnA');
dataSavePath = fullfile(Savepath,'CCA_TypeSubCal.mat');
load(dataSavePath,'OutDataStrc');
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
% SMBinDataMtxRaw = SMBinDataMtx;
% clearvars ProbNPSess
BlockSectionInfo = Bev2blockinfoFun(behavResults);

%% performing trialtype average subtraction for each frequency types
AllTrFreqs = double(behavResults.Stim_toneFreq(:));
AllTrBlocks = double(behavResults.BlockType(:));
AllTrChoices = double(behavResults.Action_choice(:));
NMTrInds = AllTrChoices(1:sum(BlockSectionInfo.BlockLens)) ~= 2;
NMTrFreqs = AllTrFreqs(NMTrInds);
NMBlockTypes = AllTrBlocks(NMTrInds);
NMBlockBoundVec = [1;abs(diff(NMBlockTypes))];
NMBlockBoundIndex = cumsum(NMBlockBoundVec);
NMActionChoice = AllTrChoices(NMTrInds);
NMBinDatas = NewBinnedDatas(NMTrInds,:,:);

% subtracted frequency averaged mean for each frequency types
FreqTypes = unique(NMTrFreqs);
NumFreqs = length(FreqTypes);
FreqAvgSubDatas = zeros(size(NewBinnedDatas));

for cf = 1 : NumFreqs
    cfInds = NMTrFreqs == FreqTypes(cf);
    cfData = NMBinDatas(cfInds,:,:);
    cfAvgData = mean(cfData);
    cfSubData = cfData - repmat(cfAvgData,sum(cfInds),1,1);
    FreqAvgSubDatas(cfInds,:,:) = cfSubData;
end

% select calculation time range
BeforeWin1 = round([-1 0]/OutDataStrc.USedbin(2));
AfterWin1 = round([0 2]/OutDataStrc.USedbin(2));
ExpandedRange = round(1/OutDataStrc.USedbin(2)); % extra time window used for validation calculation

OnsetBin = OutDataStrc.TriggerStartBin;
BeforeWinData = FreqAvgSubDatas(:,:,(OnsetBin+BeforeWin1(1)):(OnsetBin+BeforeWin1(2)-1));
BaseValidExpData = FreqAvgSubDatas(:,:,(OnsetBin+BeforeWin1(1)):(OnsetBin+BeforeWin1(2)+ExpandedRange-1));

AfterWinData = FreqAvgSubDatas(:,:,(OnsetBin+AfterWin1(1)):(OnsetBin+AfterWin1(2)-1));
AfterValidExpData = FreqAvgSubDatas(:,:,(OnsetBin+AfterWin1(1)-ExpandedRange):(OnsetBin+AfterWin1(2)-1));

BlockVarDatas = {BeforeWinData,BaseValidExpData,AfterWinData,AfterValidExpData};
%% #############################################################
% reperforming trial type avg subtraction using block wise manner

% NMTrFreqs = AllTrFreqs(NMTrInds);
% NMBlockTypes = AllTrBlocks(NMTrInds);
% NMBlockBoundVec = [1;abs(diff(NMBlockTypes))];
% NMBlockBoundIndex = cumsum(NMBlockBoundVec);
% NMActionChoice = AllTrChoices(NMTrInds);
% NMBinDatas = NewBinnedDatas(NMTrInds,:,:);

% subtracted frequency averaged mean for each frequency types
% FreqTypes = unique(NMTrFreqs);
% NumFreqs = length(FreqTypes);
BlockTypes = unique(NMBlockBoundIndex);
NumBlockTypes = length(BlockTypes);
FreqAvgSubDatas2 = zeros(size(NewBinnedDatas));
for cB = 1 : NumBlockTypes
    for cf = 1 : NumFreqs
        cfInds = NMTrFreqs == FreqTypes(cf) & NMBlockBoundIndex == cB;
        cfData = NMBinDatas(cfInds,:,:);
        cfAvgData = mean(cfData);
        cfSubData = cfData - repmat(cfAvgData,sum(cfInds),1,1);
        FreqAvgSubDatas2(cfInds,:,:) = cfSubData;
    end
end
% select calculation time range
BeforeWin1 = round([-1 0]/OutDataStrc.USedbin(2));
AfterWin1 = round([0 2]/OutDataStrc.USedbin(2));
ExpandedRange = round(1/OutDataStrc.USedbin(2)); % extra time window used for validation calculation

OnsetBin = OutDataStrc.TriggerStartBin;
BeforeWinData2 = FreqAvgSubDatas2(:,:,(OnsetBin+BeforeWin1(1)):(OnsetBin+BeforeWin1(2)-1));
BaseValidExpData2 = FreqAvgSubDatas2(:,:,(OnsetBin+BeforeWin1(1)):(OnsetBin+BeforeWin1(2)+ExpandedRange-1));

AfterWinData2 = FreqAvgSubDatas2(:,:,(OnsetBin+AfterWin1(1)):(OnsetBin+AfterWin1(2)-1));
AfterValidExpData2 = FreqAvgSubDatas2(:,:,(OnsetBin+AfterWin1(1)-ExpandedRange):(OnsetBin+AfterWin1(2)-1));

AllTimeWin = {BeforeWin1, AfterWin1, ExpandedRange, OnsetBin};
TrialVarDatas = {BeforeWinData2,BaseValidExpData2,AfterWinData2,AfterValidExpData2};

%%

DataSavefile = fullfile(Savepath,'CCACalDatas.mat');
save(DataSavefile,'BlockVarDatas','TrialVarDatas','AllTimeWin','ExistField_ClusIDs',...
    'NewAdd_ExistAreaNames','AreaUnitNumbers','-v7.3');



