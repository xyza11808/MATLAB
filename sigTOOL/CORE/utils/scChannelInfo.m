function scChannelInfo(handle, channel)
% SCCHANNELINFO displays information about a channel in a sigTOOL figure
% 
% Example:
% SCCHANNELINFO(HANDLE, CHANNEL)
% where HANDLE is the handle of the figure, and CHANNEL is the channel number
%
% Toolboxes required: None
%
% Author: Malcolm Lidierth 07/06
% Copyright © King’s College London 2006
%
% Acknowledgements:
% Revisions:

chan=getappdata(handle,'channels');
disp(chan{channel});
end
