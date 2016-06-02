function scSelectSubchannel(fhandle)
% scSelectSubchannel provides a GUI to select subchannels on multiplexed data
% 
% Examples:
% scSelectSubchannel(fhandle)
% scSelectSubchannel(channels)
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

global channels
[fhandle channels]=scParam(fhandle);

% Set up the channel lists;
clist=scGetChannelsByType(channels, {'Multiplexed'});
if isempty(clist)
    s=dbstack();
    if strcmp(s(2).name, 'menu_SelectSubchannel')
        msgbox('There are no multiplexed channels is this file','Select Subchannel', 'none');
    else
        fprintf('scSelectSubchannel: There are no multiplexed channels is this file\n');
    end
    return
end

for i=1:length(clist)
    list{i}=clist(i);
    str{i}=sprintf('%d: %s',list{i}, channels{list{i}}.hdr.title);
end


% Create a structure for jvDisplay...
Position=[0.35 0.35 0.3 0.25];
s=jvPanel('Title', 'Subchannel Selection',...
    'Position', Position,...
    'ToolTipText', '',...
    'AckText','');
% Channel Selector
s=jvElement(s, 'Component', 'channelselector',...
    'Label', 'Channel A',...
    'Position', [0.1 0.7 0.8 0.1],...
    'DisplayList', str, ...
    'ReturnValues', list);
% Subchannel selector
s=jvElement(s, 'Component', 'javax.swing.JComboBox',...
    'Label', 'Subchannel',...
    'Position', [0.1 0.45 0.35 0.1]);

s=jvElement(s, 'Component', 'javax.swing.JButton',...
    'Label', 'Reset All',...
    'Position', [0.55 0.45 0.35 0.1]);

%...and call it
h=jvDisplay(fhandle,s);
jvSetHelp(h, mfilename(), 'Select Subchannels');
h{1}.ApplyToAll.setEnabled(0);
h{1}.ChannelA.ActionPerformedCallback={@UpdateDisplay, h{1}.Subchannel};
h{1}.ResetAll.ActionPerformedCallback={@ClearAll,  h{1}.Subchannel};
uiwait();

s=getappdata(fhandle, 'sigTOOLjvvalues');

if isempty(s)
    return
end

% OK pressed
channels{s.ChannelA}.CurrentSubchannel=s.Subchannel;
setappdata(fhandle, 'channels', channels);
return


% Note that these functions are nested and share 'channels' with the
% main function workspace where it is declared as global
%---------------------------------------------------------------------
    function ClearAll(hObject, EventData,  subselector) %#ok<INUSL>
        %------------------------------------------------------------------
        % Note: has immediate effect in main function workspace but changes
        % will not be saved to the application data area unless OK is
        % pressed
        for k=1:length(channels)
            if ~isempty(channels{k})
                channels{k}.CurrentSubchannel=1;
            end
        end
        % Update the currently displayed subchannel
        subselector.setSelectedIndex(0);
    end
%------------------------------------------------------------------

%--------------------------------------------------------------------------
    function UpdateDisplay(hObject, EventData, subcontrol) %#ok<INUSL>
        %------------------------------------------------------------------
        % Note: Has no effect until OK is selected
        chan=jvGetControlValue(hObject);
        subcontrol.removeAllItems();
        for k=1:channels{chan}.hdr.adc.Multiplex
            subcontrol.addItem(num2str(k));
        end
        subcontrol.setSelectedIndex(channels{chan}.CurrentSubchannel-1);
        return
    end
%------------------------------------------------------------------

end

