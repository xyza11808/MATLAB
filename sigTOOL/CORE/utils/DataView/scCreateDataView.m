function [AxesList]=scCreateDataView(fhandle, start, stop)
% scCreateDataView generates a strip chart data view in sigTOOL
%
% Example:
%     [AxesList]=CreateDataView(fhandle)
%
%     Inputs:   fhandle = handle of the target figure
%     Outputs:  AxesList = vector containing handles for each
%               of the axes
%
% Creates a strip chart with one set of axes for each channel in the
% 'channel' field of fhandle's application data area.
% scCreateDataView calls scCreateFigControls to add the uicontrols.
%
% See also scCreateFigControls
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 10/06
% Copyright © The Author & King's College London 2006-2007
% -------------------------------------------------------------------------
%
% Revisions:
%   23.09.09    Limit channel title display to 8 characters
%   05.11.09    See within

% Get data from the figure application area
[fhandle channels]=scParam(fhandle);


switch nargin
    case 1
        t=scMinTime(fhandle);
        if t>1
            XLim=[t t+1];
        else
            XLim=[0 1];
        end
    case 2
        XLim=[start start+1];
    case 3
        XLim=[start stop];
end


% If not specified, set the display to show the first 32 channels
ChannelList=getappdata(fhandle,'ChannelList');
if isempty(ChannelList)
    ChannelList=scGenerateChannelList(fhandle);
    setappdata(fhandle,'ChannelList',ChannelList);
end


% How many channels are used?
nchan=0;
for i=1:length(ChannelList)
    if ~isempty(channels{ChannelList(i)})
        nchan=nchan+1;
    end
end
clist=zeros(nchan,1);

% Set up the figure window
set(fhandle,'NumberTitle','on',...
    'Tag','sigTOOL:DataView',...
    'WindowButtonDownFcn',{@scWindowButtonDownFcn});

% Get the maximum time on any channel for the slider control
% MaxTime2=0;
% for i=1:length(channels)
%     if ~isempty(channels{i})
%         MaxTime1=max(channels{i}.tim(:));
%         MaxTime2=max(MaxTime1,MaxTime2);
%     end
% end
MaxTime2=scMaxTime(fhandle);
setappdata(fhandle, 'MaxTime', MaxTime2);
AxesList=zeros(length(channels),1);



% Set up the uicontextmenus activated by a right mouse click
% (cntrl-click) with non-Windows OS
pathname=fullfile(scGetBaseFolder(), 'program', 'UiContextMenus', 'DataViewAxes');
uihandle=dir2menu(pathname, 'uicontextmenu');

% Set up tabbed panels - not in the release
% TabPanel=uipanel(fhandle, 'Position',[0.15 0 0.85 1],...
%     'Background', [224 223 227]/255,...
%     'BorderType', 'beveledout',...
%     'BorderWidth', 2,...
%     'ForegroundColor', [64 64 122]/255,... 
%     'HighlightColor', [64 64 122]/255,...    
%     'Tag', 'sigTOOL:TabPanel');
% h=uitabgroup('v0', 'Parent', TabPanel);
% t1=uitab('v0', h, 'title', 'Raw Data');
% AxesPanel=uipanel(TabPanel, 'Position',[0 0 1 0.95],...
%     'Background', [224 223 227]/255,...
%     'BorderType', 'beveledout',...
%     'BorderWidth', 2,...
%     'ForegroundColor', [64 64 122]/255,... 
%     'HighlightColor', [64 64 122]/255,...    
%     'Tag', 'sigTOOL:AxesPanel');

% *****************Delete for tabbed panels in 0.94 onwards****************
AxesPanel=uipanel(fhandle, 'Position',[0 0 1 1],...
    'Background', [224 223 227]/255,...
    'BorderType', 'beveledout',...
    'BorderWidth', 2,...
    'ForegroundColor', [64 64 122]/255,... 
    'HighlightColor', [64 64 122]/255,...    
    'Tag', 'sigTOOL:AxesPanel');
TabPanel=AxesPanel;
% *****************Delete for tabbed panels in 0.94 onwards****************


set(TabPanel, 'Units', 'character');
pos=get(TabPanel,'Position');
pos(1)=30;
set(TabPanel, 'Position', pos);
set(TabPanel, 'Units', 'pixels');
pos=get(TabPanel,'Position');
pos(2)=pos(2)+60;
pos(4)=pos(4)-60;
set(TabPanel, 'Position', pos);
set(TabPanel, 'Units', 'normalized');
pos=get(TabPanel,'Position');
pos(3)=1-pos(1);
set(TabPanel, 'Position', pos);

