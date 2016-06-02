function time=scMinTime(varargin)
% scMinTime returns the minimum sample time in seconds
% 
% Example
% time=scMinTime(fhandle)
% time=scMinTime(channels)
%     where
%     fhandle is a sigTOOL data view figure handle
%     channels is an scchannel object or cell array of scchannel objects
%     
%     time is first sample time in seconds
%
% scMinTime is needed as sampling does not always begin at time zero.

% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-2007
% -------------------------------------------------------------------------
if ishandle(varargin{1})
    channels=getappdata(varargin{1},'channels');
else
    channels=varargin{1};
end

time=Inf;
for i=1:length(channels)
    if ~isempty(channels{i}) && channels{i}.tim(1)<time
        time=channels{i}.tim(1);
        chan=i;
    end
end
% Convert to seconds
time=time*channels{chan}.tim.Units;
return
end
