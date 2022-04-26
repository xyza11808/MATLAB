function [binnedSP, NumSpikes] = Sptime2bins(SPTimes, binsize, TrTimeScale)
% function used to convert spike times into binned spike

binEdges = TrTimeScale(1):binsize:TrTimeScale(2);

if isempty(SPTimes)
    binnedSP = zeros(1,length(binEdges)-1);
    NumSpikes = 0;
else
   binnedSP = double(histcounts(SPTimes, binEdges) > 0);
   NumSpikes = numel(SPTimes);
end




