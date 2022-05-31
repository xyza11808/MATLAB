
% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
ksfolder = pwd;
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

BeforeFirstTrigLen = 10; % seconds
AfterLastTrigLen = 30; % seconds
TaskUsedTimeScale = [TaskTrigOnTimes(1) - BeforeFirstTrigLen,...
    TaskTrigOnTimes(end) + AfterLastTrigLen];
TotalBinSpikeLen = diff(TaskUsedTimeScale);
TaskTrigTimeAligns = TaskTrigOnTimes - TaskTrigOnTimes(1) + BeforeFirstTrigLen;
TotalTrialNum = length(TaskTrigTimeAligns); % number of trials in total

UsedClusInds = ismember(ProbNPSess.SpikeClus, ExistField_ClusIDs(:,1));
UsedSpTimes = ProbNPSess.SpikeTimes > TaskUsedTimeScale(1) & ...
    ProbNPSess.SpikeTimes < TaskUsedTimeScale(2);

UsedClusPos = ProbNPSess.SpikeClus(UsedClusInds & UsedSpTimes);
UsedSPTimes = ProbNPSess.SpikeTimes(UsedClusInds & UsedSpTimes) - ...
    TaskTrigOnTimes(1) + BeforeFirstTrigLen; % realigned to first trigger on time
clearvars ProbNPSess
%%
TimeBinSize = single(0.02);

% unique and binned cluster spikes through the whole session
UsedClusNum = size(ExistField_ClusIDs,1);
BinEdges = 0:TimeBinSize:TotalBinSpikeLen;
BinCenters = BinEdges(1:end-1) + TimeBinSize/2;
NumofSPcounts = numel(BinCenters);
BinnedSPdatas = zeros(UsedClusNum,NumofSPcounts,'single');
for cClus = 1 : UsedClusNum
    cClusSPCounts = histcounts(UsedSPTimes(UsedClusPos == ExistField_ClusIDs(cClus,1)),...
        BinEdges);
    BinnedSPdatas(cClus, :) = cClusSPCounts;
end
BinnedSPdatas = BinnedSPdatas./nanstd(BinnedSPdatas,[],2);

%% construct behavior datas
StimWin = single([-0.04,0.3]);
ChoiceWin = ([-0.1,1]);

Behav_stimOnset = single(behavResults.Time_stimOnset(:))/1000; % seconds
Behav_SessStimOnTime = Behav_stimOnset + TaskTrigTimeAligns(:);
Behav_Freqs = single(behavResults.Stim_toneFreq(:));
StimTypes = unique(Behav_Freqs);
StimNums = length(StimTypes);
StimEventTimeBin = zeros(StimNums,NumofSPcounts,'single');
for cStimNum = 1 : StimNums
    cStimInds = Behav_Freqs == StimTypes(cStimNum);
    StimEventTimeBin(cStimNum,:) = histcounts(Behav_SessStimOnTime(cStimInds),...
        BinEdges);
end

% choice event times
Behav_ChoiceT = single(behavResults.Time_answer(:))/1000; % seconds
Behav_SessChoiceT = Behav_ChoiceT + TaskTrigTimeAligns(:);

Behav_Choice = single(behavResults.Action_choice(:));
ChoiceEventTimeBin = zeros(2,NumofSPcounts,'single');
for cChoice = 1 : 2
    cChoiceInds = Behav_Choice == (cChoice - 1);
    ChoiceEventTimeBin(cChoice,:) = histcounts(Behav_SessChoiceT(cChoiceInds),...
        BinEdges);
end

% reward event times
Behav_RewardT = single(behavResults.Time_reward(:))/1000; % seconds
Behav_RewardTRaw = Behav_RewardT;
Behav_RewardT(Behav_RewardT == 0 & Behav_Choice ~= 2) = ...
    Behav_ChoiceT(Behav_RewardT == 0 & Behav_Choice ~= 2)+TimeBinSize; % error trials using choice time indicate reward omission time
Behav_SessReT = Behav_RewardT + TaskTrigTimeAligns(:);

