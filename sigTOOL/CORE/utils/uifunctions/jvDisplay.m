function h=jvDisplay(fhandle, s)
% jvDisplay creates and displays a GUI
%
% jvDisplay takes  a structure created by a prior call to jvPanel as input
% This will usually have been populated with GUI component descriptions by
% calls to jvElement. jvDisplay create the GUIs. The output of jvDisplay is
% a structure containing the handles of the GUI components. You can alter
% the properties and call methods on these handles to fine-tune the GUI.
%
% Explicitly call uiwait after invoking jvDisplay to wait for a user
% response.
%
% Example:
% h=jvDisplay(fhandle, s);
% uiwait(); 
%
% Output h is a a structure with fields for each of those in s. Each field
% contains the handle of the created jcontrol. In addition, standard 
% jcontrols (e.g. 'OK' and 'Cancel') are added to the panel.
%
% h is also added to the parent figure's application data area
% labeled as 'sigTOOL:jvhandles').
%
% Additional panels can be added to the GUI by calling jvAddPanel
%
% When 'OK' is selected, the structure of handles is replaced in the figure
% application data area with a structure containing the return values for
% each component in the GUI (labeled 'sigTOOL:jvvalues').
%
%
% See also: jvPanel, jvElement, jvAddPanel
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 07/07
% Copyright © The Author & King’s College London 2006-2007
%-------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:

% Argument check
if nargin<2
    fprintf('jvDisplay: wrong number of inputs\n');
    h=[];
    return;
end

%LF=javax.swing.UIManager.getLookAndFeel();
%javax.swing.UIManager.setLookAndFeel('javax.swing.plaf.metal.MetalLookAndFeel');

% Constants
% TODO: take these from the preferences file
Foreground=java.awt.Color(64/255,64/255,122/255);
DefaultHeight=1.25;

% Set up the panel
h.Panel=jcontrol(fhandle, 'javax.swing.JPanel',...
    'Name',['sigTOOL:' s.Panel.Title],...
    'Tag','sigTOOL:JPanel',...
    'Border',javax.swing.BorderFactory.createTitledBorder(s.Panel.Title),...
    'Name', ['sigTOOL:' s.Panel.Title],...
    'Units','normalized',...
    'ToolTipText', s.Panel.ToolTipText,...
    'Position', s.Panel.Position);

% Get panel size in pixels, impose a minimum & maximum pixel size
set(h.Panel,'Units','pixels');
ppos=get(h.Panel,'Position');
ssz=get(0,'ScreenSize');
while ppos(3)<140*ssz(3)/ssz(4) || ppos(4)<140
    ppos(3:4)=ppos(3:4)*1.1;
end
% while ppos(3)>250*ssz(3)/ssz(4) || ppos(4)>250
%     ppos(3:4)=ppos(3:4)/1.1;
% end

set(h.Panel,'Position',ppos);
parent=get(h.Panel,'hgcontainer');


% For each user-defined item, create the jcontrol
names=fieldnames(s);
for i=1:length(names)
    if isfield(s.(names{i}), 'Component')
        % Extract values from s
        ItemType=s.(names{i}).Component;% javax.swing.?????
        Label=s.(names{i}).Label;% Text label
        ToolTip=s.(names{i}).ToolTipText;
        Position=s.(names{i}).Position;% Normalized position in panel
        ListItems=s.(names{i}).DisplayList; %List for popups
        ReturnValues=s.(names{i}).ReturnValues;
        h=jvCreateUI(h, ItemType, Label, ToolTip, Position, ListItems, ReturnValues);
    end
end


% Now work in character units
set(parent,'Units','character');
pos=get(h.Panel,'Position');

% Acknowledgement string if supplied
if ~isempty(s.AckText)
    h.AckText=jcontrol(parent,'javax.swing.JLabel',...
        'Units','character',...
        'Border',javax.swing.BorderFactory.createLineBorder(java.awt.Color(122/255,138/255,153/255)),...
        'Position',[2 0.5 pos(3)-4 1],...
        'Foreground', java.awt.Color(122/255,138/255,153/255),...
        'HorizontalAlignment',javax.swing.SwingConstants.CENTER,...
        'Text',s.AckText);
