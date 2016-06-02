function scBar(ax, data)
% scBar: standard bar type plot for sigTOOL
%
% Examples:
% scBar(data)
% scBar(ax, data)
%   plot data to the current axes, or those specified in ax.
%
% Data should be a data element from a sigTOOLResultData object
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
if nargin==1
    ax=gca;
    data=ax;
end

if size(data.rdata,1)==1
    view(ax,2);
    h=bar(ax, data.tdata, data.rdata(1, :), 'histc');
    set(h, 'FaceColor', 'none',...
        'EdgeColor', [0 0 0.7],...
        'Tag', 'sigTOOL:ResultData',...
        'UserData', 1);
    set(ax, 'Box', 'off');
    setappdata(ancestor(ax,'figure'),'sigTOOLViewStyle', '2D')
else
    set(ax, 'XLimMode', 'auto');
    set(ax, 'YLimMode', 'auto');
    set(ax, 'ZLimMode', 'auto');
    h=bar3(ax, data.tdata, data.rdata', 'histc');
    set(h, 'Tag', 'sigTOOL:ResultData',...
        'UserData', 1);
    set(ax, 'Box', 'off');
    setappdata(ancestor(ax,'figure'),'sigTOOLViewStyle', '3D Bar')
end

return
end