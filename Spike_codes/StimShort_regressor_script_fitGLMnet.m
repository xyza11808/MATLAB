
% ksfolder = strrep(cSessFolder,'F:\','E:\NPCCGs\');
% ksfolder = pwd;

savefolder = fullfile(ksfolder,'Regressor_ANA');
if ~isfolder(savefolder)
    mkdir(savefolder);
end
dataSaveNames = fullfile(savefolder,'REgressorDataSaveStim.mat');
% disp(exist(dataSaveNames,'file'));
% if exist(dataSaveNames,'file')
%     return;
% end

load(fullfile(ksfolder,'NewClassHandle2.mat'));
clearvars RegressorInfosCell
ProbNPSess = NewNPClusHandle;
clearvars NewNPClusHandle
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
% clearvars ProbNPSess
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
StimWin = single([-0.02,0.3]);

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
Behav_SessTrOnBin = round(TaskTrigTimeAligns/TimeBinSize);
%% including only some times before stim onset and offset, exclude extra time binns
Behav_SessStimOnBin = round(Behav_SessStimOnTime/TimeBinSize);

UsedDataBinScales = round([-0.2,0.5]/TimeBinSize);
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

BinnedSPdatas = BinnedSPdatas(:,UsedTimeBins);

% clearvars StimEventshiftMtxs

FullEvents_predictor = StimEventshiftMtxsNew(1,:);
FullEvents_Predlabel = StimEventshiftMtxsNew(2,:);

%% BinnedSPdatas
tic
FullRegressorInfosCell = cell(size(BinnedSPdatas,1),3);
% f = waitbar(0,'Session Calculation Start...');
NumNeurons = size(BinnedSPdatas,1);
fprintf('Processing %d units...\n',NumNeurons);
ErrorU = zeros(NumNeurons,1);
parfor cU = 1:NumNeurons
    try
        [ExplainVarStrc, RegressorCoefs, RegressorPreds] = ...
            lassoelasticRegressor(BinnedSPdatas(cU,:), FullEvents_predictor, 5);
        FullRegressorInfosCell(cU,:) = {ExplainVarStrc, RegressorCoefs, RegressorPreds};
        
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
save(dataSaveNames,'ExistField_ClusIDs', 'NewAdd_ExistAreaNames', 'AreaUnitNumbers',...
    'FullRegressorInfosCell','FullEvents_predictor','-v7.3');

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