end

% Place the Apply to All checkbox
str='Apply to all open files';
h.ApplyToAll=jcontrol(parent,  'javax.swing.JCheckBox',...
    'Units','Character',...
    'Label', str,...
    'Clipping','on',...
    'Tag','sigTOOL:ApplyToAll');
set(h.ApplyToAll,'Position',[1 3 1.2*length(str) 1]);
set(h.ApplyToAll,'Units','normalized');

% Place the OK button at the bottom right of the panel
pos(1)=pos(3)-17;
pos(2)=1.75;
pos(3)=15;
pos(4)=DefaultHeight;
h.OK=jcontrol(parent,'javax.swing.JButton',...
    'Text','OK',...
    'Units','character',...
    'ActionPerformedCallback',{@OKcallback},...
    'Tag','sigTOOL:OKbutton');
set(h.OK,'Position',pos);
set(h.OK,'Units','normalized');

% Place the Cancel button above OK
pos(2)=pos(2)+pos(4)+0.25;
h.Cancel=jcontrol(parent,'javax.swing.JButton',...
    'Units','character',...
    'MouseClickedCallback',{@Cancel},...
    'Tag','sigTOOL:CANCELButton');
set(h.Cancel,'Text','Cancel');
set(h.Cancel,'Position',pos);
set(h.Cancel,'Units','normalized');

% Help button
button=javax.swing.JButton(javax.swing.ImageIcon(fullfile(scGetBaseFolder(),...
    'CORE', 'icons', 'QuestionMark.gif')));
h.Help=jcontrol(parent, button,...
    'Units', 'character',...
    'Tag', 'sigTOOL:HELPButton');
pos(1)=pos(1)-6;
pos(2)=pos(2)-(pos(4)/2)-0.125;
set(h.Help,'Position',pos);
set(h.Help, 'units', 'pixels');
h.Help.Position(3)=20;
h.Help.Position(4)=20;
h.Help.Visible='off';

% Always return units to normalized
setappdata(get(h.Panel,'Parent'),'sigTOOLjvhandles',h);
names=fieldnames(h);
for k=1:length(names)
    set(h.(names{k}),'Units','normalized');
end
%set(h.Panel,'ResizeFcn', {@PanelResize, ppos});


% Restore the L&F and pointer
% javax.swing.UIManager.setLookAndFeel(LF);
set(fhandle, 'Pointer', 'arrow');

h={h};
return
end


%--------------------------------------------------------------------------
function OKcallback(hObject, Eventdata) %#ok<INUSD>
%--------------------------------------------------------------------------
% Get the handles structure
fhandle=ancestor(hObject.hghandle,'figure');
handles=getappdata(fhandle, 'sigTOOLjvhandles');
if ~iscell(handles)
    % May have a structure so force to cell
    handles={handles};
end
% For each field...
for i=1:length(handles)
    names=fieldnames(handles{i});
    for k=1:length(names)
    s{i}.(names{k})=jvGetControlValue(handles{i}.(names{k}));
    end
end
s{1}.Panel=true;
if numel(s)==1
    % If 1x1 cell, extract to a simple structure 
    s=s{1};
end
% Place the results in the figure application area
setappdata(fhandle,'sigTOOLjvvalues',s);
% Delete the handles...
setappdata(fhandle,'sigTOOLjvhandles',[]);
% Delete panels and resume execution
for k=1:numel(handles)
    delete(handles{k}.Panel);
end
drawnow();
uiresume();
return
end


%--------------------------------------------------------------------------
function Cancel(hObject, EventData)  %#ok<INUSD>
%--------------------------------------------------------------------------
% Cancel is the callback for the Cancel button in a sigTOOL jvpanel
% Cancel deletes the panel and issues a uiresume
fhandle=ancestor(hObject.hghandle,'figure');
h=getappdata(fhandle,'sigTOOLjvhandles');
if ~iscell(h)
    h={h};
end
setappdata(fhandle,'sigTOOLjvhandles',[]);
setappdata(fhandle,'sigTOOLjvvalues',[]);
for k=1:numel(h)
    delete(h{k}.Panel);
end
uiresume();
return
end






