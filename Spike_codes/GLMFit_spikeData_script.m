
obj = ProbNPSess;
BlockSectionInfo = Bev2blockinfoFun(behavResults);
AllBlockInds = [];
for cb = 1 : BlockSectionInfo.NumBlocks
    AllBlockInds = [AllBlockInds,...
        BlockSectionInfo.BlockTrScales(cb,1):BlockSectionInfo.BlockTrScales(cb,2)];
end
NumTotalTrials = length(BlockSectionInfo.RevFreqTrInds);
SessTr_UsedInds = false(NumTotalTrials,1);
SessTr_UsedInds(AllBlockInds) = true; % using only block trials
SessTr_UsedInds(behavResults.Action_choice == 2) = false; % using non-miss trials

% script to construct regression data from spike times and trigger times
% UsedTrInds = 1:numel(obj.UsedTrigOnTime{1}); % task sessions, convert to real used trial inds in real case
UsedTrInds = SessTr_UsedInds;
TaskTrigOnTimes = obj.UsedTrigOnTime{1}(UsedTrInds); % task trigger times

UsedClusIds = obj.UsedClus_IDs;
NumClusIds = length(UsedClusIds);
% stimFreqs
stimFreqs = behavResults.Stim_toneFreq(UsedTrInds);
stimOnsettimes = double(behavResults.Setted_TimeOnset(UsedTrInds));

SessFreqTypes = unique(stimFreqs);
SessFreqTypeNum = length(SessFreqTypes);
StimDuration = 300; % ms
% stimOnsettimes

% Choices
% session trial choices 
SessChoicesAll = double(behavResults.Action_choice(UsedTrInds));
SessAnsTimes = double(behavResults.Time_answer(UsedTrInds));
ChoiceTypes = unique(SessChoicesAll);
ChoiceTypeNum = length(ChoiceTypes);
if any(SessAnsTimes < 100) % zeros answer time
    error('Empty choice time exists');
end

% RewardTimes
SesRewardTime = double(behavResults.Time_reward(UsedTrInds));
RewardDelayNum = 10; % 10 bins delay function for reward parameters

% constant variables, block types
SessionBlockTypes = behavResults.BlockType(UsedTrInds);
BlockTypes = unique(SessionBlockTypes);
BlockTypeNums = length(BlockTypes);
SessBlockNumbers = BlockSectionInfo.NumBlocks;

NMBlockStartInds = cumsum([1;BlockSectionInfo.NMBlockLens]);
% trialNums % consecutive increased values for each trial ???
% consecutive errors after switch ???


psth_bin = 100; % ms
basisFun_win = 300; % ms

StimDur_binNum = ceil(StimDuration / psth_bin); % number of stim basis function should be used to cover the whole sound duration
ChoiceDelayWin = [-0.2, 1.2]*1000; % in seconds
Choice_binNum = round(diff(ChoiceDelayWin)/psth_bin);
ChoiceDelay_initBin = ChoiceDelayWin(1)/psth_bin; % which bin after answer time to start, and the number of bin is determined by choice bin number
%%
BlockIndex = 1;
NumTrigOnTimes = numel(TaskTrigOnTimes);
AllBehavParasCell = cell(NumTrigOnTimes,1);
BinRespDatasCell = cell(NumTrigOnTimes,1);
for cTrigTimeInds = 1 : NumTrigOnTimes
    cTr_trigOnTime = TaskTrigOnTimes(cTrigTimeInds);
    if cTrigTimeInds < NumTrigOnTimes
        cTr_endTime = TaskTrigOnTimes(cTrigTimeInds+1);
    else
        cTr_endTime = cTr_trigOnTime + 15; % extra 15 seconds will be considered for the last trigger trial
    end
    cTr_time_bins = cTr_trigOnTime : (psth_bin/1000) : cTr_endTime;
    cTr_allSptimes_inds = obj.SpikeTimes >= cTr_trigOnTime &  obj.SpikeTimes <= cTr_endTime;
    NumTimeBins = length(cTr_time_bins)-1;

    cTr_allSptimes = obj.SpikeTimes(cTr_allSptimes_inds);
    cTr_allClusInds = obj.SpikeClus(cTr_allSptimes_inds);
    cTr_clusBin_spCounts = zeros(NumClusIds, NumTimeBins);
    for cclus = 1 : NumClusIds
        cTr_clusBin_spCounts(cclus,:) = histcounts(cTr_allSptimes(cTr_allClusInds == UsedClusIds(cclus)),...
            cTr_time_bins);
    end
    BinRespDatasCell{cTrigTimeInds} = cTr_clusBin_spCounts;
    
    % calculate stim_onset time matrix
    cTr_stimonset_bin = floor(stimOnsettimes(cTrigTimeInds) / psth_bin);
    cTr_stimPara_mtx_raw = zeros(NumTimeBins, SessFreqTypeNum, StimDur_binNum);
    TimeBinInds = cTr_stimonset_bin - 1 + (1 : StimDur_binNum);
    FreqTypeInds = find(SessFreqTypes == stimFreqs(cTrigTimeInds)) * ...
        ones(1,StimDur_binNum);
    stimDurBin = 1:StimDur_binNum;
    
    ind = sub2ind([NumTimeBins, SessFreqTypeNum, StimDur_binNum],...
        TimeBinInds, FreqTypeInds, stimDurBin);
    cTr_stimPara_mtx = cTr_stimPara_mtx_raw;
    cTr_stimPara_mtx(ind) = 1;
