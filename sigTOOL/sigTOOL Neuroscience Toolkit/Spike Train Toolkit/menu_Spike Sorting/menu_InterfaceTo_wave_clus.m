function varargout=menu_InterfaceTo_wave_clus(varargin)
% menu_InterfaceTo_wave_clus interface to the Wave_clus spike sorter
%
% Wave_clus is a package for unsupervised spike detection and sorting and
% is available from
% http://www.vis.caltech.edu/~rodri/Wave_clus/Wave_clus_home.htm
% It is not included in the sigTOOL distribution and needs to be downloaded
% separately.
%
% The algorithm is based on:
% R.Q.Quiroga, Z. Nadasdy & Y. Ben-Shaul(2004). Unsupervised spike detection
% and sorting with wavelets and superparamagnetic clustering,
% Neural Computation, 16, 1661-1687.
%
% The GUI for Wave_clus has been parasitized here to integrate it into 
% sigTOOL
%
% Toolboxes required: Signal Processing & Wavelet Toolboxes are needed
% together with the Statistics Toolbox if PCA is used.

% Revisions:
%   02.09 Support for Version 2 of Wave_clus included
%   22.01.10 Maintain units on output channels instead of using microseconds

% Setup menu for sigTOOL
if nargin==1 && varargin{1}==0
    if isempty(which('wave_clus'))
        varargout{1}=false;
    else
        varargout{1}=true;
    end
    varargout{2}='wave_clus';
    varargout{3}=[];
    return
end

% Main Routine
[button fhandle]=gcbo;

% Invoke Wave_clus
try
    h=findobj('Tag', 'wave_clus_figure');
    if isempty(h)
        bh=scProgressBar(0, 'sigTOOL is invoking Wave_clus',...
    'Name', 'Interface to Wave_clus', 'Progbar', 'off');
    h=wave_clus;
    LocalSetup(h, fhandle);
    delete(bh);
    else
        figure(h);
    end
catch %#ok<CTCH>
    rethrow(lasterror()); %#ok<LERR>
end

% Start up
sigTOOLParam.handle=fhandle;
sigTOOLParam.source=0;
sigTOOLParam.target=0;

% Wave_clus Version 2 support
b=findobj(h,'String', 'Plot polytrode');
if isempty(b)
    sigTOOLParam.WCVersion=1;
else
    sigTOOLParam.WCVersion=2;
    delete(b);
    delete(findobj(h,'String', 'Undo'));
end

% Update application data
setappdata(h, 'sigTOOLParam', sigTOOLParam);

% Tidy
delete(findobj(h, 'Type', 'hggroup'));
delete(findobj(h, 'Type', 'line'));

% Poplulate channel lists
PopulateChannelSelectors(h, fhandle)
return
end


%--------------------------------------------------------------------------
function SourceSelector(hObject, EventData) %#ok<INUSD,INUSL>
%--------------------------------------------------------------------------
handles=guidata(ancestor(hObject, 'figure'));
sigTOOLParam=getappdata(ancestor(hObject, 'figure'), 'sigTOOLParam');
idx=get(hObject, 'Value');
str=get(hObject, 'String');
idxt=findstr(str{idx},':');
if ~isempty(idxt)
    set(handles.file_name,'string',str{idx});
    thischan=str2num(str{idx}(1:idxt-1)); %#ok<ST2NM>
    sigTOOLParam.source=thischan;
else
    set(handles.file_name,'string','No channel selected');
    sigTOOLParam.source=0;
end
setappdata(ancestor(hObject, 'figure'), 'sigTOOLParam', sigTOOLParam);
handles.par.fnamespc='';
handles.par.fnamesave='';
guidata(ancestor(hObject, 'figure'), handles);
if isempty(idxt)
    return
end
channels=getappdata(sigTOOLParam.handle, 'channels');
if isempty(channels) || sigTOOLParam.source==0
    sr=NaN;
