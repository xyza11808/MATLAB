
% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
ksfolder = pwd;

savefolder = fullfile(ksfolder,'Regressor_ANA');
if ~isfolder(savefolder)
    mkdir(savefolder);
end
dataSaveNames = fullfile(savefolder,'REgressorDataSave3.mat');
% disp(exist(dataSaveNames,'file'));
% if exist(dataSaveNames,'file')
%     return;
% end

load(fullfile(ksfolder,'NPClassHandleSaved.mat'));
clearvars RegressorInfosCell

%% find target cluster inds and IDs
NewSessAreaStrc = load(fullfile(ksfolder,'SessAreaIndexData2.mat'));
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
AreaNameIndex = cell(Numfieldnames,1);
for cA = 1 : Numfieldnames
    cA_Clus_IDs = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchUnitRealIndex;
    cA_clus_inds = NewSessAreaStrc.SessAreaIndexStrc.(NewAdd_ExistAreaNames{cA}).MatchedUnitInds;
    ExistField_ClusIDs = [ExistField_ClusIDs;[cA_Clus_IDs,cA_clus_inds]]; % real Clus_IDs and Clus indexing inds
    AreaUnitNumbers(cA) = numel(cA_clus_inds);
    AreaNameIndex(cA) = {cA*ones(AreaUnitNumbers(cA),1)};
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
TimeBinSize = single(0.1);

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
StimWin = single([-0.1,0.4]);
ChoiceWin = ([-0.3,2]);
ReWin = ([-0.5,1]);

StimFrameWins = round(StimWin(1)/TimeBinSize):round(StimWin(2)/TimeBinSize);
Behav_stimOnset = single(behavResults.Time_stimOnset(:))/1000; % seconds
Behav_SessStimOnTime = Behav_stimOnset + TaskTrigTimeAligns(:);
Behav_Freqs = single(behavResults.Stim_toneFreq(:));
StimTypes = unique(Behav_Freqs);
StimNums = length(StimTypes);
StimEventTimeBin = zeros(StimNums,NumofSPcounts,'single');
StimEventshiftMtxs = cell(2, StimNums);
for cStimNum = 1 : StimNums
    cStimInds = Behav_Freqs == StimTypes(cStimNum);
    StimEventTimeBin(cStimNum,:) = histcounts(Behav_SessStimOnTime(cStimInds),...
        BinEdges);
    [ShiftMtx, mtxlabel] = EventPad2Mtx(StimEventTimeBin(cStimNum,:),...
        StimFrameWins, {num2str(cStimNum,'Stim%d')});
    
    StimEventshiftMtxs(:,cStimNum) = {ShiftMtx, mtxlabel};
end

% choice event times
ChoiceFrameWins = round(ChoiceWin(1)/TimeBinSize):round(ChoiceWin(2)/TimeBinSize);

Behav_ChoiceT = single(behavResults.Time_answer(:))/1000; % seconds
Behav_SessChoiceT = Behav_ChoiceT + TaskTrigTimeAligns(:);

Behav_Choice = single(behavResults.Action_choice(:));
ChoiceEventTimeBin = zeros(2,NumofSPcounts,'single');
ChoiceEventshiftMtxs = cell(2, 2);
for cChoice = 1 : 2
    cChoiceInds = Behav_Choice == (cChoice - 1);
    ChoiceEventTimeBin(cChoice,:) = histcounts(Behav_SessChoiceT(cChoiceInds),...
        BinEdges);
    
    [ShiftMtx, mtxlabel] = EventPad2Mtx(ChoiceEventTimeBin(cChoice,:),...
        ChoiceFrameWins, {num2str(cChoice,'Choice%d')});
    ChoiceEventshiftMtxs(:,cChoice) = {ShiftMtx, mtxlabel};
end

% reward event times
ReFrameWins = round(ReWin(1)/TimeBinSize):round(ReWin(2)/TimeBinSize);

Behav_RewardT = single(behavResults.Time_reward(:))/1000; % seconds
Behav_RewardTRaw = Behav_RewardT;
Behav_RewardT(Behav_RewardT == 0 & Behav_Choice ~= 2) = ...
    Behav_ChoiceT(Behav_RewardT == 0 & Behav_Choice ~= 2)+TimeBinSize; % error trials using choice time indicate reward omission time
Behav_SessReT = Behav_RewardT + TaskTrigTimeAligns(:);

ReEventTimeBin = zeros(2, NumofSPcounts,'single');
ReEventshiftMtxs = cell(2,2);
ReEventTimeBin(1,:) = histcounts(Behav_SessReT(Behav_RewardTRaw > 0),BinEdges);
[ShiftMtx, mtxlabel] = EventPad2Mtx(ReEventTimeBin(1,:),...
        ReFrameWins, {'Re1'});
