function tp=DisplayMode(tp)
% DisplayMode - private function used by result manager
%
% Example:
% tp=DisplayMode(tp)
%   sets up the display mode dialog in the sigTOOL Result Manager
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 1/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

% Supported display modes
displaymodes={'Single Frame','Multiple Frames','Waterfall', 'Column','Bars', 'Image','Surface','Contour','Scatter'};

pos=getPosition(tp);

% Set up combobox
tp.DisplayMode=jcontrol(tp.Panel, 'javax.swing.JComboBox',...
    'MaximumRowCount', length(displaymodes),...
    'Position',pos);
tp.DisplayMode.setKeySelectionManager([]);
addLabel(tp.DisplayMode, 'Display Mode');

% Populate it
for k=1:length(displaymodes)
    tp.DisplayMode.addItem(displaymodes{k});
end

% Set current value
fhandle=ancestor(tp.Panel, 'figure');
opt=getappdata(fhandle, 'sigTOOLResultOptions');


n=find(cellfun(@any, strfind(lower(displaymodes), lower(opt.displaymode))));
if n>0
    tp.DisplayMode.setSelectedIndex(n-1);
end
if isempty(n) && strcmpi(opt.displaymode, 'custom')
    tp.DisplayMode.setEnabled(false);
    tp.DisplayMode.addItem('Custom');
    tp.DisplayMode.setSelectedItem('Custom');
end

tp.DisplayMode.ActionPerformedCallback=@ActionPerformedCallback;
return
end


function ActionPerformedCallback(hObject, EventData)
mode=hObject.getSelectedItem();
fhandle=ancestor(hObject.hghandle, 'figure');
set(fhandle, 'Pointer', 'watch');
drawnow();
tp=getappdata(fhandle, 'ResultManager');
if isempty(tp)
    return
end
AxesList=getappdata(fhandle, 'AxesList');
AxesList=AxesList(AxesList>0);

result=getappdata(fhandle, 'sigTOOLResultData');

switch mode
    case 'Single Frame'
        tp.Frames.setEnabled(1);
        LocalRefresh2D(fhandle);
        result.plotstyle={@scFrames};
        h=plot(fhandle, result);
        target=getappdata(h, 'ResultManager');
        target.Frames.setText('1');
        target.DisplayMode.setSelectedItem(1);
        tp.Frames.postActionEvent();
    case 'Multiple Frames'
        tp.Frames.setEnabled(1);
        LocalRefresh2D(fhandle);
        result.plotstyle={@scFrames};
        h=plot(fhandle, result);
        target=getappdata(h, 'ResultManager');
        target.Frames.setText('1:end');
    case 'Waterfall'
        tp.Frames.setEnabled(1);
        RemoveCursors(fhandle);
        LocalRefresh2D(fhandle);
        result.plotstyle={@scWaterfall};
        plot(fhandle, result);
        tp.Frames.setText('1:end');
    case 'Column'
        tp.Frames.setEnabled(1);
        RemoveCursors(fhandle);
        LocalRefresh2D(fhandle);
        result.plotstyle={@scColumn};
        plot(fhandle, result);
        tp.Frames.setText('1:end');
    case 'Bars'
        tp.Frames.setEnabled(1);
        LocalRefresh2D(fhandle);
        result.plotstyle={@scBar};
        plot(fhandle, result);
    case 'Image'
        tp.Frames.setEnabled(0);
        RemoveCursors(fhandle);
        LocalRefresh2D(fhandle);
        result.plotstyle={@scImagesc};
        plot(fhandle, result);
    case 'Surface'
        tp.Frames.setEnabled(0);
        RemoveCursors(fhandle);
        LocalRefresh2D(fhandle);
        result.plotstyle={@scSurf};
        plot(fhandle, result);
    case 'Contour'
        tp.Frames.setEnabled(0);
        RemoveCursors(fhandle);
        LocalRefresh2D(fhandle);
        result.plotstyle={@scContour};
        plot(fhandle, result);
    case 'Scatter'
        tp.Frames.setEnabled(0);
        RemoveCursors(fhandle);
        LocalRefresh2D(fhandle);
        result.plotstyle={@scScatter};
        plot(fhandle, result);
    otherwise
end

tp=getappdata(fhandle,'ResultManager');
if ~isempty(tp)
    h=findobj(fhandle,'Tag','Colorbar');
    if isempty(h)
        tp.Options3D.colorbar.setSelected(0);
    else
        tp.Options3D.colorbar.setSelected(1);
    end
end

scRefreshResultManagerAxesLimits(fhandle);

set(fhandle, 'Pointer', 'arrow');
return
end


function LocalRefresh2D(fhandle)
h=findobj(fhandle, 'Tag', 'Colorbar');
delete(h);
h=findobj(fhandle, 'Tag', 'sigTOOL:ResultData');
delete(h);
h=findobj(fhandle, 'Tag', 'sigTOOL:ErrorData');
delete(h);
h=findobj(fhandle, 'Tag', 'sigTOOL:SelectedData');
delete(h);
h=findobj(fhandle, 'Type', 'Image');
delete(h);
return
end

function RemoveCursors(fhandle)
cursor=getappdata(fhandle, 'VerticalCursors');
for i=1:length(cursor)
    DeleteCursor(fhandle, i);
end
return
end