function scImagesc(ax, data)
% scImagesc plots images in a sigTOOL result window
%
% Example
% scImagesc(axeshandle, data)
% scImagesc(data)
%
% where
%       axeshandle  is the handle of the target axes (gca if omitted)
%       data        is the data to plot (an element from a
%                       sigTOOLResultData object data field)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

if nargin==1
    ax=gca;
    data=ax;
end

if isempty(data.odata)
    return
end


% Data limits for colormap: this ignores NaNs
mn=min(min(data.rdata));
mx=max(max(data.rdata));
if mn>=0
    csc=[0 mx];
elseif mn<0 && mx<0
    csc=[mn 0];
else
    csc=max(abs([mn,mx]));
    csc=[-csc csc];
end

% Plot the surface
h=imagesc(data.tdata, data.odata, data.rdata, ...
    'Parent', ax,...
    'Hittest', 'off');
set(ax,'CLim',csc);
if length(data.tdata)==length(data.odata) && sum(data.tdata-data.odata)==0
    set(h, 'UserData', 'sigTOOL:SYMMETRIC');
end
set(ax, 'YDir', 'normal',...
    'XLim', [min(data.tdata) max(data.tdata)],...
    'YLim', [min(data.odata) max(data.odata)]);

% Add colorbar
hc=colorbar('Peer', ax, 'Location', 'EastOutside');
ht=get(hc,'Title');
set(ht, 'String', data.rlabel);
pos=get(ht, 'Position');
set(ht, 'Rotation', 90,...
    'Position', [-1 mean(csc) pos(3)]);

% Set flag in app data area
setappdata(ancestor(ax,'figure'),'sigTOOLViewStyle', 'pseudo3D')
return
end