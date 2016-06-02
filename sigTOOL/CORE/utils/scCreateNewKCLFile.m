function scCreateNewKCLFile()
% scCreateNewKCLFile creates a dialog through which a new kcl file can be
% generated
% 
% Example:
% scCreateNewKCLFile()
% 
% scCreateNewKCLFile takes no arguments
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 04/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

fhandle=figure('Units', 'normalized',...
    'Units', 'character',...
    'Position', [30 5 140 50],...
    'NumberTitle', 'off',...
    'MenuBar', 'none',...
    'Name', 'sigTOOL: Import channels to new file');

CreatePanel(fhandle, 1);
uiwait();
return
end

%--------------------------------------------------------------------------
function CreatePanel(fhandle, NPanel)
%--------------------------------------------------------------------------
set(fhandle, 'Pointer', 'watch');
drawnow();
% Create a panel
cs=uipanel(fhandle);
set(cs, 'Units', 'character');
pos=get(cs, 'Position');
Top=pos(2)+pos(4)-3;

t(1)=jcontrol(cs, 'javax.swing.JLabel',...
    'Units', 'character',...
    'Position', [2 Top-1.5 10 5],...
    'Text', '<HTML><CENTER><FONT COLOR=BLUE>Target<P>Channel</P></FONT></CENTER></HTML>');
t(2)=jcontrol(cs, 'javax.swing.JLabel',...
    'Units', 'character',...
    'Position', [30 Top-1.5 20 5],...
    'Text', '<HTML><CENTER><FONT COLOR=BLUE>Source File</FONT></CENTER></HTML>');
t(3)=jcontrol(cs, 'javax.swing.JLabel',...
    'Units', 'character',...
    'Position', [80 Top-1.5 20 5],...
    'Text', '<HTML><CENTER><FONT COLOR=BLUE>Source Channel</FONT></CENTER></HTML>');


for i=1:14
    label(i)=jcontrol(cs, 'javax.swing.JLabel',...
         'Units', 'character',...
        'Position', [5 Top-(i*3) 5 2],...
        'Text', [num2str((NPanel-1)*14+i) ':']); %#ok<AGROW>
    file(i)=jcontrol(cs, 'javax.swing.JTextField',...
        'Units', 'character',...
        'MouseClickedCallback', {@LocalButtonDownCallback},...
        'KeyPressedCallback', {@KeyType},...
        'ActionPerformedCallback', {@Action},...
        'Position', [20 Top-(i*3) 40 2],...
        'Tag', 'filechooser'); %#ok<AGROW>
    channelselector(i)=jcontrol(cs, 'javax.swing.JComboBox',...
        'Units', 'character',...
        'Position', [70 Top-(i*3) 40 2],...
        'Tag', 'channelselector'); %#ok<AGROW>
end

t(4)=jcontrol(cs, 'javax.swing.JButton',...
    'Units', 'character',...
    'Position', [115 25 15 2],...
    'MouseClickedCallback', {@Browse},...
    'Text', 'Browse');
t(5)=jcontrol(cs, 'javax.swing.JButton',...
    'Units', 'character',...
    'Position', [115 20 15 2],...
    'MouseClickedCallback', {@Next},...
    'Text', 'Next>>');
t(5)=jcontrol(cs, 'javax.swing.JButton',...
    'Units', 'character',...
    'Position', [115 15 15 2],...
    'MouseClickedCallback', {@Back},...
    'Text', '<<Back');
t(6)=jcontrol(cs, 'javax.swing.JButton',...
    'Units', 'character',...
    'Position', [115 10 15 2],...
    'MouseClickedCallback', {@Import},...
    'Text', 'Import');
t(7)=jcontrol(cs, 'javax.swing.JButton',...
    'Units', 'character',...
    'Position', [115 5 15 2],...
    'MouseClickedCallback', {@Cancel},...
    'Text', 'Cancel');

set(t, 'Units', 'normalized');
set(label, 'Units', 'normalized');
set(file, 'Units', 'normalized');
set(channelselector, 'Units', 'normalized');
set(cs, 'Units', 'normalized');

file=file(:);
savedfile=getappdata(fhandle, 'FileListHandles');
if ~isempty(savedfile)
    file=[savedfile; file];
end
setappdata(fhandle, 'FileListHandles', file);

channelselector=channelselector(:);
savedchannelselector=getappdata(fhandle, 'ChannelSelectorHandles');
if ~isempty(savedchannelselector)
    channelselector=[savedchannelselector; channelselector];
end
setappdata(fhandle, 'ChannelSelectorHandles', channelselector);

panels=getappdata(fhandle, 'PanelDetails');
if isempty(panels)
    panels.N=1;
    panels.List=cs;
else
    if NPanel>panels.N
        panels.N=NPanel;
        panels.List(NPanel)=cs;
    end
end
panels.Current=NPanel;
setappdata(fhandle, 'PanelDetails', panels);

