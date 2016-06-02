function P=wvWelchSpectra(fhandle, varargin)
% wvWelchSpectra. Workhorse function called by spectral analysis routines.
%
% wvWelchSpectra is intended to be called from wvPowerSpectra but can be
% invoked directly.
%
% Examples:
% P=wvWelchSpectra(fhandle, PropName1, PropValue1.....)
% P=wvWelchSpectra(channels, PropName1, PropValue1.....)
% 
%
% The output P is a N x N cell matrix where N is the number of channels.The
% data are contained in the diagonal of the matrix. 
%
% wvWelchSpectra returns the Power Spectral Density. 
% 
% For continuous waveform channels, the Welch periodogram is calculated for
% sections of data of length WindowLength seconds. The length of data used 
% will be truncated, if necessary, to a multiple of WindowLength.
%
% For episodic and frame-based data, only valid data epochs will be used
% within the timerange where
%           channels{x}.tim(:,1) < t <= channels{x}.tim(:,2)  
%                   if tim has only 2 columns or
%           channels{x}.tim(:,2) < t <= channels{x}.tim(:,3)
%                   if it has 3 columns
% i.e. only post-trigger data is used if the trigger time is known.
% Note that, if WindowLength exceeds the length of the available data,
% the WindowLength for all sections will be reduced to that of
% the shortest (post-trigger) period.
% 
% Valid field/value pairs are:
%     'channellist'           the numbers for the channels to analyze
%                                   (scalar or vector list)
%     'start'                 the start time for data processing
%                                (scalar, in seconds)
%     'stop'                  the stop time for data processing
%                                (scalar, in seconds)'
%     'windowtype'            the window to apply to the data
%                                 (string: e.g. 'hamming')
%     'windowlength'          the length of the window and also of the data
%                               sections in seconds (scalar)
%     'overlap'               the overlap to be used between data sections
%                               as a percentage (scalar)
%     'overlapmode'           determines whether overalpping will be
%                               applied.OverlapMode may be set to 'on',
%                               'off' or 'auto':
%                           'auto': This is the default. Continuous waveform
%                                   data will be processed in overlapping
%                                   sections. Episodic and frame-based data will
%                                   not be overlapped.
%                           'off':  No overlapping will be performed 
%                                   regardless of the setting for Overlap.
%                           'on':   the overlap will be applied to all
%                                   channels including episodic and 
%                                   frame-based samples. It will rarely
%                                   make sense to do this.
%     'detrend'                Logical flag. If true, the linear trend will
%                              each data section be removed from each data
%                              section before taking its FFT
%     'spectrummode'           The type of spectrum to return as a string:
%                                   'normalized power spectral density'
%                                   'power spectral density'
%                                   'linear power spectral density'
%                                   'power spectrum'
%                                   'linear power spectrum'        
%     'spectrogramflag'       Not really a flag but a string. If set to
%                               'contour' or 'surface' the spectrum will be
%                               returned for each data section and plotted
%                               in 3D as a contour or surface. Otherwise,
%                               data will be averaged to produce a 2D
%                               result.
%     'decimation'          decimation factor (zero by default). If non-zero,
%                           the data to be analyzed will be anti-alias
%                           filtered and downsampled by the factor in
%                           decimate. This can be useful with oversampled 
%                           data when drawing 3D plots as graphics rendering
%                           may otherwise to too slow  
%
% Toolboxes Required: For decimation only, dfilt objects must be available
% e.g. via SP Toolbox
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------

[fhandle, channels]=scParam(fhandle);

OverlapMode='auto';
SpectrogramFlag='off';
Decimation=0;

