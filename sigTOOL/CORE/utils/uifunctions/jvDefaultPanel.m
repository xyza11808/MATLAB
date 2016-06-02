function h=jvDefaultPanel(fhandle, varargin)
% jvDefaultPanel sets up the default panel style
%
% Example:
% h=jvDefaultPanel(fhandle, PropName1, PropName2,.....)
%
% fhandle is the sigTOOL data view handle
%
% Valid property name/value pairs
%       Position:     Position of the panel
%                           (normalized 4-element position vector)
%       Title:        The title for the panel
%                           (string)
%       ChannelType:  The valid channel types e.g. 'Edge', 'Waveform' or 'all'
%                           (string)
%       ToolTipText:  Tip for the panel
%       
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/07
% Copyright © The Author & King’s College London 2007-
%-------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:

% Defaults
h=[];
[dummy Title]=fileparts(tempname());
Position=[0.35 0.35 0.3 0.3];
AckText='';
ChannelType='all';
ChannelLabels={'' ''};
% Deal with inputs
for i=1:2:length(varargin)-1
    switch lower(varargin{i})
        case 'position'
            Position=varargin{i+1};
        case 'title'
            Title=varargin{i+1};
        case 'channeltype'
            ChannelType=varargin{i+1};
        case 'channellabels'
            ChannelLabels=varargin{i+1};
        case 'acktext'
            AckText=varargin{i+1};
        otherwise
            error('jvDefaultPanel: No such property %s', varargin{i});
    end
end

if ~iscell(ChannelType)
    ChannelType={ChannelType};
    ChannelType(2)=ChannelType(1);
end

% Set up the channel lists
channels=getappdata(fhandle, 'channels');
clist=scGetChannelsByType(channels, ChannelType{1});
    list={0 clist -1};
    str={'None' 'All' 'Selected'};
    for i=4:4+length(clist)-1
        list{i}=clist(i-3);
        if list{i}<=length(channels) && ~isempty(channels{list{i}})
            titlestr=channels{list{i}}.hdr.title;
        else
            titlestr='Empty';
        end
        str{i}=sprintf('%d: %s',list{i}, titlestr);
    end

% Create a structure for jvDisplay...
s=jvPanel('Title', Title,...
    'Position', Position,...
    'ToolTipText', '',...
    'AckText',AckText);

lab='Channel A';
if ~isempty(ChannelLabels{1})
    lab=[lab ' (' ChannelLabels{1} ')'];
end
s=jvElement(s, 'Component', 'channelselector',...
    'Label', lab ,...
    'Position', [0.1 0.7 0.8 0.1],...
    'DisplayList', str, ...
    'ReturnValues', list);

% Set up the channel lists
clist=scGetChannelsByType(channels, ChannelType{2});
% if isempty(clist)
%     return
% end
list={0 clist -1};
str={'None' 'All' 'Selected'};
for i=4:4+length(clist)-1
    list{i}=clist(i-3);
    if list{i}<=length(channels) && ~isempty(channels{list{i}})
        titlestr=channels{list{i}}.hdr.title;
    else
        titlestr='Empty';
    end
    str{i}=sprintf('%d: %s',list{i}, titlestr);
end
lab='Channel B';
if ~isempty(ChannelLabels{2})
    lab=[lab ' (' ChannelLabels{2} ')'];
end
s=jvElement(s, 'Component', 'channelselector',...
    'Label', lab,...
    'Position', [0.1 0.5 0.8 0.1],...
    'DisplayList', str, ...
    'ReturnValues', list);

s=jvElement(s, 'Component', 'timermenu',...
    'Label', 'Start (s)',...
    'Position', [0.1 0.31 0.39 0.1]);

s=jvElement(s, 'Component', 'timermenu',...
    'Label', 'Stop (s)',...
    'Position', [0.51 0.31 0.39 0.1]);

%...and call it
h=jvDisplay(fhandle,s);

% activate when channel 1 has been selected if needed
if length(ChannelLabels)==2 && ~isempty(ChannelLabels{1}) && ~isempty(ChannelLabels{2})
    jvLinkChannelSelectors(h, 'all');
end

% Switch off the channel 2 selector for now...
h{1}.ChannelB.setEnabled(0);% N.B. No effect if JScrollPane

return
end



