function scContour(ax, data)
% scContour plots contours in a sigTOOL result window
%
% Examples:
% scContour(axeshandle, data)
% scContour(data)
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

% Plot the contour
[C h]=contour(ax, data.tdata, data.odata, data.rdata);
set(h,'Tag', 'sigTOOL:ResultData');

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

% Set colormap
set(ax, 'CLimMode', 'manual',...
    'Clim', csc);

% Show colorbar
hc=colorbar('Peer', ax, 'Location', 'EastOutside');
ht=get(hc,'Title');
set(ht, 'String', data.rlabel);
pos=get(ht, 'Position');
set(ht, 'Rotation', 90,...
    'Position', [-1 mean(csc) pos(3)]);

% Get rid of default box
set(ax, 'Box', 'off');

% Update figure app data area flag
setappdata(ancestor(ax,'figure'),'sigTOOLViewStyle', '3D')

return
end

