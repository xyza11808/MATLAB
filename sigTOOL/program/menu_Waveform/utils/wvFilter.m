function varargout=wvFilter(fhandle, source, target, IntFlag, Hd)
% wvFilter provides  filtering of sigTOOL waveform data
%
% Examples:
% channels=wvFilter(fhandle, source, target, Hd)
% channels=wvFilter(channels, source, target, Hd)
%
% where
%         fhandle     is a sigTOOL data figure handle
%                         source data will be taken from this figure and the
%                         application data area will be updated with the
%                         result
%         channels    is a cell array of scchannel objects
%         source      is the source channel number
%         target      is the target channel to receive the result
%                         (source and target may be equal)
%         IntFlag     flag, true to convert to int16 on disc
%         Hd          is a dfilt filter object
%
% wvFilter replaces wvFiltFilt and wvFFTFilt from earlier sigTOOL 
% versions
% 
% For all filters, wvFilter will attempt to filter the data in RAM. If
% this fails because of out-of-memory errors, filtering will instead be
% performed on a temporary channel with data being stored on disc.
% 
% FIR filters use a single pass through the data and correct for the
% group delay. Note however, that with an even number of filter
% coefficients, a shift of 0.5 samples will remain. Use filters
% with an odd number of coefficients to avoid this (i.e. specify an even
% order (n) in the design to get n+1 coefficients. FIR filters will be 
% applied using a fast FFT-based algorithm where this is possible and
% advantageous.
% 
% IIR filters are applied using a double pass, zero-phase shift
% algorithm.
% 
% For all filters, data are pre- and post -pended with a reversed and
% reflected copy of the data to minimize end-effects.
%
% See also filtfilt, filtfilthd, fftfilt, dfilt
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
%
% Revisions
%   23.12.09  Add support for channel groups

filename=[];
tempfile=[];

[fhandle, channels]=scParam(fhandle);

progbar=scProgressBar(0, '', 'Name', 'Filtering Data');
try
    % Filter in RAM if enough memory, returning result in double precision
    [dataminimum, datamaximum]=FilterInRam();
    channels{target}.hdr.adc.YLim=[dataminimum datamaximum];
    channels{target}.hdr.adc.Scale=1;
    channels{target}.hdr.adc.DC=0;
    channels{target}.hdr.adc.Func='';
    channels{target}.hdr.title=[channels{target}.hdr.title '**'];
catch %#ok<CTCH>
    if ~isOOM()
        rethrow(lasterror()) %#ok<LERR>
    else
    lasterror('reset'); %#ok<LERR>
    % Filter above failed. Set up temporary channel to accept filter output
    [channels, tempfile]=wvCopyToTempChannel(channels, source, target);
    % This block will call scRemap to free virtual memory if need be
    try
        % Try to trigger error through call to size
        cols=size(channels{target}.adc.Map.Data.Adc, 2);
    catch %#ok<CTCH>
        % Free up virtual memory is we need to
        if isOOM() && ~isempty(fhandle)
            setappdata(fhandle, 'channels', channels);
            clear('channels');
            scRemap(fhandle);
            channels=getappdata(fhandle, 'channels');
            cols=size(channels{target}.adc.Map.Data.Adc, 2);
        else
            rethrow(lasterror()); %#ok<LERR>
        end
    end
    % Do the filtering
    scProgressBar(0, progbar, '');
    switch cols
        case 0
            % No data
        case 1
            % Single column
            [dataminimum, datamaximum]=LocalFilterSingleColumn(progbar);
        otherwise
            % Multiple columns
            [dataminimum, datamaximum]=LocalFilterMultiColumn(progbar);
    end
    % Addded 25.10.08
    channels{target}.hdr.adc.YLim=[dataminimum datamaximum];
    end
end

% Tidy up
channels{target}.channelchangeflag.adc=true;
channels{target}.channelchangeflag.hdr=true;
channels{target}.channelchangeflag.tim=true;
channels{target}.channelchangeflag.mrk=true;

% Record Group data
channels=UpdateChannelTree(channels, target, source);

% Add details of this filter to the channel header
% Add m-code, not the object, so this can be saved and read on systems 
% without the dfilt classes installed.
if isfield(channels{target}.hdr.adc, 'FilterRecord')
    channels{target}.hdr.adc.FilterRecord={channels{target}.hdr.adc.FilterRecord{:} Hd.genmcode};
else
    channels{target}.hdr.adc.FilterRecord={Hd.genmcode};
end

% Replace double precision map data with integer if requested
if IntFlag
    [channels{target}, filename]=wvConvertToInteger(channels{target},...
        dataminimum, datamaximum);
    % delete the double precision file
    if (~isempty(tempfile))
        delete(tempfile);
    end
end

if ~isempty(fhandle)
    setappdata(fhandle, 'channels', channels);
    % Update temporary file list
    if ~isempty(filename)
        TempFileList=getappdata(fhandle, 'TempFileList');
        if isempty(TempFileList)
            TempFileList={filename};
        else
            TempFileList{end+1}=filename;
        end
        setappdata(fhandle, 'TempFileList', TempFileList);
    end
end
delete(progbar);

if nargout>0
    varargout{1}=channels;
end
return
%----------------------------END OF CODE FOR MAIN ROUTINE -----------------

% NESTED FUNCTIONS
%----------------------------------------------------------------------
    function [dataminimum, datamaximum]=FilterInRam()
        %------------------------------------------------------------------
        % Try to filter in double precision.
        % Will fail if insufficient memory - throwing error that will be
        % caught in calling function
        thischan=channels{source};
        epochs=getValidEpochNumbers(thischan, 1, 'end');
        
        if isMultiplexed(thischan)
            temp=thischan.adc(thischan.CurrentSource:thischan.hdr.adc.Multiplex:end, epochs);
            thischan.hdr.adc.Npoints=thischan.hdr.adc.Npoints/thischan.hdr.adc.Multiplex;
        else
            temp=thischan.adc(:, epochs);
        end
        
        cols=size(temp, 2);
        z=impzlength(Hd);
        if cols==1
            % Continuous waveform
            scProgressBar(0.5, progbar, '<HTML><CENTER>Fast filtering single epoch in RAM.<P>Please wait...</P></CENTER></HTML>');
            if isfir(Hd)
                temp=LocalFilter(Hd, temp, z);
            else
                temp=filtfilthd(Hd, temp, z);
            end
        else
            % Multiple columns
            for kk=1:cols
                if rem(kk,20)==0
                    scProgressBar(kk/cols, progbar, sprintf('<HTML><CENTER>Fast filtering in RAM<P>Epoch %d of %d</P></CENTER></HTML>', kk, cols));
                end
                if isfir(Hd)
                    temp(1:thischan.hdr.adc.Npoints(epochs(kk)), kk)=...
                        LocalFilter(Hd, temp(1:thischan.hdr.adc.Npoints(epochs(kk)), kk), z);
                else
                    temp(1:thischan.hdr.adc.Npoints(epochs(kk)), kk)=...
                        filtfilthd(Hd, temp(1:thischan.hdr.adc.Npoints(epochs(kk)), kk), z);
                end
            end
        end
        
        thischan.adc=adcarray(temp,...
            1,...
            0,...
            '',...
            thischan.adc.Units,...
            thischan.adc.Labels,...
            false);
        
        if strcmp(thischan.EventFilter.Mode,'on')
            thischan.EventFilter.Mode='off';
            thischan.tim=tstamp(thischan.tim(epochs,:));
            thischan.mrk=thischan.mrk(epochs,:);
            thischan.hdr.adc.Npoints=thischan.hdr.adc.Npoints(epochs);
        end
        
        dataminimum=min(temp(:));
        datamaximum=max(temp(:));
        channels{target}=thischan;
        return
    end
%----------------------------------------------------------------------


%----------------------------------------------------------------------
    function [dataminimum, datamaximum]=LocalFilterSingleColumn(progbar)
        %------------------------------------------------------------------
        thischan=channels{target};
        % Continuous waveform
        blocksize=(2^24)/8;
        np=thischan.hdr.adc.Npoints;
        % Number of writes
        nsect=fix(np/blocksize);
        % Elements remaining for last write
        r=rem(np, blocksize);
        if nsect<=1
            % Just one block
            scProgressBar(0.5, progbar, 'Filtering as single block...');
            if isfir(Hd)
                thischan.adc.Map.Data.Adc=LocalFilter(Hd, thischan.adc());
            else
                thischan.adc.Map.Data.Adc=filtfilthd(Hd, thischan.adc());
            end
            dataminimum=min(thischan.adc.Map.Data.Adc(:));
            datamaximum=max(thischan.adc.Map.Data.Adc(:));
        else
            % Multiple blocks
            if isfir(Hd)
                LocalFIR();
            else
                [dataminimum datamaximum]=LocalZeroPhase()
            end
            channels{target}=thischan;
            return
        end

        
        %------------------------------------------------------------------
        
        %------------------------------------------------------------------
        function [dataminimum datamaximum]=LocalZeroPhase()
            %--------------------------------------------------------------
            dataminimum=Inf;
            datamaximum=-Inf;
            len=length(thischan.adc.Map.Data.Adc);
            nfact=impzlength(Hd);
            nfact=min(len-1, nfact);
            pre=2*thischan.adc.Map.Data.Adc(1)-thischan.adc(nfact+1:-1:2);
            post=2*thischan.adc.Map.Data.Adc(len)-thischan.adc(len-1:-1:len-nfact);
            set(Hd,'persistentmemory', true);
            reset(Hd);
            
            % FORWARD FILTER PASS
            % Start
            scProgressBar(0, progbar, 'Filtering data. Forward pass...' );
            pre=filter(Hd, pre); %#ok<NASGU> this seeds Hd
            thischan.adc.Map.Data.Adc(1:blocksize)=filter(Hd, thischan.adc(1: blocksize));
            tic;
            % Middle blocks
            for i=1:nsect-2
                temp=filter(Hd, thischan.adc((i*blocksize)+1:(i*blocksize)+blocksize));
                thischan.adc.Map.Data.Adc((i*blocksize)+1:(i*blocksize)+blocksize)=temp;
                tm=toc;
                str=sprintf('<HTML><CENTER>Filtering data: Forward pass<P> %d seconds remaining.</P></CENTER></HTML>',...
                    int16(nsect*(tm/i))-tm);
                scProgressBar(i/nsect, progbar,str );
            end
            if r>0
                % Final section if needed
                thischan.adc.Map.Data.Adc(((nsect-1)*blocksize)+1: end)=...
                    filter(Hd, thischan.adc(((nsect-1)*blocksize)+1: end));
                scProgressBar(1, progbar, 'Forward pass completed' );
            end
            post=filter(Hd, post);
            
            % REVERSE PASS
            reset(Hd);
            scProgressBar(0, progbar, 'Reverse pass...' );
            filter(Hd, post(end:-1:1));
            tic;
            if r>0
                % Final section if needed
                thischan.adc.Map.Data.Adc(end:-1:((nsect-1)*blocksize)+1)=...
                    filter(Hd, thischan.adc(end:-1:((nsect-1)*blocksize)+1));
                dataminimum=min([thischan.adc.Map.Data.Adc(end:-1:((nsect-1)*blocksize)+1)' dataminimum]);
                datamaximum=max([thischan.adc.Map.Data.Adc(end:-1:((nsect-1)*blocksize)+1)' datamaximum]);
            end
            for i=nsect-2:-1:1
                temp=thischan.adc((i*blocksize)+blocksize:-1:(i*blocksize)+1);
                temp=filter(Hd, temp);
                dataminimum=min([temp' dataminimum]);
                datamaximum=max([temp' datamaximum]);
                thischan.adc.Map.Data.Adc((i*blocksize)+blocksize:-1:(i*blocksize)+1)=temp;
                tm=toc;
                str=sprintf('<HTML><CENTER>Filtering data: Reverse pass<P> %d seconds remaining.</P></CENTER></HTML>',...
                    int16(nsect*(tm/(nsect-i)))-tm);
                scProgressBar(1-(i/nsect), progbar, str);
            end
            scProgressBar(1, progbar, 'Reverse pass complete' );
            thischan.adc.Map.Data.Adc(blocksize:-1:1)=filter(Hd, thischan.adc(blocksize:-1:1));
            dataminimum=min([thischan.adc.Map.Data.Adc(blocksize:-1:1)' dataminimum]);
            datamaximum=max([thischan.adc.Map.Data.Adc(blocksize:-1:1)' datamaximum]);
            reset(Hd);
            set(Hd,'persistentmemory', false);
            return
        end
        %------------------------------------------------------------------
        
        
        %------------------------------------------------------------------
        function LocalFIR()
        %------------------------------------------------------------------
            dataminimum=Inf;
            datamaximum=-Inf;
            len=length(thischan.adc.Map.Data.Adc);
            nfact=impzlength(Hd);
            delay=LocalGetDelay(Hd);
            
            % End-effects
            pre=2*thischan.adc.Map.Data.Adc(1)-thischan.adc(nfact+1:-1:2);
            post=2*thischan.adc.Map.Data.Adc(len)-thischan.adc(len-1:-1:len-nfact);
            
            % Use the filter states to process multiple blocks
            set(Hd,'persistentmemory', true);
            reset(Hd);
            
            % Start filter
            scProgressBar(0, progbar, 'Filtering data' );
            % This seeds Hd
            filter(Hd, pre); 
            filter(Hd, thischan.adc(1:delay));
            
            % Now filter the real data
            start=delay+1;
            stop=delay+blocksize;
            idx=1;
            nblocks=fix(len/blocksize);
            iter=1;
            tic;
            while stop<len
                % Note the data written to disc is shifted to correct for
                % the group delay
                temp=filter(Hd, thischan.adc(start:stop));
                thischan.adc.Map.Data.Adc(idx:idx+blocksize-1)=temp;
                tm=toc;
                str=sprintf('<HTML><CENTRE>Filtering block %d of %d<P>%d seconds remaining.</P></CENTRE></HTML>',...
                    iter, nblocks, int16(nblocks*(tm/iter))-tm);
                scProgressBar(iter/nblocks, progbar,str );
                dataminimum=min([temp; dataminimum]);
                datamaximum=max([temp; datamaximum]);
                start=start+blocksize;
                stop=stop+blocksize;
                idx=idx+blocksize;
                iter=iter+1;
            end
            % Final data
            temp=filter(Hd, [thischan.adc.Map.Data.Adc(start:end); post]);
            thischan.adc.Map.Data.Adc(idx:end)=temp(1:len-idx+1);
            dataminimum=min([temp; dataminimum]);
            datamaximum=max([temp; datamaximum]);
            reset(Hd);
            set(Hd,'persistentmemory', false);
            return
        end
    end
%----------------------------------------------------------------------


%----------------------------------------------------------------------
    function [dataminimum, datamaximum]=LocalFilterMultiColumn(progbar)
        %------------------------------------------------------------------
        thischan=channels{target};
dataminimum=Inf;
datamaximum=-Inf;
nfact=impzlength(Hd);
for k=1:cols
    if rem(k,20)==0
        scProgressBar(k/cols, progbar,...
            sprintf('<HTML><CENTER>Filtering data<P>Epoch %d of %d</P></CENTER></HTML>', k, cols));
    end
    if isfir(Hd)
        temp=LocalFilter(Hd, thischan.adc(1:thischan.hdr.adc.Npoints(k), k), nfact);
    else
        temp=filtfilthd(Hd, thischan.adc(1:thischan.hdr.adc.Npoints(k), k), nfact);
    end
    thischan.adc.Map.Data.Adc(1:thischan.hdr.adc.Npoints(k), k)=temp;
    dataminimum=min([temp' dataminimum]);
    datamaximum=max([temp' datamaximum]);
end
channels{target}=thischan;
return
end
%----------------------------------------------------------------------


% End of main function
end

%----------------------------------------------------------------------
function x=LocalFilter(Hd, x,  nfact)
%----------------------------------------------------------------------
% Local filter function for FIR single-pass filtering
% FFT-based filtering applied where advantageous for speed

if ~isfir(Hd)
    error('FIR filter required');
end

if nargin<3
    nfact=impzlength(Hd);
end

len=length(x);
npad=min(len-1, nfact);
% Reflect and reverse at ends
pre=2*x(1)-x(npad+1:-1:2);
post=2*x(len)-x(len-1:-1:len-npad);

% Check filter
delay=LocalGetDelay(Hd);

x=vertcat(pre,x,post);

% Make sure Hd is reset
reset(Hd);
set(Hd,'persistentmemory', false);

b=Hd.Numerator;
if log2(length(x))<numel(b)
    % Use FFT-based filtering where advantageous
    x=fftfilt(b, x);
else
    x=filter(Hd, x);
end

% Retrieve data adjusting for delay
x=x(nfact+delay+1:end+delay-npad);

return
end
%----------------------------------------------------------------------

function delay=LocalGetDelay(Hd)
if islinphase(Hd)
    % Delay correction - note +/- 0.5 sample jitter
    a=groupdelay(Hd);
    delay=round(a.Data(1));
else
    errordialog('Filter is not linear phase as expected', 'wvFilter/LocalGetDelay');
    % Force exit
    error('Filter is not linear phase');
end
return
end
