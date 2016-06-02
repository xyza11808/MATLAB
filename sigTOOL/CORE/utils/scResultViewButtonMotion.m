function scResultViewButtonMotion(hObject, EventData)
% scResultViewButtonMotion button motion callback used in sigTOOL
% 
% This function provides support for data selection in result views
% 
% Example:
% scResultViewButtonMotion(hObject, EventData)
%     standard object callback
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/07
% Copyright © The Author & King’s College London 2007-
%-------------------------------------------------------------------------    
    
% Use rbbox to control rectangle in figure, but use
% positions returned from the current axes

error('Obsolete function');


ax=hittest(hObject);
if ~strcmp(get(ax, 'Type'), 'axes')
    return
end

%set(hObject, 'Pointer', 'crosshair');
pos1=get(ax,'CurrentPoint');
set(ancestor(hObject,'figure'),'WindowButtonMotionFcn',[])
r=rbbox;
set(ancestor(hObject,'figure'),'WindowButtonMotionFcn',scResultViewButtonMotion);
pos2=get(ax,'CurrentPoint');
%set(hObject, 'Pointer', 'watch');
if r(3)+r(4)==0
    % Mouse not currently pressed - rbbox will have
    % returned immediately
    return
end
% Get rid of pre-existing selections
h=findall(ax, 'Tag', 'sigTOOL:SelectedData');
delete(h);

% Get handles for lines
h=findall(ax, 'Tag', 'sigTOOL:ResultData');
% Exclude cursors
% TODO: Would it be better to tag result lines?
exc=findall(ax, 'Tag', 'Cursor');
h=h(~ismember(h,exc));

if isempty(h)
    return
elseif numel(h)>1
    %h=min(h);
end

pos=sort([pos1(1) pos2(1)]);
% Create a context menu
cmenu=uicontextmenu();
uimenu(cmenu, 'Label', 'Curve Fitting', 'Callback', @CurveFitting);
uimenu(cmenu, 'Label', 'Remove Selection', 'Callback', @RemoveSelection);
%uimenu(cmenu, 'Label', 'Summary Statistics', 'Callback', @SummaryStatistics);
uimenu(cmenu, 'Label', 'View Data', 'Callback', @OpenTable);
% For each line - superimpose new line over selected data and activate
% uicontextmenu and double click.

ViewStyle=getappdata(ax, 'sigTOOLViewStyle');

for k=1:length(h)
    xdata=get(h(k), 'XData');
    ydata=get(h(k), 'YData');
    if strcmp(ViewStyle, '3D');
        zdata=get(h(k), 'ZData');
    else
        zdata=zeros(size(ydata));
    end
    TF=xdata>=pos(1) & xdata<=pos(2);
    xdata=xdata(TF>0);
    ydata=ydata(TF>0);
    zdata=zdata(TF>0);
    line(xdata, ydata, zdata,...
        'Color', 'r',...
        'Tag', 'sigTOOL:SelectedData',...
        'UIContextMenu', cmenu,...
        'ButtonDownFcn', {@SelectedDataButtonDownFcn},...
        'UserData', get(h(k), 'UserData'),...
        'Visible', get(h(k), 'Visible'));
end
return
end