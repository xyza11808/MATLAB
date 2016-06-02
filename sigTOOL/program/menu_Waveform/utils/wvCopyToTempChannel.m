function [channels, filename]=wvCopyToTempChannel(fhandle, source, target, IntFlag)
% wvCopyToTempChannel creates a temporary sigTOOL waveform channel
%
% Data are written to a temporary file placed in the system temp folder.
% They will be deleted when the figure is closed. 
%
% Examples:
% wvCopyToTempChannel(fhandle, source, target, IntFlag)
% channels=wvCopyToTempChannel(fhandle, source, target, IntFlag)
% channels=wvCopyToTempChannel(channels, source, target, IntFlag
%
% where
%   fhandle     is the sigTOOL data view handle
%   or
%   channels    is a sigTOOL channel cell array
%   source      is the number of the channel to copy
%   target      is the number of the channel to copy data into
%   IntFlag     true to save an integer result
%                   [1] If IntFlag is true and the source data are  on
%                   disc in integer format, these values will be copied
%                   [2] If IntFlag is true and the source data are on
%                   disc in floating point format, these values will be
%                   scaled and offset and cast to int16 in the target
%                   channel
%                   [3] If IntFlag is false (default) data will be written
%                   to disc as double precision floating point, after
%                   scaling and offsetting                
%
% [channels, filename]=wvCopyToTempChannel(...)
%           also returns the name of the temporary file
%
% -------------------------------------------------------------------------
% With episodically sampled waveforms, only currently valid epochs will be
% copied.
%
% With multiplexed channels, only data from the currently selected
% subchannel will be copied.
% -------------------------------------------------------------------------
%
% See Also scCommit, memmapfile, adcarray, tempname
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
%
% Revisions
%   23.12.09  Add support for channel groups

if nargin<4
    IntFlag=false;
end

% Get the channel data
[fhandle, channels]=scParam(fhandle);

thischan=channels{source};

thisclass=thischan.adc.Map.Format{1};

% Set WriteMap flag: true if we just need to copy the integer data from the
% Map.Data.Adc field of an adcarray object. Avoids scaling
if IntFlag==true &&...
        any(strcmp(thisclass, {'int8', 'int16', 'int32', 'uint8', 'uint16', 'uin32'}))
    WriteMap=true;
else
    WriteMap=false;
    n=prod(thischan.adc.Map.Format{2});
    if n*8>2^32
        disp('Too many data points to convert to double: channels limited to 2Gb');
    end
end

% Create a temporary file in the system temp folder
filename=[tempname() '.mat'];

% Main routine
cols=size(thischan.adc, 2);
progbar=scProgressBar(0,'Copying data...','Name', 'Temporary Channel...' );

switch cols
    case 0
        % Empty - do nothing
    case 1
        % Vector - continuous waveform data
        % blocksize sets the maximum size of invidual writes
        blocksize=(2^24)/8;
        if isMultiplexed(thischan)
            np=thischan.hdr.adc.Npoints/thischan.hdr.adc.Multiplex;
        else
            np=thischan.hdr.adc.Npoints;
        end
        % Number of writes
        nsect=fix(np/blocksize);
        % Elements remaining for last write
        r=rem(np, blocksize);
        if nsect<=1
            % Just one write needed
            if WriteMap==true
                if isMultiplexed(thischan)
                    data=thischan.adc.Map.Data.Adc(thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:end);
                else
                    data=thischan.adc.Map.Data.Adc(); %#ok<NASGU>
                end
            else
                if isMultiplexed(thischan)
                    data=thischan.adc(thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:end);
                else
                    data=thischan.adc(); %#ok<NASGU>
                end
            end
            save(filename, 'data', '-v6');
            RestoreDiscClass(filename, 'data');
            dataminimum=min(data(:));
            datamaximum=max(data(:));
        else
            % Multiple writes
            if WriteMap==true
                data=thischan.adc.Map.Data.Adc(thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:blocksize);
            else
                data=thischan.adc(thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:blocksize);
            end
            % First section
            save(filename, 'data', '-v6');
            RestoreDiscClass(filename, 'data');
            dataminimum=min(data(:));
            datamaximum=max(data(:));
            tic;
            % Those in the middle
            for i=1:nsect-2
                idx=i+(thischan.CurrentSubchannel-1);
                if WriteMap==true
                    data=thischan.adc.Map.Data.Adc((idx*blocksize)+1:thischan.hdr.adc.Multiplex:(idx*blocksize)+blocksize);
                else
                    data=thischan.adc((idx*blocksize)+1:thischan.hdr.adc.Multiplex:(idx*blocksize)+blocksize);
                end
                AppendVector(filename, 'data', data );
                dataminimum=min([data' dataminimum]);
                datamaximum=max([data' datamaximum]);
                tm=toc;
                str=sprintf('<HTML><CENTER>Copying channel %d<P> %d seconds remaining.</P></CENTER></HTML>',...
                    source, int16(nsect*(tm/i))-tm);
                scProgressBar(i/nsect, progbar, str);
            end
            if r>0
                % Final section if needed
                if WriteMap==true
                    data=thischan.adc.Map.Data.Adc(((nsect-1)*blocksize)+thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:end);
                else
                    data=thischan.adc(((nsect-1)*blocksize)+thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:end);
                end
                scProgressBar(1, progbar, 'Copying data complete');
                AppendVector(filename, 'data', data);
                dataminimum=min([data' dataminimum]);
                datamaximum=max([data' datamaximum]);
            end
        end
    otherwise
        % Multiple columns in matrix
        % Write 128 columns per write
        epochspersection=128;
        epochs=getValidEpochNumbers(thischan, 1, 'end');
        if WriteMap==true
            data=thischan.adc.Map.Data.Adc(thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:end,epochs(1));
        else
            data=thischan.adc(thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:end,epochs(1));
        end
        dataminimum=min(data(:));
        datamaximum=max(data(:));
        % First column
        save(filename, 'data', '-v6');
        RestoreDiscClass(filename, 'data');
        if length(epochs)<epochspersection
            if WriteMap==true
                AppendColumns(filename, 'data', thischan.adc.Map.Data.Adc(:, epochs(2:end)));
            else
                AppendColumns(filename, 'data', thischan.adc(:, epochs(2:end)));
            end
        else
            % Middle columns in sets of epochspersection
            tic;
            for k=2:epochspersection:length(epochs)-epochspersection
                if WriteMap==true
                    data=thischan.adc.Map.Data.Adc(thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:end, epochs(k:k+epochspersection-1));
                else
                    data=thischan.adc(thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:end, epochs(k:k+epochspersection-1));
                end
                AppendColumns(filename, 'data', data);
                tm=toc;
                str=sprintf('<HTML><CENTER>Copying channel %d<P> %d seconds remaining.</P></CENTER></HTML>',...
                    source, int16(cols*(tm/k))-tm);
                scProgressBar(k/cols, progbar, str);
                dataminimum=min([data(:);dataminimum]);
                datamaximum=max([data(:);datamaximum]);
            end
            % Any remaining columns
            if k+epochspersection-1<cols
                if WriteMap==true
                    data=thischan.adc.Map.Data.Adc(thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:end, epochs(k+epochspersection:end));
                else
                    data=thischan.adc(thischan.CurrentSubchannel:thischan.hdr.adc.Multiplex:end, epochs(k+epochspersection:end));
                end
                AppendColumns(filename, 'data', data);
                dataminimum=min([data(:);dataminimum]);
                datamaximum=max([data(:);datamaximum]);
            end
        end
end

% Reset Scale & DC if written as double
if WriteMap==false
    thischan.hdr.adc.Scale=1;
    thischan.hdr.adc.DC=0;
    thischan.hdr.adc.Func='';
end
% Flag the thischan with an asterisk
thischan.hdr.title=[thischan.hdr.title '*'];


% We have copied only epochs that were selected by the Event Filter (if on)
% so set this 'off'
if strcmp(thischan.EventFilter.Mode,'on')
    thischan.EventFilter.Mode='off';
    thischan.tim=tstamp(thischan.tim(epochs,:),...
        thischan.tim.Scale,...
        thischan.tim.Shift,...
        [],...
        thischan.tim.Units,...
        false);
    thischan.mrk=thischan.mrk(epochs,:);
    thischan.hdr.adc.Npoints=thischan.hdr.adc.Npoints(epochs);
end

% And we have copied only 1 subchannel
thischan.hdr.adc.Npoints=thischan.hdr.adc.Npoints/thischan.hdr.adc.Multiplex;
thischan.hdr.adc.Multiplex=1;
thischan.hdr.adc.MultiplexInterval=[NaN NaN];
thischan.CurrentSubchannel=1;

% Set up memmap
ws=where(filename, 'data');
FormatString={ws.DiscClass{1} ws.size 'Adc'};
map=memmapfile(filename,...
    'Repeat',1,...
    'Writable', true,...
    'Format',FormatString,...
    'Offset',ws.DataOffset{1}.DiscOffset);

% Create adcarray - copy setting from old adcarray (updated above if needs
% be) but set swapbytes false - new file was created with system endian
% format
thischan.adc=adcarray(map,...
    thischan.hdr.adc.Scale,...
    thischan.hdr.adc.DC,...
    thischan.hdr.adc.Func,...
    thischan.hdr.adc.Units,...
    thischan.hdr.adc.Labels,...
    false);

% Delete progress bar
delete(progbar);

% Update the sigTOOL data view where required and release virtual memory
% used by the source channel
thischan.channelchangeflag.tim=true;
thischan.channelchangeflag.adc=true;
thischan.channelchangeflag.mrk=true;
thischan.channelchangeflag.hdr=true;

channels{target}=thischan;


% Update the application data area
if ~isempty(fhandle)
    setappdata(fhandle, 'channels', channels);
    % Keep a list of created files in the application data area.
    % These will be deleted when the figure is closed
    TempFileList=getappdata(fhandle, 'TempFileList');
    if isempty(TempFileList)
        TempFileList={filename};
    else
        TempFileList{end+1}=filename;
    end
    setappdata(fhandle, 'TempFileList', TempFileList);
end

% Record Group data
channels=UpdateChannelTree(fhandle, target, source);

% If we can, release virtual memory for source channel
if ~isempty(fhandle) && ~(source==target)
    clear('channels', 'thischan');
    channels=scRemap(fhandle, source);
end


% Replace double precision map with integer if required
if IntFlag==true && WriteMap==false
    if ~isempty(fhandle)
        clear('channels', 'thischan');
        scRemap(fhandle);
        channels=wvConvertToInteger(fhandle, target, dataminimum, datamaximum);
    else
        if nargout>0
            clear('thischan');
            [channels{target}]=wvConvertToInteger(channels{target},...
                dataminimum, datamaximum);
        end
    end
end

return
end
