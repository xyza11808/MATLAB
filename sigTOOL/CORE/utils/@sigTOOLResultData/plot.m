function [rhandle viewobj]=plot(varargin)
% plot method overloaded for sigTOOLResultData objects
%
% Example
% h=plot(data)
%   create a new sigTOOLResultView figure
% h=plot(figurehandle, result)
%   refreshes an existing sigTOOLResultView figure using the result object
%   in result
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

% Revisions:
% 30.08.09 Include support for standard MATLAB pan and zoom controls
% 08.09.09 Suppress errors when datasource view has been closed
% 10.09.09 Move scProgressBar call to ensure association of bar with
%           correct figure
% 27.09.09 Add LocalSave
% 02.01.10 Options field in result objects now supports:
%             function handles
%             cell arrays (with a function handle in the 1st element
%             uicontextmenus as before - now obsolete but still supported


if nargin==2
    progbar=scProgressBar(0, '<HTML><CENTER>Plotting data<P> Please wait...</P></CENTER></HTML>',...
    'Name', 'sigTOOL', 'Progbar', false);
    rhandle=varargin{1};
    viewobj=getappdata(rhandle, 'sigTOOLResultView');
    LocalPlot(rhandle, varargin{2});
    LocalSetupCallbacks(rhandle, varargin{2});
    setappdata(rhandle, 'sigTOOLResultData', varargin{2});
    close(progbar);
    return
end

% Set up a figure window
resultobj=varargin{1};
sourcepath=scGetBaseFolder();
rhandle=dir2menu(fullfile(sourcepath, 'CORE', 'utils', 'ResultView', 'menu'));
% Paper setup
orient(rhandle, 'landscape');

% 10.09.09 Moved code
progbar=scProgressBar(0, '<HTML><CENTER>Plotting data<P> Please wait...</P></CENTER></HTML>',...
    'Name', 'sigTOOL', 'Progbar', false);

set(rhandle,'Color',[1 1 1]);
if ~strcmp(func2str(resultobj.plotstyle{1}),'plot')
    % Standard context menu if standard result
    h=dir2menu(fullfile(sourcepath, 'program',  'UiContextMenus',...
        'ResultFigure'),'uicontextmenu');
    if ~isempty(h)
        set(rhandle,'uicontextmenu',h);
    end
end
% Add data and draw it
setappdata(rhandle,'sigTOOLResultData',resultobj);
viewobj=CreateResultView(rhandle, resultobj);

LocalSetupCallbacks(rhandle, resultobj);

% Store figure handle for deletion
% 09.11.09 Updated
if ~isempty(resultobj.datasource) && ishandle(resultobj.datasource) &&...
    strcmp(resultobj.datasourcetitle, get(resultobj.datasource, 'Name'))==1
        list=getappdata(resultobj.datasource, 'sigTOOLResultViewList');
        list=[list rhandle];
        setappdata(resultobj.datasource, 'sigTOOLResultViewList', list);
end

tp=getappdata(rhandle,'ResultManager');
if ~isempty(tp)
    h=findobj(rhandle,'Tag','Colorbar');
    if isempty(h)
        tp.Options3D.colorbar.setSelected(0);
    else
        tp.Options3D.colorbar.setSelected(1);
    end
end

% 30.08.09 Integrate MATLAB pam/zoom etc controls
if ~scverLessThan('MATLAB', '7.3')
    h=pan(rhandle);
    set(h, 'ActionPostCallback', @LocalAxesControl);
    h=zoom(rhandle);
    set(h, 'ActionPostCallback', @LocalAxesControl);
end

close(progbar);
return
end

%--------------------------------------------------------------------------
function LocalSetupCallbacks(rhandle, resultobj)
%--------------------------------------------------------------------------
sourcepath=scGetBaseFolder();

if ~strcmp(func2str(resultobj.plotstyle{1}),'plot')
    % Set up uicontextmenus for standard result structure
    h=dir2menu(fullfile(sourcepath, 'program', 'UiContextMenus',...
        'ResultAxes'),'uicontextmenu');
    ez=findobj(h, 'Label', 'EzyFit Curve Fitting');
    if ~isempty(ez)
        set(ez, 'Separator', 'on');
    end
    % Add options menu
    options=uimenu(h, 'Label', 'Options');
    
    % 02.01.10
    if isa(resultobj.options, 'function_handle')
        % Function handle
        op=resultobj.options();
    elseif iscell(resultobj.options)
        % Function handle in first cell element. Arguments in the rest
        op=resultobj.options{1}(resultobj.options{2:end});
    else
        % Obsolete from v0.93: typically a uicontextmenu
        op=resultobj.options;
    end
    
    h2=findobj(op, 'Label', 'Add Plot');
    h2=[h2 findobj(op, 'Label', 'Fit Distribution')];
    if ~isempty(h2)
        if isempty(findobj(h, 'Label', 'Remove Added Plots'))
            uimenu(h, 'Label', 'Remove Added Plots',...
                'Callback', @RemoveAddedPlots);
        end
    end
    if ~isempty(op)
        % Populate it
        %uimenu(resultobj.options, 'Label', 'Remove Added Plots', 'Callback', @RemoveAddedPlots);
        copyobj(get(op, 'Children'), options);
    else
        % Disable it if no callbacks
        set(options, 'Enable', 'off');
    end
else
    % Object so use custom uicontextmenu
    % 02.01.10
    if isa(resultobj.options, 'function_handle')
        % Function handle
        op=resultobj.options();
    elseif iscell(resultobj.options)
        % Function handle in first cell element. Arguments in the rest
        op=resultobj.options{1}(resultobj.options{2:end});
    else
        % Obsolete from v0.93: typically a uicontextmenu
        op=resultobj.options;
    end
    % Add options menu
    
    if ~isempty(op)
        h=uicontextmenu();
        copyobj(get(op, 'Children'), h);
        set(rhandle, 'UiContextMenu', h);
    end
end

% Add to axes
AxesList=getappdata(rhandle,'AxesList');
AxesList=AxesList(AxesList~=0);
AxesList=AxesList(:);
for i=1:length(AxesList)
    thismenu=copyobj(h, get(h, 'Parent'));
    set(findall(thismenu), 'UserData', AxesList(i));
    set(AxesList(i),'UiContextMenu', thismenu);
end
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function obj=CreateResultView(rhandle, result)
%--------------------------------------------------------------------------
if ischar(result.datasourcetitle)
    set(rhandle, 'Name', ['[' num2str(rhandle) '] ' result.title ':' result.datasourcetitle]);
else
    set(rhandle, 'Name', ['[' num2str(rhandle) '] ' result.title]);
end
set(rhandle, 'NumberTitle', 'off');
set(rhandle, 'Tag', 'sigTOOL:ResultView');
LocalPlot(rhandle, result);
% Figure controls
MaxTime=Inf;
for i=2:size(result.data,1)
    for j=2:size(result.data,2)
        if ~isobject(result.data{i,j}) && ~isempty(result.data{i,j})...
                && ~isempty(result.data{i,j}.tdata)
            MaxTime=min([MaxTime max(result.data{i,j}.tdata)]);
        end
    end
end
if ~strcmp(func2str(result.plotstyle{1}),'plot')
    scCreateFigControls(rhandle, MaxTime);
end
opt.displaymode=result.displaymode;
setappdata(rhandle, 'sigTOOLResultOptions', opt);
scResultManager(rhandle);
scUpdateResultOptionsButton(rhandle, result.plotstyle{1});
logo(rhandle);
set(rhandle, 'WindowButtonDownFcn', @scWindowButtonDownFcn);
set(rhandle, 'KeyPressFcn', @scWindowKeyPressFcn);
% Result View menu - change some callbacks
MenuSetupResultView(rhandle);
% Return as a sigTOOL result object
obj=sigTOOLResultView(rhandle);
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function LocalPlot(rhandle, result)
%--------------------------------------------------------------------------
frows=size(result.data,1);
fcols=size(result.data,2);

AxesPanel=findobj(rhandle, 'Tag', 'sigTOOL:AxesPanel');
if isempty(AxesPanel)
    % New view
    AxesList=AxesSetup(rhandle, result, frows, fcols);
else
    % Existing view
    AxesList=getappdata(rhandle, 'AxesList');
end

% If we are invoking plot, must be a custom object so create the parent
% uipanels
if strcmp(func2str(result.plotstyle{1}),'plot')
for i=2:frows
    for j=2:fcols
        if AxesList(i,j)~=0 && strcmpi(get(AxesList(i,j), 'Type'), 'axes')
        pos=get(AxesList(i,j), 'OuterPosition');
        par=get(AxesList(i,j), 'Parent');
        delete(AxesList(i,j));
        AxesList(i,j)=uipanel('Position', pos, 'Parent', par);
        end
    end
end
setappdata(rhandle, 'AxesList', AxesList);
end

for i=2:frows
    for j=2:fcols
        if isempty(result.data{i,j})
            continue
        end
        ax=AxesList(i,j);
        reset(ax);
        
        %Plot the data
        set(rhandle, 'Pointer', 'watch');
        result.plotstyle{1}(ax, result.data{i,j});
        setappdata(ax,'AxesSubscript',[i,j]);
        setappdata(ax,'ChannelNumbers',...
            [str2double(result.data{i,1}) str2double(result.data{1,j})]);
        %scSetResultAxesLimits(ax);
        set(rhandle, 'Pointer', 'arrow');
    end
end

% Tidy the axes
for i=2:frows
    for j=2:fcols
        if ~isempty(result.data{i,j}) && ~isobject(result.data{i,j})
            % Labels, axes options etc
            ax=AxesList(i,j);
            str=sprintf('%s => %s',result.data{i,1}, result.data{1,j});
            set(ax,...
                'Tag', sprintf('ResultAxes(%s)',str),...
                'Units', 'character',...
                'LineWidth', 1.5);
            XLim=get(ax, 'XLim');
            YLim=get(ax, 'YLim');
            ZLim=get(ax, 'ZLim');
            ht=title(ax, str,...
                'Margin', 1,...
                'EdgeColor', [0 0 0],...
                'FontSize', 7,...
                'Position', [XLim(2)*0.75 YLim(2) max(ZLim)],...
                'HorizontalAlignment', 'left',...
                'VerticalAlignment', 'bottom');
            set(ht, 'Units', 'normalized');
            set(ax, 'Units', 'normalized');
            
            % Force 2D display if requested
            if strcmp(getappdata(rhandle, 'sigTOOLViewStyle'), '2D')
                view(ax, 2);
            end
            
            % Axis directions
            if isfield(result.data{i,j}, 'tdir')
                set(ax, 'XDir', result.data{i,j}.tdir);
            end
            if isfield(result.data{i,j}, 'rdir')
                switch getappdata(rhandle, 'sigTOOLViewStyle')%result.viewstyle
                    case '2D'
                        set(ax, 'YDir', result.data{i,j}.rdir);
                    case '3D'
                        set(ax, 'ZDir', result.data{i,j}.rdir);
                end           
            end
            if isfield(result.data{i,j}, 'odir')
                set(ax, 'YDir', result.data{i,j}.odir);
            end

            % Axes labels
            style=getappdata(rhandle, 'sigTOOLViewStyle');
            switch style
                case {'', '2D'}
                    xlabel(ax, result.data{i,j}.tlabel);
                    ylabel(ax, result.data{i,j}.rlabel);
                case '3D'
                    xlabel(ax, result.data{i,j}.tlabel);
                    zlabel(ax, result.data{i,j}.rlabel);
                    if isfield(result.data{i,j}, 'olabel')
                        ylabel(ax, result.data{i,j}.olabel);
                    end
                case '3D Bar'
                    zlabel(ax, result.data{i,j}.rlabel);
                    if isfield(result.data{i,j}, 'tlabel')
                        ylabel(ax, result.data{i,j}.tlabel);
                    end
                case 'pseudo3D'
                    xlabel(ax, result.data{i,j}.tlabel);
                    if isfield(result.data{i,j}, 'olabel')
                        ylabel(ax, result.data{i,j}.olabel);
                    end
                    set(ht, 'Position',[0.9 0.9],...
                        'Color', [1 1 1],...
                        'EdgeColor', [1 1 1]);
            end

            % Mouse click menu
            %set(ax,'uicontextmenu',get(rhandle,'uicontextmenu'));
            
            switch func2str(result.plotstyle{1})
                % May need to alter some defaults
                case 'scBar'
                    axis('tight');
                    YLim=get(ax,'YLim');
                    YLim(2)=YLim(2)+0.01*YLim(2);
                    set(ax, 'YLim', YLim);
                case {'scImagesc' 'scScatter'}
                    % DO nothing
                otherwise
                    axis(AxesList(AxesList>0), 'tight');
            end
        end
    end
end


if  ~isobject(result.data{i,j})
    set(AxesList(AxesList>0), 'YLimMode', 'manual');
else
    set(AxesList(AxesList>0), 'Tag', 'sigTOOL:CustomResultPanel',...
        'BackgroundColor', 'w');
end


scUpdateResultOptionsButton(rhandle, result.plotstyle{1})


return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function [AxesList, AxesPanel]=AxesSetup(rhandle, result, frows, fcols)
%--------------------------------------------------------------------------
% Get non-zero entry count
s=sum(sum(~cellfun(@isempty, result.data(2:end,2:end))));
% How are the data represented
a=frows-1;
b=fcols-1;
if s==a && s==b
    % Only the diagonal being used
    axrows=ceil(sqrt(s));
    if axrows==s
        axcols=1;
    else
        axcols=round(s/sqrt(s));
    end
    diag=1;
elseif s==(a*b)/2-sqrt(a*b)/2
    % The diagonal is empty
    axrows=ceil(sqrt(s));
    axcols=round(s/sqrt(s));
    diag=1;
else
    % Create space for all entries (empty or not)
    axrows=ceil(sqrt(a*b));
    axcols=floor(sqrt(a*b));
    if axrows*axcols<s
        axcols=ceil(sqrt(a*b));
    end
    % Alternatively do not allocate space for empty entries but this can
    % give inappropriate aspect ratios for some objects
    %     count=0;
    %     for k=1:a
    %         for m=1:b
    %             if ~isempty(result.data{k,m})
    %                 count=count+1;
    %             end
    %         end
    %     end
    %     axcols=ceil(sqrt(count));
    %     axrows=floor(sqrt(count));

    diag=0;
end

% Set up the axes
AxesList=zeros(frows,fcols);
AxesPanel=uipanel(rhandle, 'Position',[0.15 0 0.85 1],...
    'Background', 'w',...
    'BorderType', 'line',...
    'BorderWidth', 2,...
    'ForegroundColor', [64 64 122]/255,...
    'HighlightColor', [64 64 122]/255,...
    'Tag', 'sigTOOL:AxesPanel');
set(AxesPanel, 'Units', 'pixels');
pos=get(AxesPanel,'Position');
pos(2)=pos(2)+60;
pos(4)=pos(4)-60;
set(AxesPanel, 'Position', pos);
set(AxesPanel, 'Units', 'normalized');
set(AxesPanel, 'uicontextmenu', get(rhandle, 'uicontextmenu'));

thisplot=0;
for i=2:frows
    for j=2:fcols
        if ~isempty(result.data{i,j});
            % For each result...
            if diag>0
                thisplot=diag;
                diag=diag+1;
            else
                thisplot=thisplot+1;
            end
            % Find the axes
            AxesList(i,j)=subplot(axrows,axcols,thisplot, 'Parent', AxesPanel);
        end
    end
end
setappdata(rhandle,'AxesList',AxesList)
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function MenuSetupResultView(rhandle)
%--------------------------------------------------------------------------
% Replace standard MATLAB figure callbacks
h=findall(rhandle,'Label','&Print...');
set(h, 'Callback', 'print(getappdata(gcf, ''sigTOOLResultView''))');
h=findall(rhandle,'Label','Print Pre&view...');
set(h, 'Callback', 'printpreview(getappdata(gcf, ''sigTOOLResultView''))');
h=findall(rhandle,'Tag','figMenuFileSaveAs');
set(h, 'Callback', sprintf('scExportFigure(%d)', rhandle));
h=findall(rhandle,'Tag','figMenuFileSave');
set(h, 'Callback', {@LocalSave, getappdata(rhandle, 'sigTOOLResultData')});
h=findall(rhandle,'Label','&Open...');
set(h, 'Callback', @LocalOpen);
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function logo(h)
%--------------------------------------------------------------------------
scInsertLogo(h)
return
end
%--------------------------------------------------------------------------



% CALLBACKS

%--------------------------------------------------------------------------
function RemoveAddedPlots(hObject, EventData)
%--------------------------------------------------------------------------
ax=get(hObject, 'UserData');
h=findall(get(ax, 'Parent'), 'Tag', 'sigTOOL:AddedPlotAxes',...
    'Position', get(ax, 'Position'));
delete(h);
h=findall(ancestor(hObject, 'figure'), 'Tag', 'sigTOOL:Annotation');
delete(h);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function LocalAxesControl(hObject, EventData)
%--------------------------------------------------------------------------
scRefreshResultManagerAxesLimits(ancestor(hObject, 'figure'));
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function LocalSave(hObject, EventData, obj) %#ok<INUSL>
%--------------------------------------------------------------------------
% Save a structure, not the object, for improved portability
% To restore a figure:
% [1] Load the structure from file
% [2] Re-create an object by passing it to the sigTOOLResultData
%       constructor
% [3] Plot it
obj.datasource=[];
sigTOOLResultStructure=struct(obj); %#ok<NASGU>
[a b]=fileparts(obj.datasourcetitle);
[fname,pname] = uiputfile('*.mat', 'Save sigTOOL Result', sprintf('%s.mat',b));
save(fullfile(pname, fname),'sigTOOLResultStructure');
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function LocalOpen(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
[fname,pname] = uigetfile('*.mat', 'Open sigTOOL Result');
if ischar(fname)
    load(fullfile(pname, fname));
    if exist('sigTOOLResultStructure')==1
        obj=sigTOOLResultData(sigTOOLResultStructure);
        plot(obj);
    else
        errordlg('No data, the MAT-file may not contain a sigTOOL result',...
            'sigTOOL Open');
    end
end
return
end
%--------------------------------------------------------------------------
