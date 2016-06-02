function scSurf(ax, data)
% scSurf plots surfaces in a sigTOOL result window
%
% Example
% scSurf(axeshandle, data)
% scSurf(data)
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

% Plot the surface
h=surf(ax, data.tdata, data.odata, data.rdata);
set(h, 'FaceColor', 'interp',...
    'FaceLighting', 'phong',...
    'Tag', 'sigTOOL:ResultData',...
    'EdgeColor', 'none');

% Replaced for forwards compatability 28.06.09
% T=[  0.9010,      0.4339,     0,    -0.6674;
%     -0.3579,    0.7431,     0.5654, -0.4753;
%     -0.2453,    0.5094,    -0.8248, 20.8915;
%     0,         0,          0,      1.0000];
% view(ax,T);
view(ax, [25.7114, 55.5700]);

% Set data limits for colormap: this ignores NaNs
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

% Add colorbar
hc=colorbar('Peer', ax, 'Location', 'EastOutside');
ht=get(hc,'Title');
set(ht, 'String', data.rlabel);
pos=get(ht, 'Position');
set(ht, 'Rotation', 90,...
    'Position', [-1 mean(csc) pos(3)]);

% Set flag in app data area
setappdata(ancestor(ax,'figure'),'sigTOOLViewStyle', '3D')
return
end