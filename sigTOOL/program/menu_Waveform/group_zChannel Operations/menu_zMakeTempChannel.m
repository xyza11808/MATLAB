function varargout=menu_zMakeTempChannel(varargin)


% Called as menu_MakeTempChannel(0)
if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Copy channel';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;
channels=getappdata(fhandle, 'channels');

% Active channel list
clist=scGetChannelsByType(channels, 'all');
list=num2cell(clist(1:end));
for i=1:length(clist)
    str{i}=sprintf('%d: %s',list{i}, channels{list{i}}.hdr.title); %#ok<AGROW>
end

% Empty channel list
emptylist=scGetChannelsByType(channels, 'empty');
for i=1:length(emptylist)
    str2{i}=sprintf('%d: <unused>', emptylist(i)); %#ok<AGROW>
end

% Create a structure for jvDisplay...
s=jvPanel('Title', 'Copy to temp channel',...
    'Position', [0.35 0.35 0.3 0.3],...
    'ToolTipText', '');
s=jvElement(s, 'Component', 'channelselector',...
    'Label', 'Channel A (Source)',...
    'Position', [0.1 0.7 0.8 0.1],...
    'DisplayList', str, ...
    'ReturnValues', list);
s=jvElement(s, 'Component', 'channelselector',...
    'Label', 'Channel B (Target)',...
    'Position', [0.1 0.5 0.8 0.1],...
    'DisplayList', str2,...
    'ReturnValues', num2cell(int16(emptylist)));
s=jvElement(s, 'Component', 'javax.swing.JCheckBox',...
    'Label','Save as integer',...
    'Position', [0.1 0.4 0.8 0.1]);

h=jvDisplay(fhandle,s);
jvSetHelp(h, 'Copy To Temporary Channel.html');
uiwait();
% Get the return values
s=getappdata(fhandle,'sigTOOLjvvalues');
if isempty(s)
    return
end
clear('channels');
arglist={fhandle, s.ChannelA, s.ChannelB, s.Saveasinteger};
scExecute(@scMakeTempChannel, arglist)
return
end







