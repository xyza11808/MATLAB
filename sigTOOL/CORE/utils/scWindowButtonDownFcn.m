function scWindowButtonDownFcn(hitObject, EventData) 
% scWindowButtonDownFcn callback for sigTOOL windows.
%
% Example:
% scWindowButtonDownFcn(fhandle, EventData)
%       mouse pressed callback for sigTOOL data and result windows
%
% This is the generic callback for sigTOOL figures.
% Specific graphic objects may have custom callbacks defined that do not
% depend on scWindowButtonDownFcn - hence empty coding in some cases here.
% Object specific callbacks, where defined, will be in the event queue and
% will be executed when this callback returns.
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 11/06
% Copyright © The Author & King's College London 2006-
% -------------------------------------------------------------------------
%
% Revisions:
% 29.09.08  Bug Fix
% 26.10.08  Add drawnow for uitable- needed on R2008b to flush event queue
% 21.08.09  Add support to change axis ranges in result view
% 05.05.09  Support column display mode
% 26.09.09  Improved support for CustomResultPanels


if isempty(gco)
    return
end

% Get figure handle
fhandle=ancestor(hitObject, 'figure');

% Demonstrate responding
set(fhandle, 'Pointer', 'watch');

% Deselect all
% h=findall(fhandle);
% set(h, 'Selected', 'off');

% Get the object if figure handle on input
if fhandle==hitObject
    hitObject=hittest(fhandle);
end

ObjectType=get(hitObject,'Type');
mouseclick=get(fhandle, 'SelectionType');

switch ObjectType
    
    case {'line' 'hggroup'}
        % Mouse selection on line object
        switch mouseclick
            case 'normal'
                switch get(hitObject,'Tag')
                    case 'Cursor'
                        % If a cursor, the relevant callback will be in the queue
                        % so just return
                    case 'AddedPlot'
                        set(hitObject, 'Selected', 'on');
                    case 'sigTOOL:ResultData'
                        rm=getappdata(fhandle, 'ResultManager');
                        dm=rm.DisplayMode;
                        switch dm.getSelectedItem()
                            case 'Column'
                                % Allow interactive movement of lines in
                                % column displays
                                LocalDrag(hitObject);
                            otherwise
                                % All other display types
                                switch get(fhandle,'Tag')
                                    case 'sigTOOL:DataView'
                                        DataView(fhandle, EventData);
                                    case 'sigTOOL:ResultView'
                                        ResultView(fhandle, EventData);
                                end
                        end
                end
            case 'open'
                if strcmp(get(hitObject, 'Tag'), 'AddedPlot')
                    warning('off','MATLAB:uitable:OldTableUsage');
                    data=get(hitObject, 'UserData');
                    h=figure('MenuBar', 'none',...
                        'NumberTitle', 'off',...
                        'Name', ['Table:' get(fhandle, 'Name')]);
                    set(h, 'Units', 'normalized', 'Position', [0.7 0.1 0.2 0.75]);
                    thandle=uitable(num2cell(data),{'x' 'y'});
                    set(thandle, 'Units', 'normalized', 'Position',[0 0 1 1]);
                    warning('on', 'MATLAB:uitable:OldTableUsage');
                end
            otherwise
                % Let object callback do the work
        end
        
    case {'axes','figure','uipanel'}
        switch mouseclick
            case 'normal'
                switch ObjectType
                    case 'axes'
                        % axes
                        switch get(fhandle,'Tag')
                            case 'sigTOOL:DataView'
                                DataView(fhandle, EventData);
                            case 'sigTOOL:ResultView'
                                ResultView(fhandle, EventData);
                                AxesHighlight(hitObject);
                        end
                        
                    otherwise
                        % Figure or uipanel
                        h=findall(fhandle, 'Type', 'axes', 'Selected', 'on');
                        scInteractiveAxes(h, 'off');  
                end
            case 'alt'
                % Cntrl-Click or Right button
                % If a uicontextmenu is defined for the selected object,
                % the uicontextmenu callback will be in the queue and will
                % be executed when scWindowButtonDownFcn returns.
                % Any code placed here will execute before the
                % uicontextmenu drops down
            case 'extend'
                % Not supported at present
            case 'open'
                % Double click. Copy axes and children to a new figure
                % window
                switch ObjectType
                    case 'axes'
                        ax=gca;
                        r=getappdata(ancestor(ax, 'figure'), 'sigTOOLResultData');
                        idx=getappdata(ax, 'AxesSubscript');
                        if isempty(idx)
                            % Added axes - find main result
                            hlist=findobj(fhandle, 'Type', 'axes', 'Position', get(ax, 'Position'));
                            ax=get(findall(hlist, 'Tag', 'sigTOOL:ResultData'),'Parent');
                            if isempty(ax)
                                % TODO: This could be an axes added by a
                                % custom object plot method but for the
                                % moment we'll just return
                                set(fhandle, 'Pointer', 'arrow');
                                return
                            end
                            idx=getappdata(ax, 'AxesSubscript');
                        end
                        r.data={r.data{1,1} r.data{1, idx(2)};...
                            r.data{idx(1), 1} r.data{idx(1), idx(2)}};
                        source=getappdata(ancestor(ax, 'figure'), 'ResultManager');
                        h=plot(r);
                        target=getappdata(h, 'ResultManager');
                        fcn=target.DisplayMode.ActionPerformedCallback;
                        target.DisplayMode.ActionPerformedCallback=[];
                        target.DisplayMode.setSelectedItem(source.DisplayMode.getSelectedItem());
                        target.DisplayMode.ActionPerformedCallback=fcn;
                        fcn=target.Frames.ActionPerformedCallback;
                        target.Frames.ActionPerformedCallback=[];
                        target.Frames.setText(source.Frames.getText());
                        target.Frames.ActionPerformedCallback=fcn;
                    case 'uipanel'
                        % 26.09.09
                        result=getappdata(ancestor(hitObject, 'figure'), 'sigTOOLResultData');
                        if strcmp(get(hitObject, 'Tag'), 'sigTOOL:CustomResultPanel')
                            AxesSubscript=getappdata(hitObject, 'AxesSubscript');
                            obj=result.data{AxesSubscript(1), AxesSubscript(2)};
                            chans=getappdata(hitObject, 'ChannelNumbers');
                            result.data={'Cannel' num2str(chans(1)); num2str(chans(2)) obj};
                        end   
                        plot(result);
                end
        end
