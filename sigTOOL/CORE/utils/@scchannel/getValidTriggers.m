function [trig, markers]=getValidTriggers(channel, start, stop)
% getValidTriggers returns all valid trigger times over a time period
% 
% Example:
% trig=getValidTriggers(channel, start, stop)
% [trig markers]=getValidTriggers(channel, start, stop)
% where
%     channel is an scchannel object
%     start is the start time for the search
%     stop is the stop time for the search
%     
%     trig is a vector of trigger time
%     markers, when specified, are the marker data associated with the each
%           valid trigger
%
% Returns triggers for all valid events/epoochs where
%               start <= channel.tim(:, 1) <= stop
%     
% Trigger times are those in column 1 of channel.tim if it has 1 or 2 columns
% or those in column 2 if it has 3 columns (i.e. an explicit trigger time is
% present
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
% 
% Revisions:
%   16.05.09    Add optional marker output

% Find the trigger times
epochs=convTime2ValidEpochs(channel, start, stop);
if size(channel.tim, 2)==3
    trig=channel.tim(epochs, 2);
else
    trig=channel.tim(epochs, 1);
end

% Added 16.05.09
if nargout==2
    markers=channel.mrk(epochs,:);
end

return
end
