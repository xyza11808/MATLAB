function fda=wvFilterDesign(fhandle, source, target, IntFlag, ApplyToAll)
% wvFilterDesign integrates FDATool into sigTOOL
% 
% FDATool is the standard filter design and analysis tool supplied as part
% of the MATLAB Signal Processing Toolbox.
%
% wvFilterDesign adds a sigTOOL menu to the FDATool figure
% This provides for:
% Select View:      select the sigTOOL data view
% Select Source:    select a source channel to filter
% Select Target:    select the target channel in the view
% Apply filter:     applies (and if necessary designs) the current filter
%
% Example:
% fda=wvFilterDesign(fhandle, source, target, IntFlag, ApplyToAll)
% fhandle: is the sigTOOL data view handle
% source:  is the source channel
% target:  is the target channel
% IntFlag: is true to convrt data to 16-bit integer after filtering
% ApplyToAll: applied the filter using the same source and target channels
%             in all open files
% 
% Filters are applied by calling wvFiltFilt.
%
% See Also fdatool, wvFiltFilt, scFilter
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

% Argument checks
if ~ishandle(fhandle)
    error('wvFilterDesign: a valid sigTOOL data view handle is required on input');
end

% Set up fdatool
% Get fdatool figure handle
h=findobj(0, 'Tag', 'FilterDesigner');
if numel(h)>1
    error('Multiple intances of FDATool exist. wvFilterDesign allows only one');
end

if isempty(h)
    % Invoke FDATool
    fda=fdatool();
    h=[];
elseif isempty(findobj(get(h, 'Parent'), 'Label', 'Select source'))
    % Use an instance of FDATool created outside of sigTOOL
    temp=getappdata(h,'fdatool');
    fda=temp.handle;
    h=[];
end


% If no handle found, invoke fdatool
if isempty(h) 
    % Add the sigTOOL menu to the fdatool figure window
    newmenu=uimenu(fda.Parent, 'Label', 'sigTOOL');
    uimenu(newmenu, 'Label', 'Select View');
    mChan=uimenu(newmenu, 'Label', 'Select source');
    tChan=uimenu(newmenu, 'Label', 'Select target');
    uimenu(newmenu, 'Label', 'Apply Filter',...
        'Callback', {@LocalApplyFilter, fda});
else
    % Retrieve handles from existing tool
    temp=getappdata(h,'fdatool');
    fda=temp.handle;
    mChan=findobj(fda.Parent, 'Label', 'Select source');
    tChan=findobj(fda.Parent, 'Label', 'Select target');
    findobj(fda.Parent, 'Label', 'Select View');
end

% disable unwanted options
df=findall(fda.Parent,'Tag','other');
set(df, 'Enable', 'off');

% Set default ripple (dB).
% This will not work as FDATool resets the default
% apass=findall(fda.Parent,'Tag', 'value1', 'String', '1');
% set(apass, 'String', '0.05');

figure(fda.Parent);
% Keep a record of which sigTOOL view is being dealt with in the
% application data area of fdatool parent figure.
setappdata(fda.Parent, 'sigTOOLViewHandle', fhandle);
setappdata(fda.Parent, 'sigTOOLViewSourceChannel', source);
setappdata(fda.Parent, 'sigTOOLViewTargetChannel', target);
setappdata(fda.Parent, 'sigTOOLViewIntFlag', IntFlag);
setappdata(fda.Parent, 'sigTOOLViewApplyToAll', ApplyToAll);


% Re-populate the Select View menu - may have opened more files since the
% last call
m=findobj(fda.Parent, 'Label', 'Select View');
delete(get(m, 'Children'));
h=findobj(0, 'Tag', 'sigTOOL:DataView');
for i=1:length(h)
    n=uimenu(m, 'Label', get(h(i), 'Name'),...
        'Callback', {@LocalSelectView, fda});
    if (h(i)==fhandle)
        % Check the current handle
        set(n, 'Checked', 'on');
    end
    set(n, 'UserData', h(i));
end

% Re-populate the source channel selector
ChannelSelector(fhandle, mChan, fda, source, 'Waveform');
ChannelSelector(fhandle, tChan, fda, target, 'empty');

sb=findobj(fda.Parent, 'Tag', 'StatusBar');
set(sb, 'String', sprintf('Current File: %s, Source channel %d, Target channel %d',...
    get(fhandle, 'Name'), source, target));

return
end
%--------------------------End of main routine-----------------------------

function ChannelSelector(fhandle, menu, fda, thischan, str)
% Argument checks
if nargin<5
    str='Waveform';
