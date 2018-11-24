function [OnPeakInds,OffPeakInds] = OnOffPeakValueExtract(Trace,OnFrame,fRate)
TimeWin = 0.3;
Fwin = round(TimeWin*fRate);
OnPeakTrace = Trace(OnFrame+1:OnFrame+Fwin);
[~,MaxInds] = max(abs(OnPeakTrace));
OnPeakInds = OnPeakTrace(MaxInds);

OffPeakTrace = Trace(OnFrame+Fwin+1:OnFrame+Fwin*2);
[~,offInds] = max(abs(OffPeakTrace));
OffPeakInds = OffPeakTrace(offInds);
