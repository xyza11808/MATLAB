
clearvars TypeRespCalResults TypeRespCalAvgs TypeAreaPairInfo OutDataStrc ExistField_ClusIDs

Savepath = fullfile(ksfolder,'jeccAnA');
if ~isfolder(Savepath)
    mkdir(Savepath);
end
dataSavePath = fullfile(Savepath,'CCA_TypeSubCal.mat');
if exist(dataSavePath,'file')
    return;
end
% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
% ksfolder = pwd;
load(fullfile(ksfolder,'NewClassHandle2.mat'),'behavResults');
% ProbNPSess = NewNPClusHandle;
% clearvars NewNPClusHandle
% ProbNPSess.SpikeTimes = double(ProbNPSess.SpikeTimeSample)/30000;
%% find target cluster inds and IDs
NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNewAlign.mat'));
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
% Savepath = fullfile(ksfolder,'jeccAnA');
% dataSavePath = fullfile(Savepath,'CCA_TypeSubCal.mat');
load(fullfile(ksfolder,'BlockTypeScores','RepeatBTScores.mat'),'OutDataStrc');
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

TrialVarDatas = {BeforeWinData2,BaseValidExpData2,AfterWinData2,AfterValidExpData2};

AllTimeWin = {BeforeWin1, AfterWin1, ExpandedRange, OnsetBin};
%% loop to calculate for each area pair
NumCalculations = (Numfieldnames-1)*Numfieldnames/2;
TypeRespCalResults = cell(NumCalculations,4);
TypeRespCalAvgs = cell(NumCalculations,4);
TypeAreaPairInfo = cell(NumCalculations,3);
ks = 1;
for cAr = 1 : Numfieldnames
    for cAr2 = cAr+1 : Numfieldnames
        
        BaseRepeatCorrSum = crossValCCA(BeforeWinData,BaseValidExpData,{ExistField_ClusIDs{cAr,2},ExistField_ClusIDs{cAr2,2}},0.5);
        
        % Train data correlation
        BaseTrainCorrs = cat(1,BaseRepeatCorrSum{:,3});
        % test data correlation
        BaseTestCorrs = cellfun(@diag,BaseRepeatCorrSum(:,4),'un',0);
        BaseTestCorrs = cat(2,BaseTestCorrs{:});
        % valid data correlation
        BaseValidTimeCorr = cat(3,BaseRepeatCorrSum{:,5});
        BaseValidTimeCorrAvg = mean(BaseValidTimeCorr,3);
        BaseValidTimeCorrSTD = std(BaseValidTimeCorr,[],3);
        
        % shuf threshold for thres calculation
        BaseShufCorrs = cat(2,BaseRepeatCorrSum{:,6});
        BaseShufCorrThres = prctile(BaseShufCorrs,95,2);
        
        BaseTrainCorrAvg = dataSEMmean(BaseTrainCorrs,'Trace');
        BaseTestCorrsAvg = dataSEMmean(BaseTestCorrs','Trace');
        
        BaseAvgs = {BaseTrainCorrAvg, BaseTestCorrsAvg, BaseValidTimeCorrAvg,BaseValidTimeCorrSTD,BaseShufCorrThres};
        % after Stim calculation
        AfRepeatCorrSum = crossValCCA(AfterWinData,AfterValidExpData,{ExistField_ClusIDs{cAr,2},ExistField_ClusIDs{cAr2,2}},0.5);
        
        % Train data correlation
        AfterTrainCorrs = cat(1,AfRepeatCorrSum{:,3});
        % test data correlation
        AfterTestCorrs = cellfun(@diag,AfRepeatCorrSum(:,4),'un',0);
        AfterTestCorrs = cat(2,AfterTestCorrs{:});
        % valid data correlation
        AfterValidTimeCorr = cat(3,AfRepeatCorrSum{:,5});
        AfterValidTimeCorrAvg = mean(AfterValidTimeCorr,3);
        AfterValidTimeCorrSTD = std(AfterValidTimeCorr,[],3);
        
        % shuf threshold for thres calculation
        AfterShufCorrs = cat(2,AfRepeatCorrSum{:,6});
        AfterShufCorrThres = prctile(AfterShufCorrs,95,2);
        
        AfterTrainCorrAvg = dataSEMmean(AfterTrainCorrs,'Trace');
        AfterTestCorrsAvg = dataSEMmean(AfterTestCorrs','Trace');
        
        AfterAvgs = {AfterTrainCorrAvg, AfterTestCorrsAvg, AfterValidTimeCorrAvg, AfterValidTimeCorrSTD, AfterShufCorrThres};
        % Recalculate for block-type-wise trial type subtraction datas
        Base2RepeatCorrSum = crossValCCA(BeforeWinData2,BaseValidExpData2,{ExistField_ClusIDs{cAr,2},ExistField_ClusIDs{cAr2,2}},0.5);
        
        % Train data correlation
        Base2TrainCorrs = cat(1,Base2RepeatCorrSum{:,3});
        % test data correlation
        Base2TestCorrs = cellfun(@diag,Base2RepeatCorrSum(:,4),'un',0);
        Base2TestCorrs = cat(2,Base2TestCorrs{:});
        % valid data correlation
        Base2ValidTimeCorr = cat(3,Base2RepeatCorrSum{:,5});
        Base2ValidTimeCorrAvg = mean(Base2ValidTimeCorr,3);
        Base2ValidTimeCorrSTD = std(Base2ValidTimeCorr,[],3);
        
        % shuf threshold for thres calculation
        Base2ShufCorrs = cat(2,Base2RepeatCorrSum{:,6});
        Base2ShufCorrThres = prctile(Base2ShufCorrs,95,2);
        
        Base2TrainCorrAvg = dataSEMmean(Base2TrainCorrs,'Trace');
        Base2TestCorrsAvg = dataSEMmean(Base2TestCorrs','Trace');
        Base2Avgs = {Base2TrainCorrAvg, Base2TestCorrsAvg, Base2ValidTimeCorrAvg,Base2ValidTimeCorrSTD,Base2ShufCorrThres};
        % after Stim calculation
        Af2RepeatCorrSum = crossValCCA(AfterWinData2,AfterValidExpData2,{ExistField_ClusIDs{cAr,2},ExistField_ClusIDs{cAr2,2}},0.5);
        
        % Train data correlation
        After2TrainCorrs = cat(1,Af2RepeatCorrSum{:,3});
        % test data correlation
        After2TestCorrs = cellfun(@diag,Af2RepeatCorrSum(:,4),'un',0);
        After2TestCorrs = cat(2,After2TestCorrs{:});
        % valid data correlation
        After2ValidTimeCorr = cat(3,Af2RepeatCorrSum{:,5});
        After2ValidTimeCorrAvg = mean(After2ValidTimeCorr,3);
        After2ValidTimeCorrSTD = std(After2ValidTimeCorr,[],3);
        
        % shuf threshold for thres calculation
        After2ShufCorrs = cat(2,Af2RepeatCorrSum{:,6});
        After2ShufCorrThres = prctile(After2ShufCorrs,95,2);
        
        After2TrainCorrAvg = dataSEMmean(After2TrainCorrs,'Trace');
        After2TestCorrsAvg = dataSEMmean(After2TestCorrs','Trace');
        
        After2Avgs = {After2TrainCorrAvg, After2TestCorrsAvg, After2ValidTimeCorrAvg, After2ValidTimeCorrSTD, After2ShufCorrThres};
        
        
        TypeRespCalResults(ks,:) = {BaseRepeatCorrSum, AfRepeatCorrSum, Base2RepeatCorrSum, Af2RepeatCorrSum};
        TypeRespCalAvgs(ks,:) = {BaseAvgs, AfterAvgs, Base2Avgs, After2Avgs};
        TypeAreaPairInfo(ks,:) = {NewAdd_ExistAreaNames{cAr},NewAdd_ExistAreaNames{cAr2},[numel(ExistField_ClusIDs{cAr,2}),numel(ExistField_ClusIDs{cAr2,2})]};
        
        ks = ks + 1;
    end
end
%%


save(dataSavePath,'TypeRespCalResults','TypeRespCalAvgs','OutDataStrc','TypeAreaPairInfo',...
    'ExistField_ClusIDs','NewAdd_ExistAreaNames','AllTimeWin','TrialVarDatas','BlockVarDatas','AreaUnitNumbers','-v7.3');
%%
% CalTimeBinNums = [min(OutDataStrc.BinCenters),max(OutDataStrc.BinCenters)];
% StimOnBinTime = 0; %OutDataStrc.BinCenters(OutDataStrc.TriggerStartBin);
% cCalInds = 10;
% cCalIndsPopuSize = CalResults{cCalInds,5};
%
% figure;
% hold on
%
% imagesc(OutDataStrc.BinCenters,OutDataStrc.BinCenters, CalResults{cCalInds,1});
% line(CalTimeBinNums,CalTimeBinNums,'Color','w','linewidth',1.8);
% line(CalTimeBinNums,[StimOnBinTime StimOnBinTime],'Color','m','linewidth',1.5);
% line([StimOnBinTime StimOnBinTime],CalTimeBinNums,'Color','m','linewidth',1.5);
% xlabel(['Time(s) ',CalResults{cCalInds,3},num2str(cCalIndsPopuSize(1),', n = %d')]);
% ylabel(['Time(s) ',CalResults{cCalInds,4},num2str(cCalIndsPopuSize(2),', n = %d')]);


