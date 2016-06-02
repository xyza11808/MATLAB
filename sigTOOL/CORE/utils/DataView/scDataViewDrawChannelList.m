function scDataViewDrawChannelList(fhandle, ChannelList)
% scDataViewDrawChannelList draws channels to a sigTOOL data view
% 
% Example
% scDataViewDrawChannelList(fhandle, ChannelList)
% fhandle is the figure handle
% ChannelList is the list of channels to draw
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------

channels=getappdata(fhandle, 'channels');

if nargin<2 || isempty(ChannelList)
    ChannelList=getappdata(fhandle, 'ChannelList');
else
    ChannelList=scGenerateChannelList(channels, ChannelList);
end

if isempty(ChannelList)
    return
end

% Store the cursor locations
c=getappdata(fhandle,'VerticalCursors');
x=zeros(length(c),1);
for i=1:length(c)
    if ~isempty(c)
        x(i)=GetCursorLocation(i);
        DeleteCursor(i);
    end
end
h=findobj(fhandle, 'Type', 'line');
if ~isempty(h)
    SmoothState=get(h(1), 'LineSmoothing');
else
    SmoothState='off';
end

% Delete the  present axes
ChannelList=ChannelList(ChannelList<=length(channels));
h=findobj(fhandle,'Type','Axes');
if ~isempty(h)
    XLim=get(h(end), 'XLim');
    delete(h);
else
    XLim=[0 1];
end


% Recreate the figure
setappdata(fhandle,'ChannelList',ChannelList);
channels=[]; %#ok<NASGU>
scCreateDataView(fhandle, XLim(1), XLim(2));

% Restore the cursors
% TODO: check this out for multi cursors
if isappdata(fhandle,'VerticalCursors')
    rmappdata(fhandle,'VerticalCursors');
end
for i=1:length(x)
    if ~isempty(x(i))
        CreateCursor(fhandle, i);
        SetCursorLocation(fhandle, i, x(i));
    end
end
if strcmp(SmoothState,'on')
    scLineSmoothing(true);
end

return
end
