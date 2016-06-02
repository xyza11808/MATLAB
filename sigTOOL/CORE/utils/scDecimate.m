function scDecimate(fhandle, source, target, IntFlag, r)
% scDecimate is a gateway to the wvDecimate function
% 
% Example
% scDecimate(fhandle, source, target, intflag)
% where
%     fhandle is the handle of a sigTOOL data view
%     source is the channel number of channel to copy
%     target is the channel number to copy data view
%     intflag indicates whether data should be cast to integer after
%       filtering (true/false)
%     r is the downsampling factor
% scDecimate is a gateway to the wvDecimate function which
% does most of the work
%
% See also wvFiltFilt
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

% Filter the data
wvDecimate(fhandle, source, target, IntFlag, r);
% Refresh the channel manager
scChannelManager(fhandle, true);
% Include the new channel in the display
scDataViewDrawChannelList(fhandle, unique([getappdata(fhandle, 'ChannelList') target]));
return
end