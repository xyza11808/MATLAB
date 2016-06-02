function varargout=menu_Decimate(varargin)
% menu_Filter gateway to zero-phase filtering of waveform channels

% Called as menu_Filter(0)
if nargin==1 && varargin{1}==0
    if isempty(which('dfilt'))
        varargout{1}=false;
    else
        varargout{1}=true;
    end
    varargout{2}='Decimate';
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
s=jvPanel('Title', 'Decimate',...
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
s=jvElement(s, 'Component', 'javax.swing.JComboBox',...
    'Label', 'Factor',...
    'Position', [0.1 0.3 0.2 0.1],...
    'DisplayList',num2cell(int16([2 5 10 20 50 100 200])));
s=jvElement(s, 'Component', 'javax.swing.JCheckBox',...
    'Label', 'Convert to 16 bit integer',...
    'Position', [0.35 0.325 0.6 0.1]);
h=jvDisplay(fhandle,s);
h=jvSetHelp(h, mfilename(), 'Decimation.html');
uiwait();
% Get the return values
s=getappdata(fhandle,'sigTOOLjvvalues');

if isempty(s)
    return
end

clear('channels');
arglist={fhandle, s.ChannelA, s.ChannelB,...
    s.Convertto16bitinteger, s.Factor};
scExecute(@scDecimate, arglist);

return
end







