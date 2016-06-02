function [tp, cs, tree]=scChannelManager(fhandle, updateflag)
% scChannelManager creates the channel manager for a sigTOOL data view
% 
% Example:
% [tp, cs, tree]=scChannelManager(fhandle)
% 
% scChannelManager returns the handles/jcontrols for the panel, scrollpane
% and tree. These handles are also added to the ChannelManager field of the
% figure's application data area e.g.
%         Panel: [1x1 jcontrol]
%     ScrollPane: [1x1 jcontrol]
%           Tree: [1x1 javax.swing.JTree]
%
% The channel tree is drag enabled so you can drag and drop channel
% selections into other sigTOOL GUI items. 
%
% The channel manager GUI provides access to the following (embedded)
% functions
%
% COPY: Places the current channel selection in the system clipboard
% DRAW: Draws the currently selected channels
% INSPECT*: Places a copy of the present (singly) selected channel
% structure (note not object) in the base workspace and opens it in the 
% MATLAB array editor. This can be used to view the data settings. 
% Note that editing values will have no affect on the data stored in the
% data view. 
% REMAP releases virtual memory assigned to the data channels for this, and
% all other, open sigTOOL files
% COMMIT: For the selected channels, this commits memory mapped data stored
% on disc to RAM (in both tim and adc fields). The commit function will
% return harmlessly if you receive an out of memory error. Selected
% channels are commited in numerical order.
%
% *TODO: replace this behaviour with a JTable
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
%
% Revisions:
%   08.11.09    See within


figure(fhandle);

Foreground=java.awt.Color(64/255,64/255,122/255);

% Check if channel tree is already present
s=getappdata(fhandle, 'ChannelManager');
% 08.11.09 Remove ishandle test
if nargin==1 && ~isempty(s) || nargin==2 && updateflag==false
    tp=s.Panel;
    cs=s.ScrollPane;
    tree=s.Tree;
    return
elseif nargin==2 && updateflag==true
    % Delete and recreate
    delete(s.Panel);
end

% If not create it
Background=java.awt.Color(1,1,0.9);
    
channels=getappdata(fhandle, 'channels');

% Build the tree
root=javax.swing.tree.DefaultMutableTreeNode(get(fhandle,'Name'));
% Tree Icons - keep current icons for restore
img=javax.swing.ImageIcon([matlabroot, '/toolbox/matlab/icons/HDF_object02.gif']);%(fullfile(scGetBaseFolder(),'CORE','icons','ChannelTreeWaveformClosed.gif'));
im1=javax.swing.UIManager.get('Tree.closedIcon');
javax.swing.UIManager.put('Tree.closedIcon', img);
%img=javax.swing.ImageIcon(fullfile(scGetBaseFolder(),'CORE','icons','ChannelTreeWaveformOpen.gif'));
im2=javax.swing.UIManager.get('Tree.openIcon');
javax.swing.UIManager.put('Tree.openIcon', img);


im3=javax.swing.UIManager.get('Tree.leafIcon');
img=javax.swing.ImageIcon(fullfile(scGetBaseFolder(),'CORE','icons','ChannelTreeWaveformClosed.gif'));
javax.swing.UIManager.put('Tree.leafIcon', img);

% 09.12.09
ngroup=0;
for idx=1:length(channels)
    if ~isempty(channels{idx}) && channels{idx}.hdr.Group.Number>ngroup
        ngroup=ngroup+1;
        labels{ngroup}=channels{idx}.hdr.Group.Label; %#ok<AGROW>    
    end
end

if ngroup>1
    for idx=1:ngroup
        grp(idx)=javax.swing.tree.DefaultMutableTreeNode(sprintf('%s', labels{idx} )); %#ok<AGROW>
        set(grp(idx), 'UserData', true);
        root.add(grp(idx));
    end
else
    grp(1)=root;
    set(grp(1), 'UserData', true)
end

sourcelist=getSourceChannel(channels{:});
for idx=1:length(channels)
    if isempty(channels{idx})
        continue
    end
%     if ngroup==1
%         str=['[' num2str(idx) '] ' channels{idx}.hdr.title];
%         chan=javax.swing.tree.DefaultMutableTreeNode(str);
%         set(chan, 'UserData', false);
%         grp(channels{idx}.hdr.Group.Number).add(chan);
%     else
        
        grp=CreateChannelEntry(channels, idx, grp, channels{idx}.hdr.Group.Number, [], sourcelist); %#ok<AGROW>
%     end
end


