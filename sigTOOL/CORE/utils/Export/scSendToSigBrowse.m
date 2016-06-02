function scSendToSigBrowse(varargin)
% scSendToSigBrowse sends a waveform channel to TMW's spTOOL
%
% Revisions:
%   27.12.09    Updated to use scchannel methods
%

% Axes or figure?
switch get(varargin{1}, 'Type')
    case 'axes'
        % Click on axes
        hObject=varargin{1};
    case {'hggroup' 'line'}
        % Click on line etc
        hObject=ancestor(varargin{1},'axes');
end


fhandle=ancestor(hObject,'figure');
XLim=get(gca,'XLim');
ChannelNumber=getappdata(gca, 'ChannelNumber');
data=getappdata(fhandle,'channels');
tu=data{ChannelNumber}.tim.Units;
XLim=XLim*(1/tu);
data=getData(data{ChannelNumber},XLim(1),XLim(2));
% Load the first column of data into sptool
% - multiple columns not supported
if ~isempty(data.adc)
    lbl='sigTOOL';
    s=sptool('load','Signal',data.adc(:,1),...
        getSampleRate(data),...
        lbl);
    % sptool may have an axes cluttering the view - turn that off
    h=findobj('Tag','sptool');
    h=findobj(h,'Type','axes');
    set(h,'Visible','off');
    sigbrowse('action','view');
end