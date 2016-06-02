function scFilter(fhandle, source, target, IntFlag, Hd)
% scFilter is a gateway to the sigTOOL filter functions
% 
% Example
% scFilter(fhandle, source, target, intflag, hd)
% where
%     fhandle   is the handle of a sigTOOL data view
%     source    is the channel number of channel to copy
%     target    is the channel number to copy data view
%     intflag   indicates whether data should be cast to integer after
%                   filtering (true/false)
%     hd        is a dfilt filter object
%     
% scFilter is a gateway to the wvFilter function which
% does most of the work
%
% See also dfilt, wvFilter
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
%

% Revisions:
% 26.10.08  Add support for wvFFTFilt
% 04.11.08  wvFiltFilt/wvFFTFilt now obsolete. Replaced with wvFilter         

% Filter the data
wvFilter(fhandle, source, target, IntFlag, Hd);

% Refresh the channel manager
scChannelManager(fhandle, true);
% Include the new channel in the display
scDataViewDrawChannelList(fhandle, unique([getappdata(fhandle, 'ChannelList') target]));
return
end