end
channels=getappdata(fhandle, 'channels');
clist=scGetChannelsByType(channels, str);
if nargin<4
    thischan=getappdata(fda.Parent, 'sigTOOLViewSourceChannel');
end
% if isempty(thischan) || thischan==0
%     thischan=clist(1);
% end
% Clear current menu
ch=get(menu, 'Children');
if ~isempty(ch)
    delete(ch);
end
% Re-populate
for i=1:length(clist)
    chan=clist(i);
    try
        desc=channels{chan}.hdr.title;
    catch
        desc='<unused>';
    end
    n=uimenu(menu, 'Label', sprintf('%d: %s', chan, desc),...
        'UserData', chan);
    if chan==thischan
        % Check the source handle
        set(n, 'Checked', 'on');
    end
    if strcmp(str, 'Waveform')
        set(n, 'Callback', {@LocalChannels, fda});
        if chan==thischan
            % Force an FDATool update if we have selected a new source
            LocalChannels(n, [], fda);
        end
    else
        set(n, 'Callback', {@LocalNewTarget, fda});
    end
end
clear('channels');
return
end

%--------------------------------------------------------------------------
%                               CALLBACKS
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function LocalApplyFilter(hObject, EventData, fda) %#ok<INUSL>
% This invokes the filter functions
%--------------------------------------------------------------------------
% Source channel number
source=getappdata(fda.Parent, 'sigTOOLViewSourceChannel');
target=getappdata(fda.Parent, 'sigTOOLViewTargetChannel');

if source==0 || target==0
    str=sprintf('You must select a source and target channel');
    msgbox(str,'Filter', 'warn');
    return
end

% Get the channels
fhandle=getappdata(fda.Parent, 'sigTOOLViewHandle');
channels=getappdata(fhandle, 'channels');
target=getappdata(fda.Parent, 'sigTOOLViewTargetChannel');
IntFlag=getappdata(fda.Parent, 'sigTOOLViewIntFlag');
ApplyToAll=getappdata(fda.Parent, 'sigTOOLViewApplyToAll');

if target<=length(channels) && ~isempty(channels{target})
    str=sprintf('Do you really want to overwrite channel %d', target);
    answer=questdlg(str,'Filter','Yes','No','No');
    if strcmp(answer, 'No')
        return
    end
end

% Sample rate in Hz
Fs=getSampleRate(channels{source});

% Check channel sample rate matches Fs in filter
Fs_specbox=findobj(fda.Parent,'Tag','fsspecifier_editbox');
filtFs=str2double(get(Fs_specbox, 'String'));

if (filtFs~=Fs)
    % Make sure we are working in Hz
    Fs_Units=findobj(fda.Parent, 'Tag', 'fsspecifier_popup');
    set(Fs_Units, 'Value', 2)
    cb=get(Fs_Units, 'Callback');
    cb{1}(Fs_Units, [], cb{2:end});

    % Update the sample rate
    Fs_specbox=findobj(fda.Parent,'Tag','fsspecifier_editbox');
    set(Fs_specbox, 'String', Fs,...
        'Enable', 'on');
    % Invoke standard callback as when text entered from keyboard
    cb=get(Fs_specbox, 'Callback');
    cb{1}(Fs_specbox, [], cb{2:end});
end

design=findobj(fda.Parent, 'Tag', 'designpanel_design');

if strcmp(get(design, 'Enable'),'on')
    % If the user has not designed the current selection,
    % force the filter design
    cb=get(design, 'Callback');
    cb{1}(design, [], cb{2:end});
    if ~isempty(findobj('Name', 'FDATool Error'))
        return
    end
end

Hd=fda.getfilter();
% Do some checks on the filter
if ~isstable(Hd) 
    return
end


clear('channels');
% Bring up the relevant figure
figure(fhandle)

% If we are recording, Hd will not have scope in a history file so we need
% to add a function to generate it
RecordFlag=getappdata(fhandle,'RecordFlag');
if RecordFlag
    History=getappdata(fhandle, 'History');
    str=sprintf('function Hd=function%d()\n', length(History.functions)+1);
    % Get the code stored in the sigtools.fdatool object
    code=get(get(fda,'MCode'),'buffer');
    for k=1:length(code)
        str=[str sprintf('%s\n', code{k})]; %#ok<AGROW>
    end
    History.functions{end+1}=str;
    setappdata(fhandle, 'History', History);
end