for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'channellist'
            ChannelList=varargin{i+1};
        case 'start'
            Start=varargin{i+1};
        case 'stop'
            Stop=varargin{i+1};
        case 'windowtype'
            WindowType=varargin{i+1};
        case 'windowlength'
            WindowLength=varargin{i+1};
        case 'overlap'
            Overlap=varargin{i+1};
        case 'overlapmode'
            OverlapMode=varargin{i+1};
        case 'detrend'
            DetrendFlag=varargin{i+1};
        case 'spectrogramflag'
            SpectrogramFlag=varargin{i+1};
        case 'spectrummode'
        case 'decimation'
            Decimation=varargin{i+1};
        otherwise
            error('%s unknown parameter (%s)', mfilename, varargin{i});
    end
end

% Convert seconds to base units
Start=Start/channels{ChannelList(1)}.tim.Units; %#ok<NASGU>
Stop=min(Stop, scMaxTime(channels(unique(ChannelList))));
Stop=Stop/channels{ChannelList(1)}.tim.Units; %#ok<NASGU>
WindowLength=WindowLength/channels{ChannelList(1)}.tim.Units; %#ok<NASGU>

% Pre-allocate cell
P=cell(length(ChannelList));
win=[];

progbar=scProgressBar(0, 'Gathering data...', 'Name', 'Welch Periodogram');

