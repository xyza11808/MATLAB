function varargout=scCommit(varargin)
% scCommit commits memory mapped data on disc to memory
%
% Examples:
% err=scCommit(fhandle, channelnumber)
% [channels err]=scCommit(channels, channelnumber)
%
% fhandle is a sigTOOL data view figure handle
% channels is a sigTOOL channel cell arry
% channelnumber is the number of the chanel to commit to RAM
% err is returned zero if the operation completed successfully, -1 otherwise.
%
% Use lasterror() to determine why a failure occurred. This is likely to be
% because you are out of memeory in which case channels will be unchanged.
%
% Note that the adc field of Custom channels will not be committed to RAM
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 08/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------


err=0;

% Process inputs
if ishandle(varargin{1})
    fhandle=varargin{1};
    chan=varargin{2};
    channels=getappdata(fhandle, 'channels');
elseif iscell(varargin{1})
    channels=varargin{1};
    chan=varargin{2};
else
    error('scCommit: sigTOOL data view handle or channel cell array required on input');
end

% Commit the data
try 
    % Note order: if commit fails on adc, tim will not be committed either.
    % This will return channel unchanged if out-of-memory error occurs
    % accessing channels{chan}.adc on the RHS below
    if ~isempty(channels{chan}.adc) &&...
            isempty(strfind(channels{chan}.hdr.channeltype, 'Custom')) &&...
            isa(channels{chan}.adc, 'adcarray') &&...
            ~strcmp(channels{chan}.adc.Map.Format{1}, 'double')
        channels{chan}.adc=adcarray(channels{chan}.adc(),...
            1,...
            0,...
            '',...
            channels{chan}.adc.Units,...
            channels{chan}.adc.Labels,...
            false);
        channels{chan}.hdr.title=[channels{chan}.hdr.title '**'];
    end
    if ~isempty(channels{chan}.tim)
        channels{chan}.tim=tstamp(channels{chan}.tim(),...
            1,...
            0,...
            '',...
            channels{chan}.tim.Units,...
            false);
    end
catch
    err=-1;
end


if ishandle(varargin{1})
    % Update the figure application data ...
    setappdata(fhandle, 'channels', channels);
    scChannelManager(fhandle, true);
    varargout{1}=err;
    return
else
    % ... or return the data
    varargout{1}=channels;
    varargout{2}=err;
    return
end


end
