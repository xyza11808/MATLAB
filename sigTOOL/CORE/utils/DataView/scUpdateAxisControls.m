function scUpdateAxisControls(fhandle, caller, ax)
% scUpdateAxisControls updates the x-axis controls in a sigTOOL data view

% Revisions:
% 21.08.09  Add ax as optional input
% 27.09.09  Deal with ax as a vector of handles
% 25.10.09  Remove setting of axes x limits

desc=scGetFigureType(fhandle);
if isempty(desc)
    return
end

% Find the x-axis range and update x-axis slider properties
AxesList=getappdata(fhandle, 'AxesList');
AxesList=AxesList(AxesList>0);
if nargin<3
    XLim=get(AxesList(end),'XLim');
elseif isscalar(ax)
    XLim=get(ax,'XLim');
else
    % 27.09.09 ax is vector of handles
    h=findall(fhandle, 'Type', 'axes', 'Selected', 'on');
    if isempty(h)
        return
    end
    XLim=get(h,'XLim');
end
% set(AxesList, 'XLim', XLim);
h=getappdata(fhandle, 'XAxisControls');

switch caller
    case {'xmin' 'xmax' 'increase' 'reduce' 'resultmanager'}
        fcn=h.Slider.AdjustmentValueChangedCallback;
        h.Slider.AdjustmentValueChangedCallback=[];
        h.Slider.setValue(XLim(1)*1000);
        range=XLim(2)-XLim(1);
        h.Slider.Model.setExtent(range*1000);
        h.Slider.AdjustmentValueChangedCallback=fcn;
    case 'slider'
        % No longer called by slider
end

% All
set(h.MinText, 'Text', num2str(XLim(1)));
set(h.MaxText, 'Text', num2str(XLim(2)));

% First, clean up the axes
AllAxes=findobj(fhandle, 'Type', 'axes');
scCleanUpAxes(AllAxes);
scDataViewDrawData(fhandle);

if strcmpi(caller, 'resultmanager')==0
    scRefreshResultManagerAxesLimits(fhandle);
end

return
end