function channelout=getData(channel, varargin)
% getData returns the data for a specified time period
%
% Data are returned for the period START <= t < STOP
%
% Example:
% channelout=getData(channel, start, stop)
% channelout=getData(channel, [start stop])
%
% channel is an scchannel object
% start and stop are the times marking the beginning and end
%       of the required time window.
%
% channelout on output is an scchannel object.
% Waveform data in channelout will be trimmed to the limits
%                   START <= t < STOP.
% When the channel is a 'Custom' channeltype, all epochs with
% START <= tim(:,1) < STOP will be returned.
% The epochs are defined by the highest dimension of adc.
%
%
% Toolboxes required: None
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © The Author & King’s College London 2006-2007
%-------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:



% Check inputs
switch nargin
    case 2
        temp=varargin{1};
        if length(temp)~=2
            channelout=[];
            return
        end
        start=temp(1);
        stop=temp(2);
    case 3
        start=varargin{1};
        stop=varargin{2};
    otherwise
        channelout=[];
        return
end

if stop<start || start>channel.tim(end)
    channelout=[];
    return
end

temp=[];
%Skip empty channels
if isempty(channel)
    channelout=[];
    return
end

% Copy and adapt the header information
temp.hdr=channel.hdr;
temp.hdr.tim.Scale=1;
temp.hdr.tim.Func=[];
temp.hdr.tim.Units=channel.hdr.tim.Units;


epochs=convTime2ValidEpochs(channel, start, stop);
if isempty(epochs)
    channelout=[];
    return
end

% Copy relevant timestamps...
temp.tim=channel.tim(epochs, :);

% .... and number of points
if ~isempty(temp.hdr.adc) && all(~isnan(temp.hdr.adc.Npoints))
    temp.hdr.adc.Npoints=temp.hdr.adc.Npoints(epochs);
end

if isempty(channel.adc)
    % No adc channel
    temp.tim=tstamp(temp.tim,...
        1,...
        0,...
        [],...
        channel.tim.Units,...
        false);
    temp.adc=[];
else
    if ~isempty(strfind(channel.hdr.channeltype,'Waveform'))
        temp.hdr.tim.Class='tstamp';
        % Process waveforms
        if ~isempty(strfind(channel.hdr.channeltype,'Continuous'))
            idx=convTime2ValidIndex(channel, start, stop);
            %idx(:,2)=idx(:,2);%*channel.hdr.adc.Multiplex;
            temp.adc=idx(1,1):idx(1,2);
            temp.adc=channel.adc(temp.adc);
            temp.hdr.adc.Npoints(1)=idx(2)-idx(1)+1;
            temp.tim=tstamp([convIndex2Time(channel,idx(1)) convIndex2Time(channel,idx(2))],...
                1,...
                0,...
                [],...
                channel.tim.Units,...
                false);
        else
            % Multiple columns in channel.adc
            try
                idx=convTime2ValidIndex(channel, start, stop);
            catch %#ok<CTCH>
                rethrow(lasterror()); %#ok<LERR>
            end
            if idx(1)>idx(2)
                channelout=[];
                return
            end
            if ~isempty(idx)
                [r,c]=ind2sub(size(channel.adc), idx); %#ok<NASGU>
                % Pre-allocate
                temp.adc=zeros(size(channel.adc,1),length(epochs));
                %First epoch
                try
                    temp.adc(1:r(1,2)-r(1,1)+1,1)=channel.adc(idx(1,1):idx(1,2));
                catch %#ok<CTCH>
                    error('TODO: ');
                end
                temp.adc(r(1,2)-r(1,1)+2:channel.hdr.adc.Npoints(1),1)=NaN;
                temp.hdr.adc.Npoints(1)=r(1,2)-r(1,1)+1;
                temp.tim(1,1)=convIndex2Time(channel,idx(1));
                % Middle epochs
                if length(epochs)>2
                    %temp.adc(:,2:lastrow-firstrow)=getEpochData(channel, firstrow+1:lastrow-1);
                    temp.adc(:, 2:length(epochs)-1)=channel.adc(:, epochs(2:end-1));
                end
                %Final epoch
                if length(epochs)>=2
                    temp.adc(1:r(end,2)-r(end,1)+1, end)=channel.adc(idx(end,1):idx(end,2));
                    temp.adc(r(end,2)-r(end,1)+2:channel.hdr.adc.Npoints(epochs(end)),end)=NaN;
                    temp.hdr.adc.Npoints(length(epochs))=r(end,2)-r(end,1)+1;
                    temp.tim(end,1)=convIndex2Time(channel,idx(end,1));
                end
                % Cast tim to tstamp
                temp.tim=tstamp(temp.tim,...
                    1,...
                    0,...
                    [],...
                    channel.tim.Units,...
                    false);
            end
        end
    else
        % Not a waveform - e.g. text, video etc
        nd=length(size(channel.adc));
        ix=repmat({':'},1,nd);
        ix{nd}=epochs;
        % If this is a Custom defined variable with no scaling or DC offset
        % preserve its channel type from disc (may save space and preserves
        % behaviour of called functions e.g.image with uint8 data)
        if ~isempty(strfind(channel.hdr.channeltype,'Custom')) &&...
                channel.adc.Scale==1 &&...
                channel.adc.DC==0
            temp.adc=channel.adc.Map.Data.Adc(ix{:});
        else
            temp.adc=channel.adc(ix{:});
        end
        temp.tim=channel.tim(epochs, :);
        temp.tim=tstamp(temp.tim,...
            1,...
            0,...
            [],...
            channel.tim.Units,...
            false);
    end
end

% 02/08/08 add labels
if ~isempty(temp.adc)
    temp.adc=adcarray(temp.adc,...
    1,...
    0,...
    [],...
    channel.adc.Units,...
    channel.adc.Labels,...
    false);
end

% Markers
if ~isempty(channel.mrk)
    temp.mrk=channel.mrk(epochs,:);
else
    temp.mrk=[];
end

temp.channelchangeflag=[];
temp.EventFilter.Mode='off';
temp.EventFilter.Flags=[];
channelout=scchannel(temp);
end


