function findSigEventsscale(RawTrace, Valuethres, Timescale)
% used to find significangevent scales according to the thres input

% always switch into positive trace
if mean(RawTrace) < 0
    RawTrace = -RawTrace;
    Valuethres = -Valuethres;
end




