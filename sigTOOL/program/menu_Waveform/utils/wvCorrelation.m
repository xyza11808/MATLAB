function varargout=wvCorrelation(fhandle, varargin)
% wvCorrelation calculate correlations between waveforms
%
% Example:
% wvCorrelation(fhandle, PropName1, PropValue1....)
% wvCorrelation(channels, PropName1, PropValue1....)
%       calculates the correlation(s) and plots them
% out=wvCorrelation(fhandle, PropName1, PropValue1....)
% out=wvCorrelation(channels, PropName1, PropValue1....)
%       returns a sigTOOLResultData object
%
% where fhandle is a sigTOOL data view handle and channels is a sigTOOL
% channels cell array
% 
% Valid property name/values are:
%     Refs          The list of reference channels numbers
%     Sources       The list of source channel numbers. If empty, the
%                   autocorrelations of the channels listed in refs
%                   will be calculated
%     Start         The start time for the calculations (seconds)
%     Stop          The end time for the calculations (seconds)
%     MaximumLag    The largest postive lag for which correlation should be
%                   returned. Correlations will be returned for all lags
%                   between -MaxLag and MaxLag
%     RemoveDC      A logical flag. If true, the mean of the data will be
%                   subtracted before calculating the correlations.
%     ScaleMode     Controls scaling of the result:
%                       None        No scaling - the covariance is returned
%                       Biased      Divided by N
%                       Unbiased    Divided by N-(abs)lag
%                       Coeff       Normalized to the range -1 to 1
%                   N above represents the size of the data block.
%                   This is maximally MaxBlockSize at described below.
%     MaxBlockSize  An FFT based algorithm is used to calculate the
%                   correlations. MaxBlockSize is the maximum length of
%                   data used in each FFT. This defaults to 2^22. If the
%                   length of data exceeds MaxBlockSize, multiple FFTs will
%                   be done and the returned correlation will be the
%                   simple average of these. The used block size will be
%                   length(data)/M where M is 2, 4, 8 etc chosen to yield a
%                   size less than MaxBlockize. Data points beyond M*block
%                   size will be discarded.
%
% Correlations will be calculated only those channel pairs where the sample
% rate is equal and they are sampled synchronously. Multiplexed channels
% are not supported.
%
% Note that when ScaleMode is 'none', 'Biased' or 'Coeff' the result is
% biased: the correlations will fall towards zero as the lag approaches
% the length of the data (or of the data block).
%
% Data blocks will be zero padded to avoid wraparound in the FFT. 
% Additional padding is added to produce an integer power of 2 input
% size for the FFT.
%
% Note that, when multiple data blocks are used, blocks are treated
% independently and the correlations are simply averaged. Proper
% overlap-add is not used so no account is taken of the effects between
% data points at the end of block n and those at the beginning of block n+1.
% These effects should be small for block sizes>>number of lags.
%
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

[fhandle, channels]=scParam(fhandle);

MaxBlockSize=2^22;

for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'refs'
            refs=varargin{i+1};
        case 'sources'
            sources=varargin{i+1};
        case 'start'
            Start=varargin{i+1};
        case 'stop'
            Stop=varargin{i+1};
        case 'maximumlag'
            MaxLag=varargin{i+1};
        case 'removedc'
            RemoveDC=varargin{i+1};
        case 'scalemode'
            ScaleMode=varargin{i+1};
        case 'maxblocksize'
            MaxBlockSize=varargin{i+1};
        otherwise
            %error('%s unknown parameter (%s)', mfilename, varargin{i});
    end
end

% Convert seconds to base units
Start=Start*(1/channels{refs(1)}.tim.Units);
Stop=min(Stop, scMaxTime(channels(unique([refs sources]))));
Stop=Stop*(1/channels{refs(1)}.tim.Units);
MaxLag=MaxLag*(1/channels{refs(1)}.tim.Units);

progbar=scProgressBar(0, 'Gathering indices...', 'Name', 'Waveform Correlation');

if isempty(sources)
    % Autocorrelation only
    P=cell(length(refs), length(refs));
    sources=NaN;
else
    P=cell(length(refs), length(sources));
end