end
set(fhandle, 'Pointer', 'arrow');
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function DataView(fhandle, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
h=findobj(fhandle,'Type','axes');
if isempty(h)
    return
end
% Use rbbox to control rectangle in figure, but use
% positions returned from the current axes
set(fhandle, 'Pointer', 'crosshair');
pos1=get(gca,'CurrentPoint');
r=rbbox;
pos2=get(gca,'CurrentPoint');
set(fhandle, 'Pointer', 'arrow');
if r(3)+r(4)==0
    % Mouse not currently pressed - rbbox will have
    % returned immediately
    return
end
% Update all axes
AxesList=getappdata(fhandle,'AxesList');
XLim=sort([pos1(1) pos2(1)]);
if pos1(1)==pos2(1)
    return
end
AxesList=AxesList(AxesList>0);
set(AxesList,'XLim',XLim);
% Clean up before refresh if this is a data view
if strcmp(get(fhandle,'Tag'),'sigTOOL:DataView')==1
    scCleanUpAxes(AxesList);
    setappdata(fhandle,'DataXLim',[0 0]);
    scDataViewDrawData(fhandle);
end
return
end
%-------------------------------------------------------------------------


%--------------------------------------------------------------------------
function ResultView(fhandle, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------

% Select Axes
ax=gca;
set(fhandle, 'Pointer', 'crosshair');
pos1=get(ax,'CurrentPoint');

a=get(ax, 'XLim');
b=get(ax, 'YLim');


% See if we are close to an axis. If so adjust the axis settings. If in the
% plotting area, select the data.
if pos1(1,1)<a(1) && pos1(1,1)>=a(1)-(0.15*(a(2)-a(1))) && is2D(ax) 
    % Changing Y-axis range
    rbbox();
    pos2=get(ax,'CurrentPoint');
    p=sort([pos1(1,2) pos2(1,2)]);
    if(p(1)~=p(2)) 
        set(ax,'YLim', p);
    end
elseif pos1(1,2)<b(1) && pos1(1,2)>=b(1)-(0.15*(b(2)-b(1))) && is2D(ax)
    % Changing X-axis range
    rbbox();
    pos2=get(ax,'CurrentPoint');
    p=sort([pos1(1,1) pos2(1,1)]);
    if(p(1)~=p(2))
        set(ax,'XLim', p);
        scUpdateAxisControls(fhandle,'increase',ax);
    end
else
    % Selecting data
    r=rbbox();
    pos2=get(ax,'CurrentPoint');
    if r(3)+r(4)==0
        % Mouse not currently pressed - rbbox should have
        % returned immediately
        set(fhandle, 'Pointer', 'arrow');
        return
    end
    % Mouse has been dragged
    set(fhandle, 'Pointer', 'watch');
    
    % Get handles for lines
    h=findall(ax, 'Tag', 'sigTOOL:ResultData');
    
    % Revised 10.08.8
    if isempty(h)
        % May be a superimposed set of axes -switch to the main sigTOOL result
        hlist=findobj(fhandle, 'Type', 'axes', 'Position', get(ax, 'Position'));
        h=findall(hlist, 'Tag', 'sigTOOL:ResultData');
        if isempty(h)
            return
        else
            ax=get(h, 'Parent');
        end
    end
    
    % Get rid of pre-existing selections
    delete(findall(ax, 'Tag', 'sigTOOL:SelectedData'));
    
    xr=sort([pos1(1) pos2(1)]);
    yr=sort([pos1(3) pos2(3)]);
    % Create a context menu
    cmenu=uicontextmenu();
    uimenu(cmenu, 'Label', 'Selected Data', 'ForegroundColor', [0 0 1]);
    uimenu(cmenu, 'Label', 'View Data', 'Callback', @OpenTable, 'Separator', 'on');
    uimenu(cmenu, 'Label', 'EzyFit Curve Fitting', 'Callback', @CurveFitting);
    if ~isempty(findall(fhandle, 'Type', 'uimenu', 'Label', 'Fit Distribution'))
        % Allow a distribution fit to the selection if this is enabled for the
        % entire data set
        scAddDistributionTool(cmenu);
    end
    uimenu(cmenu, 'Label', 'Remove Selection', 'Callback', @RemoveSelection);
    
    % For each line - superimpose new line over selected data and activate
    % uicontextmenu and double click.
    ViewStyle=getappdata(fhandle, 'sigTOOLViewStyle');
    result=getappdata(fhandle, 'sigTOOLResultData');
    for k=1:length(h)
        xdata=get(h(k), 'XData');
        ydata=get(h(k), 'YData');
        if strcmp(ViewStyle, '3D');
            zdata=get(h(k), 'ZData');
        else
            zdata=zeros(size(ydata));
        end
        switch func2str(result.plotstyle{1})
            case {'scBar' 'scFrames' 'scWaterfall' 'scColumn'}
                TF=xdata>=xr(1) & xdata<=xr(2);
            otherwise
                try
                    TF=xdata>=xr(1) & xdata<=xr(2) & ydata>=yr(1) &  ydata<=yr(2);
                catch %#ok<CTCH>
                    % Currently fails on plots like surface
                    return
                end
        end
        % Bug Fix 29.09.08
        if all(TF==0)
            return
        end
        xdata=xdata(TF);
        ydata=ydata(TF);
        zdata=zdata(TF);
        switch func2str(result.plotstyle{1})
            case 'scScatter'
                % Sort data
                [xdata, idx]=sort(xdata);
                ydata=ydata(idx);
                hold(ax,'on');
                % Display selected
                scatter(xdata, ydata, [], 'r',...
                    'Tag', 'sigTOOL:SelectedData',...
                    'UIContextMenu', cmenu,...
                    'ButtonDownFcn', {@SelectedDataButtonDownFcn},...
                    'UserData', get(h(k), 'UserData'),...
                    'Visible', get(h(k), 'Visible'),...
                    'Parent', ax);
                hold(ax,'off');
            case 'scBar'
                % 10.08.08 Include last bar in line
                xdata=vertcat(xdata, xdata(end)+max(diff(xdata))*0.9); %#ok<AGROW>
                ydata=vertcat(ydata, ydata(end)); %#ok<AGROW>
                zdata=vertcat(zdata, zdata(end)); %#ok<AGROW>
                line(xdata, ydata, zdata,...
                    'Color', 'r',...
                    'Tag', 'sigTOOL:SelectedData',...
                    'UIContextMenu', cmenu,...
                    'ButtonDownFcn', {@SelectedDataButtonDownFcn},...
                    'UserData', get(h(k), 'UserData'),...
                    'Visible', get(h(k), 'Visible'),...
                    'Parent', ax);
            otherwise
                line(xdata, ydata, zdata,...
                    'Color', 'r',...
                    'Tag', 'sigTOOL:SelectedData',...
                    'UIContextMenu', cmenu,...
                    'ButtonDownFcn', {@SelectedDataButtonDownFcn},...
                    'UserData', get(h(k), 'UserData'),...
                    'Visible', get(h(k), 'Visible'),...
                    'Parent', ax);
        end
    end
end
set(fhandle, 'Pointer', 'arrow');
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function AxesHighlight(ax)
%--------------------------------------------------------------------------
h=findall(ancestor(ax, 'figure'), 'Type', 'axes', 'Selected', 'on');
if ~isempty(h)
    scInteractiveAxes(h, 'off');
    set(h, 'Selected', 'off');
end
set(ax, 'Selected', 'on');
scInteractiveAxes(ax);
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function SelectedDataButtonDownFcn(fhandle, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
mouseclick=get(gcf, 'SelectionType');
if ~strcmp(mouseclick, 'open')
    return
end
OpenTable(fhandle);
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function LocalDrag(hitObject)
%--------------------------------------------------------------------------
col=get(hitObject, 'Color');
set(hitObject, 'Color', 'green');
ax=ancestor(hitObject,'axes');
fhandle=ancestor(hitObject, 'figure');
pos=get(ax, 'CurrentPoint');
setptr(fhandle, 'uddrag');
rbbox();
new=get(ax, 'CurrentPoint');
shift=new(1,2)-pos(1,2);
y=get(hitObject, 'YData');
y=y+shift;
set(hitObject, 'YData', y);
temp=get(hitObject, 'UserData');
temp(2)=temp(2)-shift;
set(hitObject, 'Userdata', temp);
set(hitObject, 'Color', col);
return
end


% SELECTED DATA UICONTEXTMENU CALLBACKS
%--------------------------------------------------------------------------
function RemoveSelection(fhandle, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
target=findobj(gca, 'Tag', 'sigTOOL:SelectedData');
if isappdata(min(target),'Table')
    h=getappdata(min(target), 'Table');
    if ishandle(h)
        delete(h);
    end
end
delete(target);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function SummaryStatistics(hObject, EventData) %#ok<DEFNU,INUSD>
%--------------------------------------------------------------------------
fhandle=ancestor(hObject, 'figure');
% TODO: Customize the statistics?
toolsmenufcn(fhandle, 'DataStatistics');
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function CurveFitting(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
% This opens a new window displaying the selected data and adds the EzyFit
% curve fitting menu to it. EzyFit should be installed from the MATLAB
% Central Site:
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=10176&objectType=file

fhandle=ancestor(hObject, 'figure');
ax=gca;
h=findobj(gca, 'Tag', 'sigTOOL:SelectedData', 'Visible','on');
if numel(h)>1
    msgbox('You can have only one trace visible for curve fitting', 'Curve Fitting');
    return
end
xdata=get(h,'xdata');
%ydata=get(h,'ydata');

% xdata & ydata maybe from patch objects or hggroups - use original data
% from sigTOOLResultData object
result=getappdata(fhandle, 'sigTOOLResultData');
idx=getappdata(gca, 'AxesSubscript');
data=result.data{idx(1),idx(2)};
minx=min(xdata);
maxx=max(xdata);
tdata=data.tdata(data.tdata>=minx & data.tdata<=maxx);
% Restrict rdata to present line
rdata=data.rdata(get(h, 'UserData'),data.tdata>=minx & data.tdata<=maxx);

try
    newf=figure('Name', sprintf('%s Frame: %d', get(fhandle, 'Name'),get(h,'UserData')));
    subplot(1,1,1);
    plot(tdata,rdata, 'o','Tag', 'sigTOOL:ExportedData');
    efmenu;
catch %#ok<CTCH>
    button=questdlg('Error in curve fitting: EzyFit may not be installed', 'Curve Fitting',...
        'Visit website', 'Continue', 'Continue');
    if strcmp(button,'Visit website')
        web('http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=10176&objectType=file');
    end
end
% Stop EzyFit appearing in all windows
set(0,'DefaultFigureCreateFcn','');
h=findobj(newf, 'Type', 'uimenu', 'Label', 'EzyFit');
uimenu(h, 'Label', 'Export To sigTOOL', 'Callback', {@GetFit, ax},...
    'Separator', 'on', 'ForegroundColor',[0 0 1]);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function OpenTable(fhandle, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
fhandle=ancestor(fhandle, 'figure');
set(fhandle, 'Pointer', 'watch');
target=findobj(gca, 'Tag', 'sigTOOL:SelectedData', 'Visible', 'on');

% Remove any pre-existing table
h=getappdata(target(1), 'Table');
if ishandle(h)
    delete(h);
end

xdata=get(target(1), 'XData')';
ViewStyle=getappdata(gca, 'sigTOOLViewStyle');

if isempty(ViewStyle) || strcmp(ViewStyle, '2D')
    % 2D View (or not set up in app data area!)
    ydata=get(target, 'YData')';
else
    % 3D
    ydata=get(target, 'ZData')';
end

% xdata & ydata maybe from patch objects or hggroups - use original data
% from sigTOOLResultData object
result=getappdata(fhandle, 'sigTOOLResultData');
idx=getappdata(gca, 'AxesSubscript');
data=result.data{idx(1),idx(2)};
minx=min(xdata);
maxx=max(xdata);
tdata=data.tdata(data.tdata>=minx & data.tdata<=maxx);
rdata=data.rdata(:,data.tdata>=minx & data.tdata<=maxx);

if size(ydata, 2)==1
    switch func2str(result.plotstyle{1})
        case 'scScatter'
            names={get(get(gca,'XLabel'),'String') get(get(gca,'YLabel'),'String')};
        case 'scBar'
            names={get(get(gca,'XLabel'),'String') get(get(gca,'YLabel'),'String')};
        otherwise
            names={get(get(gca,'XLabel'),'String') sprintf('Frame %d', get(target, 'UserData'))};
    end
    c=num2cell([tdata' rdata']);
else
    names{1}=get(get(gca,'XLabel'),'String');
    c=num2cell(tdata');
    ID=cell2mat(get(target, 'UserData'));
    for i=1:length(ID)
        % Take frame number from UserData (target handles should be in
        % order but let's check anyway)
        n=ID(i);
        if n==get(target(i), 'UserData');
            names{i+1}=sprintf('Frame %d', n); %#ok<AGROW>
            c=horzcat(c, num2cell(rdata(i,:)')); %#ok<AGROW>
        else
            error('Should never get here. n=%d , i=%d', n,i);
        end
    end
end

%h=uipanel(gcf,'Title', get(ancestor(target(1), 'figure'), 'Name'))
h=figure('MenuBar', 'none',...
    'NumberTitle', 'off',...
    'Name', ['Table:' get(ancestor(target(1), 'figure'), 'Name')]);
set(h, 'Units', 'normalized', 'Position', [0.7 0.1 0.2 0.75]);
% try
%     % DO NOT USE new uitable for now - no context sensitive menu so it can
%     % not be used for cut/paste
%     % R2008a onwards
%     % This returns a uitable
%     thandle=uitable(h, 'Data', c, 'ColumnName', names);
%     % Flush queue
%     drawnow();
% catch
% R2007b and earlier
% This returns an hgjavacomponent object
warning('off','MATLAB:uitable:OldTableUsage');
drawnow();%26.10.08 Flush queue
thandle=uitable(c, names);
warning('on', 'MATLAB:uitable:OldTableUsage');
% end
set(thandle, 'Units', 'normalized', 'Position',[0 0 1 1]);
setappdata(min(target), 'Table', h);
set(ancestor(fhandle, 'figure'), 'Pointer', 'arrow');
return
end
%--------------------------------------------------------------------------