% Add tree to a GUI
% Create a panel
tp=jcontrol(fhandle,'javax.swing.JPanel',...
    'Tag', 'sigTOOL:ChannelManagerPanel',...
    'Foreground', Foreground,...
    'Border',javax.swing.BorderFactory.createTitledBorder('Channel Manager'));
tp.Position=[0 0 0.15 1];

% Create a scrollpane in the panel
cs=jcontrol(tp,'javax.swing.JScrollPane');
cs.Position=[0.05 0.05 0.9 0.95];
cs.setVerticalScrollBarPolicy(javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS);

% Add tree to the scrollpane
treeModel=javax.swing.tree.DefaultTreeModel(root);
tree=javax.swing.JTree(treeModel);
tree.setBackground(Background);
tree.setDragEnabled(true);
% TODO: Provide drop controls in the tree?
% dnd=java.awt.dnd.DropTarget();
% set(dnd, 'DropCallback', @TreeDropCallback);
% tree.setDropTarget(dnd);

% Add to scrollpane
cs.setViewportView(tree);
cs.Tag='sigTOOL:ChannelManagerScrollPane';

% Expand the tree
srow=0;
rows=tree.getRowCount();
while srow~=rows
    for k=rows:-1:1
        tree.expandRow(k);
    end
    srow=rows;
    rows=tree.getRowCount();
end

tp.Units='character';
tp.Position(3)=30;
if tp.Position(4)>tree.getRowCount()+20
    tp.Position(2)=tp.Position(2)+tp.Position(4)-tree.getRowCount()-20;
    tp.Position(4)=tree.getRowCount()+20;
end
tp.Units='normalized';


setappdata(fhandle,'ChannelManager',struct('Panel', tp, 'ScrollPane', cs,...
    'Tree', tree));

%drawnow();

% Now add the action buttons
cs.Units='character';
cs.Position(2)=cs.Position(2)+6;
cs.Position(4)=cs.Position(4)-7.5;
button.copy=jcontrol(tp, 'javax.swing.JButton',...
    'Foreground', Foreground,...
    'Label', 'Copy',...
    'Position',[0.4 0.15 0.4 0.05],...
    'ToolTipText', 'Copy selected channel numbers',...
    'ActionPerformedCallback',{@Copy fhandle,});
button.copy.Units='character';
button.copy.Position(1)=1;
button.copy.Position(2)=cs.Position(2)-2;
button.copy.Position(3)=14;
button.copy.Position(4)=1.5;

button.draw=jcontrol(tp, 'javax.swing.JButton',...
    'Foreground', Foreground,...
    'Label', 'Draw',...
    'ToolTipText', 'Draw selected channels',...
    'ActionPerformedCallback',{@Draw, fhandle});
button.draw.Units='character';
button.draw.Position=button.copy.Position;
button.draw.Position(1)=button.draw.Position(1)+button.draw.Position(3);

button.remap=jcontrol(tp, 'javax.swing.JButton',...
    'Foreground', Foreground,...
    'Label', 'Remap',...
    'ToolTipText', 'Release virtual memory for all channels and files',...
    'ActionPerformedCallback',{@remap, fhandle});
button.remap.Units='character';
button.remap.Position=button.copy.Position;
button.remap.Position(2)=button.remap.Position(2)-1.5;

button.setB=jcontrol(tp, 'javax.swing.JButton',...
    'Foreground', Foreground,...
    'Label', '',...
    'ToolTipText', 'Unassigned');
button.setB.Units='character';
button.setB.Position=button.draw.Position;
button.setB.Position(2)=button.setB.Position(2)-1.5;

button.inspect=jcontrol(tp, 'javax.swing.JButton',...
    'Foreground', Foreground,...
    'Label', 'Inspect channel in array editor',...
    'ToolTipText', 'Inspect',...
    'ActionPerformedCallback',{@Inspect, fhandle});
button.inspect.Units='character';
button.inspect.Position=button.remap.Position;
button.inspect.Position(2)=button.inspect.Position(2)-1.5;

button.commit=jcontrol(tp, 'javax.swing.JButton',...
    'Foreground', Foreground,...
    'Label', 'Commit',...
    'ToolTipText', 'Commit data to RAM',...
    'ActionPerformedCallback',{@Commit, fhandle});
button.commit.Units='character';
button.commit.Position=button.setB.Position;
button.commit.Position(2)=button.commit.Position(2)-1.5;

