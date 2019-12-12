function [ROIdatas,SessSeqSynchronyIndex] = SessSeptedCoefCal(RawMergeData,FrameIndex)
% calculate the coef value seperatedly within each session and then
% averaged together
TotalFrameNums = size(RawMergeData,2);
if sum(FrameIndex) ~= TotalFrameNums
    error('Unmatched total frames and raw data size');
end

NumImageSess = length(FrameIndex);
cBase = 1;
ROIdatas = zeros(size(RawMergeData,1));
SessSeqSynchronyIndex = zeros(NumImageSess,1);
% SessCoefs = cell(NumImageSess,1);
for cSess = 1 : NumImageSess
    cSessData = RawMergeData(:,cBase:(cBase + FrameIndex(cSess)-1));
    cSessCoef = corrcoef(cSessData');
%     SessCoefs{cSess} = cSessCoef;
    
    ROIdatas = ROIdatas + cSessCoef;
    
    SessSeqSynchronyIndex(cSess) = Popu_synchrony_fun(cSessData);
    cBase = cBase + FrameIndex(cSess);
    
end

ROIdatas = ROIdatas/NumImageSess;
