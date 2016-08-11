function CP_And_dprime_cal(RawData,TrialFreq,AlignFrame,TimeLength,FrameRate,ActionChoice,varargin)
% this function will be used for calculating choice probability and d prime
% for single ROI and return its result

if nargin > 6
    freqBound = 16000;  % default boundary frequency
else
    freqBound = varargin{1};
    if isempty(freqBound)
        freqBound = 16000;
    end
end

TrialFreq = double(TrialFreq);
FreqType = unique(TrialFreq);
[TrialNum,ROINum,FrameNum] = size(RawData);
if TrialNum ~= numel(TrialFreq) || TrialNum ~= numel(ActionChoice)
    error('Trial Length is not the same as frequency number, please check input data formation.\n');
end

MissInds = ActionChoice == 2;
if sum(MissInds)
    warning('Miss trial exists, excluded all missing trials');
    RawData(MissInds,:,:) = [];
    TrialNum = TrialNum - sum(MissInds);
    TrialFreq(MissInds) = [];
    ActionChoice(MissInds) = [];
end

if length(TimeLength) == 1
    FrameScale = sort([AlignFrame,AlignFrame+floor(TimeLength*FrameRate)]);
elseif length(TimeLength) == 2
    FrameScale = sort([AlignFrame+floor(TimeLength(1)*FrameRate),AlignFrame+floor(TimeLength(2)*FrameRate)]);
    StartTime = min(TimeLength);
    TimeScale = max(TimeLength) - min(TimeLength);
else
    warning('Input TimeLength variable have a length of %d, but it have to be 1 or 2',length(TimeLength));
    return;
end
if FrameScale(1) < 1
    warning('Time Selection excceed matrix index, correct to 1');
end
if FrameScale(2) > FrameNum
    warning('Time Selection excceed matrix index, correct to %d',DataSize(3));
end

DataSelection = RawData(:,:,FrameScale(1):FrameScale(2));
TrialMaxData = max(DataSelection,[],3);  % trial max value within selection range (will this be a problem since decay time also shows high amplitude)
% two dimensional matrix, trialnum by ROInum

CPAll = zeros(numel(FreqType),ROINum);
ROCreverseAll = zeros(numel(FreqType),ROINum);
% DPrime = zeros(numel(FreqType),ROINum);   % used for behavior
% discrimination test
for nFreq = 1 : numel(FreqType)
    cFreq = FreqType(nFreq);
    cFreqTrials = TrialFreq == cFreq;
    cFreqData = TrialMaxData(cFreqTrials,:);
    cFreqAChoice = ActionChoice(cFreqTrials);
    [cp,ROCreverse] = StatisCal(cFreqData,cFreqAChoice);
    CPAll(nFreq,:) = cp;
    ROCreverseAll(nFreq,:) = ROCreverse;
%     DPrime(nFreq,:) = dp;
end
save ChoiceProbSave.mat CPAll ROCreverseAll -v7.3

function [cp,ROCreverse] = StatisCal(Data,AChoice)
% function used for calculate cp and d prime
[TriNum,ROInum] = size(Data);
cp = zeros(ROInum,1);
% dp = zeros(ROInum,1);
ROCreverse = zeros(ROInum,1);
if sum(AChoice)/TriNum < 0.3 || sum(AChoice)/TriNum > 0.7 %|| TriNum < 100;
    warning('Single distribution trial number is not enough, the calcualtion result may inaccurate.');
    return;
end

parfor nROI = 1 : ROInum
    cROIData = Data(:,nROI);
    LeftChoiceData = cROIData(AChoice == 0);
    RightChoiceData = cROIData(AChoice == 1);
    DataIn = [LeftChoiceData(:);RightChoiceData(:)];
    LabelIn = [zeros(numel(LeftChoiceData),1),ones(numel(RightChoiceData),1)];
    [ROCv,ROCrev] = rocOnlineFoff([DataIn,LabelIn]);
    if ROCrev
        ROCv = 1 - ROCv;
    end
    cp(nROI) = ROCv;
    ROCreverse(nROI) = ROCrev;
end
