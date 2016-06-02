function varargout=wvFiltFilt(fhandle, source, target, IntFlag, Hd)
% wvFiltFilt provides zero-phase filtering of sigTOOL waveform data
%
%
% THIS FUNCTION IS OBSOLETE. USE wvFilter INSTEAD

% Examples:
% channels=wvFiltFilt(fhandle, source, target, Hd)
% channels=wvFiltFilt(channels, source, target, Hd)
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
% See also filtfilt, filtfilthd, dfilt
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
%

warning('wvFiltFilt is obsolete. Call wvFilter instead');
varargout=wvFilter(fhandle, source, target, IntFlag, Hd);



%% 
% Revisions:
%   25.10.08    Correct hdr.adc.YLim when saving as floating point
% 
% filename=[];
% tempfile=[];
% 
% [fhandle, channels]=scParam(fhandle);
% 
% progbar=scProgressBar(0, '', 'Name', 'Filtering Data');
% try
%     % Filter in RAM if enough memory, returning result in double precision
%     [dataminimum, datamaximum]=FilterInRam();
%     channels{target}.hdr.adc.YLim=[dataminimum datamaximum];
%     channels{target}.hdr.adc.Scale=1;
%     channels{target}.hdr.adc.DC=0;
%     channels{target}.hdr.adc.Func='';
%     channels{target}.hdr.title=[channels{target}.hdr.title '**'];
% catch %#ok<CTCH>
%     lasterror('reset'); %#ok<LERR>
%     % Filter above failed. Set up temporary channel to accept filter output
%     [channels, tempfile]=wvCopyToTempChannel(channels, source, target);
%     % This block will call scRemap to free virtual memory if need be
%     try
%         cols=size(channels{target}.adc.Map.Data.Adc, 2);
%     catch %#ok<CTCH>
%         % Free up virtual memory is we need to
%         if isOOM() && ~isempty(fhandle)
%             setappdata(fhandle, 'channels', channels);
%             clear('channels');
%             scRemap(fhandle);
%             channels=getappdata(fhandle, 'channels');
%             cols=size(channels{target}.adc.Map.Data.Adc, 2);
%         else
%             rethrow(lasterror()); %#ok<LERR>
%         end
%     end
%     % Do the filtering
%     scProgressBar(0, progbar, '');
%     switch cols
%         case 0
%             % No data
%         case 1
%             % Single column
%             [dataminimum, datamaximum]=LocalFilterSingleColumn();
%         otherwise
%             % Multiple columns
%             [dataminimum, datamaximum]=LocalFilterMultiColumn();
%     end
%     % Addded 25.10.08
%     channels{target}.hdr.adc.YLim=[dataminimum datamaximum];
% end
% 
% % Tidy up
% channels{target}.channelchangeflag.adc=true;
% channels{target}.channelchangeflag.hdr=true;
% channels{target}.channelchangeflag.tim=true;
% channels{target}.channelchangeflag.mrk=true;
% 
% % Replace double precision map data with integer if requested
% if IntFlag
%     [channels{target}, filename]=wvConvertToInteger(channels{target},...
%         dataminimum, datamaximum);
%     % delete the double precision file
%     if (~isempty(tempfile))
%         delete(tempfile);
%     end
% end
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
% delete(progbar);
% 
% if nargout>0
%     varargout{1}=channels;
% end
% return
% %----------------------------END OF MAIN ROUTINE ----------------------------
% 
% % NESTED FUNCTIONS
% %----------------------------------------------------------------------
%     function [dataminimum, datamaximum]=FilterInRam()
%         %----------------------------------------------------------------------
%         % Try to filter in double precision. 
%         % Will fail if insufficient memory - throwing error that will be
%         % caught in calling function
%         thischan=channels{source};
%         epochs=getValidEpochNumbers(thischan, 1, 'end');
% 
%         if isMultiplexed(thischan)
%             temp=thischan.adc(thischan.CurrentSource:thischan.hdr.adc.Multiplex:end, epochs);
%             thischan.hdr.adc.Npoints=thischan.hdr.adc.Npoints/thischan.hdr.adc.Multiplex;
%         else
%             temp=thischan.adc(:, epochs);
%         end
% 
%         cols=size(temp, 2);
%         z=impzlength(Hd);
%         if cols==1
%             % Continuous waveform
%             scProgressBar(0.5, progbar, '<HTML><CENTER>Fast filtering in single pass<P>Please wait...</P></CENTER></HTML>');
%             temp=filtfilthd(Hd, temp, z);
%         else
%             % Multiple columns
%             for kk=1:cols
%                 if rem(kk,20)==0
%                     scProgressBar(kk/cols, progbar, sprintf('<HTML><CENTER>Fast filtering in RAM<P>Epoch %d of %d</P></CENTER></HTML>', kk, cols));
%                 end
%                 temp(1:thischan.hdr.adc.Npoints(epochs(kk)), kk)=...
%                     filtfilthd(Hd, temp(1:thischan.hdr.adc.Npoints(epochs(kk)), kk), z);
%             end
%         end
% 
%         thischan.adc=adcarray(temp,...
%             1,...
%             0,...
%             '',...
%             thischan.adc.Units,...
%             thischan.adc.Labels,...
%             false);
% 
%         if strcmp(thischan.EventFilter.Mode,'on')
%             thischan.EventFilter.Mode='off';
%             thischan.tim=tstamp(thischan.tim(epochs,:));
%             thischan.mrk=thischan.mrk(epochs,:);
%             thischan.hdr.adc.Npoints=thischan.hdr.adc.Npoints(epochs);
%         end
% 
%         dataminimum=min(temp(:));
%         datamaximum=max(temp(:));
%         channels{target}=thischan;
%         return
%     end
% %----------------------------------------------------------------------
% 
% 
% %----------------------------------------------------------------------
%     function [dataminimum, datamaximum]=LocalFilterSingleColumn()
%         %------------------------------------------------------------------
%         thischan=channels{target};
%         % Continuous waveform
%         blocksize=(2^24)/8;
%         np=thischan.hdr.adc.Npoints;
%         % Number of writes
%         nsect=fix(np/blocksize);
%         % Elements remaining for last write
%         r=rem(np, blocksize);
%         if nsect<=1
%             % Just one block
%             scProgressBar(0.5, progbar, 'Filtering as single block...');
%             thischan.adc.Map.Data.Adc=filtfilthd(Hd, thischan.adc());
%             dataminimum=min(thischan.adc.Map.Data.Adc(:));
%             datamaximum=max(thischan.adc.Map.Data.Adc(:));
%         else
%             % Multiple blocks
%             len=length(thischan.adc.Map.Data.Adc);
%             nfact=impzlength(Hd);
%             nfact=min(len-1, nfact);
%             pre=2*thischan.adc.Map.Data.Adc(1)-thischan.adc(nfact+1:-1:2);
%             post=2*thischan.adc.Map.Data.Adc(len)-thischan.adc(len-1:-1:len-nfact);
%             set(Hd,'persistentmemory', true);
%             reset(Hd);
%             % FORWARD FILTER PASS
%             % Start
%             scProgressBar(0, progbar, 'Filtering data. Forward pass...' );
%             pre=filter(Hd, pre); %#ok<NASGU> this seeds Hd
%             thischan.adc.Map.Data.Adc(1:blocksize)=filter(Hd, thischan.adc(1: blocksize));
%             tic;
%             % Middle blocks
%             for i=1:nsect-2
%                 temp=filter(Hd, thischan.adc((i*blocksize)+1:(i*blocksize)+blocksize));
%                 thischan.adc.Map.Data.Adc((i*blocksize)+1:(i*blocksize)+blocksize)=temp;
%                 tm=toc;
%                 str=sprintf('<HTML><CENTER>Filtering data: Forward pass<P> %d seconds remaining.</P></CENTER></HTML>',...
%                     int16(nsect*(tm/i))-tm);
%                 scProgressBar(i/nsect, progbar,str );
%             end
%             if r>0
%                 % Final section if needed
%                 thischan.adc.Map.Data.Adc(((nsect-1)*blocksize)+1: end)=...
%                     filter(Hd, thischan.adc(((nsect-1)*blocksize)+1: end));
%                 scProgressBar(1, progbar, 'Forward pass completed' );
%             end
%             post=filter(Hd, post);
%             % REVERSE PASS
%             reset(Hd);
%             dataminimum=Inf;
%             datamaximum=-Inf;
%             scProgressBar(0, progbar, 'Reverse pass...' );
%             filter(Hd, post(end:-1:1));
%             tic;
%             if r>0
%                 % Final section if needed
%                 thischan.adc.Map.Data.Adc(end:-1:((nsect-1)*blocksize)+1)=...
%                     filter(Hd, thischan.adc(end:-1:((nsect-1)*blocksize)+1));
%                 dataminimum=min([thischan.adc.Map.Data.Adc(end:-1:((nsect-1)*blocksize)+1)' dataminimum]);
%                 datamaximum=max([thischan.adc.Map.Data.Adc(end:-1:((nsect-1)*blocksize)+1)' datamaximum]);
%             end
%             for i=nsect-2:-1:1
%                 temp=thischan.adc((i*blocksize)+blocksize:-1:(i*blocksize)+1);
%                 temp=filter(Hd, temp);
%                 dataminimum=min([temp' dataminimum]);
%                 datamaximum=max([temp' datamaximum]);
%                 thischan.adc.Map.Data.Adc((i*blocksize)+blocksize:-1:(i*blocksize)+1)=temp;
%                 tm=toc;
%                 str=sprintf('<HTML><CENTER>Filtering data: Reverse pass<P> %d seconds remaining.</P></CENTER></HTML>',...
%                     int16(nsect*(tm/(nsect-i)))-tm);
%                 scProgressBar(1-(i/nsect), progbar, str);
%             end
%             scProgressBar(1, progbar, 'Reverse pass complete' );
%             thischan.adc.Map.Data.Adc(blocksize:-1:1)=filter(Hd, thischan.adc(blocksize:-1:1));
%             dataminimum=min([thischan.adc.Map.Data.Adc(blocksize:-1:1)' dataminimum]);
%             datamaximum=max([thischan.adc.Map.Data.Adc(blocksize:-1:1)' datamaximum]);
%         end
%         channels{target}=thischan;
%         return
%     end
% %----------------------------------------------------------------------
% 
% %----------------------------------------------------------------------
%     function [dataminimum, datamaximum]=LocalFilterMultiColumn()
%         %------------------------------------------------------------------
%         thischan=channels{target};
%         dataminimum=Inf;
%         datamaximum=-Inf;
%         nfact=impzlength(Hd);
%         for k=1:cols
%             if rem(k,20)==0
%                 scProgressBar(k/cols, progbar,...
%                     sprintf('<HTML><CENTER>Filtering data<P>Epoch %d of %d</P></CENTER></HTML>', k, cols));
%             end
%             temp=filtfilthd(Hd, thischan.adc(1:thischan.hdr.adc.Npoints(k), k), nfact);
%             thischan.adc.Map.Data.Adc(1:thischan.hdr.adc.Npoints(k), k)=temp;
%             dataminimum=min([temp' dataminimum]);
%             datamaximum=max([temp' datamaximum]);
%         end
%         channels{target}=thischan;
%         return
%     end
% %----------------------------------------------------------------------
% 
% 
% end
%%