else
    sr=getSampleRate(channels{sigTOOLParam.source});
end

delete(findobj(handles.wave_clus_figure, 'Type', 'hggroup'));
delete(findobj(handles.wave_clus_figure, 'Type', 'line'));

USER_DATA=get(handles.wave_clus_figure,'userdata');
USER_DATA{1}=set_parameters_sigTOOL(sr,handles);
if size(channels{thischan}.adc,2)>1
    switch size(channels{thischan}.tim,2)
        case 1
            % Nothing to do
        case 2
            USER_DATA = get(handles.wave_clus_figure,'userdata');
            sr=getSampleRate(channels{thischan});
            USER_DATA{1}.sr=sr;
            USER_DATA{1}.w_pre=0;
            USER_DATA{1}.w_post=channels{thischan}.hdr.adc.Npoints(1);
            set(handles.wave_clus_figure,'userdata',USER_DATA);
        case 3
            USER_DATA = get(handles.wave_clus_figure,'userdata');
            sr=getSampleRate(channels{thischan});
            pre=findMaxPreTime(channels{thischan}, channels{thischan}.tim(:,2));
            post=findMaxPostTime(channels{thischan}, channels{thischan}.tim(:,2));
            USER_DATA{1}.w_pre=floor(pre*channels{thischan}.tim.Units/(1/sr));
            USER_DATA{1}.w_post=floor(post*channels{thischan}.tim.Units/(1/sr));
            USER_DATA{1}.sr=sr;
            set(handles.wave_clus_figure,'userdata',USER_DATA);
    end
end
set(handles.wave_clus_figure,'userdata',USER_DATA);
set(handles.file_name,'string','Parameters have been reset');drawnow();
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function TargetSelector(hObject, EventData) %#ok<INUSD,INUSL>
%--------------------------------------------------------------------------
handles=guidata(ancestor(hObject, 'figure'));
sigTOOLParam=getappdata(ancestor(hObject, 'figure'), 'sigTOOLParam');
idx=get(hObject, 'Value');
str=get(hObject, 'String');
idxt=findstr(str{idx},':');
if ~isempty(idxt)
    thischan=str2num(str{idx}(1:idxt-1)); %#ok<ST2NM>
    sigTOOLParam.target=thischan;
else
    set(handles.file_name,'string','No channel selected');
    sigTOOLParam.target=0;
