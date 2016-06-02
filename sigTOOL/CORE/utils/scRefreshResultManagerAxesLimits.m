function scRefreshResultManagerAxesLimits(fhandle)
% scRefreshResultManagerAxesLimits updates the Result Manager axes limits
% boxes
%
% Example:
% scRefreshResultManagerAxesLimits(fhandle)
% where fhandle is the handle of a sigTOOL result view
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

ax=findall(fhandle, 'Type', 'axes', 'Selected', 'on');
tp=getappdata(fhandle, 'ResultManager');

if isempty(tp)
    return
end

s=tp.AxesLimits;
if isempty(ax)
    s.XMin.setText('');
    s.XMax.setText('');
    s.YMin.setText('');
    s.YMax.setText('');
    s.ZMin.setText('');
    s.ZMax.setText('');
else
    x=get(ax, 'XLim');
    s.XMin.setText( num2str(x(1), 4));
    s.XMax.setText(num2str(x(2), 4));
    y=get(ax, 'YLim');
    s.YMin.setText( num2str(y(1), 4));
    s.YMax.setText(num2str(y(2), 4));
    if ~is2D(ax)
        z=get(ax, 'ZLim');
        s.ZMin.setText( num2str(z(1), 4));
        s.ZMax.setText(num2str(z(2), 4));
    else
        s.ZMin.setText('');
        s.ZMax.setText('');
    end
end

% Check calling function to avoid infinite loop
st=dbstack();
for i=1:length(st)
    if strcmpi(st(i).name, 'scUpdateAxisControls');
        % Avoid infinite loop by returning
        return
    end
end

if ~isempty(ax)
    scUpdateAxisControls(fhandle, 'resultmanager', ax);
end
return
end