function ph=plot(varargin)
% plot method overloaded for jpeth class
% 
% Examples:
% ph=plot(obj)
%     plots the object in a new figure
% ph=plot(handle, obj)
%     plots the object in the figure or uipanel specified by handle
%     
% ph is the handle of the parent figure or uipanel of the plot
% 
% Note, if no output arguments are specified, the handle property of the jpeth
% object in the calling workspace will be updated with the value of ph
% where this is possible (i.e. where the object is a named variable
% in the calling workspace resolvable by a call to inputname(...)).
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

switch nargin
    case 0
        return
    case 1
        % No parent specified
        obj=varargin{1};
        fhandle=figure();
        mataxes=gca;
        ph=fhandle;
        obj.handle=fhandle;
        if nargout==0 && ~isempty(inputname(1))
             assignin('caller', inputname(1), obj);
        end
    case 2
        % Parent in first argument
        [fhandle mataxes]=setparent(varargin{1});
        obj=varargin{2};
        ph=get(mataxes, 'Parent');
        obj.handle=ph;
        if nargout==0 && ~isempty(inputname(2))
             assignin('caller', inputname(2), obj);
        end
    otherwise
        [fhandle mataxes]=setparent(varargin{3});
        ph=get('Parent', mataxes);
        obj=varargin{1}; 
        obj.handle=ph;
        if nargout==0 && ~isempty(inputname(1))
             assignin('caller', inputname(1), obj);
        end
end

% Problems with OpenGL - user painters
set(fhandle, 'Renderer', 'painters');
% Orient
orient(fhandle, 'landscape');

% Matrix
matrix=getMatrix(obj);
% Set timebase in ms
tb=obj.tbase*obj.tscale*1e3;
bw=getBinWidth(obj);
% Plot matrix
pl=obj.display(tb-bw/2, tb-bw/2, matrix, 'Parent', mataxes, 'Hittest', 'off');
switch func2str(obj.display)
    case 'surf'
        set(mataxes, 'XLim', [tb(1) tb(end)],...
        'YLim', [tb(1) tb(end)],...
        'ZLim', [min(min(matrix)) max(max(matrix))],...
        'Hittest', 'off');
        set(pl, 'EdgeColor', 'none');
end
set(mataxes, 'YDir', 'normal',...
    'Units', 'normalized',...
    'XTickLabelMode', 'manual',...
    'XTickLabel',[],...
    'YTickLabelMode', 'manual',...
    'YTickLabel',[]);
title(mataxes, obj.mode);
set(mataxes, 'Position', [0.2 0.3 0.25 0.25]);
set(mataxes, 'Units', 'pixels');
p=get(mataxes, 'Position');
set(mataxes, 'ButtonDownFcn', {@MatrixCallback tb matrix});


% Set data limits for colormap: this ignores NaNs
mn=min(min(matrix));
mx=max(max(matrix));
if mn>=0
    csc=[0 mx];
elseif mn<0 && mx<0
    csc=[mn 0];
else
    csc=max(abs([mn,mx]));
    csc=[-csc csc];
end

% Set colormap
set(mataxes, 'CLimMode', 'manual',...
    'Clim', csc);

t=max([p(3) p(4)]);
set(mataxes, 'Position', [p(1) p(2) t t]);
p=get(mataxes, 'Position');
set(mataxes, 'Units', 'normalized');


%PETH1
h=axes('Parent', ph, 'Position', [0.2 0.1 0.25 0.15]);
set(h, 'Units', 'pixels');
p1=get(h, 'Position');
p1(3)=t;
set(h, 'Position', p1);
x=obj.peth1;
h1=bar(tb, x, 'histc');
set(h1, 'Hittest', 'off');
set(h, 'XLim', [min(tb) max(tb)]);
set(h, 'Color', 'none', 'GridLineStyle', 'none', 'Box', 'off',...
    'YAxisLocation', 'right');
set(h, 'Units', 'normalized',...
    'ButtonDownFcn', {@LocalCallback tb x});
x=get(h, 'XLim');
y=get(h,'YLim');
title(h, 'PETH 1', 'Position', [x(1) y(2)],...
    'HorizontalAlignment', 'left');

% PETH2
h=axes('Parent', ph, 'Position', [0.01 0.3 0.15 0.25]);    
set(h, 'Units', 'pixels');
p2=get(h, 'Position');
p2(4)=t;
set(h, 'Position', p2);
x=obj.peth2;
h2=bar(tb, x, 'histc');
set(h2, 'Hittest', 'off');
set(h, 'XLim', [min(tb) max(tb)]);
view(-90, 90);
p2(1)=p2(1)+p2(3)-p1(4)+10;
p2(3)=p1(4);
set(h, 'Position', p2);
set(h, 'Color', 'none', 'GridLineStyle', 'none', 'Box', 'off');
set(h, 'Units', 'normalized',...
    'ButtonDownFcn', {@LocalCallback tb x});
