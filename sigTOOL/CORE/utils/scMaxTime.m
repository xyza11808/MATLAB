function time=scMaxTime(varargin)
% scMaxTime returns the maximum sample time in seconds
% 
% Example
% time=scMaxTime(fhandle)
% time=scMaxTime(channels)
%     where
%     fhandle is a sigTOOL data view figure handle
%     channels is an scchannel object or cell array of scchannel objects
%     
%     time is maximum sample time in seconds
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-2007
% -------------------------------------------------------------------------
    
[fhandle channels]=scParam(varargin{1});
time=0;
for i=1:length(channels)
    if ~isempty(channels{i})&& channels{i}.tim(end)>time
        time=channels{i}.tim(end);
        chan=i;
    end
end
% Convert to seconds
time=time*channels{chan}.tim.Units;
return
end