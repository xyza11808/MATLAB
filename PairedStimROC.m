function ROIAUCABS = PairedStimROC(DataUsing,DataStimulus,varargin)
% data using structure dimension size: ntrials by nROIs
[nTr,nROI] = size(DataUsing);
if length(DataStimulus) ~= nTr
    error('Stimulus length is unequal with data row number.');
end
StimType = unique(DataStimulus);
if length(StimType) ~= 2
    error('Stim Length is more or less than 2 types, can not perform binary roc analysis.');
end
InputStimType = double(double(DataStimulus > StimType(1)));

ROIAUCAll = zeros(nROI,1);
ROIAUCisRev = zeros(nROI,1);
for nmnm = 1 : nROI
    cData = DataUsing(:,nmnm);
    ROCinputData = [cData,InputStimType(:)];
    [AUC,isReverse] = rocOnlineFoff(ROCinputData);
    ROIAUCAll(nmnm) = AUC;
    ROIAUCisRev(nmnm) = isReverse;
end
ROIAUCABS = ROIAUCAll;
ROIAUCABS(logical(ROIAUCisRev)) = 1 - ROIAUCABS(logical(ROIAUCisRev));
