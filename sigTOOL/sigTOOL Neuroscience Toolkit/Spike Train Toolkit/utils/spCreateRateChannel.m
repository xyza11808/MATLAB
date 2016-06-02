function varargout=spCreateRateChannel(fhandle, varargin)
% spCreateRateChannel creates rate channels from event data
% 
% Example:
% channels=spCreateRateChannel(fhandle, InputName1, InputValue1,....)
% channels=spCreateRateChannel(channels, InputName1, InputValue1,....)
% 
% where   fhandle is a valid sigTOOL data view handle. 
%             If fhandle is provided on input the data view will be updated
%             with the new channels on completion
%         channels is a sigTOOL channel cell array
% Valid input options are:
%         Sources     A list of channnels to use as source for the
%                     input events (scalar or vector)
%         Targets     A list of channel numbers to use as the output targets 
%                     (scalar or vector)
%         Start       The start time for the conversion (scalar in seconds)
%         Stop        The stop time for the conversion (scalar in seconds)
%         BinWidth    The binwidth to use for counting spikes. This
%                       determines the effective sample rate in the target
%                       channel: a bin width of 1ms corresponds to a sample
%                       rate of 1kHz (scalar in seconds)
%         Scaling     A string, either:
%                         'count'     Results will be returned as events/bin
%                         or
%                         'rate'      Results will be scaled to events/second
%         Windowcoeff A vector of window coefficients which will be used to filter
%                     the result. This must be of odd-length and symmetrical
%                     to avoid phase-shifts.
%
% Note that data in the adcarray of the target channel may be a sparse 
% double precision vector.
%
% See also adcarray
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 04/08
% Copyright © The Author & King's College London 2008-
% ------------------------------------------------------------------------- 
%

% Revisions:
% 25.10.08  Memory/speed enhancements
% 11.12.08  Further memory/speed enhancements
% 23.12.09  Add support for channel groups
%           Correct out-by-one error on length of returned channel

% Process arguments
for i=1:2:length(varargin)
    switch lower(varargin{i})
        case 'sources'
            Sources=varargin{i+1};
        case 'targets'
            Targets=varargin{i+1};
        case 'start'
            Start=varargin{i+1};
        case 'stop'
            Stop=varargin{i+1};
        case 'binwidth'
            BinWidth=varargin{i+1};
        case 'scaling'
            Scaling=varargin{i+1};
        case 'windowcoeff'
            W=varargin{i+1};
        otherwise
            error('Unrecognized parameter: %s', varargin{i});
    end
end


[fhandle channels]=scParam(fhandle);

tu=channels{findFirstChannel(channels{:})}.tim.Units;
Start=Start*(1/tu);
Stop=Stop*(1/tu);
BinWidth=BinWidth*(1/tu);


for k=1:length(Sources)
    thissource=Sources(k);
    t=getValidTriggers(channels{thissource}, Start, Stop);
    t=t(t>=Start & t<Stop);
%     count=sparse(floor(t(end)/BinWidth)+1, 1);%25.10.08 Use sparse not zeros
    idx=floor(t/BinWidth)+1;
    % 25.10.08
%     if numel(unique(idx))==numel(idx)
%         % Max of 1 spike per bin
%         count(idx)=1;
%     else
%         % More than 1 spike in one or more bins
%         for m=1:length(idx)
%         count(idx(m))=count(idx(m))+1;
%         end
%     end
    
% 11.12.08 This is faster. 
    count=sparse(idx,ones(numel(idx,1)),1);
    
    thistarget=Targets(k);
    channels{thistarget}=channels{thissource};
    
    switch lower(Scaling)
        case 'rate'
            count=count/(BinWidth*channels{thissource}.tim.Units);
            channels{thistarget}.hdr.adc.Units='Hz';
        case 'count'
            channels{thistarget}.hdr.adc.Units='Count';
    end
       
    n=length(W);
    if n>1
        % Check window coefficient match the assumptions below
        if rem(n,2)~=1
            error('Window must be of odd length');
        end
        if sum(W-W(end:-1:1))~=0
            error('Window must be symmetrical');
        end
        % Moving window
        nn=length(count);
        % Apply - must be full for filter
        count=full(count);
        count=filter(W, 1, [count; zeros(n,1)]);
        % Adjust for delay
        % 21.12.09 Correct out-by-1 error
        count=count(1+floor(n/2):floor(n/2)+nn);
        % Scale for display
        channels{thistarget}.hdr.adc.YLim=[0 max(count)];
    else
        channels{thistarget}.hdr.adc.YLim=[0 max(count)+1];
    end
    
    % If full, convert back to sparse if enough zeros to make it worthwhile
    if ~issparse(count) && sum(count==0)>=numel(count)/4
        count=sparse(count);
    end
    
    channels{thistarget}.adc=adcarray(count,...
        1,...
        0,...
        [],...
        channels{thistarget}.hdr.adc.Units,...
        {''},...
        false);
    issparse(channels{thistarget}.adc.Map.Data.Adc)
    channels{thistarget}.tim=tstamp([0 t(end)],...
        1,...
        0,...
        [],...
        channels{thissource}.tim.Units,...
        false);
    channels{thistarget}.mrk=[];

    channels{thistarget}.hdr.adc.SampleInterval=...
        [BinWidth*channels{thissource}.tim.Units*1e6 1e-6];
    channels{thistarget}.hdr.adc.Npoints=nn;
    channels{thistarget}.hdr.adc.Multiplex=1;
    channels{thistarget}.hdr.adc.MultiInterval=[0 0];
    channels{thistarget}.hdr.adc.Labels={''};
    
    channels{thistarget}.hdr.channeltype='Continuous Waveform (Rate Histogram)'; 

    channels=UpdateChannelTree(channels, thistarget, thissource);
            
    if ~isempty(fhandle)
        setappdata(fhandle, 'channels', channels);
        % Refresh the channel manager
        scChannelManager(fhandle, true);
        % Include the new channel in the display
        scDataViewDrawChannelList(fhandle,...
            unique([getappdata(fhandle, 'ChannelList') thistarget]));
    end
end

if nargout
    varargout{1}=channels;
else
    clear('channels');
end

return
end