ReEventshiftMtxs(:,1) = {ShiftMtx, mtxlabel};
ReEventTimeBin(2,:) = histcounts(Behav_SessReT(Behav_RewardTRaw == 0),BinEdges);
[ShiftMtx, mtxlabel] = EventPad2Mtx(ReEventTimeBin(2,:),...
        ReFrameWins, {'Re2'});
ReEventshiftMtxs(:,2) = {ShiftMtx, mtxlabel};

% BlockType values
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
    if numel(TaskTrigTimeAligns) == cBlockTrialInds(2)
        cB_endTrTime = TaskTrigTimeAligns(cBlockTrialInds(2)) + 10 - TimeBinSize; % using extra 10 seconds after the last tr onset
    elseif numel(TaskTrigTimeAligns) > cBlockTrialInds(2)
        cB_endTrTime = TaskTrigTimeAligns(cBlockTrialInds(2)+1) - TimeBinSize;
    else
       error('Block size larger than maximum trial number.'); 
    end
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
BTEventshiftMtxs = {(BTDataBin(1,:))',(BTDataBin(2,:))';'BTlow','BThigh'};
%
% TrIndex value assigns
TrIndexBins = zeros(1, NumofSPcounts,'single');
Behav_SessTrOnBin = round(TaskTrigTimeAligns/TimeBinSize);
TotalTrNum = numel(Behav_SessTrOnBin);
for cTr = 1 : TotalTrNum-1
   TrIndexBins(Behav_SessTrOnBin(cTr)+1:Behav_SessTrOnBin(cTr+1)) = cTr;
end
TrIndexBins(Behav_SessTrOnBin(TotalTrNum):(Behav_SessTrOnBin(TotalTrNum)+6/TimeBinSize)) = TotalTrNum;

