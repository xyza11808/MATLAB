function fhandle=cvSetup(varargin)
% cvSetup sigTOOL single channel viewer entry function
%
% This is still under development. It will change substantially in future
% releases of sigTOOL.
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


% Examples:
% cvSetup(filename);
% cvSetup(filename, chan);
% cvSetup(fhandle, chan);
% cvSetup(channels, chan);
% cvSetup(data, Fs);


% TODOs: Remove the following temporary fixes
% cvRawDataAxis shifts all data to have zero start time


if isempty(which('scOpen'))
    fh=sigTOOL();
    delete(fh);
end

chan=[];
channels=[];
sourcehandle=[];
filename='';

switch nargin
    case 0
        % Do nothing for the moment
        fhandle=[];
        return
    case 1
        % Filename specified on input. Assume we want channel 1
        if ischar(varargin{1})
            filename=LocalLoadData(varargin{1});
        elseif ishandle(varargin{1})
            [sourcehandle channels]=scParam(varargin{1});
        end
        chan=NaN;
    case 2
        if ischar(varargin{1})
            % Filename and channel specified
            filename=LocalLoadData(varargin{1});
            chan=varargin{2};
        elseif isscalar(varargin{1}) || iscell(varargin{1});
            % sigTOOL data view or channel cell array
            [sourcehandle channels]=scParam(varargin{1});
            chan=varargin{2};
        elseif isnumeric(varargin{1})
            % Raw data
            channels=LocalCreateChannel(varargin{:});            
        end
end

if isempty(channels) && ~isempty(sourcehandle)
    channels=getappdata(sourcehandle, 'channels');
elseif ~isempty(filename)
    channels=scOpen(filename);
end

if isempty(chan)
    chan=findFirstChannel(channels{:});
end

% Set up the Viewer GUI and place the data in the application data area
fhandle=figure('Name', 'Channel Viewer',...
    'Units', 'normalized',...
    'ToolBar', 'none',...
    'Position',[0.05 0.05 0.85 0.85]);
setappdata(fhandle, 'channels', channels);



cvManager(fhandle);
chan=cvUserWindow1(fhandle, chan);
cvRawDataAxis(fhandle);

UpdateTableColumnNames(fhandle, chan);

return
end


function filename=LocalLoadData(filename)
[pathstr name ext]=fileparts(filename);
switch ext
    case '.kcl'
        % Already a sigTOOL data file
    otherwise
        % Import file
        fcn=scSelectImporter(ext);
        filename=fcn(filename);
end
return
end

function channels=LocalCreateChannel(data, Fs)
% This is called if cvSetup is supplied with a vector of data from the
% MATLAB comand line. Create a sigTOOL compatible scchannel object
channels{1}.hdr=scCreateChannelHeader();
channels{1}.hdr.channeltype='Continuous Waveform';
channels{1}.hdr.title='Data';
channels{1}.hdr.adc.SampleInterval=[1e6/Fs 1e-6];
channels{1}.hdr.adc.Units='';
channels{1}.hdr.adc.Npoints=length(data);
channels{1}.hdr.adc.YLim=[min(data) max(data)];
channels{1}.adc=adcarray(data,...
    1,...
    0,...
    [],...
    '',...
    false);
start=0;
stop=(length(data)-1)*prod(channels{1}.hdr.adc.SampleInterval);
channels{1}.hdr.tim.Scale=1e-6;
channels{1}.hdr.tim.Shift=0;
channels{1}.hdr.tim.Func=[];
channels{1}.hdr.tim.Units=1;
channels{1}.tim=tstamp([start stop]*1e6,...
    1e-6,...
    0,...
    [],...
    1,...
    false);
channels{1}.mrk=[];
channels{1}=scchannel(channels{1});    
return
end

