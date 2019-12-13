function [UsedPeak_Amps,UsedPeak_locs] = EventIndexSyncPeakNum(IndexData,GapBin,varargin)
% the first column is real data, and second is real data
IsSmooth = 0;
if nargin > 2
    if ~isempty(varargin{1})
        IsSmooth = varargin{1};
    end
end
if IsSmooth
    ww = gausswin(7,0.5);
    RealIndex = conv(IndexData(:,1),ww,'same')/sum(ww);
else
    RealIndex = IndexData(:,1);
end
BaseValue = mean(IndexData(:,2));
RealIndex(RealIndex < BaseValue) = BaseValue;

[Peaks,locs,width,Prominences] = findpeaks(RealIndex,'MinPeakDistance',GapBin,'MinPeakHeight',BaseValue*1.1);
ShortWidthPeak = width < (30/2);% at least for 1 second data-points
LowPromPeak = Prominences < BaseValue/3;
UsedPeakInds = ~(ShortWidthPeak(:) | LowPromPeak(:));

UsedPeak_Amps = Peaks(UsedPeakInds);
UsedPeak_locs = locs(UsedPeakInds);



