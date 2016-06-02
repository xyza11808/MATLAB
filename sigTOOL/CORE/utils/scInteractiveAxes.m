function scInteractiveAxes(ax, action)
% scInteractiveAxes coordinates cursor control over axes limits
% in a sigTOOL result view
%
% Example:
% scInteractiveAxes(ax)
%     activates interactive control on the specified set of axes
% scInteractiveAxes(ax, 'off')   
%     deactivates interaction
% 
% When activated, scInteractiveAxes allows the user to
%   [1] Drag the zero tick to a new position
%   [2] Stretch or compress an axis by dragging a non-zero tick to a new
%   position
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


    
switch nargin
    case 0
        ax=gca;
    case 1
    case 2
        if strcmpi(action, 'off')==1
            if ishandle(ax)
            h=findall(ax, 'Tag', 'sigTOOL:XTick');
            delete(h);
            h=findall(ax, 'Tag', 'sigTOOL:YTick');
            delete(h);
%             set(ax, 'LineWidth', 1.5);
            set(ax, 'Selected', 'off');
            scRefreshResultManagerAxesLimits(ancestor(ax, 'figure'));
            end
            return
        end
end


if ~is2D(ax)
    % Only works with 2D views
    scRefreshResultManagerAxesLimits(ancestor(ax, 'figure'));
    return
end

% Deselect any presently selected axes
fh=ancestor(ax, 'figure');
h=findall(fh, 'Tag', 'sigTOOL:XTick');
delete(h);
h=findall(fh, 'Tag', 'sigTOOL:YTick');
delete(h);
h=findall(fh, 'Type', 'axes');
% set(h, 'LineWidth', 1.5);
set(h, 'Selected', 'off');

% Select target axes
set(ax, 'Selected', 'on');

% set(ax, 'LineWidth', 3);

XLim=get(ax, 'XLim');
YLim=get(ax, 'YLim');

% Place an invisible text box over each axis tick
% The button down callbacks for these text boxes coordinate the changes to
% the axes
xt=get(ax, 'XTick');
for i=1:length(xt)
    h=text(xt(i), YLim(1), ' ',...
        'HorizontalAlignment', 'Center',...
        'BackgroundColor', 'None',...
        'EdgeColor', 'None',...
        'FontSIze', 16,...
        'LineWidth', 1,...
        'ButtonDownFcn', @XLocalButtonDownFcn,...
        'UserData', [xt(i), YLim(1)],...
        'Clipping', 'off',...
        'Tag', 'sigTOOL:XTick');
    set(h, 'Units', 'normalized');
end

yt=get(ax, 'YTick');
for i=1:length(yt)
    h=text(XLim(1), yt(i), '     ',...
        'HorizontalAlignment', 'Center',...
        'BackgroundColor', 'None',...
        'EdgeColor', 'None',...
        'FontSIze', get(ax, 'FontSize'),...
        'LineWidth', 1,...
        'ButtonDownFcn', @YLocalButtonDownFcn,...
        'UserData', [0 yt(i)],...
        'Clipping', 'off',...
        'Tag', 'sigTOOL:YTick');
    set(h, 'Units', 'normalized');
end

% Update other axis controls in the figure with the new settings
scRefreshResultManagerAxesLimits(ancestor(ax, 'figure'));
end


function XLocalButtonDownFcn(hObject, EventData)
setptr(ancestor(hObject,'figure'),'lrdrag');
ax=ancestor(hObject,'axes');
start=get(hObject, 'UserData');
rbbox();
setptr(ancestor(hObject,'figure'),'arrow');
new=get(ax, 'CurrentPoint');
XLim=get(ax, 'XLim');
if start(1)==0
    XLim=XLim-new(1,1);
else
    r=start(1)/new(1,1);
    XLim=XLim*r; 
end
try
    set(ax, 'XLim', XLim);
    scInteractiveAxes(ax, 'off');
    scInteractiveAxes(ax);
catch
    % XLim may be invalid - ignore error
end
return
end

function YLocalButtonDownFcn(hObject, EventData)
setptr(ancestor(hObject,'figure'),'uddrag');
ax=ancestor(hObject,'axes');
start=get(hObject, 'UserData');
rbbox();
setptr(ancestor(hObject,'figure'),'arrow');
new=get(ax, 'CurrentPoint');
YLim=get(ax, 'YLim');
if start(2)==0
    YLim=YLim-new(1,2);
else
    r=start(2)/new(1,2);
    YLim=YLim*r; 
end
try
    set(ax, 'YLim', YLim);
    scInteractiveAxes(ax, 'off');
    scInteractiveAxes(ax);
catch
    % YLim invalid - ignore
end

return
end

