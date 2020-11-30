function ShufCorrs = Eventscaleshuf(RawTrace, Valuethres, shufscale, RefTrace)
% shuf the raw trace based on event itself, and move event entirely
% the shuf scale is limited by shufscale

[~, PeakscaleInds] = findSigEventsscale(RawTrace, Valuethres, 3500);
NumPeaks = size(PeakscaleInds,1);

nShufRepeats = 200;
ShufCorrs = zeros(nShufRepeats, 20001);
parfor cRepeat = 1 : nShufRepeats
    ShufEventTrace = RawTrace;
    if NumPeaks == 1
       cPshiftV = round((rand - 0.5) * shufscale);
       ShufEventTrace =  circshift(RawTrace,cPshiftV);
    else
        for cP = 1 : NumPeaks
            cPshiftV = round((rand - 0.5) * shufscale); % shift scale, either left or right
        %     RawEventTime = PeakscaleInds(cP,:);

            if cP == 1
                Readyshiftscale = [1,PeakscaleInds(2,1)-1];
            elseif cP == NumPeaks
                Readyshiftscale = [PeakscaleInds(NumPeaks-1,2)+1,...
                    numel(RawTrace)];
            else
                Readyshiftscale = [PeakscaleInds(cP-1,2)+1,...
                    PeakscaleInds(cP+1,1)-1];
            end
            ShufEventTrace(Readyshiftscale(1):Readyshiftscale(2)) = ...
                circshift(RawTrace(Readyshiftscale(1):Readyshiftscale(2)),cPshiftV);
        end
    end
    [r, ~] = xcorr(ShufEventTrace, RefTrace,10000,'Coeff');
    ShufCorrs(cRepeat,:) = r;
end
%%
% figure;
% hold on
% plot(RawTrace,'k')
% plot(ShufEventTrace,'r')

    
    


