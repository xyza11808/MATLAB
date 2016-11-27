function [DataOutput,FreqTypes] = SessionDataExtra(AlignedData,TrialResult,TrialStim,AlignF,Frate,NormalInds,SingleStimTrNum)
% this function is specifically used for extracting data from input data
% set and return a formalized matrix data so that multisession data can be
% put together

if sum(NormalInds)
    AlignedData = AlignedData(NormalInds,:,:);
    TrialResult = TrialResult(NormalInds);
    TrialStim = TrialStim(NormalInds);
end
if isequal(length(TrialStim),size(AlignedData,1),length(TrialResult))
    error('Input data size mismatch, please check your input data');
end
% function will only use correct trials for further analysis
SelectTrInds = TrialResult == 1;
SelectTrStim = TrialStim(SelectTrInds);
SelectTrData = AlignedData(SelectTrInds,:,:);
FrameScale = [AlignF+1,AlignF + round(1.5*Frate)];
DataUsing = SelectTrData(:,:,FrameScale(1):FrameScale(2));
DataUsingResp = max(DataUsing,[],3);

FreqTypes = unique(SelectTrStim);
FreqNum = length(FreqTypes);
if mod(FreqNum,2)
    error('Input Trial stims should be an even number, please check your input data');
end
DataOutput = zeros(FreqNum,SingleStimTrNum,size(DataUsingResp,2));
for nFreq = 1 : FreqNum
    cFreq = FreqTypes(nFreq);
    cFreqTrInds = SelectTrStim == cFreq;
    cFreqTrData = DataUsingResp(cFreqTrInds,:);
    if size(cFreqTrData,1) > SingleStimTrNum
        RandInds = randsample(size(cFreqTrData,1),SingleStimTrNum);
        DataOutput(nFreq,:,:) = cFreqTrData(RandInds);
    elseif size(cFreqTrData,1) == SingleStimTrNum
        DataOutput(nFreq,:,:) = cFreqTrData;
    else
        for nn = 1 : SingleStimTrNum
            SingleSampleInds = randsample(size(cFreqTrData,1),3);
            sampleData = mean(cFreqTrData(SingleSampleInds,:));
            DataOutput(nFreq,nn,:) = sampleData;
        end
    end
end