% button.commit.Units='normalized';
% button.remap.Units='normalized';
% button.setB.Units='normalized';
% button.inspect.Units='normalized';
% button.draw.Units='normalized';
% button.copy.Units='normalized';
% cs.Units='normalized';
% tp.Units='normalized';


h=get(get(tp, 'uipanel'),'Children');
set(h, 'Units', 'normalized');

javax.swing.UIManager.put('Tree.closedIcon', im1);
javax.swing.UIManager.put('Tree.openIcon', im2);
javax.swing.UIManager.put('Tree.leafIcon', im3);

errm=scCheckChannels(fhandle);
if ~isempty(errm)
    img=javax.swing.ImageIcon(fullfile(scGetBaseFolder(),'CORE','icons','warning.gif'));
    button.warning=jcontrol(tp, 'javax.swing.JButton',...
    'Foreground', Foreground,...
    'Position', [0.45 0.01 0.1 0.1],...
    'ToolTipText', 'Click here to view potential problems with this data file',...
    'ActionPerformedCallback',{@ViewWarnings, errm});
    button.warning.setIcon(img);
    button.warning.Units='pixels';
    button.warning.Position(3:4)=25;
    button.warning.Units='normalized';
end

set(tree, 'MouseClickedCallback', @CallBack);
return
end

%--------------------------------------------------------------------------
function grp=CreateChannelEntry(channels, idx, grp, n, chan, sourcechannels)
%--------------------------------------------------------------------------
str=['[' num2str(idx) '] ' channels{idx}.hdr.title];
if channels{idx}.hdr.Group.SourceChannel==0
    chan=javax.swing.tree.DefaultMutableTreeNode(str);
    set(chan, 'UserData', false);
    grp(n).add(chan);
    idx2=find(sourcechannels==idx);
    for k=1:numel(idx2)
        grp=CreateChannelEntry(channels, idx2(k), grp, n, chan, sourcechannels);
        set(chan, 'UserData', true);
    end
elseif ~isempty(chan)
    new=javax.swing.tree.DefaultMutableTreeNode(str);
    chan.add(new);
    set(new, 'UserData', true);
    idx2=find(sourcechannels==idx);
    for k=1:numel(idx2)
        grp=CreateChannelEntry(channels, idx2(k), grp, n, new, sourcechannels);
        set(chan, 'UserData', true);
    end
end
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function CallBack(hObject, EventData)
%--------------------------------------------------------------------------
if EventData.getClickCount()>1
    % TODO: Put code here for channel details
end
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function Copy(hObject, EventData, fhandle) %#ok<INUSL>
%--------------------------------------------------------------------------
ChannelList=scGetChannelTree(fhandle, 'selected');
if ~isempty(ChannelList)
    clipboard('copy', num2str(ChannelList));
end
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Draw(hObject, EventData, fhandle) %#ok<INUSL>
%--------------------------------------------------------------------------
ChannelList=scGetChannelTree(fhandle, 'selected');
if ~isempty(ChannelList)
    % TODO: See called function
    scDataViewDrawChannelList(fhandle, ChannelList);
end
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function remap(hObject, EventData, fhandle) %#ok<INUSD>
%--------------------------------------------------------------------------
scRemap();
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function Inspect(hObject, EventData, fhandle) %#ok<INUSL>
%--------------------------------------------------------------------------
ChannelList=scGetChannelTree(fhandle, 'selected');
if length(ChannelList)==1
    channels=getappdata(fhandle, 'channels');
    inspect(channels{ChannelList});
else
    warndlg('You must select a single channel for editing');
end
return
end

%--------------------------------------------------------------------------
function Commit(hObject, EventData, fhandle) %#ok<INUSL>
%--------------------------------------------------------------------------
ChannelList=scGetChannelTree(fhandle, 'selected');
err=0;
if ~isempty(ChannelList)
    for idx=1:length(ChannelList)
        chan=ChannelList(idx);
        ok=scCommit(fhandle, chan);
        err=err+ok;
    end
end
if err~=0
    errmsg=lasterror(); %#ok<LERR>
    errmsg=sprintf('Some channels could not be committed to RAM\n%s', errmsg.message);
    warndlg(errmsg);
    lasterror('reset'); %#ok<LERR>
end
return
end


function ViewWarnings(hObject, EventData, errm) %#ok<INUSL>
errm=sprintf('%s\n\n%s\n%s',errm, 'Select File->File Information to see details.',...
    'For an explanation of the errors/warnings type "helpwin scCheckChannels"');
warndlg(errm, 'File problems');
return
end

% function TreeDropCallback(hObject, EventData)
% % TODO:
% return
% end