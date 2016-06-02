function phase=getPhase(trigobj, eventobj, start, stop)
% getPhase returns the phase of an event during a cycle
% 
% Examples:
% phase=getPhase(trigchannel, eventchannel)
% phase=getPhase(trigchannel, eventchannel, start, stop)
%
% returns the phase of the events in eventchannel in relation to the cycles
% defined by the events in trigchannel
%
% If defined, start and stop give the time period to use. Otherwise these
% default to start=0 and stop=Inf.
%  
% The output, phase, is a double precision vector. For each element, the
% fractional part represents the phase while the non-fractional part
% represents the number of the valid cycle that each event occurred
% in. Thus phase=2.75 indicates that an event occurred 3/4 of the way
% through the second valid cycle in the period start to stop.
%
% Only valid events in eventchannel will be used. For triggers, only
% valid events will be used to mark the start of a cycle but all physical 
% events will be searched for the end of cycle marker (i.e for the start
% of the subsequent cycle). This is useful when there are breaks in the
% data e.g. if there are 10 cycles but the 10th was interrupted, mark 1-9 as
% valid. Only these will be used for triggers but the onset of the
% interupted 10th cycle will be used to determine the length of the 9th
% cycle for calculating phase correctly.
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
% 

if nargin<3
    start=0;
end

if nargin<4
    stop=Inf;
end

% Get triggers and cyclelengths
strig=getValidTriggers(trigobj, start, stop);
etrig=getPhysicalTriggers(trigobj, start, stop);
cyclelength=zeros(size(strig));
for k=1:length(strig)-1
    cyclelength(k)=etrig(find(etrig==strig(k),1)+1)-strig(k);
end

% Get events
events=getValidTriggers(eventobj, start, stop);

% Now calculate the phases
idx=find(events>strig(1), 1);
phase=zeros(length(events), 1);
k=1;
for tr=1:length(strig)-1
    stop=strig(tr)+cyclelength(tr);
    while events(idx)<stop
        phase(k)=tr+(events(idx)-strig(tr))/cyclelength(tr);
        idx=idx+1;
        k=k+1;
    end        
end

% Trim
phase=phase(1:k-1);
return
end

