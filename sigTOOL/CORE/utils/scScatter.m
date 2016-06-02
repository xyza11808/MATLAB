function scScatter(ax, data)
% scScatter generates a standard sigTOOL scatter plot
% 
% Example
% scScatter(ax, data)
% where ax is the target axes (deafults to gca)
% data is an element from a sigTOOLResultData.Data field
% 
% % -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

if nargin==1
    ax=gca;
    data=ax;
end

if numel(data.tdata)~=numel(data.rdata)
    return
end

view(ax,2);

h=scatter(ax, data.tdata, data.rdata);
set(h, 'Tag', 'sigTOOL:ResultData',...
        'UserData', 1,...
        'Sizedata', 3);
set(ax, 'Box', 'off');
XLim=get(ax, 'XLim');
YLim=get(ax, 'YLim');
if XLim(1)>0
    XLim(1)=0;
    set(ax, 'XLim', XLim);
end
YLim(2)=max(data.rdata);
if YLim(1)>0
    YLim(1)=0;  
end
set(ax, 'YLim', YLim);
setappdata(ancestor(ax,'figure'),'sigTOOLViewStyle', '2D')
return
end