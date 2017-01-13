function [LeftLickRates,RightLickRates] = LickT2lickRate(lick_time_struct,nbins,varargin)
% this function is specifically used for calculating the lick rate for each
% trial and return is result in two cell array indicates left and right
% trial results
TrTime = 9;
if nargin > 2
    if ~isempty(varargin{1})
        TrTime = varargin{1};
    end
end
nTrs = length(lick_time_struct);
LeftLickRates = cell(nTrs,1);
RightLickRates = cell(nTrs,1);
for nTr = 1 : nTrs
    LeftLickTimes = lick_time_struct(nTr).LickTimeLeft;
    RightLickTimes = lick_time_struct(nTr).LickTimeRight;
    if isempty(LeftLickTimes)
        LeftLickRates{nTr} = zeros(1,nbins);
    else
        LeftLickRates{nTr} = lickrate_plot(LeftLickTimes,nbins,TrTime*1000);
    end
    if isempty(RightLickTimes)
        RightLickRates{nTr} = zeros(1,nbins);
    else
        RightLickRates{nTr} = lickrate_plot(RightLickTimes,nbins,TrTime*1000);
    end
end