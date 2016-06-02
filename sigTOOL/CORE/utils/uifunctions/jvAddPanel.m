function h=jvAddPanel(h, varargin)
% jvAddPanel adds a rectangular panel to an existing GUI panel
%
% Example
% h=jvAddPanel(h, PropName1, PropValue1,...)
% h=jvAddPanel(fhandle, PropName1, PropValue1,...)
%
% h contains the handles to the existing GUI (as returned by jvDisplay).
% Alternatively, supply fhandle (a figure handle). In this case the GUI 
% component handles will be retrieved from the figure's application data
% area. Handles are stored in a structure, or a cell array of structures.
%
% The returned h will be a cell array, with an element for each panel.
%
% Valid input properties are:
%     *Title:         the title for the added panel
%                         (string)
%     *Place:         'East' or 'South' to place the new panel to the right
%                     or beneath the existing panel(s)
%                         (string)
%     *Dimension:     the width or height for 'East' and 'South' addition
%                     respectively as a fraction of the overall width or height
%                     of the existing panel(s)
%                         (scalar)
%     ToolTipText:    tool tip text
%                         (string)
%          * Required properties
%
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

% Deal with inputs
if ishandle(h)
    % If h is a figure handle on input, get the GUI handles from the
    % application data area
    h=getappdata(h,'sigTOOLUihandles');
    if isempy(h)
        error('scAddPanel: No panel to add to');
    end
end

if ~iscell(h)
    % If h is a structure, convert to cell array
    h={h};
end

% Deal with options
Title='None';
ToolTipText='';
Place='east';
metric=0.5;
for i=1:2:length(varargin)-1
    switch lower(varargin{i})
        case 'title'
            Title=varargin{i+1};
        case 'place'
            Place=varargin{i+1};
        case 'tooltiptext'
            ToolTipText=varargin{i+1};
        case 'dimension'
            metric=varargin{i+1};
        otherwise
            error('scAddPanel: unrecognized property %s', varargin{i});
    end
end

% Add the new panel
% Round pixel position - stops gaps appearing
h{1}.Panel.Units='pixels';
h{1}.Panel.Position=ceil(h{1}.Panel.Position);

% Find present panel positions
ppos(1,:)=h{1}.Panel.Position;
for i=2:length(h)
    h{i}.Panel.Units='pixels';
    ppos(end+1,:)=h{i}.Panel.Position;  %#ok<AGROW>
    h{i}.Panel.Units='normalized';
end

% Calculate the position of the net rectangle
pos(1)=min(ppos(:,1));%left
pos(2)=min(ppos(:,2));%bottom
%width
pos(3)=ppos(1,3);
for i=2:size(ppos,1)
    if ppos(i,1)~=ppos(1,1)
        pos(3)=pos(3)+ppos(i,3);
    end
end
%height
pos(4)=ppos(1,4);
for i=2:size(ppos,1)
    if ppos(i,2)~=ppos(1,2)
        pos(4)=pos(4)+ppos(i,4);
    end
end

% Set up position for new panel
switch lower(Place)
    case {'right', 'east'}
        pos=floor([pos(1)+pos(3) pos(2) pos(3)*metric pos(4)]);
    case {'bottom', 'south'}
        pos=ceil([pos(1) pos(2)-(pos(4)*metric) pos(3) pos(4)*metric]);
end


% Create an empty cell for the new handles...
h{end+1}={};
% ... and add the new panel to it
h{end}.Panel=jcontrol(h{1}.Panel.Parent,'javax.swing.JPanel',...
    'Border',javax.swing.BorderFactory.createTitledBorder(Title),...
    'Units','pixels',...
    'ToolTipText', ToolTipText,...
    'Position',pos);
h{end}.Panel.Units='normalized';
h{end}.Panel.Tag='sigTOOL:addedPanel';
h{1}.Panel.Units='normalized';

% Update figure application data area with the new handles structure
setappdata(get(h{1}.Panel,'Parent'),'sigTOOLjvhandles',h);

return
end

