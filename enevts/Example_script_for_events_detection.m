
%% These parameters need to be determined.
thr = thrFactor*roiParam(j).sd;
dthr = roiParam(j).sd;
slopeThresh = 2*roiParam(j).slope_sd;
slope_span = roiParam(j).slope_span;
trace_orig = obj(i).dff(j,:);
trace = smooth(trace_orig,5,'sgolay');

%%
% Use de-noised trace for event detection: denoised by wavelet then
% smoothed.
%                     trace_dn = smooth(roiParam(j).traces_dn(i,:),3); % trace; %
% event detection on de-nosied traces
eventTiming = CaEventDetector(trace,thr,dthr,slope_span,slopeThresh); %,slopeThresh,slope_span);
event = struct([]);

if ~isempty(eventTiming)
    %             figure(gcf);
    %             plot(ts,trace);title([str1 str2]);
    for k = 1:size(eventTiming,1) % number of events in each trial
        onset = eventTiming(k,1);
        offset = eventTiming(k,2);
        time_thresh = eventTiming(k,3)*unitTime;
        t = (onset:offset).*unitTime;
        y = trace(onset:offset);
        if length(y)< 4
            continue;
        end
        temp = Ca_getEventParam(y,t);
        temp.time_thresh = time_thresh;
        temp.trialID = obj(i).TrialNo;
        temp.ROIid = j;
        temp.ts = t;
        temp.value = trace_orig(onset:offset);
        event = [event temp];
    end
else
    event = [];
end