% Make sure the first axes is visible
%h=subplot(1,1,1,'Parent', AxesPanel);
%set(h,'HandleVisibility','off');

% For each non-empty channel in ChannelList, create an axes
j=0;
for idx=1:length(ChannelList)
    
    chan=ChannelList(idx);
    
    if isempty(channels{chan})
        continue
    end

    % Increment axes counter
    j=j+1;
    % Index of channels
    clist(j)=chan;
    
    % Alternate between labeling left and right axes
    switch (bitget(j,1))
        case {0}
            yalign='right';
        case {1}
            yalign='left';
    end
    
    % Create the axes and store the handle
    AxesList(idx)=subplot(nchan,1,j, 'Parent', AxesPanel);
    
    % Set up the axes properties
    set(AxesList(idx), 'Units','normalized',...
        'Tag',['ChannelAxes' num2str(chan)],...
        'YTickMode','auto',...
        'YAxisLocation',yalign,...
        'XTick',[],...
        'XLimMode','manual',...
        'YLimMode','manual',...
        'FontSize',6,...
        'UIContextMenu', uihandle);
    % Place the channel number for the axes in the application data area of
    % the axes
    setappdata(AxesList(idx),'ChannelNumber',chan);
    
    % Set up the channel title and, for waveforms, the units field label
    slen=min(length(channels{chan}.hdr.title), 8);
    str=sprintf('%d:%s\n',chan, channels{chan}.hdr.title(1:slen));
    if isfield(channels{chan}.hdr,'adc') &&...
            ~isempty(channels{chan}.hdr.adc)
        str=horzcat(str, channels{chan}.hdr.adc.Units);
    end
    ylabel(str,'FontSize',7);
    if isempty(findstr(channels{chan}.hdr.channeltype,'Waveform'))
        set(AxesList(idx),'YTick',[])
    end

    try
        % The YLim field of hdr.adc should be set by the function that
        % created the channel (e.g. an ImportXXX function)
        YLim=channels{chan}.hdr.adc.YLim;
        set(AxesList(idx),'YLim',YLim)
    catch
        % if not ..
        YLim=[-5 5];
        set(AxesList(idx),'YLim',YLim);
        lasterror('reset');
    end
end

% If no axes exist, create one via gca
if isempty(AxesList)
    AxesList=gca;
end

% Save, then ignore zero entries
setappdata(fhandle,'AxesList',AxesList);
AxesList=AxesList(AxesList>0);

% Optimize the height of each channel axes
pos1=get(AxesList(1),'Position');
if length(AxesList)>1
    pos2=get(AxesList(end),'Position');
    height=(0.95-pos2(2))/length(AxesList);
    height=min(height,0.95-pos1(2));
else
    height=pos1(4);
end

 for i=1:length(AxesList)
     pos2=get(AxesList(i),'Position');
%     pos2(1)=0.05;
%     pos2(3)=0.9;
     pos2(4)=height;
     set(AxesList(i),'Position',pos2);
 end
% 
obj=scChannelManager(fhandle);
set(AxesList,'Units','pixels');
set(obj,'Units','pixels');
for i=1:length(AxesList)
    pos2=get(AxesList(i),'Position');
    pos2(4)=pos2(4)-2;
%     pos2(1)=obj.Position(1)+obj.Position(3)+50;
%     pos2(3)=pos2(3)-50;
    set(AxesList(i),'Position',pos2);
end
set(AxesList,'Units','normalized');
set(obj,'Units','normalized');
set(AxesList,'XLim',XLim); 


setappdata(fhandle,'DataXLim',[0 0]);



set(AxesList(end),'XTickMode','auto');
xlabel('Time (s)','FontSize',8);


% Put up the uicontrols...
scCreateFigControls(fhandle, MaxTime2);
% ...and the logo (do not remove this - sigTOOL will exit)
scInsertLogo(fhandle);
% ... then draw the data
channels=[];
scSec();
sigTOOLDataView(fhandle);
scDataViewDrawData(fhandle);

%Before exit, make sure we resize controls if figure is resized
set(fhandle,'ResizeFcn','scResizeFigControls');

end