ReEventTimeBin = zeros(2, NumofSPcounts,'single');
ReEventTimeBin(1,:) = histcounts(Behav_RewardT(Behav_RewardTRaw > 0),BinEdges);
ReEventTimeBin(2,:) = histcounts(Behav_RewardT(Behav_RewardTRaw == 0),BinEdges);

BlockSectionInfo = Bev2blockinfoFun(behavResults);
% TotalTrialNum
BTDataBin = zeros(2, NumofSPcounts,'single');
for cB = 1 : length(BlockSectionInfo.BlockTypes)
    cBlockTrialInds = BlockSectionInfo.BlockTrScales(cB,:);
    if cB == 1
        cB_startTrTime = 0;
    else
        cB_startTrTime = TaskTrigTimeAligns(cBlockTrialInds(1));
    end
    cB_endTrTime = TaskTrigTimeAligns(cBlockTrialInds(2)+1) - TimeBinSize;
    BTDataBin(1,BinEdges(1:end-1) >= cB_startTrTime & BinEdges(1:end-1) < cB_endTrTime) = ...
        BlockSectionInfo.BlockTypes(cB);
end
if BlockSectionInfo.BlockTrScales(end,2) < TotalTrialNum
    % extra block trial exists, but not longer longer enough to be included
    % as another block
    UsedBlockEndInds = TaskTrigTimeAligns(BlockSectionInfo.BlockTrScales(end,2)+1);
    BTDataBin(1,BinEdges(1:end-1) > UsedBlockEndInds) = 1 - BlockSectionInfo.BlockTypes(end);
end
BTDataBin(2,:) = 1 - BTDataBin(1,:);
% %%
% % ii = 1;
% predictors = cell(2,length(Events_times));
% for ii = 1 : length(Events_times)
%     [ShiftMtx, EventIndex_vec] = GeneratePredictors(Events_times{ii}, ...
%         Events_Win{ii}, EventsLabelAndIndex{ii,1}, ...
%         EventsLabelAndIndex{ii,2}, BinCenters, TimeBinSize);
%     predictors(:,ii) = {ShiftMtx, EventIndex_vec};
% end

%%
task_regressors = {StimEventTimeBin;ChoiceEventTimeBin;ReEventTimeBin;BTDataBin};
TaskEventWins = {StimWin;ChoiceWin;ChoiceWin;[-0.1,0.1]};
TaskEventShifts = cellfun(@(x) round(x(1)/TimeBinSize):round(x(2)/TimeBinSize),...
    TaskEventWins,'un',0);
TaskEventLabels = {'Stim','Choice','reward','BlockType'};

lambda = 0;
zs = [false,false];
cvfold = 5;
use_constant = true;
return_constant = false;

 [mua_taskpred_k,mua_taskpred_long,mua_taskpred_expl_var,mua_taskpred_reduced_long] = ...
            AP_regresskernel(task_regressors,BinnedSPdatas,TaskEventShifts, ...
            lambda,zs,cvfold,return_constant,use_constant);
 


%%
TaskpredTotal = mua_taskpred_expl_var.total;
TaskpredAlone = mua_taskpred_expl_var.partial(:,:,1);
TaskpredOmit = mua_taskpred_expl_var.partial(:,:,2);

%% test dataset
N = 1000;
X = {rand(1,N);rand(1,N);rand(1,N);rand(1,N)};
Y = [X{1}+X{2}; X{3}+0.1*X{4}.^2; randn(1,N)];%, X(:,1) + 0.25*randn(N,1)
PredShifts = {-2:2;-3:1;-1:1;-2:2};
lambda = 0;
zs = [false,false];
cvfold = 5;
use_constant = false;
return_constant = false;

[taskpred_k,taskpred_long,taskpred_expl_var,taskpred_reduced_long] = ...
            AP_regresskernel(X,Y,PredShifts, ...
            lambda,zs,cvfold,return_constant,use_constant);
 
%%
TaskpredTotal2 = taskpred_expl_var.total;
TaskpredAlone2 = taskpred_expl_var.partial(:,:,1);
TaskpredOmit2 = taskpred_expl_var.partial(:,:,2);






