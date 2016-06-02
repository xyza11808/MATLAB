function [fhandle, AxesPanel, annot, pos]=printprepare(obj)
% printprepare helper function for sigTOOLResultView prints
% 
% Example:
% [fhandle, AxesPanel, annot, pos]=printprepare(obj)

fhandle=get(obj, 'Parent');
ChannelManager=findobj(fhandle, 'Tag', 'sigTOOL:ChannelManagerPanel');
if ishandle(ChannelManager)
    delete(get(get(ChannelManager,'UserData'), 'uipanel'));
    delete(ChannelManager);
end
XAxisControls=getappdata(fhandle,'XAxisControls');
delete(XAxisControls.Panel);
if ishandle(XAxisControls)
    delete(XAxisControls);
end
h=findobj(fhandle, 'Tag', 'sigTOOL:ShowOnExport');
set(h, 'Visible', 'on')
AxesPanel=findobj(fhandle, 'Tag', 'sigTOOL:AxesPanel');
pos=get(AxesPanel, 'Position');
set(AxesPanel, 'Position', [0 0 1 1],...
    'BackgroundColor', 'w');
annot=annotation(fhandle, 'textbox',...
    'Position',[0.65 0.01 0.3 0.04],...
    'EdgeColor', [1 1 1],...
    'String','Printed from sigTOOL \copyright King''s College London',...
    'Color', [0.5 0.5 0.5]);
warning('off','MATLAB:Print:CustomResizeFcnInPrint');
set(findobj(fhandle, 'Type', 'uicontrol'), 'Visible', 'off');
return
end