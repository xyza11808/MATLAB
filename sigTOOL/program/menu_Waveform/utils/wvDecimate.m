function varargout=wvDecimate(fhandle, source, target, IntFlag, r)
% wvDecimate filters and downsamples sigTOOL waveforms channels
% 
% Examples:
% wvDecimate(fhandle, source, target, IntFlag, r)
% wvDecimate(channels, source, target, IntFlag, r)
% 
% where
%         fhandle     is a sigTOOL data figure handle
%                         the channel data in the specified figure will be
%                         updated
%         channels    is a cell array of scchannel objects
%         source      is the source channel number
%         target      is the target channel to receive the result
%                         (source and target may be equal)
%         IntFlag     is a true false/flag. 
%                     If true the the downsampled data will be scaled and
%                     cast to int16 on disc.
%                     If false, data will be returned in double precision
%         r           is the downsampling factor,
%                         e.g. 10 to reduce the sample rate by 10
%
% out=wvDecimate(....)
%       returns the sigTOOL channel cell array
%                         
% wvDecimate applies a Chebyshev Type 1 lowpass filter to prevent aliaing
% before downsampling. This has a cut-off frequency of 0.4x the new sample
% rate
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------                     

% NB Note that wvFiltFilt below does much of the work, epoch and subchannel
% selection, channelchangestate flag setting etc as well as converting to
% integer where requested.

% Prepare lowpass filter. Use odd order filters to avoid shifts in mean
% See TMW Technical Solution 1-2YWEQD
Hd=LocalFilter(r, 13);
if isempty(Hd)
    error('wvDecimate: Can not design suitable filter');
end

% Anti-alias filter
if ishandle(fhandle)
    % Figure handle on input
    channels=wvFilter(fhandle, source, target, IntFlag, Hd);
else
    % sigTOOL channel cell array on input
    channels=wvFilter(fhandle, source, target, IntFlag, Hd);
    fhandle=[];
end

% Decimate
cols=size(channels{target}.adc, 2);
progbar=scProgressBar(0, '', 'Name', 'Decimate');
switch cols
    case 0
        return
    case 1
        % Continuous waveform
        LocalDecimateSingleColumn();
    otherwise
        % Framed or episodic waveform
        LocalDecimateMultiColumn();
end

% Tidy up
channels{target}.adc.Map.Writable=false;
close(progbar);

% If figure handle specified on input, update the application data area
if ~isempty(fhandle)
    setappdata(fhandle, 'channels', channels);
end

if nargout
    varargout{1}=channels;
else
    clear('channels');
end

return


%------------------------------------------------------------------
    function LocalDecimateSingleColumn()
        %------------------------------------------------------------------
        blocksize=r*(2^24)/8;
        np=channels{target}.hdr.adc.Npoints;
        nsect=fix(np/blocksize);
        endblocksize=rem(np, blocksize);
        if nsect<=1
            % Decimate in single block
            scProgressBar(0.5, progbar, 'Downsampling...');
            idx=1:r:channels{target}.hdr.adc.Npoints;
            channels{target}.adc.Map.Data.Adc(1:length(idx))=...
                channels{target}.adc.Map.Data.Adc(idx);
            channels{target}.hdr.adc.Npoints=length(idx);
        else
            % Decimate in multiple blocks
            tic;
            for i=0:nsect-1
                idx=(i*blocksize)+1:r:(i*blocksize)+blocksize;
                idxt=i*blocksize/r+1:i*blocksize/r+length(idx);
                channels{target}.adc.Map.Data.Adc(idxt)=...
                    channels{target}.adc.Map.Data.Adc(idx);
                tm=toc;
                str=sprintf('<HTML><CENTER>Downsampling<P>%d seconds remaining</P></CENTER></HTML>',...
                    int16(nsect*tm/max(i, 1)-tm));
                scProgressBar(i/nsect, progbar, str);
            end
            scProgressBar(1, progbar, 'Downsampling complete');
            if endblocksize>0
                i=nsect;
                idx=(i*blocksize)+1:r:(i*blocksize)+endblocksize;
                idxt=i*blocksize/r+1:i*blocksize/r+length(idx);
                channels{target}.adc.Map.Data.Adc(idxt)=...
                    channels{target}.adc.Map.Data.Adc(idx);
            end
            channels{target}.hdr.adc.Npoints=(nsect*blocksize)+endblocksize;
        end

        channels{target}.hdr.adc.SampleInterval(1)=...
            channels{target}.hdr.adc.SampleInterval(1)*r;
        ts=channels{target}.tim();
        ts(1,end)=ts(1,1)+(channels{target}.hdr.adc.Npoints-1)*...
            (getSampleInterval(channels{target})/channels{target}.tim.Units);
        channels{target}.tim=tstamp(ts,...
            1,...
            0,...
            [],...
            channels{target}.tim.Units,...
            false);
        return
    end
