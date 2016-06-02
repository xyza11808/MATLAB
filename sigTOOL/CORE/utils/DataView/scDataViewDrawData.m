function scDataViewDrawData(fhandle, render)
% scDataViewDrawData draws or updates the sigTOOL data view
%
% Examples:
% scDataViewDrawData(fhandle)
% scDataViewDrawData(fhandle, render)
% update the data display in the sigTOOL data view with the specified handle.
%
% The optional render flag, if specified, will override the setting of
% DataView.PreRenderDataView from the scPreferences.mat file. Pre-rendering
% of data reduces the number of data points drawn to match the screen
% resolution. Render should be logical (true or false).
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/06
% Copyright © The Author & King's College London 2006
%--------------------------------------------------------------------------
%
% Revisions:
%   22.10.08    See within
%   27.01.10    Fix bug: wrong numbering of active (green) markers

% Make sure this is a sigTOOL data view
if ~strcmp(get(fhandle, 'Tag'), 'sigTOOL:DataView')
    return
end

% Set pointer to watch - remember to restore it later
set(fhandle,'Pointer', 'watch');
drawnow();

% Get axes handles
AxesList=getappdata(fhandle, 'AxesList');%findobj(fhandle, 'Type', 'axes');
% Delete existing lines
h=findobj(AxesList(AxesList>0),'Tag', 'sigTOOL:Data');%'Type', 'hggroup',
delete(h);

% Get the data
channels=getappdata(fhandle, 'channels');
ChannelList=getappdata(fhandle, 'ChannelList');
if isempty(ChannelList)
    ChannelList=scGenerateChannelList(channels);
    setappdata(fhandle,'ChannelList',ChannelList);
end

% Set options from scPreferences.mat
p=getappdata(fhandle,'DataView');

% Override scPreference.mat setting if called with an explicit render mode
% Render is logical (true or false)
if nargin>=2
    p.PreRenderDataView=render;
end

lineoptions={'Color',p.DefaultLineColor,...
    'Tag','sigTOOL:Data'};
h=findobj(fhandle,'Type','line');
if ~isempty(h) && strcmp(get(h(1),'LineSmoothing'),'on')
    lineoptions{end+1}='Linesmoothing';
    lineoptions{end+1}='on';
end

textoptions={'BackgroundColor', p.MarkerTextBackgroundColor,...
    'EdgeColor',p.MarkerTextEdgeColor,...
    'Margin', p.MarkerTextMargin,...
    'FontSize', p.MarkerTextFontSize,...
    'Clipping','on',...
    'Tag', 'sigTOOL:MarkerValue'};
% Define 8 colors for multiplexed data
ColorCycle={lineoptions{2};[0 0.7 0];[0.7 0 0];[0 0 0.5];[0 0.5 0];[0.5 0 0];[0.5 0.5 0.5]};


% Constants used for plotting TTL data
high=0;
low=-4.5;
h=findobj(fhandle,'Type','axes');
XLim=get(h(end),'XLim');

%----------------------------------------------------------------------
% PLOT THE DATA
% Note precedence given to channel types:
% custom>=edge>pulse>waveform
%----------------------------------------------------------------------
% 'i' is the channel number

