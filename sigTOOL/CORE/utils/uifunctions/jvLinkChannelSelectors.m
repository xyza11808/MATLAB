function jvLinkChannelSelectors(h, linkmethod)
% jvLinkChannelSelectors links the Channel B selection to the Channel A


if ~iscell(h)
    h={h};
end

if nargin<2
    linkmethod='all';
end


switch lower(linkmethod)
    % Supported link methods
    case 'all'
        set(h{1}.ChannelA, 'ActionPerformedCallback', {@All, h{1}.ChannelB});
    case 'fs'
        set(h{1}.ChannelA, 'ActionPerformedCallback', {@Fs, h{1}.ChannelB});
    case {'synchronized' 'synchro'}
        set(h{1}.ChannelA, 'ActionPerformedCallback', {@Synchro, h{1}.ChannelB});
    case {'equal epochs'}
        set(h{1}.ChannelA, 'ActionPerformedCallback', {@EqualEpochs, h{1}.ChannelB});
end

return
end

%--------------------------------------------------------------------------
function All(hObj, EventData, target) %#ok<INUSL>
%--------------------------------------------------------------------------
target.setEnabled(true);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Fs(hObj, EventData, target) %#ok<INUSL>
%--------------------------------------------------------------------------
% Get data
fhandle=ancestor(hObj.hghandle, 'figure');
% Channel 1 selection
chan1=jvGetControlValue(hObj);
if chan1<1
    return
end
% Find channels with matching sample rate
channels=getappdata(fhandle, 'channels');
interval=prod(channels{chan1}.hdr.adc.SampleInterval);
list=[0 scFindMatchingFs(channels, interval)];
list=list(list>0);
% Update
UpdateChannelB(target, channels, list)
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Synchro(hObj, EventData, target) %#ok<INUSL>
%--------------------------------------------------------------------------
% Get data
fhandle=ancestor(hObj.hghandle, 'figure');
% Channel 1 selection
chan1=jvGetControlValue(hObj);
% Find channels with matching sample rate
channels=getappdata(fhandle, 'channels');
list=[0 scFindSynchronized(channels, chan1)];
% Update
UpdateChannelB(target, channels, list)
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function UpdateChannelB(target, channels, list)
%--------------------------------------------------------------------------
% Update channel 2 selector list
list=list(list>0);
% Create the menu drop down
str=cell(length(list),1);
str{1}='None';
for i=1:length(list)
    str{i+1}=sprintf('%d: %s',list(i),channels{list(i)}.hdr.title);
end
target.removeAllItems();
for k=1:length(str)
    target.addItem(str{k});
end
% Update the application data area
ReturnValues=num2cell([0; list']);
setappdata(target, 'ReturnValues', ReturnValues);
target.setEnabled(true);
return
end
%-------------------------------------------------------------------------

%-------------------------------------------------------------------------
function EqualEpochs(hObj, EventData, target) %#ok<INUSL>
%-------------------------------------------------------------------------
% Get data
fhandle=ancestor(hObj.hghandle, 'figure');
channels=getappdata(fhandle, 'channels');
% Channel 1 selection
chan1=jvGetControlValue(hObj);
if chan1==0
    return
end
% Find channels with matching epoch numbers
chan=scGetChannelsByType(fhandle, 'Episodic');
n=size(channels{chan1}.tim, 1);
TF=zeros(size(channels));
for k=1:length(chan)
    if ~isempty(channels{chan(k)})
        TF(chan(k))=size(channels{chan(k)}.tim, 1)==n;
    end
end
list=find(TF>0);
% Update
UpdateChannelB(target, channels, list)
return
end