%     clearvar cTr_stimPara_mtx_raw
    
    stim_paramtx_final = reshape(cTr_stimPara_mtx,[NumTimeBins, SessFreqTypeNum*StimDur_binNum]);
    
    % calculate choice time matrix
    cTr_choicetime_bin = floor(SessAnsTimes(cTrigTimeInds) / psth_bin);
    cTr_choicePara_mtx_raw = zeros(NumTimeBins, ChoiceTypeNum, Choice_binNum);
    choiceTimebinInds = cTr_choicetime_bin + ChoiceDelay_initBin + (1:Choice_binNum);
    ChoiceTypeInds = find(ChoiceTypes == SessChoicesAll(cTrigTimeInds)) * ...
        ones(1,Choice_binNum);
    Choicedelaybin = 1:Choice_binNum;
    
    choice_inds = sub2ind([NumTimeBins, ChoiceTypeNum, Choice_binNum],...
        choiceTimebinInds, ChoiceTypeInds, Choicedelaybin);
    cTr_choicepara_mtx = cTr_choicePara_mtx_raw;
    cTr_choicepara_mtx(choice_inds) = 1;
%     clearvar cTr_choicePara_mtx_raw
    
    choice_paramtx_final = reshape(cTr_choicepara_mtx, [NumTimeBins, ChoiceTypeNum*Choice_binNum]);
    
    % reward time matrix
    cTr_Reward_mtx_raw = zeros(NumTimeBins,RewardDelayNum);
    cTr_Reward_mtx = cTr_Reward_mtx_raw;
    if SesRewardTime(cTrigTimeInds) > 1000 % with reward
        RewardTimeBin = floor(SesRewardTime(cTrigTimeInds) / psth_bin);
        RewardTimeInds = RewardTimeBin - 1 + (1:RewardDelayNum);
        DelayInds = 1:RewardDelayNum;
        
        Re_Inds = sub2ind([NumTimeBins,RewardDelayNum],...
            RewardTimeInds, DelayInds);
        cTr_Reward_mtx(Re_Inds) = 1;
    end
    Rew_paramtx_final = cTr_Reward_mtx;
    
    % block type matrix
    cTrBlock_type = SessionBlockTypes(cTrigTimeInds);
    cTr_blockType_mtx_raw = zeros(NumTimeBins,BlockTypeNums);
    cTr_blockType_mtx = cTr_blockType_mtx_raw;
    cTr_blockType_mtx(:,BlockTypes == cTrBlock_type) = 1;
    
    Blocktytpe_paramtx_final = cTr_blockType_mtx;
    
    % added block number matrix, increased with block numbers and not
    % related with real block types
    cTr_blockInds_mtx_raw = zeros(NumTimeBins,SessBlockNumbers);
    if cTrigTimeInds >= NMBlockStartInds(BlockIndex+1)
        BlockIndex = BlockIndex + 1;
    end
    cTr_blockInds_mtx = cTr_blockInds_mtx_raw;
    cTr_blockInds_mtx(:, BlockIndex) = 1;
    
    BlockInds_paramtx_final = cTr_blockInds_mtx;
    
    
    cTr_mergeBehav_paras = [stim_paramtx_final, choice_paramtx_final, Rew_paramtx_final, Blocktytpe_paramtx_final, BlockInds_paramtx_final];
    AllBehavParasCell{cTrigTimeInds} = cTr_mergeBehav_paras;
    
end

%%
AllBehavParams_Mtx = cell2mat(AllBehavParasCell);
AllUnitBinRespData_Mtx = (cell2mat(BinRespDatasCell'))' + 1e-6;

%%
ccUsedUnit = 60;
close
figure;
hold on
plot(AllUnitBinRespData_Mtx(:,ccUsedUnit),'k')
%%
UsedUnit_respData = AllUnitBinRespData_Mtx(:,ccUsedUnit);
lamdaValues = 10.^linspace(-5,5,120);
[b_values,FitInfo] = lassoglm(AllBehavParams_Mtx,UsedUnit_respData,'poisson','Alpha',0.9,'lambda',lamdaValues,'CV',10);

%%
yhat = glmval(b_values(:,FitInfo.IndexMinDeviance), AllBehavParams_Mtx, 'log','constant','off');

plot(yhat,'r')

%%
figure;lassoPlot(b_values,FitInfo,'PlotType','CV')
legend('show')