count=0;
for idx=1:length(ChannelList)
    
    i=ChannelList(idx);
    
    
    if isempty(channels{i}) || isempty(channels{i}.tim)
        continue
    end
    
    
    tlim=XLim/channels{i}.tim.Units;
    try
        data=getData(channels{i}, tlim(1), tlim(2));
    catch
        err=lasterror();
        % Likely to be Out of Memory error. Clean up virtual memory if so
        if isOOM()
            clear('channels', 'data');
            scRemap();
            channels=getappdata(fhandle, 'channels');
            data=getData(channels{i}, tlim(1), tlim(2));
        else
            % Avoid rethrow stack problem (TMW Bug 336891)
            error(err);
        end
    end
    
    if isempty(data) || isempty(data.tim)
        continue
    end
    
    
    ah=AxesList(idx);
    subplot(ah);
    
    
    yvalues=[];
    if isempty(data.tim)
        continue
    end
    
    if ~isempty(strfind(data.hdr.channeltype,'Custom'))
        channeltype='Custom';
    else
        if ~isempty(strfind(data.hdr.channeltype,'Edge'))
            channeltype='Edge';
        else
            if ~isempty(strfind(data.hdr.channeltype,'Pulse'))
                channeltype='Pulse';
            else
                if ~isempty(strfind(data.hdr.channeltype,'Waveform'))
                    channeltype='Waveform';
                end
            end
        end
    end
    
    switch channeltype
        case {'Edge', 'Custom'}
            %----------------------------------------------------------------------
            % "Custom" data and TTL data - edge triggers and markers
            %----------------------------------------------------------------------
            set(ah,'YLim',[-5 5]);
            if ~isempty(strfind(data.hdr.channeltype,'Falling'))
                line(tlim,[high high],lineoptions{:});
            else
                line(tlim,[low low],lineoptions{:});
            end
            ts=data.tim()*data.tim.Units;
            for k=1:length(data.tim)
                line( [ts(k) ts(k)],[low high],...
                    lineoptions{:});
            end
        case {'Pulse'}
            %----------------------------------------------------------------------
            % Pulses
            %----------------------------------------------------------------------
            % Start condition. data.tim(1,1) is always a low to high
            % Draw low level
            set(ah,'YLim',[-5 5]);
            %             line([tlim(1) data.tim(1,1)],[low low],...
            %                 lineoptions{:});
            % Edges & high levels
            ts=data.tim()*data.tim.Units;
            for k=1:size(ts,1)
                % Draw rising edge
                line([ts(k,1) ts(k,1)],[low high],...
                    lineoptions{:});
                % Draw falling edges
                line([ts(k,end) ts(k,end)],[high low],...
                    lineoptions{:});
                % Draw high levels
                line([ts(k,1) ts(k,end)],[high high],...
                    lineoptions{:});
            end
            % Low levels
            for k=2:size(ts,1)
                line([ts(k-1,end) ts(k,1)],[low low],...
                    lineoptions{:});
            end
            % Final low level if on screen
            if ts(end,end)<=tlim(2)
                line([ts(end,end) tlim(2)],[low low],...
                    lineoptions{:});
            end
        case {'Waveform'}
            %----------------------------------------------------------------------
            % Waveform data
            %----------------------------------------------------------------------
            % Set up the time vector for the xaxis
            if isempty(data.adc)
                continue
            end
            xvalues=getTimeVector(data, 'seconds');
            % vector/matrix - multiplexed?
            [rows columns]=size(data.adc);
            if columns==1 && data.hdr.adc.Multiplex<=1
                % Single continuous trace
                yvalues=data.adc();
                if isempty(strfind(data.hdr.channeltype, 'Histogram'))
                    % Pre-rendering if required.
                    if p.PreRenderDataView==true
                        n=data.hdr.adc.Npoints(1);
                        [xvalues, yvalues]=PreRender(xvalues(1:n), yvalues(1:n), data.hdr);
                    end
                    line(xvalues, yvalues, lineoptions{:});
                else
                    % Histogram
                    pos=get(ah, 'YAxisLocation');
                    str=get(get(ah, 'YLabel'), 'String');
                    stairs(xvalues, yvalues, lineoptions{:});
                    set(ah, 'XLimMode', 'manual');
                    set(ah, 'XLim', XLim);
                    set(ah, 'YLim', data.hdr.adc.YLim);
                    set(ah,'YAxisLocation',pos);
                    ylabel(ah, str);
                end
            else
                % Multiple traces or multiplexed data
                yvalues(:,1:columns)=data.adc(:,1:columns);
                % Pre-rendering
                if p.PreRenderDataView==true && data.hdr.adc.Multiplex==1
                    [xvalues, yvalues]=PreRender(xvalues,yvalues,data.hdr);
                    for k=1:size(xvalues,2)
                        % Omit last value - may be based on incomplete
                        % (zero-padded) column in DownSample
                        n(k)=length(xvalues(~isnan(xvalues(1:end, k)), k))-2;
                    end
                else
                    n=data.hdr.adc.Npoints;
                end
                % TODO: Can we increase speed here further
                inc=data.hdr.adc.Multiplex;
                for j=1:inc
                    for k=1:size(xvalues,2)
                        idx1=j:inc:n(k);
                        x=xvalues(idx1,k);
                        y=yvalues(idx1,k);
                        line(x, y,...
                            lineoptions{:},...
                            'Color', ColorCycle{j});
                    end
                end
                
                %                 %Is this faster? Not by much
                %                 inc=data.hdr.adc.Multiplex;
                %                 x=nan(max(n),size(xvalues,2));
                %                 y=nan(max(n),size(xvalues,2));
                %                 for j=1:inc
                %                     for k=1:size(xvalues,2)
                %                         idx1=j:inc:n(k);
                %                         x(1:length(idx1),k)=xvalues(idx1,k);
                %                         y(1:length(idx1),k)=yvalues(idx1,k);
                %                     end
                %                 end
                %                 line(x, y,...
                %                     lineoptions{:},...
                %                     'Color', ColorCycle{j});
                
            end
    end %[End of SWITCH]
    linelist=findobj(ah,'Type','line','Tag','sigTOOL:Data');
    grp=hggroup();
    set(linelist, 'Parent', grp);
    set(grp,'Tag','sigTOOL:Data');
    %----------------------------------------------------------------------
    % Now draw any marker values for the channel
    %----------------------------------------------------------------------
    
    % Ignore markers if there are none, they are all the same or the
    % preferences file tells us to
    if  isempty(data.mrk) ||...
            length(unique(channels{i}.mrk))==1 ||...
            p.NumberOfMarkersToShow<=0
    else
        % Otherwise
        if ~isfield(data.hdr,'channeltypeFcn') ||...
                isempty(data.hdr.channeltypeFcn)
            % It is a passive marker....
            ButtonDownFcn='';
            Color=[1 1 0];% Yellow backround for inactive marker
        else
            % ...or it is associated with a callback i.e. active
            ButtonDownFcn=sprintf('scMarkerButtonDownFcn(''%s'')',...
                data.hdr.channeltypeFcn);
            Color=[0.4 0.8 0];% Green background for active marker
        end
        
        YLim=get(ah,'YLim');
        
        for k=1:size(data.mrk,1)
            % Limit the number of markers
            switch class(data.mrk)
                case 'char'
                    ts=data.tim()*data.tim.Units;
                    h=text(ts(k,1), YLim(2), data.mrk(k,:),...
                        'HorizontalAlignment','center',...
                        'VerticalAlignment','top',...
                        textoptions{:},...
                        'BackgroundColor', Color,...
                        'ButtonDownFcn', ButtonDownFcn,...
                        'Clipping','on');
                otherwise
                    temp=data.mrk(k,1:p.NumberOfMarkersToShow);
                    % Only show those >= ....
                    temp=temp(temp>=p.ShowMarkersGreaterThanOrEqualTo);
                    % And cast to the required class (usually uint8=>char)
                    if ~isempty(cast(temp,data.hdr.markerclass))% Added 22.10.08
                        temp=cast(temp,data.hdr.markerclass);
                    end
                    % If we are left with any to show....
                    if ~isempty(temp)
                        % Convert to text if numeric
                        if isnumeric(temp)
                            temp=mat2str(temp);
                        end
                        % Display
                        ts=data.tim()*data.tim.Units;
                        h=text(ts(k,1), YLim(2), temp,...
                            'HorizontalAlignment','center',...
                            'VerticalAlignment','top',...
                            textoptions{:},...
                            'BackgroundColor', Color,...
                            'ButtonDownFcn', ButtonDownFcn,...
                            'Clipping','on');
                        % Associate the data in the adc field with the text if we
                        % have a callback defined. Place the index in the
                        % application data area rather than the data to save memory
                        if ~isempty(ButtonDownFcn) && ~isempty(data.adc)
                            setappdata(h,'Data',[i str2double(temp)]);% 27.01.10
                        end
                    end
            end
        end
    end
    textlist=findobj(ah,'Type','text', 'Tag', 'sigTOOL:MarkerValue');
    grp=hggroup();
    set(textlist,'Parent',grp);
    set(grp,'Tag','sigTOOL:MarkerValue');