x=get(h, 'XLim');
y=get(h,'YLim');
title(h, 'PETH 2', 'Position', [x(2) y(2)],...
    'HorizontalAlignment', 'left');

% Coincidence histogram
h=axes('Parent', ph, 'Position', [0.575   0.2967    0.4882    0.6076]);
x=getCoincidence(obj,1);
h3=bar3(tb, x, 'histc');
set(h3, 'Hittest', 'off');
set(h, 'Color', 'none', 'GridLineStyle', 'none', 'Box', 'off',...
    'ButtonDownFcn', {@LocalCallback tb x});
view(-145,43);
set(h, 'XLim', [min(tb) max(tb)]);
set(h, 'YLim', [min(tb) max(tb)]);
z=get(h,'ZLim');
title(h, 'Coincidence', 'Position', [0 0 z(2)],...
    'HorizontalAlignment', 'center',...
    'VerticalAlignment', 'bottom');

% XCorr
h=axes('Parent', ph, 'Position', [0.2321    0.5    0.5258    0.5]);
[x tb]=getXcorr(obj);
% Plot
h4=bar3(tb*1e3, x, 'histc');
set(h4, 'Hittest', 'off')
view(-145,-47);
set(h, 'Color', 'none', 'GridLineStyle', 'none', 'Box', 'off');
set(h, 'XLim', [min(tb) max(tb)]*1e3);
set(h, 'YLim', [min(tb) max(tb)]*1e3);
set(h, 'Units', 'normalized', 'ButtonDownFcn', {@LocalCallback tb*1e3 x});
z=get(h,'ZLim');
title(h, 'Correlation', 'Position', [0 0 z(2)],...
    'HorizontalAlignment', 'left');

% Colorbar
drawnow();
h=colorbar('peer', mataxes);
set(h, 'Position', [0.9 0.05 0.025 .3]);
    
% Set small font for clarity
h=findall(ph, 'Type', 'text');
h=[h; findall(ph, 'Type', 'axes')];
set(h, 'FontUnits', 'points', 'FontSize', 7);
set(h, 'FontUnits', 'normalized');

% Add title or name
if strcmpi(get(ph, 'Type'), 'figure')
    set(ph, 'Name', getLabel(obj));
else
    % Force update
    set(ph, 'Title', '');
    set(ph, 'Title', getLabel(obj));
end

return
end


function [fhandle mataxes]=setparent(in)
tp=get(in, 'Type');
fhandle=ancestor(in, 'figure');
figure(fhandle);
switch tp
    case 'figure'
        clc;
        mataxes=subplot(1,1,1);
    case 'uipanel'
        h=allchild(in);
        delete(h);
        mataxes=axes('Parent', in);
end
return
end

%--------------------------------------------------------------------------
% Callbacks
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function LocalCallback(hObject, EventData, x, y)
%--------------------------------------------------------------------------
type=get(ancestor(hObject, 'figure'), 'SelectionType');
if strcmpi(type, 'open')
    str=get(get(hObject, 'Title'), 'String');
    fhandle=figure('Name', str);
    ax=subplot(1,1,1);
    pos=get(ax,'Position');
    pos(3)=pos(3)*0.7;
    set(ax, 'Position', pos);
    bar(ax, x, y, 'histc');
    axis('tight')
    figure(fhandle);
    warning('off', 'MATLAB:uitable:OldTableUsage')
    thandle=uitable(num2cell([x(:) y(:)]),{'x' 'y'});
    warning('on', 'MATLAB:uitable:OldTableUsage')
    set(thandle, 'Units', 'normalized',...
        'Position', [0.71 0.1 0.25 0.8]);
    try
        set(thandle, 'ColumnWidth', {50});
    catch %#ok<CTCH>
        % Older versions
        setColumnWidth(thandle,50);
    end
else
    return
end
return
end

%--------------------------------------------------------------------------
function MatrixCallback(hObject, EventData, x, y)
%--------------------------------------------------------------------------
type=get(ancestor(hObject, 'figure'), 'SelectionType');
if strcmpi(type, 'open')
    matrix=ones(length(x)+1);
    matrix(1,2:end)=x(:)';
    matrix(2:end,1)=x(:);
    matrix(2:end, 2:end)=y;
    matrix=num2cell(matrix);
    matrix{1}='Time(ms) ';
    fhandle=figure;
    figure(fhandle);
    warning('off', 'MATLAB:uitable:OldTableUsage')
    thandle=uitable(matrix, repmat({''},1, size(matrix,1)), repmat({''},1, size(matrix,2)));
    warning('on', 'MATLAB:uitable:OldTableUsage')
    set(thandle, 'Units', 'normalized',...
        'Position', [0 0 1 1]);
    try
        set(thandle, 'ColumnWidth', {50});
    catch %#ok<CTCH>
        % Older versions
        setColumnWidth(thandle,50);
    end
    drawnow();
else
    return
end
return
end