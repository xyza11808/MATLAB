
ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
load(fullfile(ksfolder,'NPClassHandleSaved.mat'));

%% find target cluster inds and IDs
NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexDataNew.mat'));
NewAdd_AllfieldNames = fieldnames(NewSessAreaStrc.SessAreaIndexStrc);
NewAdd_ExistAreasInds = find(NewSessAreaStrc.SessAreaIndexStrc.UsedAbbreviations);
NewAdd_ExistAreaNames = NewAdd_AllfieldNames(NewAdd_ExistAreasInds);
if strcmpi(NewAdd_ExistAreaNames(end),'Others')
    NewAdd_ExistAreaNames(end) = [];
end
NewAdd_NumExistAreas = length(NewAdd_ExistAreaNames);

Numfieldnames = length(NewAdd_ExistAreaNames);
ExistField_ClusIDs = [];
AreaUnitNumbers = zeros(NewAdd_NumExistAreas,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs = [ExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
end

%%

ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

TaskTrigOnTimes = ProbNPSess.UsedTrigOnTime{ProbNPSess.CurrentSessInds};

BeforeFirstTrigLen = 10;
AfterLastTrigLen = 30;
TaskUsedTimeScale = [TaskTrigOnTimes(1) - BeforeFirstTrigLen,...
    TaskTrigOnTimes(end) + AfterLastTrigLen];
TotalBinSpikeLen = diff(TaskUsedTimeScale);
TaskTrigTimeAligns = TaskTrigOnTimes - TaskTrigOnTimes(1) + BeforeFirstTrigLen;

UsedClusInds = ismember(ProbNPSess.SpikeClus, ExistField_ClusIDs(:,1));
UsedSpTimes = ProbNPSess.SpikeTimes > TaskUsedTimeScale(1) & ...
    ProbNPSess.SpikeTimes < TaskUsedTimeScale(2);

UsedClusPos = ProbNPSess.SpikeClus(UsedClusInds & UsedSpTimes);
UsedSPTimes = ProbNPSess.SpikeTimes(UsedClusInds & UsedSpTimes) - ...
    TaskTrigOnTimes(1) + BeforeFirstTrigLen; % realigned to first trigger on time

%%
TimeBinSize = single(0.005);

% unique and binned cluster spikes through the whole session
UsedClusNum = size(ExistField_ClusIDs,1);
BinEdges = 0:TimeBinSize:TotalBinSpikeLen;
BinCenters = BinEdges(1:end-1) + TimeBinSize/2;
NumofSPcounts = numel(BinCenters);
BinnedSPdatas = single(zeros(NumofSPcounts,UsedClusNum));
for cClus = 1 : UsedClusNum
    cClusSPCounts = histcounts(UsedSPTimes(UsedClusPos == ExistField_ClusIDs(cClus,1)),...
        BinEdges);
    BinnedSPdatas(:,cClus) = cClusSPCounts;
end
BinnedSPdatas = BinnedSPdatas/TimeBinSize;
%% construct behavior datas
StimWin = single([-0.025,0.3]);
ChoiceWin = ([-0.1,1]);

Behav_stimOnset = single(behavResults.Time_stimOnset(:))/1000; % seconds
Behav_SessStimOnTime = Behav_stimOnset + TaskTrigTimeAligns(:);
Behav_ChoiceT = single(behavResults.Time_answer(:))/1000; % seconds
Behav_SessChoiceT = Behav_ChoiceT + TaskTrigTimeAligns(:);

Behav_Freqs = single(behavResults.Stim_toneFreq(:));
StimTypes = unique(Behav_Freqs);
StimNums = length(StimTypes);

Events_times = cell(StimNums+2,1);
Events_Win = cell(StimNums+2,1);
EventsLabelAndIndex = cell(StimNums+2,2);
for cStimNum = 1 : StimNums
    cStimInds = Behav_Freqs == StimTypes(cStimNum);
    Events_times{cStimNum} = Behav_SessStimOnTime(cStimInds);
    Events_Win{cStimNum} = StimWin;
    EventsLabelAndIndex(cStimNum,:) = {cStimNum, 1};
end

Behav_Choice = single(behavResults.Action_choice(:));
ChoiceSign = [-1,1];
for cChoice = 1 :2
    cChoiceInds = Behav_Choice == (cChoice - 1);
    Events_times{cChoice + StimNums} = Behav_SessChoiceT(cChoiceInds);
    Events_Win{cChoice + StimNums} = ChoiceWin;
    EventsLabelAndIndex(cChoice + StimNums,:) = ...
        {cChoice + StimNums, ChoiceSign(cChoice)};
end

%%
% ii = 1;
predictors = cell(2,length(Events_times));
for ii = 1 : length(Events_times)
    [ShiftMtx, EventIndex_vec] = GeneratePredictors(Events_times{ii}, ...
        Events_Win{ii}, EventsLabelAndIndex{ii,1}, ...
        EventsLabelAndIndex{ii,2}, BinCenters, TimeBinSize);
    predictors(:,ii) = {ShiftMtx, EventIndex_vec};
end

%%
PredictorMtx = cat(2,predictors{1,:});
PredictorIndexAll = uint8(cat(2,predictors{2,:}));

%%
% if nnz(BinnedSPdatas)/numel(BinnedSPdatas) < 0.2
%     BinnedSPdatas = sparse(BinnedSPdatas);
% end
BinnedSPdatas = single(BinnedSPdatas);
%%

tic
[a, b, R2] = CanonCor2all({BinnedSPdatas}, {PredictorMtx});
toc

%%
TotalTrNum = numel(TaskTrigOnBin);
TaskTrigOnBin = uint32(TaskTrigTimeAligns/TimeBinSize);
Temporal2trialInds = uint16(zeros(size(BinnedSPdatas,1),1));
Temporal2trialInds(1:TaskTrigOnBin(2)-1) = 1;
Temporal2trialInds(TaskTrigOnBin(end):end) = TotalTrNum;
for cTr = 2 : numel(TaskTrigOnBin)-1
    Temporal2trialInds(TaskTrigOnBin(cTr):TaskTrigOnBin(cTr+1)-1) = cTr;
end

%%
UsedNodesNum = 20;

nfold = 10;
DatafoldsInds = cvpartition(TotalTrNum,'KFold',nfold);
TrIndsVec = 1:TotalTrNum;

opts.alpha = 0.5;
opts = glmnetSet(opts);
opts.lambda = linspace(1e-5,120,100);
%%
for cf = 1 : nfold
    cTrainInds = DatafoldsInds.training(cf);
    cTestInds = ~cTrainInds;
    
    TrainTrNums = TrIndsVec(cTrainInds);
    TestTrNums = TrIndsVec(cTestInds);
    
    TrainTr2Index = ismember(Temporal2trialInds,TrainTrNums);
    TestTr2Index = ismember(Temporal2trialInds,TestTrNums);
    
    TrainData_predictor = PredictorMtx(TrainTr2Index,:);
    TrainData_y = BinnedSPdatas(TrainTr2Index,:);
    
    fit = glmnet(TrainData_predictor*b(:,1:UsedNodesNum),TrainData_y,'gaussian',opts);
    fitCoefAlls = glmnetCoef(fit, 0.5);
    
    fitK = (fitCoefAlls(2:end))';
    
    TestData_predictor = PredictorMtx(TestTr2Index,:);
    PredData_y = TestData_predictor * (b(:,1:UsedNodesNum) * fitK(:,1:UsedNodesNum)');

    
    
end



