function varargout=wvConvertToInteger(varargin)
% wvConvertToInteger converts a waveform channel to 16 bit integer format
%
% wvConvertToInteger converts floating point data in a sigTOOL waveform
% channel to 16 bit integer
%
% Data in the Map.Data.Adc field are scaled as
%       out=(in-DC)/scale
% where:
%       scale=(datamaximum-dataminimum)/65535
%       DC=(dataminimum+datamaximum)/2;
% dataminimum and datamaximum will be calculated from the supplied data
% unless specified on input.
%
% Examples:
% channels=wvConvertToInteger(fhandle, chan)
% channels=wvConvertToInteger(fhandle, chan, dataminimum, datamaximum)
%
% channels=wvConvertToInteger(channels, chan)
% channels=wvConvertToInteger(channels, chan, dataminimum, datamaximum)
%
% data=wvConvertToInteger(data)
% data=wvConvertToInteger(data, dataminimum, datamaximum)
%
% Integer data are written to a temporary file
%        [...., filename]=wvConvertToInteger(.....)
%            also returns the name of the temporary file
%
% where:
%       fhandle     is a sigTOOL data view handle
%       channels    is a sigTOOL channel cell array
%       data        is a sigTOOL channel cell array element or channel
%                       structure
%
% Data output is to a temporary file in the system temp folder [as returned
% by tempdir()] which will be memory mapped.
%
% If fhandle is supplied, the figure application data area will be updated.
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

dataminimum=[];
datamaximum=[];
fhandle=[];
channels=[];
chan=[];

if iscell(varargin{1}) || isstruct(varargin{1}) || isobject(varargin{1})
    if length(varargin{1})==1
        % wvConvertToInteger(channel,...)
        thischan=varargin{1};
        if iscell(thischan)
            thischan=thischan{1};
        end
        if nargin>1
            dataminimum=varargin{2};
            datamaximum=varargin{3};
        end
    else
        % wvConvertToInteger(channels, chan....)
        channels=varargin{1};
        chan=varargin{2};
        thischan=channels{chan};
        if nargin>2
            dataminimum=varargin{3};
            datamaximum=varargin{4};
        end
    end
else
    % wvConvertToInteger(fhandle, chan.....)
    fhandle=varargin{1};
    chan=varargin{2};
    channels=getappdata(fhandle, 'channels');
    thischan=channels{chan};
    if nargin>2
        dataminimum=varargin{3};
        datamaximum=varargin{4};
    end
end

if ~strcmp(thischan.adc.Map.Format{1}, 'double') &&...
        ~strcmp(thischan.adc.Map.Format{1}, 'single')
    error('wvConvertToInteger: adcarray must map to a floating point array');
end

if isempty(dataminimum)
    data=thischan.adc();
    dataminimum=min(data(:));
    datamaximum=max(data(:));
end


% Rescale the data
thischan.hdr.adc.YLim=[dataminimum datamaximum];
thischan.hdr.adc.Scale=(datamaximum-dataminimum)/65535;
thischan.hdr.adc.DC=(dataminimum+datamaximum)/2;

filename=[tempname() '.mat'];

progbar=scProgressBar(0,'','Name', 'Converting data');
cols=size(thischan.adc, 2);
switch cols
    case 0
        % Empty - do nothing
    case 1
        % Continuous waveform
        blocksize=2^20;
        np=thischan.hdr.adc.Npoints;
        % Number of writes
        nsect=fix(np/blocksize);
        % Elements remaining for last write
        r=rem(np, blocksize);
        if nsect<=1
            % Just one write needed
            data=int16((thischan.adc.Map.Data.Adc-thischan.hdr.adc.DC)/thischan.hdr.adc.Scale); %#ok<NASGU>
            save(filename, 'data', '-v6');
            RestoreDiscClass(filename, 'data');
        else
            % Multiple writes
            data=int16((thischan.adc.Map.Data.Adc(1: blocksize)-thischan.hdr.adc.DC)/thischan.hdr.adc.Scale); %#ok<NASGU>
            % First section
            save(filename, 'data', '-v6');
            RestoreDiscClass(filename, 'data');
            % Those in the middle
            tic;
            for i=1:nsect-2
                AppendVector(filename, 'data', int16(((thischan.adc.Map.Data.Adc((i*blocksize)+1:(i*blocksize)+blocksize))...
                    -thischan.hdr.adc.DC)/thischan.hdr.adc.Scale));
                tm=toc;
                str=sprintf('<HTML><CENTER>Converting to 16 bit integer<P> %d seconds remaining</P></CENTER></HTML>',...
                    int16(nsect*(tm/i))-tm);
                scProgressBar(i/nsect, progbar, str);
            end
            if r>0
                % Final section if needed
                AppendVector(filename, 'data', int16(((thischan.adc.Map.Data.Adc(((nsect-1)*blocksize)+1: end))...
                    -thischan.hdr.adc.DC)/thischan.hdr.adc.Scale))
            end
        end
    otherwise
        % Multiple columns in matrix
        % Write 128 columns per write
        epochspersection=128;
        data=int16((thischan.adc.Map.Data.Adc(:,1)-thischan.hdr.adc.DC)/thischan.hdr.adc.Scale); %#ok<NASGU>
        % First column
        save(filename, 'data', '-v6');
        RestoreDiscClass(filename, 'data');
        if size(thischan.adc, 2)<epochspersection
            AppendColumns(filename, 'data', int16((thischan.adc.Map.Data.Adc(:, 2:end)-thischan.hdr.adc.DC)/thischan.hdr.adc.Scale));
        else
            % Middle columns in sets of epochspersection
            for k=2:epochspersection:cols-epochspersection
                AppendColumns(filename, 'data', int16((thischan.adc.Map.Data.Adc(:, k:k+epochspersection-1)...
                    -thischan.hdr.adc.DC)/thischan.hdr.adc.Scale));
                scProgressBar(k/cols, progbar, 'Converting to 16 bit integer...');
            end
            % Any remaining columns
            if k+epochspersection-1<cols
                AppendColumns(filename, 'data', int16((thischan.adc.Map.Data.Adc(:, k+epochspersection:end)...
                    -thischan.hdr.adc.DC)/thischan.hdr.adc.Scale));
            end
        end
end

% Set up new memmap
ws=where(filename, 'data');
FormatString={ws.DiscClass{1} ws.size 'Adc'};
map=memmapfile(filename,...
    'Repeat',1,...
    'Writable', true,...
    'Format',FormatString,...
    'Offset',ws.DataOffset{1}.DiscOffset);

% Create adcarray and replace adc field of thischan with the new data
thischan.adc=adcarray(map,...
    thischan.hdr.adc.Scale,...
    thischan.hdr.adc.DC,...
    '',...
    thischan.hdr.adc.Units,...
    thischan.hdr.adc.Labels,...
    false);


% Finish
scProgressBar(1, progbar, 'Converting to 16 bit integer...');

if ~isempty(chan)
    channels{chan}=thischan;
end

thischan.channelchangeflag.adc=true;
thischan.channelchangeflag.hdr=true;

if ~isempty(fhandle)
    channels{chan}=thischan;
    setappdata(fhandle, 'channels', channels);
    % Update temporary file list
    TempFileList=getappdata(fhandle, 'TempFileList');
    if isempty(TempFileList)
        TempFileList={filename};
    else
        TempFileList{end+1}=filename;
    end
    setappdata(fhandle, 'TempFileList', TempFileList);
end

if nargout>0
    if ~isempty(channels)
        varargout{1}=channels;
    else
        varargout{1}=thischan;
    end
end

if nargout==2
    varargout{2}=filename;
end

delete(progbar);
return
end