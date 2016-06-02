function varargout=wvFFTFilt(fhandle, source, target, IntFlag, Hd)
% wvFFTFilt provides FFT-based filtering of sigTOOL waveform data
%
% THIS FUNCTION IS OBSOLETE. USE wvFilter INSTEAD


% wvFFTFilt is used only for FIR filters. wvFFTFilt uses a single pass
% through the data and corrects for the filter delay. The data are stored
% in RAM for filtering: if out-of-memory errors occur use wvFilter
% instead
%
% In general, there is little-or-no speed gain using wvFFTFilt over using
% the more general wvFilter function
%
% Examples:
% channels=wvFFTFilt(fhandle, source, target, Hd)
% channels=wvFFTFilt(channels, source, target, Hd)
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
%         Hd          is a dfilt filter object
%
% See also wvFilter
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 10/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------
%

warning('wvFFTFilt is obsolete. Call wvFilter instead');
varargout=wvFilter(fhandle, source, target, IntFlag, Hd);

%% if ~isfir(Hd)
%     % Make sure we have FIR filter
%     error('FIR filter required');
% end
% 
% 
% % Get channel data
% [fhandle, channels]=scParam(fhandle);
% 
% if isMultiplexed(channels{source})
%     error('Multiplexed channels not presently supported');
% end
% 
% % Set up a temporary channel - double precision, data in RAM
% channels{target}=channels{source};
% 
% % Filter properties
% b=Hd.Numerator;
% npad=impzlength(Hd);
% a=groupdelay(Hd);
% if max(a.Data)-min(a.Data)>eps(a.Data(1))
%     error('Filter has non-uniform group delay. Use double-pass algorithm instead');
% end
% % Delay correction - note +/- 0.5 sample jitter
% delay=round(a.Data(1));
% 
% progbar=scProgressBar(0, '', 'Name', 'FFT-based filter');
% nepochs=size(channels{target}.adc,2);
% if nepochs==1 || numel(unique(channels{target}.hdr.adc.Npoints))==1
%     % Continuous or Framed waveform
%     % Pad beginning - reverse & reflect
%     scProgressBar(0.25, progbar, '<HTML><CENTER>Setting up<P>Please wait...</P></CENTER></HTML>');
%     pre=2*channels{target}.adc(1,:);
%     m=size(channels{target}.adc(npad+1:-1:2,:),1);
%     pre=repmat(pre,m,1)-channels{target}.adc(npad+1:-1:2,:);
%     % Pad end
%     post=2*channels{target}.adc(end,:);
%     m=size(channels{target}.adc(end-1:-1:end-npad,:),1);
%     post=repmat(post,m,1)-channels{target}.adc(end-1:-1:end-npad,:);
%     y=vertcat(pre,...
%         channels{target}.adc(),...
%         post);
%     % Filter
%     scProgressBar(0.5, progbar, '<HTML><CENTER>Filtering data<P>Please wait...</P></CENTER></HTML>');
%     y=fftfilt(b, y);
%     % Get relevant elements correcting for delay
%     scProgressBar(0.75, progbar, '<HTML><CENTER>Finishing<P>Please wait...</P></CENTER></HTML>');
%     y=y(npad+delay+1:end+delay-npad,:);
%     dataminimum=min(min(y));
%     datamaximum=max(max(y));
%     scProgressBar(1, progbar, '<HTML><CENTER>Done</CENTER></HTML>');
% else
%     % Unequal length epochs
%     y=channels{target}.adc();
%     dataminimum=Inf;
%     datamaximum=-Inf;
%     for k=1:nepochs
%         % Pad beginning - reverse & reflect
%         if rem(k-1,50)==0
%         scProgressBar(k/nepochs, progbar, '<HTML><CENTER>Filtering</CENTER></HTML>');
%         end
%         np=channels{target}.hdr.adc.Npoints(k);
%         pre=2*channels{target}.adc(1,k)-channels{target}.adc(npad+1:-1:2,k);
%         post=2*channels{target}.adc(np,k)-channels{target}.adc(np-1:-1:np-npad,k);
%         temp=vertcat(pre,...
%             y(1:np,k),...
%             post);
%         temp=fftfilt(b, temp);
%         y(1:np,k)=...
%             temp(npad+delay+1:end+delay-npad,:);
%         dataminimum=min(dataminimum, min(y(:,k)));
%         datamaximum=max(datamaximum, max(y(:,k)));
%     end
% end
% 
% % Create adcarray
% channels{target}.adc=adcarray(y,...
%     1,...
%     0,...
%     '',...
%     channels{target}.adc.Units,...
%     channels{target}.adc.Labels,...
%     false);
% 
% 
% 
% % Tidy up
% channels{target}.channelchangeflag.adc=true;
% channels{target}.channelchangeflag.hdr=true;
% channels{target}.channelchangeflag.tim=true;
% channels{target}.channelchangeflag.mrk=true;
% 
% % Replace double precision data with integer if requested - this also saves
% % the data to a temporary file
% filename=[];
% if IntFlag
%     [channels{target}, filename]=wvConvertToInteger(channels{target},...
%         dataminimum, datamaximum);
% end
% 
% 
% if ~isempty(fhandle)
%     setappdata(fhandle, 'channels', channels);
%     % Update temporary file list
%     if ~isempty(filename)
%         TempFileList=getappdata(fhandle, 'TempFileList');
%         if isempty(TempFileList)
%             TempFileList={filename};
%         else
%             TempFileList{end+1}=filename;
%         end
%         setappdata(fhandle, 'TempFileList', TempFileList);
%     end
% end
% 
% if nargout>0
%     varargout{1}=channels;
% end
% 
% delete(progbar);
% 
% return
% end%%
