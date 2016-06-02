function time=scMaxSeconds(varargin)
% scMaxSeconds returns the maximum sample time from all channels
% 
% Examples
% time=scMaxSeconds(fhandle)
% time=scMaxSeconds(channels)
% 
% time is returned in seconds
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

error('Is this obsolete')

[fhandle channels]=scParam(varargin{1});

time=0;
for i=1:length(channels)
    if ~isempty(channels{i})&& channels{i}.tim(end)>time
        time=channels{i}.tim(end)*channels{i}.tim.Units;
    end
end