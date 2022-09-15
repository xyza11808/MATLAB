function OutDatas = points2kernal(AllPoints, labels, countBin)
% function used to convert distributed points into kernal lines for plots

if ~exist('countBin','var')
    countBin = 30;
end

Unilabel = unique(labels);
label1Inds = labels == Unilabel(1);
label2Inds = labels == Unilabel(2);

label1Data = AllPoints(label1Inds);
label2Data = AllPoints(label2Inds);

[label1Count, label1Edge] = histcounts(label1Data,countBin);
label1centers = (label1Edge(1:end-1)+label1Edge(2:end))/2;
[label2Count, label2Edge] = histcounts(label2Data,countBin);
label2centers = (label2Edge(1:end-1)+label2Edge(2:end))/2;

OutDatas = struct();
OutDatas.Label1Cent = label1centers;
OutDatas.Label1Count = sgolayfilt(label1Count,3,7);
OutDatas.Label2Cent = label2centers;
OutDatas.Label2Count = sgolayfilt(label2Count,3,7);
