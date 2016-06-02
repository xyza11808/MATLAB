function plot_Ca_event(event,h_axis)

if ~exist('h_axis')
    h_axis = gca;
end
t = event.ts;
y = event.value;

t_rise = event.t_rise;
y_rise = event.y_rise;
t_decay = event.t_decay;
y_decay = event.y_decay;

riseP = event.riseExpFitParam;
decayP = event.decayExpFitParam;

if ~isnan(riseP)
    f_rise = riseP(1) + riseP(2)*exp(-t_rise/riseP(3));
else
    f_rise = NaN;
end;
if ~isnan(decayP)
    f_dec = decayP(1) + decayP(2)*exp(-t_decay/decayP(3));
else
    f_dec = NaN;
end;
axes(h_axis); hold on;

plot(t,y, 'r');

plot(event.local_max_time,event.local_max,'c*');
if ~isnan(f_rise)
    plot(t_rise, f_rise,'g');
end
if ~isnan(f_dec)
    plot(t_decay,f_dec,'g');
end
% plot([t1 t2], [event.peak/2 event.peak/2], 'y');
hold off