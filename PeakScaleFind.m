function [StartInds, EndInds] = PeakScaleFind(RawTrace,Peak,Thres)
% find the peak-waveform scale using given peak_Index and Peak end
% threshold value
if numel(RawTrace) <= Peak
    error('Peak index should within given trace length.');
end
if length(Peak) > 1
    error('Only single peak index was supported currently.');
end
if length(Thres) == 1
    [StartThres,EndThres] = deal(Thres);
else
    StartThres = Thres(1);
    EndThres = Thres(2);
end

% locate start inds
StartInds = find(RawTrace(1:Peak) < StartThres,1,'last');
if isempty(StartInds)
    StartInds = 1;
else
    StartInds = StartInds + 1;
end

% find the end index
EndInds = find(RawTrace((1+Peak):end) < EndThres,1,'first');
if isempty(EndInds)
    EndInds = numel(RawTrace)-Peak;
else
    EndInds = EndInds - 1;
end
EndInds = Peak + EndInds;

