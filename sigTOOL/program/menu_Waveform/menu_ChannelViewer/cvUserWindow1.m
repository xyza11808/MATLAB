function chan=cvUserWindow1(fhandle, chan)

[fhandle channels]=scParam(fhandle);

setappdata(fhandle, 'ScrollSpeed', 20);


% Set up the control panel
h=findobj(fhandle, 'Tag', 'CV:ManagerPanel');
if strcmp(get(h, 'Type'),'hgjavacomponent')
    % Old style uitable
    h=get(h, 'UserData');
end

pos=get(h, 'Position');
s.Panel=uipanel('Units', 'normalized',...
    'Position', [pos(3) 0 1-pos(3) 0.3],...
    'ForegroundColor', [0 0 0.7],...
    'Title', 'Controls',...
    'Tag', 'CV:UserPanel');
if ismac
    set(s.Panel, 'BackgroundColor', [.95 .95 .95]);
end

% Add a text message field
s.usermessage=jcontrol(s.Panel, 'javax.swing.JTextField',...
    'Position', [0.1 0.85 0.8 0.1],...
    'Tag', 'UserMessage');
s.usermessage.setHorizontalAlignment(javax.swing.SwingConstants.CENTER);


% Add the channel selected, choosing the selected channel if specified
s.channelselector=LocalCreateChannelSelector();%(channels, chan, panel);

% Now set up the option buttons
s.inverttrace=jcontrol(s.Panel, 'javax.swing.JCheckBox',...
    'Label', 'Invert Trace',...
    'Position', [0.1 0.45 0.2 0.1],...
    'ActionPerformedCallback', @LocalInvert);
%s.inverttrace.setEnabled(false);

s=jvCreateUI(s, 'javax.swing.JComboBox', 'Time base (s)', '', [0.35 .65 .2 .1], num2cell([.01 .02 .05 .1 .2 .5 1 2 5]), [] );
s.Timebase.setSelectedItem(.1);


s=jvCreateUI(s, 'javax.swing.JComboBox', 'Number of traces', '', [0.35 .45 .2 .1], num2cell([1 2 5 10 20 50]), [] );
s.Numberoftraces.setSelectedItem(5);


ScrollControls(s.Panel);

s.LineSmoothing=jcontrol(s.Panel, 'javax.swing.JCheckBox',...
    'Label', 'Line Smoothing',...
    'Position', [0.725 0.2 0.225 0.1],...
    'ActionPerformedCallback', @LocalLineSmoothing);

s.ShowTable=jcontrol(s.Panel, 'javax.swing.JCheckBox',...
    'Label', 'Show Table',...
    'Position', [0.725 0.1 0.225 0.1],...
    'ActionPerformedCallback', @LocalTableControl);
s.ShowTable.setSelected(true);

helpbutton=AddHelp(s.Panel);


s.channelselector.ActionPerformedCallback=[];
s.Timebase.ActionPerformedCallback=[];
s.Numberoftraces.ActionPerformedCallback=[];

s.channelselector.ItemStateChangedCallback=@LocalUpdate;
s.Timebase.ItemStateChangedCallback={@LocalUpdate s.channelselector};
s.Numberoftraces.ItemStateChangedCallback={@LocalUpdate s.channelselector};

s.logo=jcontrol(s.Panel, 'javax.swing.JButton',...
    'Units', 'pixels',...
    'Position', [2 2 85 45],...
    'ActionPerformedCallback', []);
s.logo.setIcon(javax.swing.ImageIcon(which('Logo.gif')));
s.logo.MouseClickedCallback='web http://sourceforge.net/projects/sigtool/ -browser';

s.text=jcontrol(s.Panel, 'javax.swing.JLabel',...
    'Position', [.15 .05 .55 .1]);
s.text.setText('** This Channel Viewer is under development and will change in future releases');

setappdata(fhandle, 'ViewerControls',s);
return

    function channelselector=LocalCreateChannelSelector()%(channels, chan, panel)
        % Generate the channel list...
        clist=scGetChannelsByType(channels, 'Continuous Waveform');
        for i=1:length(clist)
            list{i}=clist(i);
            if list{i}<=length(channels) && ~isempty(channels{list{i}})
                titlestr=channels{list{i}}.hdr.title;
            else
                titlestr='Empty';
            end
            str{i}=sprintf('%d: %s',list{i}, titlestr);
        end
        %... and set up a channel selector
        s=jvCreateUI(s, 'channelselector', 'Channel', '', [0.1 0.65 0.2 0.1], str, list);
        idx=find(clist==chan, 1);
        if isempty(idx)
            item=str{1};
            chan=clist(1);
        else
            item=str{idx};
            chan=clist(idx);
        end
        channelselector=s.Channel;
        channelselector.ActionPerformedCallback=[];
        channelselector.setSelectedItem(item);
        % Flush event queue
        drawnow();
        setappdata(fhandle, 'thisChannel', chan);
        return
    end
end

function LocalUpdate(hObject, EventData, button)
if get(EventData,'StateChange')~=1
    return
end
% Find channel from channel selector
if nargin>2
    hObject=button;
end
fhandle=ancestor(hObject.hghandle, 'figure');
idx=hObject.getSelectedIndex();
if isempty(idx)
    return
end
list=getappdata(hObject);
chan=list.ReturnValues{idx+1};
setappdata(fhandle, 'thisChannel', chan);

UpdateTableColumnNames(fhandle, chan);

cvRawDataAxis(fhandle);
return
end






function LocalLineSmoothing(hObject, EventData)
fhandle=ancestor(hObject.hghandle, 'figure');
h=findobj(fhandle, 'Tag', 'DataLine');
if hObject.isSelected();
    set(h, 'LineSmoothing', 'on');
else
    set(h, 'LineSmoothing', 'off');
end
return
end

function LocalTableControl(hObject, EventData)
fhandle=ancestor(hObject.hghandle, 'figure');
h=getappdata(fhandle, 'cvUitable');
if hObject.isSelected();
    try 
        set(h, 'Enable', 'on');
    catch
        set(h, 'Visible', 1);
    end
else
    try
        set(h, 'Enable', 'off');
    catch
        set(h, 'Visible', 0);
    end
end
return
end

function LocalInvert(hObject, EventData)
fhandle=ancestor(hObject.hghandle, 'figure');
y=getappdata(fhandle, 'ydata');
y=y*-1;
setappdata(fhandle, 'ydata', y);
yrange=abs(max(y)-min(y));
setappdata(fhandle, 'YRange', yrange);
cvScroll(fhandle,1,1);
return
end

% function LocalChannelSelector(hObject, EventData)
% % Find channel from channel selector
% fhandle=ancestor(hObject.hghandle, 'figure');
% idx=hObject.getSelectedIndex();
% if isempty(idx)
%     return
% end
% list=getappdata(hObject);
% chan=list.ReturnValues{idx+1};
% setappdata(fhandle, 'thisChannel', chan);
% RawDataAxis(fhandle, chan);
% return
% end