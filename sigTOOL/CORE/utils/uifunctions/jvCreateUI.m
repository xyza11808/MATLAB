function h=jvCreateUI(h, ItemType, Label, ToolTip, Position, ListItems, ReturnValues)
% jvCreateUI helper function for sigTOOL GUI creation routines

parent=h.Panel;
fhandle=ancestor(h.Panel,'figure');
fname=Label;
fname=jvMakeFieldName(fname);
% Constants
% TODO: take these from the preferences file?
Foreground=java.awt.Color(64/255,64/255,122/255);
DefaultHeight=1.25;


switch ItemType
    case {'javax.swing.JComboBox', 'channelselector'}
        % Set up the jcontrol
        h.(fname)=jcontrol(parent,'javax.swing.JComboBox');
        set(h.(fname), 'Position', Position,...
            'Name', fname,...
            'ActionPerformedCallback', @Action);
        for k=1:length(ListItems)
            h.(fname).addItem(ListItems{k});
        end
        % Give a title
        set(h.(fname),'Units','character');
        pos=get(h.(fname),'Position');
        pos(2)=pos(2)+pos(4);
        pos(4)=DefaultHeight;
        h.(fname).setEditable(true);
        h.([fname 'Label'])=jcontrol(parent,'javax.swing.JLabel',...
            'Foreground', Foreground,...
            'Units','character',...
            'Text',Label);
        set(h.([fname 'Label']),'Position',pos);
        setappdata(h.(fname), 'ReturnValues', ReturnValues);
        
        if strcmp(ItemType, 'channelselector')
            % Enable drag & drop from channel manager
            temp=get(h.(fname).Editor,'EditorComponent');
            set(temp,'KeyReleasedCallback', @Paste);
            
            %tr=javax.swing.TransferHandler('text');
            %tr=awtcreate('javax.swing.TransferHandler', 'Ljava.lang.String;', 'text');
            %temp.setTransferHandler(tr);
            %dnd=temp.getDropTarget();
            dnd=java.awt.dnd.DropTarget();
            temp.setDropTarget(dnd);
            dnd=handle(dnd, 'callbackProperties');
            set(dnd, 'DropCallback', @ListDraggedCallback);
        end
        
        
    case {'javax.swing.JList'}
        % Note the handle of the JScrollPane is placed in the
        % output - not the JList which is placed in its viewport
        h.(fname)=jcontrol(parent,'javax.swing.JScrollPane',...
            'VerticalScrollBarPolicy',javax.swing.ScrollPaneConstants.VERTICAL_SCROLLBAR_ALWAYS,...
            'ToolTipText', ToolTip);
        set(h.(fname),'Position', Position);
        % Give a title
        set(h.(fname),'Units','character');
        pos=get(h.(fname),'Position');
        pos(2)=pos(2)+pos(4);
        pos(4)=DefaultHeight;
        h.([fname 'Label'])=jcontrol(parent,'javax.swing.JLabel',...
            'Foreground', Foreground,...
            'Units','character',...
            'Text', Label);
        set(h.([fname 'Label']),'Position',pos);
        set(h.([fname 'Label']),'Units','normalized');
        temp=javaObject('javax.swing.JList');
        temp.setListData(ListItems);
        setappdata(temp, 'ReturnValues', ReturnValues);
        set(temp,'Name','Try This');
        h.(fname).setViewportView(temp);
        
    case {'timermenu'}
        % Timer controls e.g. start and stop time.  These are simply a
        % special case of a JComboBox
        list=MakeTimeMenu(fhandle, Label);
        h.(fname)=jcontrol(parent,'javax.swing.JComboBox',...
            'Editable',true,...
            'ToolTipText', ToolTip,...
            'Tag','TimeMenu');
        set(h.(fname),'Position', Position);
        jcomp=get(h.(fname),'hgcontrol');
        for k=1:length(list)
            jcomp.addItem(list{k});
        end
        % Give a title
        set(h.(fname),'Units','character');
        pos=get(h.(fname),'Position');
        pos(2)=pos(2)+pos(4);
        pos(4)=DefaultHeight;
        h.([fname 'Label'])=jcontrol(parent,'javax.swing.JLabel',...
            'Foreground', Foreground,...
            'Units','character',...
            'Text',Label);
        set(h.([fname 'Label']),'Position',pos);
        setappdata(h.(fname), 'ReturnValues', ReturnValues);
        
    case {'javax.swing.JCheckBox'}
        h.(fname)=jcontrol(parent,'javax.swing.JCheckBox',...
            'Foreground', Foreground,...
            'ToolTipText', ToolTip,...
            'Text', Label,...
            'Tag','checkbox');
        set(h.(fname),'Position', Position);
        set(h.(fname),'Units', 'character');
        h.(fname).Position(4)=DefaultHeight;
        h.(fname).setSelected(true);
        
    case 'javax.swing.JButton'
        h.(fname)=jcontrol(parent,'javax.swing.JButton',...
            'Foreground', Foreground,...
            'ToolTipText', ToolTip,...
            'Text', Label,...
            'Tag','button');
        set(h.(fname),'Position', Position);
        set(h.(fname),'Units', 'character');
        h.(fname).Position(4)=DefaultHeight;
        
    case 'javax.swing.JPanel'
        h.(fname)=jcontrol(parent, 'javax.swing.JPanel',...
            'Border',javax.swing.BorderFactory.createTitledBorder(Label),...
            'Units','normalized',...
            'ToolTipText', ToolTip,...
            'Position', Position);
        
    case 'javax.swing.JTextField'
        h.(fname)=jcontrol(parent,ItemType,...
            'Foreground', Foreground,...
            'ToolTipText', ToolTip,...
            'Text', ListItems,...
            'Tag','editbox');
        
        set(h.(fname),'Position', Position);
        set(h.(fname),'Units', 'character');
        h.(fname).Position(4)=DefaultHeight;
        % Title
        set(h.(fname),'Units','character');
        pos=get(h.(fname),'Position');
        pos(2)=pos(2)+pos(4);
        pos(4)=DefaultHeight*1.5;
        h.(fname).setEditable(true);
                h.([fname 'Label'])=jcontrol(parent,'javax.swing.JLabel',...
            'Foreground', Foreground,...
            'Units','character',...
            'Text',Label);
        set(h.([fname 'Label']),'Position',pos);
        
    case 'javax.swing.JLabel'
        h.(fname)=jcontrol(parent,ItemType,...
            'Foreground', Foreground,...
            'ToolTipText', ToolTip,...
            'Tag','editbox');
        set(h.(fname),'Position', Position);
        h.(fname).setText(Label);
        
    case {'javax.swing.JTextPane', 'javax.swing.JScrollPane'}
        h.(fname)=jcontrol(parent,ItemType,...
            'Foreground', Foreground,...
            'ToolTipText', ToolTip,...
            'Tag','editbox');
        set(h.(fname),'Position', Position);

        % Title
        set(h.(fname),'Units','character');
        pos=get(h.(fname),'Position');
        pos(2)=pos(2)+pos(4);
        pos(4)=DefaultHeight*1.5;
        h.([fname 'Label'])=jcontrol(parent,'javax.swing.JLabel',...
            'Foreground', Foreground,...
            'Units','character',...
            'Text',Label);
        set(h.([fname 'Label']),'Position',pos);
        switch ItemType
            case 'javax.swing.JTextPane'
                h.(fname).setEditable(true);
                h.(fname).setText(ListItems);
            case 'javax.swing.JScrollPane'
                j=javax.swing.JTextArea;
                j.setText(ListItems);
                j.setEditable(true);
                h.(fname).setViewportView(j);
        end
        
        
    case {'javax.swing.JColorChooser'}
        h.(fname)=jcontrol(parent,'javax.swing.JColorChooser',...
            'Tag','sigTOOL:ColorChooser');
        set(h.(fname),'Position', Position);
        