% NB. If nsect>1, the loop below simply calculates the average correlation
% across the sections. The zero padding to avoid wraparound is divided
% between both ends of data so that full overlap-add procedures could be
% included later - but if MaxBlockSize>>nlags this will hardly make any
% difference.

for m=1:length(refs)
    % For each reference channel
    thisref=refs(m);
    interval=getSampleInterval(channels{thisref});
    Fs=getSampleRate(channels{thisref});
    nlags=round(MaxLag*channels{thisref}.tim.Units/interval);
    
    % If there are more than MaxBlockSize data points, break the channel into
    % blocks and return the average correlation across those blocks
    nsect=1;
    [idx1, idx2]=findVectorIndices(channels{thisref}, Start, Stop);
    np=idx2-idx1;
    npoints=np;
    while npoints>MaxBlockSize
        nsect=nsect*2;
        npoints=floor(np/nsect);
    end
    if rem(npoints, 2)==1
        % Make sure npoints is even - needed to get power of 2 length below
        npoints=npoints-1;
    end
    % Create pad vector - right size to give power of 2 FFT later
    padlen=(2^nextpow2(npoints+2*nlags)-npoints)/2;
    pad=zeros(padlen,1);

    for n=1:length(sources)
        % For each source channel
        if length(sources)==1 && isnan(sources(1))
            thissource=thisref;
        else
            thissource=sources(n);
        end
        scx=0;
        scy=0;
        if ~isInSynch(channels{thisref}, channels{thissource}) ||...
                isMultiplexed(channels{thisref}, channels{thissource})
            continue
        end

        ac=zeros(npoints+2*length(pad),1);
        for k=0:nsect-1
            scProgressBar((k+1)/nsect, progbar,...
                sprintf('<HTML><CENTER>Reference %d<P> Processing channel %d</P></CENTER><HTML>',...
                thisref,thissource));
            id1=idx1+(k*npoints);
            id2=id1+npoints-1;
            data=channels{thisref}.adc(id1:id2);
            if RemoveDC
                data=data-mean(data);
            end
            Xx=[pad;data;pad];
            Xxp=fft(Xx);
            scx=scx+sum(data.^2);

            if thisref==thissource
                ac=ac+(Xxp.*conj(Xxp));
            else
                data=channels{thissource}.adc(id1:id2);
                if RemoveDC
                    data=data-mean(data);
                end
                Yy=[pad;data;pad];
                Yyp=fft(Yy);
                ac=ac+(Xxp.*conj(Yyp));
                scy=scy+sum(data.^2);
            end
        end
        % Take inverse FFT and recenter data
        ac=ifft(ac)/nsect;
        ac=fftshift(ac);
        % Get correlation at required lags
        corr=ac(floor(length(ac)/2)-nlags+1:floor(length(ac)/2)+nlags+1);
        % Lags (ms)
        lags=-nlags:nlags;
        % Timebase
        P{m,n}.tdata=lags*interval*1e3;

        switch lower(ScaleMode)
            case {'coeff'}
               if scy>0
                    scale=sqrt(scx*scy)/nsect;
                else
                    scale=scx/nsect;
                end
                corr=corr/scale;
            case 'biased'
                corr=corr/npoints;
            case 'unbiased'
                bias=npoints-abs(lags');
                corr=corr./bias;
            case 'none'
                corr=corr*npoints;
        end


        P{m,n}.rdata=corr';

        P{m,n}.tlabel='Lag (ms)';
        P{m,n}.rlabel='Correlation';

        P{m,n}.details.args=struct(varargin{:});
        P{m,n}.details.mode=ScaleMode;
        P{m,n}.details.codesource=mfilename();
        P{m,n}.details.reference=thisref;
        P{m,n}.details.source=thissource;
        P{m,n}.details.nfft=length(ac);
        P{m,n}.details.Fs=Fs;
        P{m,n}.details.npoints=npoints;
        P{m,n}.details.nsect=nsect;
    end
end
if length(sources)==1 && isnan(sources(1))
    % Autocorrs only
    sources=refs;
end
Q=scPrepareResult(P, {refs sources}, channels);
out.datasource=fhandle;
out.title='Waveform Correlation';
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






