
NumTrials = 539;
NumUnits = 124;
NumFrames = 30;
cFrameRate = 30;
cFrameTimes = 1/cFrameRate;
RespData = rand(NumTrials, NumUnits, NumFrames); % aligned to stim onset data
stimOnBin = cFrameRate*1;  %s, default baseline length is 1s

RespData = single(RespData);

% pakage each trial into a cell for random sampling of trials
RespData2C = squeeze(mat2cell(permute(RespData,[3,2,1]), NumFrames,NumUnits,ones(NumTrials,1)));

%% preparing zy's 2p data
load('dff_data_All_bigroi_2020.mat', 'dff_trials');
load('rs4_20200914_Afc_used.mat');
if exist('SessionResults','var')
    [behavResults,behavSettings] = behav_cell2struct(SessionResults, SessionSettings);
end

%%
FrameRate = 30; % about 29.6Hz
PreSoundFrameNum = 1*FrameRate;
AfSoundFrameNum = 3*FrameRate;
AllTrStimOnFrame = round(double(behavResults.Time_stimOnset(:))/FrameRate);

NumTrials = length(dff_trials);
UsedRangeDatas = cell(1,NumTrials);
for cTr = 1 : NumTrials
    cTrData = dff_trials{cTr};
    cTrOnsetTime = AllTrStimOnFrame(cTr);
    cTrUsedFrames = (cTrOnsetTime-PreSoundFrameNum+1):(cTrOnsetTime+AfSoundFrameNum);
    cTrUsedFrameData = cTrData(:,cTrUsedFrames);
    UsedRangeDatas{cTr} = cTrUsedFrameData;
end

NewBinnedDatas = permute(cat(3,UsedRangeDatas{:}),[3 1 2]);
stimOnBin = PreSoundFrameNum;
cFrameTimes = 1/FrameRate;
% %% for electrophysiology data use
% NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
% OnsetBin = OutDataStrc.TriggerStartBin;
% stimOnBin = OnsetBin;
% cFrameTimes = OutDataStrc.USedbin(2);
%% construct behavior matrix
% behavior datas

if ~isfield(behavResults,'BlockType')
    if ~isfield(behavResults,'Block_Type')
        error('The block type field is missing or unrecognized, Please check your input variable.');
    else
        behavResults.BlockType = behavResults.Block_Type;
    end
end
 
BlockSectionInfo = Bev2blockinfoFun(behavResults);

ActionChoice = double(behavResults.Action_choice(:));
NMTrInds = ActionChoice(1:BlockSectionInfo.BlockTrScales(end,2)) ~= 2;

%%
RespDataRaw = NewBinnedDatas(NMTrInds,:,:);
% RespData = NewBinnedDatas();
% [NumTrials,NumUnits,NumFrames] = size(RespData);
% RespDataCUsed = squeeze(mat2cell(permute(RespData,[3,2,1]), NumFrames,NumUnits,ones(NumTrials,1)));

NMActionChoices = ActionChoice(NMTrInds);
BlockTypeAll = double(behavResults.BlockType(:));
NMBlockTypes = BlockTypeAll(NMTrInds);

NMBlockTypeLabels = NMBlockTypes + 1;
NMActionChoices = NMActionChoices + 1;

NMBlockIndex = cumsum([1;abs(diff(NMBlockTypes))]);

% AllTrInds = {double(behavResults.Action_choice(:)),double(behavResults.BlockType(:))};
TrialFreqsAll = double(behavResults.Stim_toneFreq(:));

RevFreqs = BlockSectionInfo.BlockFreqTypes(BlockSectionInfo.IsFreq_asReverse>0);
RevFreqInds = (ismember(TrialFreqsAll,RevFreqs));
NMRevFreqIndsRaw = RevFreqInds(NMTrInds);
NMTrFreqsAll = TrialFreqsAll(NMTrInds);

FreqTypes = unique(NMTrFreqsAll);
FreqTypeNum = length(FreqTypes);
NMTrialsNums = sum(NMTrInds);

NMStimOnTime = double(behavResults.Time_stimOnset(NMTrInds));
NMAnsTimes = double(behavResults.Time_answer(NMTrInds));
NMReTimes = double(behavResults.Time_reward(NMTrInds));

NMAlignAnsBins = round((NMAnsTimes - NMStimOnTime)/cFrameTimes/1000);
NMAlignReBins = round(max(NMReTimes - NMStimOnTime, 0)/cFrameTimes/1000);

UsedMaxLenData = max(max(NMAlignAnsBins),max(NMAlignReBins))+stimOnBin;

%%

% RespDataUsed = RespData(NMTrInds,:,:);
% RespDataCUsed = RespData2C(NMTrInds);
% 
RespData = RespDataRaw(:,:,1:UsedMaxLenData+3);
[NumTrials,NumUnits,NumFrames] = size(RespData);
RespDataCUsed = squeeze(mat2cell(permute(RespData,[3,2,1]), NumFrames,NumUnits,ones(NumTrials,1)));

TimeBinSize = single(cFrameTimes); % frame time as bin size

