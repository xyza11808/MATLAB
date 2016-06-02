function varargout=menu_Filter(varargin)
% menu_Filter provides zero-phase filtering of waveform channels

% Called as menu_Filter(0)
if nargin==1 && varargin{1}==0
    if isempty(which('dfilt'))
        varargout{1}=false;
    else
        varargout{1}=true;
    end
    varargout{2}='Digital Filter';
    varargout{3}=[];
    return
end

[button fhandle]=gcbo;
channels=getappdata(fhandle, 'channels');

% Active channel list
clist=scGetChannelsByType(channels, 'Waveform');
list=num2cell(clist(1:end));
for i=1:length(clist)
    str{i}=sprintf('%d: %s',list{i}, channels{list{i}}.hdr.title); %#ok<AGROW>
end

% Empty channel list
emptylist=scGetChannelsByType(channels, 'empty');
for i=1:length(emptylist)
    str2{i}=sprintf('%d: <unused>', emptylist(i));
end

% Create a structure for jvDisplay...
s=jvPanel('Title', 'Filter',...
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
    'ReturnValues', num2cell(emptylist));
s=jvElement(s, 'Component', 'javax.swing.JCheckBox',...
    'Label', 'Convert to 16 bit integer (after filtering)',...
    'Position', [0.15 0.35 0.8 0.1]);
h=jvDisplay(fhandle, s);
jvSetHelp(h, mfilename(), 'Digital Filter');
uiwait();
% Get the return values
s=getappdata(fhandle,'sigTOOLjvvalues');

if isempty(s)
    return
end

clear('channels');
wvFilterDesign(fhandle, s.ChannelA, s.ChannelB,...
    s.Convertto16bitinteger, s.ApplyToAll);

return
end