end
setappdata(ancestor(hObject, 'figure'), 'sigTOOLParam', sigTOOLParam);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Run(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
% sigTOOL specific components
% Much of this code has been copied form the Wave_Clus package
DirectoryOnEntry=pwd;
try
    cd(tempdir());
    sigTOOLParam=getappdata(ancestor(hObject, 'figure'), 'sigTOOLParam');
    handles=guidata(ancestor(hObject, 'figure'));
    set(handles.file_name,'string','Initializing. Please wait ...');drawnow();
    if isempty(sigTOOLParam) || ~isfield(sigTOOLParam, 'source')...
            || sigTOOLParam.source==0
        set(handles.file_name,'string','No data');drawnow();
        return
    else
        fhandle=sigTOOLParam.handle;
        thischan=sigTOOLParam.source;
        channels=getappdata(fhandle, 'channels');
    end

    if size(channels{thischan}.adc,2)==1
        % Continuous waveform
        x.data=channels{thischan}.adc()';
        set(handles.file_name,'string',sprintf('Processing %g Msamples Please wait ...',...
            round(numel(x.data)/1e6)));drawnow();
        x.sr=getSampleRate(channels{thischan});
        set(handles.force_button, 'String', 'Force')
        USER_DATA=get(handles.wave_clus_figure,'userdata');
        handles.par=USER_DATA{1};
        set(handles.min_clus_edit,'string',num2str(handles.par.min_clus));
        set(handles.file_name,'string','Detecting spikes...');drawnow();
        [spikes,thr,index]=amp_detect_wc(x.data,handles);     %#ok<NASGU> % Detection with amp. thresh.
        set(handles.cont_data, 'YLim', [min(x.data) max(x.data)]);
    else
        % Framed waveform
        if size(channels{thischan}.tim,2)==3
            % Explicit trigger available
            index=channels{thischan}.tim(:,2)'*channels{thischan}.tim.Units*1e3;
            USER_DATA = get(handles.wave_clus_figure,'userdata');
            sr=getSampleRate(channels{thischan});
            pre=USER_DATA{1}.w_pre*(1/sr)/channels{thischan}.tim.Units;
            post=USER_DATA{1}.w_post*(1/sr)/channels{thischan}.tim.Units;
            spikes=extractPhysicalFrames(channels{thischan}, channels{thischan}.tim(:,2), pre+post, pre);
            USER_DATA{2} = spikes;
            USER_DATA{3} = index(:)';
            set(handles.wave_clus_figure,'userdata',USER_DATA);
        elseif size(channels{thischan}.tim,2)==2
            % No trigger
            spikes=channels{thischan}.adc()';
            index=channels{thischan}.tim(:,1)'*channels{thischan}.tim.Units*1e3;
            USER_DATA = get(handles.wave_clus_figure,'userdata');
            USER_DATA{2} = spikes;
            USER_DATA{3} = index(:)';
            set(handles.wave_clus_figure,'userdata',USER_DATA);
        end
        handles.par=USER_DATA{1};
        set(handles.min_clus_edit,'string',num2str(handles.par.min_clus));
        tb=zeros(size(spikes));
        tb(:,1)=index;
        tb=cumsum(tb,2);
        set(handles.cont_data, 'XLim', [0 index(end)]);
        for k=1:size(tb,1)
            line('XData', tb(k,:), 'YData', spikes(k,:),...
                'Parent', handles.cont_data,...
                'Color', 'blue');
        end
    end


    set(handles.file_name,'string','Extracting features....');
    drawnow();
    try
        [inspk]=wave_features_wc(spikes,handles);             % Extract spike features.
    catch %#ok<CTCH>
        errmsg2();%#ok<LERR> % Maybe no wavelet toolbox
    end
    set(handles.file_name,'string','Running SPC ...');drawnow();
    handles.par.fname_in='tmp_data';
    fname_in=handles.par.fname_in;
    save(fname_in,'inspk','-ascii');                      %Input file for SPC
    handles.par.fname=[handles.par.fname '_wc'];          %Output filename of SPC
    handles.par.fnamespc=handles.par.fname;
    handles.par.fnamesave=handles.par.fnamespc;
    warning('off', 'MATLAB:DELETE:Permission');
    [clu,tree]=run_cluster(handles);
    warning('on', 'MATLAB:DELETE:Permission');
    USER_DATA=get(handles.wave_clus_figure,'userdata');
    USER_DATA{4}=clu;
    USER_DATA{5}=tree;
    USER_DATA{7}=inspk;
    set(handles.wave_clus_figure,'userdata',USER_DATA);
    temp=find_temp(tree,handles);                                   %Selects temperature.
    temperature=handles.par.mintemp+temp*handles.par.tempstep;
    axes(handles.temperature_plot);
    switch handles.par.temp_plot
        case 'lin'
            plot([handles.par.mintemp handles.par.maxtemp-handles.par.tempstep], ...
                [handles.par.min_clus handles.par.min_clus],'k:',...
                handles.par.mintemp+(1:handles.par.num_temp)*handles.par.tempstep, ...
                tree(1:handles.par.num_temp,5:size(tree,2)),[temperature temperature],[1 tree(1,5)],'k:')
        case 'log'
            semilogy([handles.par.mintemp handles.par.maxtemp-handles.par.tempstep], ...
                [handles.par.min_clus handles.par.min_clus],'k:',...
                handles.par.mintemp+(1:handles.par.num_temp)*handles.par.tempstep, ...
                tree(1:handles.par.num_temp,5:size(tree,2)),[temperature temperature],[1 tree(1,5)],'k:')
    end
    xlim([0 handles.par.maxtemp])
    xlabel('Temperature');
    if strcmp(handles.par.temp_plot,'log')
        set(get(gca,'ylabel'),'vertical','Cap');
    else
        set(get(gca,'ylabel'),'vertical','Baseline');
    end
    ylabel('Clusters size');
    set(handles.file_name,'string',get(fhandle, 'Name'));
    if size(clu,2)-2 < size(spikes,1);
        classes=clu(temp,3:end)+1;
        classes=[classes(:)' zeros(1,size(spikes,1)-handles.par.max_spk)];
    else
        classes=clu(temp,3:end)+1;
    end
    guidata(hObject, handles);
    USER_DATA=get(handles.wave_clus_figure,'userdata');
    USER_DATA{6}=classes(:)';
    USER_DATA{8}=temp;
    USER_DATA{9}=classes(:)';                                     %backup for non-forced classes.
    set(handles.wave_clus_figure,'userdata',USER_DATA);
    handles.setclus=0;
    set(handles.file_name,'string','Plotting results ...');
    drawnow();
    cluster_sizes=zeros(1,USER_DATA{1}.max_clus);
    for i=1:USER_DATA{1}.max_clus
        cluster_sizes(i)=length(find(classes==i));
    end
    nclusters=length(find(cluster_sizes(:) >= USER_DATA{1}.min_clus));
    
    if sigTOOLParam.WCVersion>1
% definition of clustering_results
    clustering_results(:,1) = repmat(temp,length(classes),1); % GUI temperatures
    clustering_results(:,2) = classes'; % GUI classes 
    clustering_results(:,3) = repmat(temp,length(classes),1); % original temperatures 
    clustering_results(:,4) = classes'; % original classes 
    clustering_results(:,5) = repmat(handles.par.min_clus,length(classes),1); % minimum number of clusters
    clustering_results_bk = clustering_results; % old clusters for undo actions
    USER_DATA{10} = clustering_results;
    USER_DATA{11} = clustering_results_bk;
    handles.merge = 0;
    handles.reject = 0;
    handles.undo = 0;
    handles.minclus = handles.par.min_clus;
    handles.setclus = 0;
    set(handles.wave_clus_figure,'userdata',USER_DATA);
    end

    if sum(nclusters>0)
        try
        plot_spikes(handles);
        catch
            m=lasterror();
            if strcmpi(m.identifier, 'MATLAB:nonExistentField')
                fprintf('\n\nError: Maximum number of clusters probably set above permitted maximum.\nMATLAB message:\n');
                rethrow(lasterror);
            end
        end
        set(handles.file_name,'string','Done.');drawnow();
    else
        set(handles.file_name,'string','No clusters found.');drawnow();
    end

    USER_DATA = get(handles.wave_clus_figure,'userdata');
    clustering_results = USER_DATA{10};
    
    if sigTOOLParam.WCVersion>1
        mark_clusters_temperature_diagram(handles,tree,clustering_results);
    end

    set(handles.force_button, 'string', 'Force');
    cd(DirectoryOnEntry);
catch %#ok<CTCH>
    cd(DirectoryOnEntry);
    rethrow(lasterror()); %#ok<LERR>
end
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function Export(hObject, EventData, fhandle) %#ok<INUSL>
%--------------------------------------------------------------------------
data=CreateChannel(fhandle, hObject);
channels=getappdata(fhandle, 'channels');
sigTOOLParam=getappdata(ancestor(hObject, 'figure'), 'sigTOOLParam');
if ~isfield(sigTOOLParam, 'target') || sigTOOLParam.target==0
    thistarget=length(channels)+1;
else
    thistarget=sigTOOLParam.target;
end
channels{thistarget}=scchannel(data);
setappdata(fhandle, 'channels', channels);
% Refresh the channel manager
scChannelManager(fhandle, true);
% Include the new channel in the display
scDataViewDrawChannelList(fhandle,...
    unique([getappdata(fhandle, 'ChannelList') thistarget]));
% Refresh menus
PopulateChannelSelectors(ancestor(hObject, 'figure'), fhandle);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function par=set_parameters_sigTOOL(sr,handles)
%--------------------------------------------------------------------------
% set_parameters_sigTOOL: This sets a slightly modified version of
% set_parameters_simulation settings as the default for sigTOOL
% SPC PARAMETERS
par=set_parameters_simulation(sr ,'sigTOOL', handles);
if isnan(sr)
    par.w_pre=16;
    par.w_post=32;
else
    par.w_pre=round(0.001/(1/sr));
    par.w_post=round(0.002/(1/sr));
end
par.detect_fmax=min(sr*0.4,3000);              %low pass filter for detection
par.sort_fmax=min(sr*0.4,3000);                %low pass filter for sorting
par.detection='neg';               % type of threshold
par.stdmin = 4.0;                    % minimum threshold for detection
par.stdmax = Inf;                     % maximum threshold for detection
USER_DATA{1}=par;
set(handles.wave_clus_figure,'userdata',USER_DATA);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function EditParameters(hObject, EventData) %#ok<INUSD>
%--------------------------------------------------------------------------
USER_DATA=get(ancestor(hObject, 'figure'),'UserData');
try
    [USER_DATA{1} changeflag]=EditStructureGUI(USER_DATA{1}, ancestor(hObject, 'figure'));
catch
    % No data loaded yet - 
    return
end
if changeflag
    set(ancestor(hObject, 'figure'),'UserData',USER_DATA);
    handles=guidata(ancestor(hObject, 'figure'));
    delete(findobj(handles.wave_clus_figure, 'Type', 'hggroup'));
    delete(findobj(handles.wave_clus_figure, 'Type', 'line'));
    set(handles.file_name,'string','Using edited parameters');drawnow();
end
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function data=CreateChannel(fhandle, hObject)
%--------------------------------------------------------------------------
handles=guidata(ancestor(hObject, 'figure'));
USER_DATA=get(handles.wave_clus_figure,'userdata');
spikes=USER_DATA{2};
par=USER_DATA{1};
classes=USER_DATA{6};

% Classes should be consecutive numbers
i=1;
while i<=max(classes)
    if isempty(classes(find(classes==i))) %#ok<FNDSB>
        for k=i+1:max(classes)
            classes(find(classes==k))=k-1; %#ok<FNDSB>
        end
    else
        i=i+1;
    end
end
cluster_class=zeros(size(spikes,1),2);
cluster_class(:,1)=classes(:);
cluster_class(:,2)=USER_DATA{3}';
channels=getappdata(fhandle, 'channels');
sigTOOLParam=getappdata(ancestor(hObject, 'figure'), 'sigTOOLParam');
thischan=sigTOOLParam.source;
data.hdr=channels{thischan}.hdr;

tim=zeros(size(cluster_class,1),3);
tim(:,1)=cluster_class(:,2)*1e-3-(par.w_pre*(1/par.sr));
tim(:,2)=cluster_class(:,2)*1e-3;
tim(:,3)=cluster_class(:,2)*1e-3+((par.w_post-1)*(1/par.sr));

% 22.01.10 Maintain units instead of using microseconds
tim=tim/channels{thischan}.tim.Units;
data.tim=tstamp(tim,...
    1,...
    0,...
    [],...
    channels{thischan}.tim.Units,...
    false);
data.hdr.tim.TargetClass='tstamp';
data.hdr.tim.Scale=1;
data.hdr.tim.Shift=0;
data.hdr.tim.Func=[];
data.hdr.tim.Units=channels{thischan}.tim.Units;

data.mrk=cluster_class(:,1);

data.adc=adcarray(spikes',...
    1,...
    0,...
    [],...
    '',...
    {'Time' 'Spike'},...
    false);

data.hdr.channeltype='Framed Waveform (Spike)';
data.hdr.channeltypeFcn='';

data.hdr.adc.Labels={'Time' 'Spike'};
data.hdr.adc.TargetClass='adcarray';
data.hdr.adc.SampleInterval=[(1/par.sr)*(1/channels{thischan}.tim.Units) channels{thischan}.tim.Units];
data.hdr.adc.Scale=1;
data.hdr.adc.DC=0;
data.hdr.adc.YLim=[double(min(data.adc(:)))*data.hdr.adc.Scale+data.hdr.adc.DC...
    double(max(data.adc(:)))*data.hdr.adc.Scale+data.hdr.adc.DC];
data.hdr.adc.Func=[];
data.hdr.adc.Units='';
data.hdr.adc.Npoints(1:size(data.adc,2))=par.w_pre+par.w_post;
data.hdr.adc.Multiplex=1;
data.hdr.adc.MultiInterval=[0 0];
return
end
%--------------------------------------------------------------------------


%--------------------------------------------------------------------------
function [s changeflag]=EditStructureGUI(s, figh)
%--------------------------------------------------------------------------
names={'stdmin',...
    'stdmax',...
    'detection',...
    'w_pre',...
    'w_post',...
    'interpolation',...
    'int_factor',...
    'ref',...
    'detect_fmin',...
    'detect_fmax',....
    'sort_fmin',...
    'sort_fmax',...
    'inputs',...
    'scales',...
    'features',...
    'min_clus',...
    'mintemp',...
    'tempstep',...
    'maxtemp',...
    'match',...
    'max_spk',...
    'max_clus'};

st=jvPanel('Title', 'Edit Parameters',...
    'Position', [0.25 0.3 0.55 0.55],...
    'AckText', 'sigTOOL interface to Wave Clus');

n=length(names);
rows=5;
columns=ceil(n/5);

Top=0.8;
Left=0.01;

count=0;
for r=1:rows
    for c=1:columns
        count=count+1;
        if count>length(names)
            break
        end
        val=s.(names{count});
        if isnumeric(val)
            val=num2str(val);
        end
        st=jvElement(st, 'Component', 'javax.swing.JTextField',...
            'Label', names{count} ,...
            'Position', [Left+((r-1)*0.2) Top-((c-1)*0.15) 0.15 0.1],...
            'DisplayList', val);
    end
end

h=jvDisplay(figh, st);
set(h{1}.ApplyToAll, 'Visible', 'off');
uiwait();
st2=getappdata(figh,'sigTOOLjvvalues');
if isempty(st2)
    changeflag=false;
else
    changeflag=true;
    for i=1:length(names)
        val=st2.(names{i});
        if isnumeric(s.(names{i}))
            val=str2num(val); %#ok<ST2NM>
        end
        s.(names{i})=val;
    end
end

return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function LocalSetup(h, fhandle)
%--------------------------------------------------------------------------
handles=guidata(h);
delete(findobj(h, 'Type', 'hggroup'));
delete(findobj(h, 'Type', 'line'));
sigTOOLParam.handle=fhandle;
sigTOOLParam.source=0;
setappdata(h, 'sigTOOLParam', sigTOOLParam);

% Source selector
set(handles.data_type_popupmenu,'Value',1);
if ~isempty(handles.text2)
    set(handles.text2, 'String', 'Source:');
    pos=get(handles.data_type_popupmenu, 'Position');
    pos(1)=0.01;
    pos(2)=pos(2)+pos(4);
    pos(4)=pos(4)/2;
    set(handles.text2, 'Position', pos,...
        'BackgroundColor', [0.92549 0.92549 0.85098]);
end
pos=get(handles.data_type_popupmenu,'Position');
pos(1)=0.01;
set(handles.data_type_popupmenu,'Position',pos);
set(handles.data_type_popupmenu, 'Callback', @SourceSelector);

% Target selector
pos(1)=pos(1)+pos(3)+0.01;
handles.sigtool.targetchannel=copyobj(handles.data_type_popupmenu, h);
set(handles.sigtool.targetchannel, 'Position', pos,...
    'String', {''});
handles.sigtool.text1=copyobj(handles.text2, h);
pos(2)=pos(2)+pos(4);
pos(4)=pos(4)/2;
set(handles.sigtool.text1, 'Position', pos, 'String', 'Target');
set(handles.sigtool.targetchannel, 'Callback', @TargetSelector);


pos=get(handles.load_data_button,'Position');
pos(2)=pos(2)-pos(4)*1.25;
set(handles.load_data_button, 'Position', pos,...
    'Callback', @Run,...
    'String', 'Run');
set(handles.save_clusters_button, 'String', 'Export Clusters');
set(handles.save_clusters_button, 'Callback', {@Export, fhandle});
set(handles.set_parameters_button, 'String', 'Edit Parameters');
set(handles.set_parameters_button, 'Callback', {@EditParameters});
set(handles.text11,'Style', 'pushbutton',...
    'Callback', 'web(''www.vis.caltech.edu/~rodri/Wave_clus/Wave_clus_home.htm'',''-browser'')',...
    'TooltipString', 'Click for Wave-clus website',...
    'FontSize',16);

th=findobj(h, 'Style', 'text');
th=[th;findobj('Style', 'radiobutton')];
set(th, 'BackgroundColor', [0.92549 0.92549 0.85098]);
set(handles.file_name, 'BackgroundColor', [0.9 0.9 0.9],...
    'ForegroundColor', 'blue',...
    'String', 'No channel selected');
pos=get(handles.file_name, 'Position');
pos(2)=pos(2)+1.5*pos(4);
%set(h, 'Units', 'normalized');

if isempty(findobj(2, 'Tag', 'AckText'))
    uicontrol('Parent', h,...
        'Style', 'text',...
        'String','www.vis.caltech.edu/~rodri/Wave_clus/Wave_clus_home.htm',...
        'ForegroundColor', 'blue',...
        'BackgroundColor', [0.92549 0.92549 0.85098],...
        'Units', 'normalized',...
        'Position', pos,...
        'Tag', 'AxkText');
end
handles.datatype='sigTOOL';
guidata(h, handles);
return
end
%--------------------------------------------------------------------------

%--------------------------------------------------------------------------
function PopulateChannelSelectors(h, fhandle)
%--------------------------------------------------------------------------
handles=guidata(h);
channels=getappdata(fhandle, 'channels');
set(handles.data_type_popupmenu,'Value',1);
str{1}='None';
list=scGetChannelsByType(fhandle, 'Waveform');
for i=1:length(list)
    str{i+1}=sprintf('%d: %s', list(i), channels{list(i)}.hdr.title); %#ok<AGROW>
end
set(handles.data_type_popupmenu, 'String', str);
str{1}='None';
set(handles.sigtool.targetchannel, 'String', {});
list=scGetChannelsByType(fhandle, 'Empty');
for i=1:length(list)
    str{i+1}=sprintf('%d: <Unused>', list(i)); %#ok<AGROW>
end
set(handles.sigtool.targetchannel, 'String', str);

% Update data areas
guidata(h, handles);
USER_DATA=get(h,'userdata');
USER_DATA{1}=[];%set_parameters_sigTOOL(NaN, handles);
set(h,'userdata',USER_DATA);
return
end
%--------------------------------------------------------------------------
        
%--------------------------------------------------------------------------
function errmsg2()
%--------------------------------------------------------------------------
str=which('wavedec');
if isempty(str)
    str=sprintf('sigTOOL could not find a copy of MATLAB Wavelet toolbox');
    questdlg(str, 'Installation required', 'ok', 'ok');
else
    error(lasterror()); %#ok<LERR>
end
end
%--------------------------------------------------------------------------