LocalButtonDownCallback(file((NPanel-1)*14+1).hgcontrol, []);
scInsertLogo(cs);
set(fhandle, 'Pointer', 'arrow');
drawnow();
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Browse(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
persistent pathname
if isempty(pathname)
    s=load(fullfile(scGetBaseFolder(),...
        'program', 'scPreferences.mat'), 'Filing');
    pathname=s.Filing.OpenSaveDir;
end
[filename, pathname]=uigetfile([pathname '*.kcl']);
if filename~=0
    h=findobj(get(hObject.hghandle, 'Parent'),...
        'Type', 'hgjavacomponent',...
        'Selected', 'on');
    fh=findobj(h, 'Tag', 'filechooser');
    fhh=get(fh, 'UserData');
    name=fullfile(pathname, filename);
    fhh.setText(name);
    Action(fhh, []);
end
clipboard('copy', name);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Action(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
name=char(hObject.getText());
if isempty(name)
    return
end
channels=scOpen(name);
h=findobj(get(hObject.hghandle, 'Parent'),...
    'Type', 'hgjavacomponent',...
    'Selected', 'on');
ch=findobj(h, 'Tag', 'channelselector');
chh=get(ch, 'UserData');
chh.removeAllItems();
chh.addItem('None');
for k=1:length(channels)
    if ~isempty(channels{k})
        chh.addItem(['[' num2str(k) '] ' channels{k}.hdr.title]);
    end
end
clear('channels');
return
end

%--------------------------------------------------------------------------
function KeyType(hObject, EventData)
%--------------------------------------------------------------------------
if EventData.isControlDown()==0
    return
else
    if char(EventData.getKeyCode)=='V'
        %Paste
        Action(hObject, []);
    end
end
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function LocalButtonDownCallback(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
fhandle=ancestor(hObject.hghandle, 'figure');
file=getappdata(fhandle, 'FileListHandles');
channelselector=getappdata(fhandle, 'ChannelSelectorHandles');
idx=[];
for i=1:length(file)
    set(file(i).hghandle,'Selected','off');
    set(file(i), 'Background', java.awt.Color(1,1,1));
    set(channelselector(i).hghandle, 'Selected', 'off');
    set(channelselector(i), 'Background', java.awt.Color(1,1,1));
    if file(i).hgcontrol==hObject
        idx=i;
    end
end
set(hObject.hghandle,'Selected','on');
set(hObject, 'Background', java.awt.Color(1,1,0.8));
if ~isempty(idx)
    set(channelselector(idx).hghandle,...
        'Selected', 'on');
    set(channelselector(idx),...
        'Background', java.awt.Color(1,1,0.8));
end
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Next(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
fhandle=ancestor(hObject.hghandle, 'figure');
ResetPanel(fhandle);
panels=getappdata(fhandle, 'PanelDetails');
nextPanel=panels.Current+1;
if nextPanel>panels.N
    CreatePanel(fhandle, nextPanel);
else
    set(findall(panels.List(nextPanel)), 'Visible', 'on');
    panels.Current=nextPanel;
    setappdata(fhandle, 'PanelDetails', panels);
end
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Back(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
fhandle=ancestor(hObject.hghandle, 'figure');
ResetPanel(fhandle);
panels=getappdata(fhandle, 'PanelDetails');
targetPanel=panels.Current-1;
if targetPanel<1
    targetPanel=1;
end
set(findall(panels.List), 'Visible', 'off');
set(findall(panels.List(targetPanel)), 'Visible', 'on');
panels.Current=targetPanel;
setappdata(fhandle, 'PanelDetails', panels);

return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function ResetPanel(phandle)
%--------------------------------------------------------------------------
files=getappdata(get(phandle, 'Parent'), 'FileListHandles');
set(files, 'Background', java.awt.Color(1,1,1));
channelselector=getappdata(fhandle, 'ChannelSelectorHandles');
set(channelselector, 'Background', java.awt.Color(1,1,1));
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Cancel(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
fhandle=ancestor(hObject.hghandle, 'figure');
delete(fhandle);
uiresume()
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Import(hObject, EventData) %#ok<INUSD>
fhandle=ancestor(hObject.hghandle, 'figure');
files=getappdata(fhandle, 'FileListHandles');
channelselector=getappdata(fhandle, 'ChannelSelectorHandles');

newchannels=cell(length(files),1);
fileinmem='';

Group=1;
for i=1:length(files)
    name=char(files(i).getText());
    if isempty(name)
        continue
    else
        thistxt=channelselector(i).getSelectedItem();
        if strcmp(thistxt, 'None')==1
            continue
        else
            idx1=findstr(thistxt, '[');
            idx2=findstr(thistxt, ']');
            if isempty(idx1) || isempty (idx2)
                continue
            else
                thischan=str2double(thistxt(idx1+1:idx2-1));
                if strcmp(fileinmem, name)==0
                    channels=scOpen(name);
                end
                fileinmem=name;
                newchannels{i}=channels{thischan};
                if i>1 && strcmp(name, char(files(i-1).getText()))==0
                    Group=Group+1;
                end
                newchannels{i}.hdr.Group.Number=Group;
                [path filename]=fileparts(name); %#ok<ASGLU>
                newchannels{i}.hdr.Group.Label=filename;
                newchannels{i}.hdr.Group.Details=[];
            end
        end
    end
end

delete(fhandle);
uiresume();

ts=zeros(length(newchannels),1);
tu=zeros(length(newchannels),1);
for i=1:length(newchannels)
    if ~isempty(newchannels{i})
        ts(i)=newchannels{i}.tim.Scale;
        tu(i)=newchannels{i}.tim.Units;
    end
end
if length(unique(tu(tu>0)))>1
    %Units not consistent
    mintu=min(tu(tu>0));
    for i=1:length(newchannels)
        if ~isempty(newchannels{i})
            newchannels{i}.tim.Scale=newchannels{i}.tim.Scale*(newchannels{i}.tim.Units/mintu);
            newchannels{i}.tim.Units=mintu;
            newchannels{i}.hdr.tim.Scale=newchannels{i}.tim.Scale;
            newchannels{i}.hdr.tim.Units=mintu;
        end
    end
end
        
plot(newchannels{:});
return
end