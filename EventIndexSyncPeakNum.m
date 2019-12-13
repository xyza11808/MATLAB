function [Peaks,locs] = EventIndexSyncPeakNum(IndexData,GapBin)
% the first column is real data, and second is threhold data

RealIndex = IndexData(:,1);
BaseValue = mean(IndexData(:,2));
RealIndex(RealIndex < BaseValue) = BaseValue;

[Peaks,locs] = findpeaks(RealIndex,'MinPeakDistance',GapBin,'MinPeakHeight',BaseValue*1.1);


