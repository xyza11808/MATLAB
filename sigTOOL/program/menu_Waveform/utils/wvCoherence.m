function varargout=wvCoherence(fhandle, varargin)
% wvCoherence: returns the coherence or SNR via a Welch periodogram
%
% Exampe:
% result=wvCoherence(fhandle, field1, value1, field2, value2....)
%     
% returns a sigTOOLResultData object. If no output is requested the result
% will be plotted.
%
% Only continuous waveform data can be analyzed with this function. The
% coherence or SNR will be returned for each channel pair that [1] have the
% same sampling frequency and [2] were sampled synchronously.
%
% Valid field/value pairs are:
%     'channellist'           a two-element cell array. Element 1 should 
%                               contain the numbers of the channels to use
%                               as reference channels, Element 2 those of
%                               the source channels.
%                                   (2-element cell array)
%     'start'                 the start time for data processing
%                                (scalar, in seconds)
%     'stop'                  the stop time for data processing
%                                (scalar, in seconds)'
%     'windowtype'            the window to apply to the data
%                                 (string: e.g. 'hamming')
%     'windowlength'          the length of the window and also of the data
%                               sections (scalar)
%     'overlap'               the overlap to be used between data sections
%                               as a percentage (scalar)
%     'mode'                  a string: 'coherence' to return magnitude-
%                             squared coherence, 'snr' for the signal-to-
%                             noise ratio.
%     'detrend'               Logical flag. If true, the linear trend will
%                             each data section be removed from each data
%                             section before taking its FFT
%
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

[fhandle, channels]=scParam(fhandle);

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
        case 'mode'
            CMode=varargin{i+1};
        case 'detrend'
            DetrendFlag=varargin{i+1};
        otherwise
            %error('%s unknown parameter (%s)', mfilename, varargin{i});
    end
end

refs=ChannelList{1};
sources=ChannelList{2};

% Convert from seconds to base units
Start=Start/channels{refs(1)}.tim.Units;
Stop=min(Stop, scMaxTime(channels(unique([refs sources]))));
Stop=Stop/channels{refs(1)}.tim.Units;
WindowLength=WindowLength/channels{refs(1)}.tim.Units;

% Pre-allocate cell
P=cell(length(refs), length(sources));

progbar=scProgressBar(0, 'Gathering indices...', 'Name', 'Waveform Coherence');

win=[];
for m=1:length(refs)
    thisref=refs(m);
    nfft=round(WindowLength/getSampleInterval(channels{thisref})*channels{thisref}.tim.Units);
    Fs=getSampleRate(channels{thisref});
    if length(win)~=nfft
        % If nfft has changed, calculate window and prepare for detrend
        win=WindowType(nfft);
        % Prepare for detrend below
        a=[((1:nfft)/nfft)' ones(nfft,1)];
    end
    t=(Start:WindowLength-(WindowLength*Overlap*0.01):Stop-WindowLength)';
    idx1=findValidFrameIndices(channels{thisref}, t, WindowLength, 0);
    Pxx=zeros(nfft,1);
    Pyy=zeros(nfft,1);
    Pxy=zeros(nfft,1);
    for n=1:length(sources)
        thissource=sources(n);
        if thisref==thissource ||...
                ~isInSynch(channels{thisref}, channels{thissource})  ||...
                isMultiplexed(channels{thisref}, channels{thissource})
            continue
        end
        idx2=findValidFrameIndices(channels{thissource}, t, WindowLength, 0);
        for k=1:size(idx1,1)
            if rem(round(k/size(idx1,1)),0.05)==0
            scProgressBar(k/size(idx1, 1), progbar,...
                sprintf('<HTML><CENTER>Reference %d<P> Processing channel %d</P></CENTER><HTML>',...
                thisref, thissource));
            end
            Xx=channels{thisref}.adc(idx1(k,1):idx1(k,2));
            Yy=channels{thissource}.adc(idx2(k,1):idx2(k,2));
            if DetrendFlag
                Xx=win.*(Xx-a*(a\Xx));
                Yy=win.*(Yy-a*(a\Yy));
            else
                Xx=win.*Xx;
                Yy=win.*Yy;
            end
            Xx=fft(Xx);
            Yy=fft(Yy);
            Xx2=Xx.*conj(Xx);
            Yy2=Yy.*conj(Yy);
            Xy2=Yy.*conj(Xx);
            Pxx=Pxx+Xx2;
            Pyy=Pyy+Yy2;
            Pxy=Pxy+Xy2;
        end
        
        
        % Need one-sided results only
        if rem(nfft,2)
            idx=1:(nfft+1)/2;
        else
            idx=1:nfft/2+1;
        end
        P{m,n}.rdata=((Pxy(idx).*conj(Pxy(idx)))./(Pxx(idx).*Pyy(idx)))';
        
        switch CMode
            case 'coherence'
                P{m,n}.rlabel='Coherence';
                out.title='Waveform Coherence';
            case 'snr';
                P{m,n}.rdata=P{m,n}.rdata./(1-P{m,n}.rdata);
                P{m,n}.rlabel='SNR';
                out.title='Signal to Noise Ratio';
        end
        P{m,n}.tdata=(0:length(idx)-1)/(WindowLength*channels{thisref}.tim.Units);
        P{m,n}.tlabel='Frequency (Hz)';


        NBW=sum(win'*win)/sum(win)^2;
        P{m,n}.details.args=struct(varargin{:});
        P{m,n}.details.codesource=mfilename();
        P{m,n}.details.reference=thisref;
        P{m,n}.details.source=thissource;
        P{m,n}.details.enbw=Fs*NBW;
        P{m,n}.details.Fs=Fs;
        P{m,n}.details.nenbw=nfft*NBW;
        P{m,n}.details.nfft=nfft;
        P{m,n}.details.nsect=size(idx1, 1);
        P{m,n}.details.Overlap=0;
    end
end
Q=scPrepareResult(P, ChannelList, channels);
out.datasource=fhandle;
out.data=Q;
out.plotstyle={@scFrames};
out.displaymode='Single Sweep';
out.viewstyle='2D';
out=sigTOOLResultData(out);
if nargout==0
    plot(out);
else
    varargout{1}=out;
end
delete(progbar);
return
end