% Put the target channel in the list of source channels for future calls
h=get(findobj(fda.Parent, 'Label', 'Select target'), 'Children');
s=findobj(fda.Parent, 'Label', 'Select source');
h=findobj(h, 'UserData', target);
set(h, 'Checked', 'off');
set(h, 'Label', sprintf('%d: Filtered Data', target));
copyobj(h, s);
delete(h);
setappdata(fda.Parent, 'sigTOOLViewTargetChannel', 0);

% Now call scFilter via scExecute
arglist={fhandle, source, target, IntFlag, Hd};
scExecute(@scFilter, arglist, ApplyToAll);

return
end


%--------------------------------------------------------------------------
function LocalChannels(hObject, EventData, fda) %#ok<INUSL>
% Keeps menus and FDATool synchronized
%--------------------------------------------------------------------------
% Get the channels
fhandle=getappdata(fda.Parent, 'sigTOOLViewHandle');
channels=getappdata(fhandle, 'channels');

% Source channel number
source=get(hObject, 'UserData');

% Sample rate in Hz
Fs=1/channels{source}.hdr.adc.SampleInterval(2)...
    /channels{source}.hdr.adc.SampleInterval(1);

% Make sure we are working in Hz
Fs_Units=findobj(fda.Parent, 'Tag', 'fsspecifier_popup');
set(Fs_Units, 'Value', 2)
cb=get(Fs_Units, 'Callback');
cb{1}(Fs_Units, [], cb{2:end});

% Update the sample rate
Fs_specbox=findobj(fda.Parent,'Tag','fsspecifier_editbox');
set(Fs_specbox, 'String', Fs,...
    'Enable', 'on');
% Invoke standard callback as when text entered from keyboard
cb=get(Fs_specbox, 'Callback');
cb{1}(Fs_specbox, [], cb{2:end});

% Refresh the menus
h=get(get(hObject, 'Parent'), 'Children');
set(h, 'Checked', 'off');
set(hObject, 'Checked', 'on');

if isempty(channels{source})
    source=[];
end
setappdata(fda.Parent, 'sigTOOLViewSourceChannel', source);

sb=findobj(fda.Parent, 'Tag', 'StatusBar');
set(sb, 'String', sprintf('Current File: %s, Source channel %d, Target channel %d',...
    get(fhandle, 'Name'), source, getappdata(fda.Parent, 'sigTOOLViewTargetChannel')));

clear('channels');
return
end

%--------------------------------------------------------------------------
function LocalNewTarget(hObject, EventData, fda) %#ok<INUSL>
% Select new target channel
%--------------------------------------------------------------------------
fhandle=getappdata(fda.Parent, 'sigTOOLViewHandle');
h=get(get(hObject, 'Parent'), 'Children');
set(h, 'Checked', 'off');
set(hObject, 'Checked', 'on');
target=get(hObject, 'UserData');
source=getappdata(fda.Parent, 'sigTOOLViewSourceChannel');
setappdata(fda.Parent, 'sigTOOLViewTargetChannel',target);
sb=findobj(fda.Parent, 'Tag', 'StatusBar');
set(sb, 'String', sprintf('Current File: %s, Source channel %d, Target channel %d',...
    get(fhandle, 'Name'), source, target));
return
end

%--------------------------------------------------------------------------
function LocalSelectView(hObject, EventData, fda) %#ok<INUSL>
% Select sigTOOL data view
%--------------------------------------------------------------------------
m=get(get(hObject, 'Parent'), 'Children');
set(m, 'Checked', 'off');
set(hObject, 'Checked', 'on');
fhandle=get(hObject, 'UserData');
setappdata(fda.Parent, 'sigTOOLViewHandle', fhandle);

% Now check the channel selections are valid for this view
channels=getappdata(fhandle, 'channels');

mChan=findobj(fda.Parent, 'Label', 'Select source');
ChannelSelector(fhandle, mChan, fda);
source=getappdata(fda.Parent, 'sigTOOLViewSourceChannel');
if source>0 && isempty(channels{source})
    source=0;
end
setappdata(fda.Parent, 'sigTOOLViewSourceChannel', source);

target=getappdata(fda.Parent, 'sigTOOLViewTargetChannel');
tChan=findobj(fda.Parent, 'Label', 'Select target');
ChannelSelector(fhandle, tChan, fda, target, 'empty');
if target>0 && ~isempty(channels{target})
    target=0;
end
setappdata(fda.Parent, 'sigTOOLViewTargetChannel', target);

sb=findobj(fda.Parent, 'Tag', 'StatusBar');
set(sb, 'String', sprintf('Current File: %s, Source channel %d, Target channel %d',...
    get(fhandle, 'Name'), source, target));
clear('channels');
return
end