end

% Added 25.11.09
set(h.(fname), 'Tag', fname);

names=fieldnames(h);
for k=1:length(names)
    set(h.(names{k}),'Units','normalized');
end

return
end


%--------------------------------------------------------------------------
function list=MakeTimeMenu(fhandle, whichend)
%--------------------------------------------------------------------------
switch whichend
    case {'Start (s)'}
        list={sprintf('%5.1f', 0) 'Data Minimum' 'Axes Minimum'};
    case {'Stop (s)'}
        % 10.01.09 Round up to the nearest 100ms
        st=ceil(scMaxTime(fhandle)*10)/10;
        list={sprintf('%5.1f', st) 'Data Maximum' 'Axes Maximum'};
end
cursors=getappdata(fhandle,'VerticalCursors');
j=length(list)+1;
for i=1:length(cursors)
    if ~isempty(cursors(i))
        list{j}=['Cursor ' num2str(i)];
        j=j+1;
    end
end
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function ListDraggedCallback(hObject, EventData)
%--------------------------------------------------------------------------
%  This is a workaround because of a MATLAB bug affecting getTransferable()
%  calls to the JRE.
menu=EventData.getSource();
texteditor=menu.getComponent();
combobox=get(get(texteditor,'AccessibleContext'),'AccessibleParent');
combobox.setSelectedIndex(-1);
texteditor.setText(num2str(scGetChannelTree(gcf,'selected')));
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Paste(hObject, EventData)
%--------------------------------------------------------------------------
% TODO: Check if statement for non-Win platforms
if isunix
    targetkey='Y';
else
    targetkey='V';
end
if EventData.isControlDown() &&...
        strcmpi(EventData.getKeyText(EventData.getKeyCode()), targetkey)
    combobox=get(get(hObject,'AccessibleContext'),'AccessibleParent');
    combobox.setSelectedIndex(-1);
    set(hObject, 'Text', clipboard('paste'));
end
return
end
%--------------------------------------------------------------------------

function Action(hObject, EventData)
hObject.grabFocus()
return
end
