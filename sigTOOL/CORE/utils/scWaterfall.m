function scWaterfall(ax, data)
% scWaterfall generates a standard sigTOOL Waterfall plot
% 
% Example
% scWaterfall(ax, data)
% where ax is the target axes (deafults to gca)
% data is an element from a sigTOOLResultData.Data field
% 
% % -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
%

if nargin==1
    ax=gca;
    data=ax;
end

if isempty(data.odata)
    return
end

% Replaced for forwards compatability 28.06.09
% T=[  0.9010,      0.4339,     0,    -0.6674;
%     -0.3579,    0.7431,     0.5654, -0.4753;
%     -0.2453,    0.5094,    -0.8248, 20.8915;
%     0,         0,          0,      1.0000];
% view(ax,T);
view(ax, [25.7114, 55.5700]);

set(ax, 'XLimMode', 'auto');
set(ax, 'YLimMode', 'auto');
set(ax, 'ZLimMode', 'auto');

if isempty(data.odata)
    return
elseif isvector(data.odata)
    z=zeros(size(data.rdata));
    for k=1:length(data.odata)
        z(k,:)=data.odata(k);
    end
end

for k=1:size(data.rdata, 1)
    if isfield(data, 'barFlag') && data.barFlag==true
        [x,zz]=stairs(data.tdata, data.rdata(k,:));
        line('Parent', ax,...
            'XData', x,...
            'YData', (k-1)*ones(size(x)),...
            'ZData', zz,...
            'Color', [0.1 0.1 0.5],...
            'Tag', 'sigTOOL:ResultData',...
            'UserData', k);
    else
        line('Parent', ax,...
            'XData', data.tdata,...
            'YData', z(k,:),...
            'ZData', data.rdata(k,:),...
            'Color', [0.1 0.1 0.5],...
            'Tag', 'sigTOOL:ResultData',...
            'UserData', k);
    end
end

% set(ax, 'XLim',[min(data.tdata) max(data.tdata)]);
% set(ax, 'YLim',[min(z(:)) max(z(:))]);
% set(ax, 'ZLim',[min(data.rdata(:)) max(data.rdata(:))]);
% set(ax, 'XLimMode', 'manual');
% set(ax, 'YLimMode', 'manual');
% set(ax, 'ZLimMode', 'manual');

setappdata(ancestor(ax,'figure'),'sigTOOLViewStyle', '3D')

return
end
