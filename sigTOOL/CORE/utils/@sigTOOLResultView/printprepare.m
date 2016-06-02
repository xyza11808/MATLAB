function [fhandle, AxesPanel, annot, pos, displaymode]=printprepare(obj)
% printprepare helper function for sigTOOLResultView prints
% 
% Example:
% [fhandle, AxesPanel, annot, pos]=printprepare(obj)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

% Revisions:
%   12.03.09    Maintain aspect ratio of graph panel

fhandle=get(obj, 'Parent');
ResultManager=findobj(fhandle, 'Tag', 'sigTOOL:ResultManagerPanel');
hlist=getappdata(fhandle, 'ResultManager');
displaymode=hlist.DisplayMode.getSelectedItem();
if ishandle(ResultManager)
    delete(get(get(ResultManager,'UserData'), 'uipanel'));
    delete(ResultManager);
end

XAxisControls=getappdata(fhandle,'XAxisControls');
if ~isempty(XAxisControls)
    delete(XAxisControls.Panel);
    if ishandle(XAxisControls)
        delete(XAxisControls);
    end
end

h=findobj(fhandle, 'Tag', 'sigTOOL:ShowOnExport');
set(h, 'Visible', 'on')
AxesPanel=findobj(fhandle, 'Tag', 'sigTOOL:AxesPanel');
pos=get(AxesPanel, 'Position');
newpos=pos;
newpos(1)=newpos(1)-((1-newpos(3))/2);
set(AxesPanel, 'Position', newpos);

result=getappdata(fhandle,'sigTOOLResultData');

annot=annotation(fhandle, 'textbox',...
    'Position',[0.5 0 0.4 pos(2)-0.01],...
    'EdgeColor', [1 1 1],...
    'FontSize', 7,...
    'String','Printed from sigTOOL: M. Lidierth (2009) Journal of Neuroscience Methods 178, 188-196.',...
    'Color', [0.5 0.5 0.5]);
if ~isempty(result.acktext)
    annot(2)=annotation(fhandle, 'textbox',...
    'Position',[0.1 0.01 0.35 0.04],...
    'EdgeColor', [1 1 1],...
    'String',result.acktext,...
    'Color', [0.5 0.5 0.5]);
end


warning('off','MATLAB:Print:CustomResizeFcnInPrint');
set(findobj(fhandle, 'Type', 'uicontrol'), 'Visible', 'off');
return
end