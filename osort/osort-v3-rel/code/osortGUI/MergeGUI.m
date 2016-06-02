%
% main file for graphical user interface for Osort
%
% initial version written by Matthew McKinley, Summer 2007.
% 
%
%


function varargout = MergeGUI(varargin)

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Merge_OpeningFcn, ...
    'gui_OutputFcn',  @Merge_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT
%% helper functions
function loadfile(dir,handles)

if (exist(dir)==0)
    error('load directory does not exist');
    return
end
global PATH
PATH = dir;

filenames = what(dir);
filenames = filenames.mat;
filenames = filenames';
load([PATH filenames{1}],'paramsUsed');

global THRESH
THRESH = num2str(paramsUsed(2));

index = strfind(dir,THRESH);
finaldir = [dir(1:(index-1)) 'final/'];
if exist(finaldir,'dir')
    filenames2 = what(finaldir);
    filenames2 = filenames2.mat;
    filenames2 = checkfinalnames(filenames2,finaldir);
    filenames = [filenames filenames2]';
end


for i=1:length(filenames)
    files{i}= getchannels(filenames{i},'on');
end

%sort files for display
files = files';
for i= 1 :length(files)
    tmpStr = files{i};
    if tmpStr(end) =='^' | tmpStr(end) == '*'
        tmpStr=tmpStr(1:end-1);
    end
    
    filesnum(i) = str2num(tmpStr);
end
[sortedfiles IX] = sort(filesnum);
files = files(IX);

global FULLNAMES
FULLNAMES = filenames(IX);

set(handles.channel,'Value',1)
set(handles.channel,'String',files);

clusters = load([dir filenames{1}],'useNegative');
clusters = clusters.useNegative;
for i=1:length(clusters)
    clust{i}= clusters(i);
end

set(handles.cluster,'Value',[])
set(handles.cluster,'String',clust);

%%
function channelnumber = getchannels(string, symbol)

channelnumber = [];
for i = 1:length(string);
    if isstrprop(string(i),'digit')
        channelnumber = [channelnumber string(i)];
    end
end

if strcmp(symbol,'on')
    if (isempty(findstr(string,'merged')) == 0)
        channelnumber = [channelnumber '^'];
    elseif (isempty(findstr(string,'selected')) == 0)
        channelnumber = [channelnumber '*'];
    end
end

%%
function files = checkfinalnames(filenames,finaldir)

global THRESH
files = {};
if isempty(filenames)
    return;
else
    load([finaldir filenames{1}],'paramsUsed');
    if paramsUsed(2)== str2num(THRESH);
        files = [filenames{1} checkfinalnames(filenames(2:end),finaldir)];
    else
        checkfinalnames(filenames(2:end),finaldir);
    end
end

%%
function items = getselected(handles, channelorcluster)

values = get(eval(['handles.' channelorcluster]),'Value');
string = get(eval(['handles.' channelorcluster]),'String');

for i = 1:length(values)
    items{i} = string{values(i)};
end

%%
function clusternum = stringtonum(cell,counter)

if (counter > length(cell))
    clusternum = cell2mat(cell);
else
    cell{counter} = str2num(cell{counter});
    counter = (counter + 1);
    clusternum = stringtonum(cell,counter);
end

%%
function openingbehavior(handles)

global FULLNAMES;
channel = getselected(handles, 'channel');

value = get(handles.channel,'Value');
if (isempty(strfind(FULLNAMES{value}, 'new'))==0)
    set(handles.key,'String','new channel')
elseif (isempty(strfind(FULLNAMES{value}, 'merged'))==0)
    set(handles.key,'String','^ indicates merged file')
elseif (isempty(strfind(FULLNAMES{value}, 'select'))==0)
    set(handles.key,'String','* indicates usable clusters defined')
end

%%
function altselect(handles)

global VALUES
recent = get(handles.cluster,'Value');

if isempty(intersect(VALUES,recent))
    VALUES = [VALUES recent];
else
    VALUES = setdiff(VALUES,recent);
end

set(handles.cluster,'Value',VALUES);
    
%% opening function and callbacks
function Merge_OpeningFcn(hObject, eventdata, handles, varargin)

global VALUES 
VALUES = 1;

global DEFAULTDIRECTORY;
if exist(DEFAULTDIRECTORY,'file')
    load(DEFAULTDIRECTORY);
    if exist('loadmerge','var')
        set(handles.load1,'String',loadmerge);
        loadfile(loadmerge,handles);
        openingbehavior(handles);
    end
end

handles.output = hObject;

guidata(hObject, handles);


%%
function varargout = Merge_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

%%
function cluster_Callback(hObject, eventdata, handles)
altselect(handles);

%%
function cluster_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function channel_Callback(hObject, eventdata, handles)
global FULLNAMES;
global PATH;
global THRESH;
global VALUES;
value = get(handles.channel,'Value');
if ~isempty(FULLNAMES)
    if isempty(strfind(FULLNAMES{value}, 'selected'))
        filename = [PATH FULLNAMES{value}];
    else
        index = strfind(PATH,THRESH);
        filename = [PATH(1:(index-1)) 'final' '\' FULLNAMES{value}];
    end

    clusters = load(filename,'useNegative');
    clusters = clusters.useNegative;

    for i=1:length(clusters)
        clust{i}= clusters(i);
    end

    set(handles.cluster,'Value',[]);
    set(handles.cluster,'String',clust);
    
    VALUES = 1;
    
    openingbehavior(handles);
end

%%
function channel_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%%
function merge_Callback(hObject, eventdata, handles)
global FULLNAMES;
global THRESH;
global PATH;

global DEFAULTDIRECTORY;
if exist(DEFAULTDIRECTORY,'file')
    loadmerge = get(handles.load1,'String');
    if iscell(loadmerge)
        loadmerge = loadmerge{1};
    end
    save(DEFAULTDIRECTORY, 'loadmerge','-append')
end

value = get(handles.channel,'Value');

if isempty(strfind(FULLNAMES{value}, 'selected'))
    filename = [PATH FULLNAMES{value}];
else
    index = strfind(THRESH,threshelper);
    filename = [PATH(1:(index-1)) 'final' '\' FULLNAMES{value}];
end

channel1 = FULLNAMES{value};
channel2 = getchannels(channel1,'off');

cluster = getselected(handles,'cluster');
cluster = stringtonum(cluster,1);

global FIGUREPATH
mergeClustersAutomatic(FIGUREPATH,cluster,channel1,channel2);

%%
function load_Callback(hObject, eventdata, handles)

file = get(handles.load1,'String');

if iscell(file)
    file = file{1};
end

loadfile(file,handles);

openingbehavior(handles);

global DEFAULTDIRECTORY;
if exist(DEFAULTDIRECTORY,'file')
    loadmerge = get(handles.load1,'String');
    save(DEFAULTDIRECTORY, 'loadmerge','-append')
end

%%
function load1_Callback(hObject, eventdata, handles)
dir = get(handles.load1,'String');

if iscell(dir)
    dir = dir{1};
end

if (strcmp(dir(end),'/')==0)&&(strcmp(dir(end),'\')==0)
    set(handles.load1,'String',[dir '/'])
end

%%
function load1_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