TrIndexEventshiftMtxs = {TrIndexBins';'TrialIndex'};

%% including only some times before stim onset and offset, exclude extra time binns
Behav_SessStimOnBin = round(Behav_SessStimOnTime/TimeBinSize);

UsedDataBinScales = round([-1,4]/TimeBinSize);
TotalTrNum = numel(Behav_SessStimOnTime);
UsedTimeBins = false(1,NumofSPcounts);
cTrExcludedBins = zeros(TotalTrNum,2);
for cTr = 1 : TotalTrNum
    if cTr < TotalTrNum
        cTrUsedBins = [Behav_SessStimOnBin(cTr) + UsedDataBinScales(1),...
            min(Behav_SessStimOnBin(cTr) + UsedDataBinScales(2),Behav_SessTrOnBin(cTr+1))];
    else
        cTrUsedBins = [Behav_SessStimOnBin(cTr) + UsedDataBinScales(1),...
            Behav_SessStimOnBin(cTr) + UsedDataBinScales(2)];
    end
    UsedTimeBins(cTrUsedBins(1):cTrUsedBins(2)) = true;
    cTrExcludedBins(cTr,1) = cTrUsedBins(1) - Behav_SessTrOnBin(cTr);
    if cTr < TotalTrNum
       cTrExcludedBins(cTr,2) =  Behav_SessTrOnBin(cTr+1) - cTrUsedBins(2);
    end
end

%% only used designed time bins for speed
% UsedTimeBins = true(1,NumofSPcounts);
StimEventshiftMtxsNew = [cellfun(@(x) x(UsedTimeBins,:),StimEventshiftMtxs(1,:),'un',0);StimEventshiftMtxs(2,:)];
ChoiceEventshiftMtxsNew = [cellfun(@(x) x(UsedTimeBins,:),ChoiceEventshiftMtxs(1,:),'un',0);ChoiceEventshiftMtxs(2,:)];
ReEventshiftMtxsNew = [cellfun(@(x) x(UsedTimeBins,:),ReEventshiftMtxs(1,:),'un',0);ReEventshiftMtxs(2,:)];
BTEventshiftMtxsNew = [cellfun(@(x) x(UsedTimeBins,:),BTEventshiftMtxs(1,:),'un',0);BTEventshiftMtxs(2,:)];
TrIndexMtxsNew = [cellfun(@(x) x(UsedTimeBins,:),TrIndexEventshiftMtxs(1,:),'un',0);TrIndexEventshiftMtxs(2,:)];

BinnedSPdatas = BinnedSPdatas(:,UsedTimeBins);

clearvars StimEventshiftMtxs ChoiceEventshiftMtxs ReEventshiftMtxs BTEventshiftMtxs
%%
eventMerge = 1;

if eventMerge == 1
    StimEventshiftMtxs_Used = {cat(2,StimEventshiftMtxsNew{1,:});cat(2,StimEventshiftMtxsNew{2,:})};
    ChoiceEventshiftMtxs_Used = {cat(2,ChoiceEventshiftMtxsNew{1,:});cat(2,ChoiceEventshiftMtxsNew{2,:})};
    ReEventshiftMtxs_Used = {cat(2,ReEventshiftMtxsNew{1,:});cat(2,ReEventshiftMtxsNew{2,:})};
    BTEventshiftMtxs_Used = {cat(2,BTEventshiftMtxsNew{1,:});cat(2,BTEventshiftMtxsNew{2,:})};
    TrIndexMtxsNew_Used = TrIndexMtxsNew;
else
    StimEventshiftMtxs_Used = StimEventshiftMtxsNew;
    ChoiceEventshiftMtxs_Used = ChoiceEventshiftMtxsNew;
    ReEventshiftMtxs_Used = ReEventshiftMtxsNew;
    BTEventshiftMtxs_Used = BTEventshiftMtxsNew;
    TrIndexMtxsNew_Used = TrIndexMtxsNew;
end
%%
AllTaskEvents = [StimEventshiftMtxs_Used,ChoiceEventshiftMtxs_Used,...
    BTEventshiftMtxs_Used,TrIndexMtxsNew_Used]; %,BTEventshiftMtxs_Used,ReEventshiftMtxs_Used
TaskEvents_predictor = AllTaskEvents(1,:);
TaskEvents_Predlabel = AllTaskEvents(2,:);

%% BinnedSPdatas
tic
RegressorInfosCell = cell(size(BinnedSPdatas,1),3);
rrr_RegressorInfosCell = cell(size(BinnedSPdatas,1),3);
% f = waitbar(0,'Session Calculation Start...');
NumNeurons = size(BinnedSPdatas,1);
ErrorU = zeros(NumNeurons,1);
parfor cU = 1:NumNeurons
    try
        [ExplainVarStrc, RegressorCoefs, RegressorPreds] = ...
            lassoelasticRegressor(BinnedSPdatas(cU,:), TaskEvents_predictor, 5);
        if mean(ExplainVarStrc.fullmodel_explain_var) >= 0.02
            [ExplainVarStrc_rrr, RegressorCoefs_rrr, RegressorPreds_rrr] = ...
                rrr_lassoelasticRegressor(BinnedSPdatas(cU,:), TaskEvents_predictor, 5);
            rrr_RegressorInfosCell(cU,:) = {ExplainVarStrc_rrr, ...
                RegressorCoefs_rrr, RegressorPreds_rrr};
        end
        RegressorInfosCell(cU,:) = {ExplainVarStrc, RegressorCoefs, RegressorPreds};
    catch ME
        fprintf('Errors for unit %d.\n',cU);
        ErrorU(cU) = 1;
    end
%     Progress = (cU - 1)/(NumNeurons - 1);
%     waitbar(Progress,f,sprintf('Processing %.2f%% of all calculation...',Progress*100));
end
toc
% waitbar(1,f,'Calculation complete!');
% close(f);
%%

save(dataSaveNames, 'RegressorInfosCell',...
    'ExistField_ClusIDs', 'NewAdd_ExistAreaNames','rrr_RegressorInfosCell', 'AreaUnitNumbers', '-v7.3');



%%
% predictMtxAll = cat(2,TaskEvents_predictor{:});
% TaskTrigOnBins = round(TaskTrigTimeAligns/0.1);
% NumPredictor = size(predictMtxAll,2);
% PredictorSize = cellfun(@(x) size(x,2),TaskEvents_predictor);
% PredictorSizePos = cumsum(PredictorSize);
% %%
% figure('position',[100 100 630 900]);
% ExamplepredictorData = predictMtxAll(TaskTrigOnBins(2):TaskTrigOnBins(7),:);
% PlotBinNum = size(ExamplepredictorData,1);
% him = imagesc(ExamplepredictorData);
% colormap jet
% set(him,'alphadata',abs(ExamplepredictorData) > 0);
% ExampleTrStartInds = TaskTrigOnBins(2:7) - TaskTrigOnBins(2)+1;
% for cTr = 1 : length(ExampleTrStartInds)
%     line([0.5 NumPredictor+0.5],[ExampleTrStartInds(cTr)+0.5 ExampleTrStartInds(cTr)+0.5],'Color','c','linewidth',1.6);
% end
% set(gca,'box','off')
% for cEdge = 1 : length(PredictorSizePos)
%     line([PredictorSizePos(cEdge) PredictorSizePos(cEdge)],[0.5 PlotBinNum+0.5],'Color','k','linewidth',1.2);
% end
% 
% %%
% set(gca,'xtick',[20 70 110 124],'xticklabel',{'Stim','Choice','Reward','Block'},...
%     'ytick',[30 80 130 200 260],'yticklabel',{'Trial1','Trial2','Trial3','Trial4','Trial5'});
% 
% %%
% 
% saveas(gcf,'Designed predictor matrix plot');
% saveas(gcf,'Designed predictor matrix plot','png');
% saveas(gcf,'Designed predictor matrix plot','pdf');
% 


