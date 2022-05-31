function [eventshiftMtx, LabelVec] = EventPad2Mtx(Events, shifts, eventlabel)
% function used to construct event matrix and the corresponded label vec

if numel(Events) ~= length(Events)
    warning('The expected input is a single col or row, please check your input.');
    return;
end
Events = Events(:);
ShiftNums = length(shifts);

eventshiftMtx = repmat(Events,1,ShiftNums);
eventshiftMtx = ZerosPadShift(eventshiftMtx, shifts);


LabelVec = repmat(eventlabel,1,ShiftNums);
