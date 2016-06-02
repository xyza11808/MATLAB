eventTiming = CaEventDetector(trace,thr,dthr,slope_span,slopeThresh); 
t = (onset:offset).*unitTime;
y = trace(onset:offset);
if length(y)< 4
	event(i) = Ca_getEventParam(y,t);
end