end
% Restore pointer
set(fhandle,'Pointer','arrow');
refresh();%drawnow();
end
%--------------------------------------------------------------------------
% End of main function scope
%--------------------------------------------------------------------------



%--------------------------------------------------------------------------
function [xvalues, yvalues]=PreRender(xvalues,yvalues, header)
%--------------------------------------------------------------------------
% PreRender minimizes the number of data points drawn to the screen.
% It finds the width of the display (in pixels) and returns only two
% xvalue, yvalue pairs for each x-pixel. These are the minimum and maximum
% for the yvalues to be drawn at that pixel location on the x-axis.
% Prerender presently works only on non-multiplexed
% waveform channels

% The DataView.PreRenderDataView flag in the scPreferences file determines
% whether sigTOOL pre-renders data. By default, this is set to true

% Revisions:
% 15.09.08 Multiple monitors now accounted for

% Find axis width (in pixels)
range=get(0,'MonitorPositions');
% 15.09.08: Assume using first monitor
xpixels=range(1, 3);
p=get(gca,'Position');
xpixels=xpixels*p(3);
% Return 2 data points per pixel of width by taking minima and maxima
n=xpixels*2;
% Downsample factor
factor=floor(numel(xvalues)/n);
% If already fewer points than pixels, return
if factor<=2 || header.adc.Multiplex>1
    return
end
if numel(xvalues)>n*factor
    n=n+rem(numel(xvalues),n)/factor;
end
n=floor(n);


if size(xvalues,2)==1
    % Vector of data
    [xvalues, yvalues]=DownSample(xvalues,yvalues, factor, n);
else
    % Matrix
    m=floor(n/size(xvalues,2));
    if m<2
        % Limit factor to return at least 2 points for the line
        factor=floor(size(xvalues,1)/2);
        m=2;
    end
    x=zeros(m*2,size(xvalues,2));
    y=zeros(m*2,size(xvalues,2));
    for i=1:size(xvalues,2)
        [x(:,i) y(:,i)]=DownSample(xvalues(:,i), yvalues(:,i), factor, m);
    end
    xvalues=x;
    yvalues=y;
end
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function [x, y]=DownSample(xvalues, yvalues, factor, n)
%----------------------------------------------------------------------
% Downsample x and y values
x(1,:)=xvalues(1:factor:factor*n);
x(2,:)=x(1,:);
yvalues=reshape(yvalues(1:factor*n),factor,n);
% Min and max from columns
y=min(yvalues);
y(2,:)=max(yvalues);
% Return column vectors
x=x(:);
y=y(:);
end
%--------------------------------------------------------------------------