%------------------------------------------------------------------


%------------------------------------------------------------------
    function LocalDecimateMultiColumn()
        %------------------------------------------------------------------

        if size(channels{target}.tim, 2)==3
            mode=1;
        else
            mode=0;
        end

        if ~isa(channels{target}.adc.Map, 'memmapfile')
            % Receive data into temp buffer for speed (avoids subsasgn
            % calls in loop below)
            units=channels{target}.adc.Units;
            labels=channels{target}.adc.Labels;
            temp=channels{target}.adc.Map.Data.Adc;
            bufflag=true;
        else
            % Work on memmapfile
            bufflag=false;
        end
        

        for k=1:cols
            if rem(k,20)==0
                scProgressBar(k/cols, progbar, sprintf('Downsampling Epoch %d of %d', k, cols));
            end
            
            if mode
                % Episodic data. Make sure we keep the data sample that is
                % coincident with the trigger
                trg=convTime2ValidIndex(channels{target}, channels{target}.tim(k,2));
                [row col]=ind2sub(size(channels{target}.adc), trg);
                if col~=k
                    % This should never execute
                    error('wvDecimate: Unexpected inequality (k vs col) - this is a bug');
                end
                idx=row:-r:1;
                idx=[idx(end:-1:1) row+r:r:channels{target}.hdr.adc.Npoints(k)];
            else
                % No trigger available
                idx=1:r:channels{target}.hdr.adc.Npoints(k);
            end

            % Downsample and update channel header
            channels{target}.hdr.adc.Npoints(k)=length(idx);
            if bufflag
                temp(1:length(idx),k)=temp(idx,k);
            else
                channels{target}.adc.Map.Data.Adc(1:length(idx),k)=...
                    channels{target}.adc.Map.Data.Adc(idx,k);
            end
        end
        
        channels{target}.hdr.adc.SampleInterval(1)=...
            channels{target}.hdr.adc.SampleInterval(1)*r;
        ts=channels{target}.tim();
        ts(:, end)=ts(:, 1)+...
            (channels{target}.hdr.adc.Npoints(:)-1)*...
            (getSampleInterval(channels{target})/channels{target}.tim.Units);
        channels{target}.tim=tstamp(ts,...
            1,...
            0,...
            [],...
            channels{target}.tim.Units,...
            false);
        
        if bufflag
            % Place temp buffer in adc as adcarray object
            channels{target}.adc=adcarray(temp,...
                1,...
                0,...
                '',...
                units,...
                labels,...
                false);
        end
        return
    end
%------------------------------------------------------------------

end

% ----- END OF MAIN + NESTED FUNCTIONS

%-------------------------------------------------------------------------
function Hd=LocalFilter(r, N)
%-------------------------------------------------------------------------
% LocalFilter returns a Chebshev Type I lowpass filter with a cutoff at
% 0.4Fs/r where Fs is the target sampling rate.
% N is the filter order. If a stable filter of 0dB gain can not be designed
% with this value of N, N will be reduced. If N falls below 2, Hd will
% be returned empty.
% The filter designed here is essentially the same as that used in the
% MATLAB decimate function except that a dfilt object is returned.

if ~rem(N,2)
    error('You should use an odd order filter');
end

if N<3
    Hd=[];
    return
end
Fpass = 0.8/r;  % Passband Frequency
Apass = 0.05;  % Passband Ripple (dB)
% Design filter
[z,p,k]=cheby1(N, Apass, Fpass);
[sos_var,g]=zp2sos(z, p, k);
Hd=dfilt.df2sos(sos_var, g);
% Check we have a stable filter with 0dB gain in the passband
% (within Apass dB);
[m, f]=freqz(Hd);
idx=find(f<0.8/r,1);
g=20*log10(abs(m(idx)));
if g<-Apass || g>Apass || ~isstable(Hd)
    % If not, try lowering the order, but keep odd order
    Hd=LocalFilter(r, N-2);
end
return
end
