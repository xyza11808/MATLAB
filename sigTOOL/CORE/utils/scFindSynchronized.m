function list=scFindSynchronized(channels, chan)
% scFindSynchronized Helper function for sigTOOL uicontrols
%
% scFindSynchronized finds waveform data with syncronized samples
% Waveform channels are considered to be synchronized only if all data
% samples fall within one sample interval of one another.
%
% If Event Filtering is enabled scFindSynchronized will compare only valid
% samples. 
%
% Example:
% ChanList=scFindSynchronized(channels, chan)
% ChanList=scFindSynchronized(fhandle, chan)
% where:
%   channels is a sigTOOL data cell array
%   fhandle is the handle of a sigTOOL data view to take the channels from
%   chan is the template channel to match
%
% ChanList is a vector of waveform channel numbers with synchronized
% samples
%
%
% See also scGetTimePeriod
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © The Author & King’s College London 2006-2007
%-------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:

% 08.11.08
if numel(chan)>1
    chan=chan(1);
end

if isempty(chan) || chan==0
    list=[];
    return
end

[fhandle channels]=scParam(channels);

% Get channels with matching sample rates
interval=prod(channels{chan}.hdr.adc.SampleInterval);
list=scFindMatchingFs(channels, interval);

% Now check the sample times match
TF=zeros(size(list));
maxtime=scMaxTime(channels);

% Get linear indices of valid epochs for template channel
indices1=convTime2ValidIndex(channels{chan}, 0, maxtime);
% Convert indices to times
time1start=convIndex2Time(channels{chan}, indices1(:,1));
time1stop=convIndex2Time(channels{chan}, indices1(:,2));

for i=1:length(list)
    % Repeat for each channel in the list
    k=list(i);
    indices2=convTime2ValidIndex(channels{k}, 0, maxtime);
    time2start=convIndex2Time(channels{chan}, indices2(:,1));
    time2stop=convIndex2Time(channels{chan}, indices2(:,2));
    % Check all start/stop times fall within one sample interval
    TF(i)=all(time1start>=time2start-interval) && all(time1start<=time2start+interval) &&...
        all(time1stop>=time2stop-interval) && all(time1stop<=time2stop+interval);
end
% Return only those channel that are in synch
list=list(TF>0);
return
end
    


