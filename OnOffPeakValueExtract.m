function [OnPeakInds,OffPeakInds] = OnOffPeakValueExtract(Trace,OnFrame,fRate)
TimeWin = 1;
Fwin = round(TimeWin*fRate);
if numel(Trace) < (OnFrame+Fwin*2)
   OnPeakInds = -1;
   OffPeakInds = -1;
else
    OnPeakTrace = Trace(OnFrame+1:OnFrame+Fwin);
    % [~,MaxInds] = max(abs(OnPeakTrace));
    % OnPeakInds = OnPeakTrace(MaxInds);
    OnPeakInds = mean(OnPeakTrace) - max(Trace(OnFrame),0);

    OffPeakTrace = Trace(OnFrame+Fwin+1:OnFrame+Fwin*2);
    % [~,offInds] = max(abs(OffPeakTrace));
    % OffPeakInds = OffPeakTrace(offInds);
    OffPeakInds = mean(OffPeakTrace) - max(Trace(OnFrame),0);
end
    