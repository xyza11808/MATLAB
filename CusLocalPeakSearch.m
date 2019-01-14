function [PosiPeakInds, EventsAreaMask,IsPeakTraceExist] = CusLocalPeakSearch(RawData,PeakThres,PeakDur,varargin)
% this function is used for peak detection for calcium data, in order to
% find significant calcium transients

if length(RawData) ~= numel(RawData)
    error('Input should be a vector data');
end
nFrames = numel(RawData);
 if size(RawData,2) ~= 1
     RawData = RawData(:);
 end
 StdFactor = 4;
 if isempty(PeakThres)
     PeakThres = (mad(RawData,1) * 1.4826) * StdFactor;  % 2 times std value
 end
 PeakWidth = 30;
 if nargin > 3
     if ~isempty(varargin{1})
         PeakWidth = varargin{1};
     end
 end
 
 if isempty(PeakDur)
     PeakDur = 10; % frame numbers
 end
 [Count,Cen] = hist(RawData,100);
 [~,MaxInds] = max(Count);
Baseline = max(Cen(MaxInds),0) + (mad(RawData,1) * 1.4826)*1.5; % above baseline of 1.5 s.t.d.
StartBase = max(Cen(MaxInds),0) + (mad(RawData,1) * 1.4826)*2; % above baseline of 2 s.t.d.
EndBase = max(Cen(MaxInds),0) + (mad(RawData,1) * 1.4826)*0.5; % above baseline of 2 s.t.d.
PeakThres = PeakThres + Cen(MaxInds);
BeforePeakF = round(PeakDur/3);
AfterPeakF = round(PeakDur/3*2);
AboveThresInds = find(RawData > PeakThres);
nInds = length(AboveThresInds);
IsPosiblePeak = zeros(nInds,1);
LastPeakInds = 1;
for cInds = 1 : nInds
    if (AboveThresInds(cInds) > BeforePeakF+1) && (AboveThresInds(cInds) < (nFrames - AfterPeakF - 1)) % within the possible range
        cIndsNearData = RawData(AboveThresInds(cInds) - BeforePeakF:AboveThresInds(cInds)+AfterPeakF);
        cIndsPos = BeforePeakF + 1;
        if sum(cIndsNearData > PeakThres) > length(cIndsNearData)*0.8
            if mean(cIndsNearData(cIndsPos-1:cIndsPos+1)) > mean(cIndsNearData(1:5)) && ...
                  mean(cIndsNearData(cIndsPos-1:cIndsPos+1)) > mean(cIndsNearData(end-9:end))
              DataDerivate = diff(cIndsNearData);
              BeforePeakDif = DataDerivate(1:BeforePeakF); %reach at peak position
              BeforePeakDifSign = double(BeforePeakDif > 0);
              % onset part must have at least 7 consecutive positive slope
              SmoothSign = smooth(BeforePeakDifSign,5);
              SmoothSignUsed = SmoothSign;
              SmoothSignUsed(1:3) = 0;
              SmoothSignUsed(end-2:end) = 0;
              if max(SmoothSignUsed) >= 0.8  || max(BeforePeakDif) > PeakThres/StdFactor % exist of consecutive positive slope
                  if cInds > 1 && (AboveThresInds(cInds) - LastPeakInds) > BeforePeakF
                      if ~(sum(RawData(LastPeakInds:AboveThresInds(cInds)) > Baseline) == (AboveThresInds(cInds)-LastPeakInds+1))
                          IsPosiblePeak(cInds) = 1;
                          LastPeakInds = AboveThresInds(cInds);
                      end
                  end
              end
            end
        end
    end
end
PosiPeakInds = AboveThresInds(logical(IsPosiblePeak));
%%
EventsArea = zeros(size(RawData));
IsPeakTraceExist = ones(size(PosiPeakInds));
DetectPeakNum = length(PosiPeakInds);
PeakInds = PosiPeakInds;
for cPeak = 1 : DetectPeakNum
    cPeakInds = PeakInds(cPeak);
    TempStartInds = cPeakInds - find(RawData(1:cPeakInds) < StartBase,1,'last');
    TempEndInds = find(RawData(cPeakInds+1:end) < EndBase,1,'first');
    if isempty(TempEndInds) && isempty(TempStartInds)
        IsPeakTraceExist(cPeak) = 0;
        continue;
    elseif isempty(TempEndInds)
        TempEndInds = length(RawData) - cPeakInds;
    elseif isempty(TempStartInds)
        TempStartInds = cPeakInds - 1;
    end 
    PeakRangeInds = [cPeakInds - TempStartInds+1,cPeakInds + TempEndInds - 1];
    if PeakRangeInds(2) <= PeakRangeInds(1)
        IsPeakTraceExist(cPeak) = 0;
        continue;
    elseif (PeakRangeInds(2) - PeakRangeInds(1)) < PeakWidth
        IsPeakTraceExist(cPeak) = 0;
        continue;
    end
    EventsArea(PeakRangeInds(1):PeakRangeInds(2)) = 1;
end
EventsAreaMask = logical(EventsArea);
% EventsTraceData = RawData(EventsAreaMask);
% EventsTraceDiff = diff(EventsTraceData);
