ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);

% SMBinDataMtx = permute(cat(3,ProbNPSess.TrigData_Bin{ProbNPSess.CurrentSessInds}{:,1}),[1,3,2]);

OutDataStrc = ProbNPSess.TrigPSTH_Ext([-1 5],[200 100],ProbNPSess.StimAlignedTime{ProbNPSess.CurrentSessInds});
NewBinnedDatas = permute(cat(3,OutDataStrc.TrigData_Bin{:,1}),[1,3,2]);
NewBin_StimOnset = OutDataStrc.TriggerStartBin;
[NumTrs, NumUnits, NumBins] = size(NewBinnedDatas);

%%
TrStimsFreqsAll = double(behavResults.Stim_toneFreq(:));
FreqTypes = unique(TrStimsFreqsAll);
FreqTypeNum = length(FreqTypes);
FreqTrialNums = zeros(FreqTypeNum,1);
for cf = 1 : FreqTypeNum
    FreqTrialNums(cf) = sum(TrStimsFreqsAll == FreqTypes(cf));
end
MaxTypeNums = max(FreqTrialNums);

NeuronStimwiseRespData = nan(NumBins, MaxTypeNums, FreqTypeNum, NumUnits);
for cf = 1 : FreqTypeNum
    cfTrInds = (TrStimsFreqsAll == FreqTypes(cf));
    cfRespData = permute(NewBinnedDatas(cfTrInds,:,:),[3,1,2]);
    NeuronStimwiseRespData(:,1:FreqTrialNums(cf),cf,:) = cfRespData;
end

%%
S = TrStimsFreqsAll;
R = squeeze(NewBinnedDatas(:,1,NewBin_StimOnset+3));
C = double(behavResults.Action_choice(:));
NMTrInds = C ~= 2;