for idx1=1:length(ChannelList)
    
    chan=ChannelList(idx1);
    
    if isMultiplexed(channels{chan})
        % Multiplexed - extract current subchannel to temp channel
        list=scGetChannelsByType(fhandle, 'empty');
        channels=wvCopyToTempChannel(channels, chan, list(1), true);
        chan=list(1);
    end
    
    if Decimation>1
        % If requested decimate the data.
        channels=wvDecimate(channels, chan, chan, false, Decimation);
    end
    

    nfft=round(WindowLength/getSampleInterval(channels{chan})*channels{chan}.tim.Units);
    
    if strcmp(channels{chan}.hdr.channeltype, 'Continuous Waveform')
        %------------------------------------------------------------------
        % Continuous Waveform
        %------------------------------------------------------------------
        if ~strcmp(OverlapMode, 'off')
            noverlap=round(Overlap*nfft/100);
        else
            noverlap=0;
        end
        indices=GetIndices(channels{chan}, Start, Stop, nfft, noverlap);
        data=channels{chan}.adc;
    else
        %------------------------------------------------------------------
        % Episodic or frame-based data
        %------------------------------------------------------------------
        indices=GetIndices(channels{chan}, Start, Stop, nfft, 0);
        % Limit nfft to length of shortest epoch
        nfft=min(nfft, (indices(1,2)-indices(1,1))+1);       
        if strcmp(OverlapMode, 'on') && Overlap>0
            % Form a vector from the required data to allow overlap of
            % sections. Recalculate indices based on new vector
            noverlap=round(Overlap*nfft/100);
            % Convert to vector
            % For lengthy channels, this may take some time and/or
            % result in a memory error
            data=scEpochToVector(channels{chan}, indices);
            % Recalculate the indices
            indices=GetIndices(data, Start, Stop, nfft, noverlap);
        else
            % No overlap so use existing indices
            noverlap=0;
            data=channels{chan}.adc;
        end    
    end
    
    if length(win)~=nfft
        % If nfft has changed, calculate window and prepare for detrend
        win=WindowType(nfft);
        % Prepare for detrend below
        a=[((1:nfft)/nfft)' ones(nfft,1)];
    end

    %----------------------------------------------------------------------
    % Build the periodogram
    % 
    % Equivalent to the following for continuous waveforms
%     figure();
%     channels{chan}.adc.Func=@detrend;
%     [Pxx, F]=pwelch(channels{chan}.adc, hamming(nfft), noverlap,...
%         nfft, getSampleRate(channels{chan}));
%     channels{chan}.adc.Func=[];
%     plot(F, Pxx);assignin('base','Pxx',Pxx); assignin('base','F',F);
    %----------------------------------------------------------------------
    
    % Pre-allocate output
    nsect=size(indices,1);
    %P{idx1, idx1}.tdata=zeros(nfft,1);
    if SpectrogramFlag
        P{idx1, idx1}.rdata=zeros(nsect, nfft);
    else
        P{idx1, idx1}.rdata=zeros(1,nfft);
    end
    % Loop over sections
    for j=1:nsect
        scProgressBar(j/nsect, progbar, sprintf('Channel %d...',chan));
        arrayindex=(indices(j,1):indices(j,2))';
        x=data(arrayindex);
        if DetrendFlag
            x=win.*(x-a*(a\x));
        else
            x=win.*x;
        end
        Xx=fft(x);
        switch SpectrogramFlag
            case {'surface' 'contour' 'image'}
                P{idx1, idx1}.rdata(j,:)=Xx.*conj(Xx);
            otherwise
                P{idx1, idx1}.rdata=P{idx1, idx1}.rdata+(Xx.*conj(Xx))';
        end
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    
    % Scale output to PSD
    Fs=getSampleRate(channels{chan});
    SampleInterval=getSampleInterval(channels{chan});
    switch SpectrogramFlag
        case {'contour' 'surface' 'image'}
            P{idx1,idx1}.odata=(0:nsect-1)'*(((nfft-1)*SampleInterval)-((noverlap-1)*SampleInterval));
            P{idx1,idx1}.tdata=(0:nfft-1)*Fs/nfft;
            P{idx1,idx1}.rdata=P{idx1,idx1}.rdata/(Fs*win'*win);
        otherwise
            P{idx1,idx1}.tdata=(0:nfft-1)*Fs/nfft;
            P{idx1,idx1}.rdata=P{idx1,idx1}.rdata/(Fs*nsect*win'*win);
            P{idx1,idx1}.odata=[];
    end

        
    NBW=sum(win'*win)/sum(win)^2;
    P{idx1, idx1}.details.args=struct(varargin{:});
    P{idx1, idx1}.details.codesource=mfilename();
    P{idx1, idx1}.details.channel=chan;
    P{idx1, idx1}.details.enbw=Fs*NBW;
    P{idx1, idx1}.details.Fs=Fs;
    P{idx1, idx1}.details.nenbw=nfft*NBW;
    P{idx1, idx1}.details.nfft=nfft;
    P{idx1, idx1}.details.noverlap=noverlap;
    P{idx1, idx1}.details.nsect=nsect;
    if noverlap==0
        P{idx1, idx1}.details.Overlap=0;
    end
    
    % Clear the local copies to release virtual memory
    data=[];
    channels{chan}.adc=[];
end
delete(progbar);
return
end


function [indices]=GetIndices(channel, start, stop, nfft, noverlap)
if iscell(channel) && numel(channel)>1
    error('GetIndices: single channel required on input');
end

if iscell(channel)
    channel=channel{1};
end

if isa(channel, 'double');
    indices=[1 length(channel)];
else
    indices=convTime2ValidIndex(channel, start, stop);
end
        
if isnumeric(channel) || size(indices,1)==1
    % Continuous waveform or vector
    upperbound=fix(indices(2)/nfft)*nfft-noverlap;
    idx1=indices(1):nfft-noverlap:upperbound-nfft+1;
    idx2=idx1+nfft-1;
    indices=[idx1' idx2'];
else
    % Episodic or frame-based data
    if size(channel.tim, 2)==3
        % Align on trigger if there is one
        [r c]=ind2sub(size(channel.adc), indices(:,1));
        pretime=channel.tim(c,2)-channel.tim(c,1);
        npre=round(pretime/prod(channel.hdr.adc.SampleInterval));
        indices(c,1)=indices(c,1)+npre;
    end
    % Find minimum section length
    MinLength=min(indices(:,2)-indices(:,1)+1);
    % Reduce nfft if not enough data
    nfft=min(nfft, MinLength);
    % Calculate the indices
    indices(:,2)=indices(:,1)+nfft-1;
end

return
end


