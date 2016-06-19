function SigPeakIsolation(RawData,trialTypes,TrialOutCome,varargin)
% this function is tried to detect significant transcent from raw
% Fluorescence trace, and only significant events will be keeped
%

if ~isequal(size(RawData,1),length(trialTypes),length(TrialOutCome))
    warning('Input variable have different trial number, quit function.');
    return;
end
missTrials = TrialOutCome == 2;
if ~sum(missTrials)
    ConsiderData = RawData(~missTrials,:,:);
else
    ConsiderData = RawData;
end

[TrialNum,ROInum,FrameNum] = size(ConsiderData);

SessionStd = 1.4826*mad(ConsiderData(:),1);

for nT = 1 : ROInum
    CurrentTrace = reshape((squeeze(ConsiderData(:,nT,:)))',[],1);
    SFResult = SFThresGene(CurrentTrace,1000,0.05);
    
    
end

function SFThresGene(Data,nIter,alpha)

if numel(Data) ~= length(Data)
    Data = Data(:);
end
parfor nn = 1 : nIter
    SF