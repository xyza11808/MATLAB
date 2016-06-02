function scMakeTempChannel( fhandle, source, target, IntFlag)
% scMakeTempChannel copies data to a temporary sigTOOL channel
% 
% Example
% scMakeTempChannel(fhandle, source, target, IntFlag)
% where
%     fhandle is the handle of a sigTOOL data view
%     source is the channel number of channel to copy
%     target is the channel number to copy data view
%     
% scMakeTempChannel is a gateway to the wvCopyToTempChannel function which
% does most of the work for waveform channels

% Update the figure application data area
wvCopyToTempChannel(fhandle, source, target, IntFlag);
% Refresh the channel manager
scChannelManager(fhandle, true);
% Include the new channel in the display
scDataViewDrawChannelList(fhandle, unique([getappdata(fhandle, 'ChannelList') target]));
return
end