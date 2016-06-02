function varargout=scGetChannelValues(fhandle, time, mode)
% scGetChannelValues returns the values on each channel at a specified time
%
% Examples
% y=scGetChannelValues(fhandle, time)
% y=scGetChannelValues(fhandle, time, mode)
%
% fhandle is the handle of a sigTOOL figure window
% time is the time to return values for
% mode (if set) is a string. Either 'pixel' or 'interval' (see below)
%
%
% y is a cell array with one element for each channel
%
% Waveform channels:
% The value placed in y is the value at time. If there is no sample at time,
% y{channelnumber} will be empty unless mode is set. Then:
%     if mode=='pixel'
%         the value of the first sample at or after time but 
%         within one pixel width will be returned. If there is none,
%         y{channelnumber} will be empty. This mode will typically be used
%         with cursor functions
%     if mode=='interval'
%         the value of the nearest sample at or after time will be
%         returned if it lies within one sample interval. If not,
%         y{channelnumber} will be empty.
%
% Edges
% If an edge occurs at time, y{channelnumber} will be set true.
% If mode=='pixel', the edge can be within one pixel width of time.
%
% Pulses
% y{channelnumber} will be true if the channel is high at time,
% and false otherwise

errormargin=0;

switch scGetFigureType(fhandle)
    case 'sigTOOL:DataView:'
        channels=getappdata(fhandle, 'channels');

        y=cell(length(channels), 1);
        x=zeros(length(channels), 1);

        if nargin==3 && strcmpi(mode,'pixel')
            % Find the width of a pixel (in seconds)
            AxesList=getappdata(fhandle, 'AxesList');
            XLim=get(AxesList(end),'XLim');
            units=get(AxesList(end),'Units');
            set(AxesList(end),'Units','pixels');
            pixels=get(AxesList(end),'Position');
            set(AxesList(end),'Units', units);
            pixelwidth=(XLim(2)-XLim(1))/pixels(3);
        end

        for chan=1:length(channels)

            if isempty(channels{chan})
                continue
            end


            % Waveform channels
            if ~isempty(strfind(channels{chan}.hdr.channeltype,'Waveform'))

                if nargin==2 || strcmpi(mode, 'interval')
                    errormargin=prod(channels{chan}.hdr.adc.SampleInterval);
                elseif nargin==3 && strcmpi(mode,'pixel')
                    errormargin=pixelwidth;
                else
                    errormargin=0;
                end

                % Get sample time in x
                idx=convTime2ValidIndex(channels{chan}, time);
                x(chan)=convTime2ValidIndex(channels{chan}, idx);
                % Get the y-axis value if in range
                % No need to check x(chan)>=time-errormargin as
                % convTime2ValidIndex returns the first sample at or after t
                if x(chan)<=time+errormargin
                    y{chan}=channels{chan}.adc(idx);
                else
                    y{chan}=[];
                end
            end

            % Edge
            if ~isempty(strfind(channels{chan}.hdr.channeltype,'Edge'))
                if nargin==3 && strcmpi(mode,'pixel')
                    errormargin=pixelwidth;
                else
                    errormargin=0;
                end

                % Set x to the time of the next edge
                idx=find(channels{chan}.tim()>=time-errormargin,1);
                x(chan)=channels{chan}.tim(idx,1);
                if channels{chan}.tim(idx,1)>=time-errormargin &&...
                        channels{chan}.tim(idx,1)<=time+errormargin
                    y{chan}=true;
                else
                    y{chan}=false;
                end
                %                 if ~isempty(strfind(channels{chan}.hdr.channeltype,'Falling'))
                %                     % Invert logic if a falling edge
                %                     y{chan}=~y{chan};
                %                 end
            end

            % Pulse
            if ~isempty(strfind(channels{chan}.hdr.channeltype,'Pulse'))
                % Get the first rising edge before the time
                idx=find(channels{chan}.tim(:,1)<=time,1,'last');
                if isempty(idx)
                    % State assumed low at time zero by default -
                    % Import**** functions insert rising edge at or before
                    % zero when initial state is high
                    y{chan}=false;
                else
                    y{chan}=true;
                end
                % Check the falling edge
                if channels{chan}.tim(idx,end)<time
                    y{chan}=false;
                end
                x(chan)=time;
            end

        end
end


if nargout==2
    varargout{1}=x;
    varargout{2}=y;
else
    varargout{1}=y;
end
end

