function [BinCent2second, BinCountSmooth] = st2binfun(st,timebin,smoothbin,MaxTimeLen)
% the timebin and smoothbin should both in ms format
% the maxTimeLen should be in second format
st = st * 1000; % change into ms format

TotalTime_in_ms =  MaxTimeLen*1000;
BinEdges = 0:timebin:TotalTime_in_ms;
[BinCounts,~] = histcounts(st,BinEdges);
BinCenters = BinEdges(1:end-1)+timebin/2;
if ~isempty(smoothbin)
    OverlapBinNums = ceil(smoothbin/timebin);
    BinCountSmooth = smooth(BinCounts(:),OverlapBinNums);
end
BinCent2second = BinCenters(:)/1000;




