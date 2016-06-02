function varargout=scRemap(fhandle, ChannelList, mode)
% scRemap releases virtual memory used by a sigTOOL data view
%
% Examples:
% scRemap()
% channels=scRemap(fhandle)
% channels=scRemap(fhandle, ChannelList)
% channels=scRemap(fhandle, ChannelList, mode)
%
% If no input is given, scRemap releases the virtual memory allocated to all
% sigTOOL data views that are currently open in this instance of MATLAB.
% If fhandle is specified, scRemap releases the virtual memory allocated
% to the specified view only.If ChannelList is specified, only memory
% associated with the specified channels will be released.
%
% mode is a string: 'include' (default) or 'exclude'. When mode=='exclude',
% memory for all channels except those in ChannelList will be released.
%
% scRemap updates the application data area(s) of the relevant figure(s).
% If requested, a copy will be returned in channels
%
% To free up virtual memory successfully, scRemap requires that no
% copies/references to the relevant channel(s) exist in any other MATLAB
% workspace.
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

if nargin==0
    h=findobj('Tag', 'sigTOOL:DataView');
    for k=1:length(h)
        scRemap(h(k));
    end
    return
end

% Get a local copy of the channel data
channels=getappdata(fhandle, 'channels');

% Remove the copy in the application data area
if ~isempty(channels)
    rmappdata(fhandle, 'channels');
end

if nargin==1
    ChannelList=1:length(channels);
end

if nargin==3 && strcmp(mode, 'exclude')
    temp=1:length(channels);
    ChannelList=temp(~ismember(temp, ChannelList));
end

for k=1:length(ChannelList)
    chan=ChannelList(k);

    % Check we have an adcarray map
    if ~isempty(channels{chan}) &&...
            ~isempty(channels{chan}.adc) &&...
            isa(channels{chan}.adc, 'adcarray')
        
        % Check it is memory mapped
        if isa(channels{chan}.adc.Map, 'memmapfile')

            % Copy the memmapfile propery settings
            Filename=channels{chan}.adc.Map.Filename;
            Writable=channels{chan}.adc.Map.Writable;
            Offset=channels{chan}.adc.Map.Offset;
            Format=channels{chan}.adc.Map.Format;
            Repeat=channels{chan}.adc.Map.Repeat;

            % Reinitialize the map - no virtual memory will be allocated until an
            % attempt is made to access data in the new object
            channels{chan}.adc.Map=memmapfile(Filename,...
                'Writable', Writable,...
                'Offset', Offset,...
                'Format', Format,...
                'Repeat', Repeat);
        end


    end
end

% Place in application data area and quit
setappdata(fhandle, 'channels', channels);
if nargout>0
    varargout{1}=channels;
end
return
end



