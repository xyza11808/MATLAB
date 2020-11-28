function [PeakPointsInds, PeakScaleInds] = findSigEventsscale(RawTrace, Valuethres, Timescale)
% used to find significangevent scales according to the thres input

% always switch into positive trace
if max(RawTrace) < 1
    RawTrace = -RawTrace;
    Valuethres = -Valuethres;
end
% hcf = figure;
% hold on
% plot(RawTrace,'k')
% line([1 numel(RawTrace)],[Valuethres,Valuethres],'Color','g');

AboveThesDatas = RawTrace > Valuethres;
SmoothScale = smooth(AboveThesDatas, Timescale); % longer enough event should have 1 values after smooth
SmoothDif = [0;diff(SmoothScale(:)>=1)];
PeakPointsInds = find(SmoothDif == 1);
NumPeaks = length(PeakPointsInds);
PeakScaleInds = zeros(NumPeaks,2);
IsPeakExclude = zeros(NumPeaks, 1);
%%
for cPInds = 1 : NumPeaks
    %
    cInds = PeakPointsInds(cPInds);
    StartInds = find(AboveThesDatas(1:cInds)<1,1, 'last');
    if isempty(StartInds)
       StartPoint = 1; % reset to start inds
    else
        StartPoint = StartInds + 1; 
    end
    
    EndInds = find(AboveThesDatas(cInds:end)<1,1, 'first');
    if isempty(EndInds)
        Endpoint = length(AboveThesDatas); % reset to end length
    else
       Endpoint = cInds + EndInds - 1;
    end
    %
    PeakScaleInds(cPInds,:) = [StartPoint, Endpoint];
    if Endpoint - StartPoint < Timescale || max(RawTrace(StartPoint:Endpoint)) < 2
        IsPeakExclude(cPInds) = 1;
    else
%         plot(StartPoint:Endpoint,RawTrace(StartPoint:Endpoint),'r','linewidth',1);
    end
    %
end

%%
PeakPointsInds(logical(IsPeakExclude)) = [];
PeakScaleInds(logical(IsPeakExclude),:) = [];




    




