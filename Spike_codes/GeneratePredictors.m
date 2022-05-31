function [ShiftMtx, EventIndex_vec] = GeneratePredictors(EventTimes, EventWin, EventIndex, ...
    EventLabels, SessTimeBins, timebinsize)
% function used to generate prediction matrix

EventWin2Bin = round(EventWin/timebinsize);
WinBinsAll = EventWin2Bin(1):EventWin2Bin(2);
NumWinBins = length(WinBinsAll);

SessBinLens = numel(SessTimeBins);

EventTime2Bins = round(EventTimes(:)/timebinsize);
EventRowIndex = repmat(EventTime2Bins,1,NumWinBins);
EventColIndex = repmat(1:NumWinBins,numel(EventTimes),1);

ShiftPadMtxRaw = sparse(EventRowIndex(:),EventColIndex(:),...
    ones(numel(EventRowIndex),1)*EventLabels,SessBinLens,NumWinBins);

EventShiftsValue = (1:NumWinBins) - 1;
ShiftMtx = ZerosPadShift(ShiftPadMtxRaw, EventShiftsValue);

EventIndex_vec = repmat(EventIndex, 1, NumWinBins);















