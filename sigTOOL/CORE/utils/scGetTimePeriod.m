function out=scGetTimePeriod(data, varargin)
% scGetTimePeriod returns the data for a specified time period
%
% Data are returned for the period START <= t < STOP
%
% Example:
% DATAOUT=scGetTimePeriod(DATAIN, START, STOP)
% DATAOUT=scGetTimePeriod(DATAIN, [START STOP])
%
% DATAIN is a sigTOOL channel array or element
% START and STOP are the times (in seconds) marking the beginning and end
%       of the required time window.
%
% DATAOUT is a sigTOOL channel array containing scchannel objects.
% Waveform data in DATAOUT will be trimmed to the limits START <= t < STOP.
% When the channel is a 'Custom' channeltype, all epochs with
% START <= tim(:,1) < STOP will be returned.
% The epochs are defined by the highest dimension of adc.
%
% ADCARRAY and TSTAMP objects in DATAIN will be returned as double 
% in DATAOUT
%
% See also ADCARRAY, TSTAMP
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

warning('This function has been replaced by the getData scchannel method');

% Check inputs
switch nargin
    case 2
        temp=varargin{1};
        if length(temp)~=2
            out=[];
            return
        end
        start=temp(1);
        stop=temp(2);
    case 3
        start=varargin{1};
        stop=varargin{2};
    otherwise
        out=[];
        return
end

if stop<start
    out=[];
    return
end


% Pre-allocate the output cell array
out=cell(length(data),1);

%Loop for each channel
for i=1:length(data)
    temp=[];
    %Skip empty channels
    if isempty(data{i})
        out{i}=[];
        continue
    end

    % Copy and adapt the header information
    temp.hdr=data{i}.hdr;
    temp.hdr.tim.Scale=1;
    temp.hdr.tim.Func=[];


    epochs=convTime2ValidEpochs(data{i}, start, stop);
    
%     % Copy relevant timestamps...
     temp.tim=data{i}.tim(epochs, :);
    
    % .... and number of points
    if ~isempty(temp.hdr.adc)
        temp.hdr.adc.Npoints=temp.hdr.adc.Npoints(epochs);
    end

    if isempty(temp.tim)
        temp.tim.mrk=[];
        temp.adc=[];
        out{i}=temp;
        continue
    end

    if isempty(data{i}.adc)
        % No adc data
      temp.tim=tstamp(temp.tim,...
                    1,...
                    0,...
                    [],...
                    data{i}.tim.Units,...
                    false);
        temp.adc=[];
    else
        if ~isempty(strfind(data{i}.hdr.channeltype,'Waveform'))
            temp.hdr.tim.Class='tstamp';
            % Process waveforms
            if ~isempty(strfind(data{i}.hdr.channeltype,'Continuous'))
                idx=convTime2ValidIndex(data{i}, start, stop);
                %idx(:,2)=idx(:,2);%*data{i}.hdr.adc.Multiplex;
                temp.adc=idx(1,1):idx(1,2);
                temp.adc=data{i}.adc(temp.adc);
                temp.hdr.adc.Npoints(1)=idx(2)-idx(1)+1;
                temp.tim=tstamp([convIndex2Time(data{i},idx(1)) convIndex2Time(data{i},idx(2))],...
                    1,...
                    0,...
                    [],...
                    data{i}.tim.Units,...
                    false);

            else
                % Multiple columns in data{i}.adc
                try
                    idx=convTime2ValidIndex(data{i}, start, stop);
                catch
                    error('Line 111: TODO: Work out why this happens');
                end
                if isempty(idx)
                    continue
                end
                [r,c]=ind2sub(size(data{i}.adc), idx);
                % Pre-allocate
                temp.adc=zeros(size(data{i}.adc,1),length(epochs));
                %First epoch
                temp.adc(1:r(1,2)-r(1,1)+1,1)=data{i}.adc(idx(1,1):idx(1,2));
                temp.adc(r(1,2)-r(1,1)+2:data{i}.hdr.adc.Npoints(1),1)=NaN;
                temp.hdr.adc.Npoints(1)=r(1,2)-r(1,1)+1;
                temp.tim(1,1)=convIndex2Time(data{i},idx(1));
                % Middle epochs
                if length(epochs)>2
                    %temp.adc(:,2:lastrow-firstrow)=getEpochData(data{i}, firstrow+1:lastrow-1);
                    temp.adc(:, 2:length(epochs)-1)=data{i}.adc(:, epochs(2:end-1));
                end
                %Final epoch
                if length(epochs)>=2
                    temp.adc(1:r(end,2)-r(end,1)+1, end)=data{i}.adc(idx(end,1):idx(end,2));
                    temp.adc(r(end,2)-r(end,1)+2:data{i}.hdr.adc.Npoints(epochs(end)),end)=NaN;
                    temp.hdr.adc.Npoints(length(epochs))=r(end,2)-r(end,1)+1;
                    temp.tim(end,1)=convIndex2Time(data{i},idx(end,1));
                end
                % Cast tim to tstamp
                temp.tim=tstamp(temp.tim,...
                    1,...
                    0,...
                    [],...
                    data{i}.tim.Units,...
                    false);
            end
        else
            % Not a waveform - e.g. text, video etc
            nd=length(size(data{i}.adc));
            ix=repmat({':'},1,nd);
            ix{nd}=epochs;           
            % If this is a Custom defined variable with no scaling or DC offset
            % preserve its data type from disc (may save space and preserves
            % behaviour of called functions e.g.image with uint8 data)
            if ~isempty(strfind(data{i}.hdr.channeltype,'Custom')) &&...
                    data{i}.adc.Scale==1 &&...
                        data{i}.adc.DC==0 
                temp.adc=data{1}.adc.Map.Data.Adc(ix{:});
            else
                temp.adc=data{i}.adc(ix{:});
            end
        end
    end 
    
    % Markers
    if ~isempty(data{i}.mrk)
        temp.mrk=data{i}.mrk(epochs,:);
    else
        temp.mrk=[];
    end
    
    temp.channelchangeflag=[];
    temp.EventFilter=[];
    out{i}=scchannel(temp);
end
end


