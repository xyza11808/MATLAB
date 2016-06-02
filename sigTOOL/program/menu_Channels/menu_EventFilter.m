function varargout=menu_EventFilter(varargin)
% menu_EventFilter sets up the event filters in sigTOOL
% 
% menu_EventFilter associates a function handle and, optionally, a template 
% containing a set of values to match to a sigTOOL data view.
% These are stored in the application data area of the calling figure.
% Separate functions and templates are provided for each of the Channel 
% selections A and B.
%
% Analysis functions can call the event filter functions to determine which
% subsets of timestamps or data epochs to analyze, typically using the
% scEventFilter function.
% 
% Event Filter Functions
% The function should accept a channel cell element on input and return a
% row vector of logical flags:   true if the template is matched
%                                false otherwise
% The returned vector has one element for each epoch of data
%
% The following standard functions are defined that do not require any
% marker data in the channel
% 'Off'         returns true for all epochs in the channel (default)
% 'Odd epochs'  returns true for odd numbered epochs, false otherwise
% 'Even epochs' returns true for even numbered epochs, false otherwise 
% 
% The following require a simple numeric matrix in the channel marker field
% 'Match Any'   returns true if any marker value for the epoch matches 
%               any of specified values in the template, false otherwise
% 'Match All'   returns true if there is a match between each 
%               element in each row of marker data, and the corresponding
%               element in the specified template 
% 
% e.g.
%              channels{1}.mrk(10,:)=[0 1 2 3]
%       'Match Any' with an input of 0, 1, 2 or 3 would return true
%       'Match All' with an input [0 1 2 3] would return true
% 
% If you select 'Custom' from the menu you will be prompted to select a
% custom defined m-file. Such an m-file should have the form
% [TF match]=functionname(channel, match)
% where     channel is an scchannel object
%           match, if present, are the values to match (e.g. as in
%           matchany)
% TF is the output to place in the channel.EventFilter.Flags field and is a
% logical vector with one value for each event/epoch in channel.
% Functions must return match, even if it is unused (return it empty).
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

if nargin==1 && varargin{1}==0
    varargout{1}=true;
    varargout{2}='Event Filter';
    varargout{3}=[];
    return
end


% Marker function
[button fhandle]=gcbo;
% Set up the channel lists
channels=getappdata(fhandle, 'channels');
clist=scGetChannelsByType(channels, {'All'});
if isempty(clist)
    return
end

for i=1:length(clist)
    list{i}=clist(i);
    str{i}=sprintf('%d: %s',list{i}, channels{list{i}}.hdr.title);
end


% Create a structure for jvDisplay...
Position=[0.35 0.35 0.3 0.25];
s=jvPanel('Title', 'Event Filter Setup',...
    'Position', Position,...
    'ToolTipText', '',...
    'AckText','');

s=jvElement(s, 'Component', 'channelselector',...
    'Label', 'Channel A',...
    'Position', [0.1 0.7 0.8 0.1],...
    'DisplayList', str, ...
    'ReturnValues', list);

s=jvElement(s, 'Component', 'javax.swing.JComboBox',...
    'Label', 'Mode',...
    'Position', [0.1 0.45 0.35 0.1],...
    'DisplayList', {'Off' 'Cursors' 'Odd Epochs' 'Even Epochs' 'Every Nth Epoch', 'Match Any' 'Match All' 'Custom'},...
    'ReturnValues', {'',...
        'CursorEventFilter'...
        'OddEpochs',...
        'EvenEpochs',...
        'EveryNthEpoch',...
        'MatchAny',...
        'MatchAll',...
        ''});

%...and call it
h=jvDisplay(fhandle,s);
% Deal with Custom selection through a callback
h{1}.Mode.ActionPerformedCallback={@CustomCallback};
jvSetHelp(h, mfilename(), 'Event Filters');
uiwait();

s=getappdata(fhandle, 'sigTOOLjvvalues');
if isempty(s)
    return
end

scApplyEventFilter(fhandle, s.ChannelA, s.Mode);
return
end



%--------------------------------------------------------------------------
function CustomCallback(hObject, EventData)
%--------------------------------------------------------------------------
fhandle=ancestor(hObject.hghandle,'figure');
idx=hObject.getSelectedIndex()+1;
str=hObject.getSelectedItem();

switch str
    case 'Custom'
        filename=uigetfile('*.m', 'Select Custom Event Filter Function');
        if filename==0
            return
        end
        [dum filename]=fileparts(filename);
        func=str2func(filename);
        func(fhandle);
        hObject.insertItemAt(filename, idx-1);        
    otherwise
        return
end
return
end

