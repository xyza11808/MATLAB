function [PeakResp,fMeanData]=RFDAtaPlot(OrganizeData,FreqType,StimOnTime,FrameRate,varargin)
%this function is tried to plot all frequency data out and extract their
%peak response amplitude for comparation with 2AFC

[DBNum,FreqNumRD,TimeTrace] = size(OrganizeData);
RealFreqType = length(FreqType);
FreqRepeat = FreqNumRD/RealFreqType;

fInds = zeros(FreqRepeat,RealFreqType);
% fMeanData = zeros(RealFreqType,TimeTrace);

for n = 1 : FreqRepeat
    fInds(n,:) = n:FreqRepeat:FreqNumRD;
    if n == 1
        fMeanData = OrganizeData(:,fInds(n,:),:);
    else
        fMeanData = fMeanData  + OrganizeData(:,fInds(n,:),:); 
    end
end
fMeanData = fMeanData / FreqRepeat;  % nDB times nFreq times nFrame

TimeScale = 1.5; %by default using 1.5s time window to calculate response maxima
if nargin > 4
    if ~isempty(varargin{1})
        TimeScale = varargin{1};
    end
end
FrameScale = floor(TimeScale*FrameRate);
DataSelect = fMeanData(:,:,(StimOnTime+1):(StimOnTime+1+FrameScale));
PeakResp = max(DataSelect,[],3);  % nDB times nFreq, mean peak for each stimuli
% save RFPeakData.mat PeakResp fMeanData -v7.3