%% construct behavior datas
IsSpikeData = 0;

if IsSpikeData
    StimWin = single([-0.1,0.3]);
    ChoiceWin = ([-0.2,1.5]);
    ReWin = ([-0.1,2]);
else % if input is calcium data
    StimWin = single([-0.1,2]);
    ChoiceWin = ([-0.5,2.5]);
    ReWin = ([-0.5,2.5]);
end


StimFrameWins = round(StimWin(1)/TimeBinSize):round(StimWin(2)/TimeBinSize);
ChoiceFrameWins = round(ChoiceWin(1)/TimeBinSize):round(ChoiceWin(2)/TimeBinSize);
ReFrameWins = round(ReWin(1)/TimeBinSize):round(ReWin(2)/TimeBinSize);
% ContinuedFrameCounts = (1:NumFrames:NMTrialsNums*NumFrames)';

BinEdges = 0.5:(NumFrames+0.5);


%% construct fit data matrix for each trial

StimWinBinNums = length(StimFrameWins);
StimOnBinBaseVec = zeros(NumFrames, 1, 'single');
StimOnBinBaseVec(stimOnBin+1) = 1; % all stim onset bin is the same, directly assign the bin value
[StimShiftMtx,~] = EventPad2Mtx(StimOnBinBaseVec,...
        StimFrameWins, {'Stim'});
StimBaseFun = zeros(NumFrames, StimWinBinNums, 'single');
StimBaseDataC = cell(1, FreqTypeNum);
StimBaseDataC(:) = {StimBaseFun};

ChoiceWinNums = length(ChoiceFrameWins);
ChoiceAnsOnBin = zeros(NumFrames, 1, 'single');
ChoiceBaseDataC = cell(1,2);
ChoiceBaseDataC(:) = {zeros(NumFrames, ChoiceWinNums, 'single')};


ReWinNums = length(ReFrameWins);
ReAnsOnBin = zeros(NumFrames, 1, 'single');
ReBaseDataC = {zeros(NumFrames, ReWinNums, 'single')};


AllStimDataMtxs = cell(NMTrialsNums, FreqTypeNum);
AllStimDataMtxsMerged = cell(NMTrialsNums, 1);
AllChoiceDataMtx = cell(NMTrialsNums, 2);
AllChoiceDataMtxMerged = cell(NMTrialsNums, 1);
AllRewardDataMtx = cell(NMTrialsNums, 1);

for cTr = 1:NMTrialsNums
    % constructing stim predictor matrix
    cStimTypeInds = find(FreqTypes == NMTrFreqsAll(cTr));
    cStimBasedata = StimBaseDataC;
    
    cStimBasedata{cStimTypeInds} = StimShiftMtx;
    AllStimDataMtxs(cTr,:) = cStimBasedata;
    AllStimDataMtxsMerged{cTr} = cat(2,cStimBasedata{:});
    
    % constructing choice predictor matrix
    cChoiceOnVec = ChoiceAnsOnBin;
    cChoiceOnVec(NMAlignAnsBins(cTr)+stimOnBin) = 1;
    [cCShiftMtx,~] = EventPad2Mtx(cChoiceOnVec,...
        ChoiceFrameWins, {'Choice'});
    cChoiceDataMtx = ChoiceBaseDataC;
    cChoiceDataMtx{NMActionChoices(cTr)} = cCShiftMtx;
    AllChoiceDataMtx(cTr,:) = cChoiceDataMtx;
    AllChoiceDataMtxMerged{cTr} = cat(2,cChoiceDataMtx{:});
    
    % constructing reward predictor matrix
    if NMAlignReBins(cTr) > 1e-5  % with reward
        cReOnVec = ReAnsOnBin;
        cReOnVec(NMAlignReBins(cTr)) = 1;
        [cRShiftMtx, ~] = EventPad2Mtx(cReOnVec,ReFrameWins, {'reward'});
        AllRewardDataMtx{cTr} = cRShiftMtx;
    else
        AllRewardDataMtx(cTr) = ReBaseDataC;
    end
    
end

%%
UsedPredictors = {AllStimDataMtxsMerged, AllChoiceDataMtxMerged, AllRewardDataMtx};
% UsedPredictors = {AllStimDataMtxsMerged(totalUsedTrs), AllChoiceDataMtxMerged(totalUsedTrs)};

%% random sampling of trials for calculation
% NumTrRepeats = 100;

for cU = 49% : NumUnits  %57
%     cU_allTrData = cellfun(@(x) x(:,cU),RespDataCUsed(totalUsedTrs),'un',0);
    cU_allTrData = cellfun(@(x) x(:,cU),RespDataCUsed,'un',0);
    cU_alldataTrace = cat(1,cU_allTrData{:});
    cU_allTraceZS = zscore(cU_alldataTrace);
    cU_normTrData = mat2cell(cU_allTraceZS,cellfun(@numel,cU_allTrData));
    
    [AllIterPreds,AllIterCoefs,AllIterEVars,AllCoefFactor] = ...
        lassoelasticRegressor_Itering(cU_normTrData, UsedPredictors, 5);

    

end


