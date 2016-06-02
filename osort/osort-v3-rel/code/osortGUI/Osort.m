%
% main file for graphical user interface for Osort
%
% initial version written by Matthew McKinley, Summer 2007.
% 
%
%


%% initialize GUI

function varargout = GUI(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @GUI_OpeningFcn, ...
    'gui_OutputFcn',  @GUI_OutputFcn, ...
    'gui_LayoutFcn',  [], ...
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

%% helper functions to be used later in the code
function setfieldvalues(tags,handles)
for i = 1:length(tags)
    str1 = eval(['handles.' tags{i,1}]);
    str2 = tags{i,2};
    if strcmp(get(str1,'Style'),'edit')
        
        if ~ischar(str2)
           str2=num2str(str2); 
        end
        
        if size(str2,1)~=1
            str2=str2';
        end
        set(str1,'String',str2)
        
        
    else
        set(str1,'Value',str2)
    end
end

function tags = getfieldvalues(tags,handles)
for i = 1:length(tags)
    str1 = eval(['handles.' tags{i,1}]);
    str2 = get(str1,'String');
    str3 = get(str1,'Value');                                                                                                                                                                                                                                                                                                                                               
    
    if strcmp(get(str1,'Style'),'edit')
        tags{i,2} = str2;
    else
        tags{i,2} = str3;
    end
end

function savedirectories(handles,dir)

if exist(dir,'file')
    savdir = get(handles.saveparams,'String');
    if iscell(savdir);
        savdir = savdir{1};
    end
    loaddir = get(handles.loadparams,'String');
    if iscell(loaddir);
        loaddir = loaddir{1};
    end
    save(dir, 'savdir', 'loaddir', '-append');
end

function loaddirectories(handles)

global DEFAULTDIRECTORY;

if exist(DEFAULTDIRECTORY,'file')
    load(DEFAULTDIRECTORY);
    if exist('loaddir','var')&&exist('savdir','var')
        set(handles.saveparams,'String',savdir);
        set(handles.loadparams,'String',loaddir);
    end
end

function [paths, paramsIn, dp, filesToProcess, groundChannels, extractionThreshold] = assignparameters(tags)

paths = [];

paths.pathOut = tags{1,2};
paths.pathRaw = tags{2,2};
paths.pathFigs = tags{3,2};
paths.patientID = tags{4,2};
filesToProcess = str2num( tags{5,2} );
groundChannels = str2num( tags{6,2} );
extractionThreshold = str2num(tags{7,2}); 

paramsIn=[];

paramsIn.samplingFreq= str2num(tags{11,2}); %only used if rawFileVersion==3 || ==4
paramsIn.doDetection=tags{12,2};
paramsIn.doSorting=tags{13,2};
paramsIn.doFigures=tags{14,2};
paramsIn.noProjectionTest= (tags{15,2} == 0);
paramsIn.doRawGraphs=tags{16,2};
paramsIn.doGroundNormalization= tags{17,2};
paramsIn.outputFormat=tags{18,2};
dp.waveletName= tags{31,2};
dp.scalesRange= str2num( tags{32,2});
dp.kernelSize = str2num(tags{33,2});
paramsIn.minNrSpikes = str2num(tags{34,2});
paramsIn.displayFigures = tags{35,2};
paths.timestampspath = tags{36,2};
paramsIn.blockNrRawFig = str2num( tags{37,2} );

if (tags{8,2} + tags{9,2} +  tags{10,2} +  tags{37,2}) == 0
    paramsIn.rawFileVersion = 0;
end
if tags{8,2};%1 is analog cheetah, 2 is digital cheetah (NCS), 3 is txt file.  determines sampling freq&dynamic range.
    paramsIn.rawFileVersion = 1;
elseif tags{9,2};
    paramsIn.rawFileVersion = 2;
elseif tags{10,2};
    paramsIn.rawFileVersion = 3;
elseif tags{37,2};
    paramsIn.rawFileVersion = 4;
end

if (tags{26,2} + tags{27,2} +  tags{28,2} + tags{29,2} + tags{30,2}) == 0
    paramsIn.detectionMethod = 0;
end
if tags{26,2} %1 power, 2 T pos, 3 T min, 3 T abs, 4 wavelet
    paramsIn.detectionMethod = 2;
elseif tags{27,2}
    paramsIn.detectionMethod = 3;
elseif tags{28,2}
    paramsIn.detectionMethod = 4;
elseif tags{29,2}
    paramsIn.detectionMethod = 1;
elseif tags{30,2}
    paramsIn.detectionMethod = 5;
end

if (tags{22,2} +  tags{23,2} + tags{24,2} + tags{25,2}) == 0
    paramsIn.peakAlignMethod = 0;
end
if tags{22,2} %1 find Peak, 2 none, 3 peak of power, 4 MTEO peak
    paramsIn.peakAlignMethod = 2;
elseif tags{23,2}
    paramsIn.peakAlignMethod = 1;
elseif tags{24,2}
    paramsIn.peakAlignMethod = 3;
elseif tags{25,2}
    paramsIn.peakAlignMethod = 4;
end

if (tags{19,2} +  tags{20,2} + tags{21,2}) == 0
    paramsIn.defaultAlignMethod = 0;
end
if tags{19,2};%only used if peak finding method is "findPeak". 1=max, 2=min, 3=mixed
    paramsIn.defaultAlignMethod = 1;
elseif tags{20,2};
    paramsIn.defaultAlignMethod = 2;
elseif tags{21,2};
    paramsIn.defaultAlignMethod = 3;
end


function openingbehavior(handles)

if get(handles.rawFileVersionC,'Value')== 1 || get(handles.rawFileVersionD,'Value')== 1
    enablesamplingrate(handles);
else
    disablesamplingrate(handles);
end

disablefigurepath(handles);
if get(handles.doFigures,'Value') || get(handles.doRawGraphs,'Value')    
    enablefigurepath(handles);
end
 
if (get(handles.doDetection,'Value')==0)
    disablemethod(handles);
    disablethreshold(handles);
    disablewavelet(handles);
    disablekernel(handles);
    disablescales(handles);
    disablepeakalignmethod(handles);
    disablealignmethod(handles);
    set(handles.examplethresh,'String','e.g. 4')
    if get(handles.detectionMethodE, 'Value')
        disappearkernel(handles);
        set(handles.examplethresh,'String','e.g. 0.1')
    else
        disappearwavelet(handles);
        disappearscales(handles);
        set(handles.examplethresh,'String','e.g. 5')
    end
else
enablemethod(handles);
enablethreshold(handles);
enablepeakalignmethod(handles);
    if get(handles.detectionMethodA, 'Value')||get(handles.detectionMethodB, 'Value')||get(handles.detectionMethodC, 'Value')
        disappearwavelet(handles);
        disappearscales(handles);
        reappearkernel(handles);
        disablekernel(handles);
        set(handles.examplethresh,'String','e.g. 4')
    elseif get(handles.detectionMethodD, 'Value')
        disappearwavelet(handles);
        disappearscales(handles);
        reappearkernel(handles);
        enablekernel(handles);
        set(handles.examplethresh,'String','e.g. 5')
    else
        disappearkernel(handles);
        reappearwavelet(handles);
        enablewavelet(handles);
        reappearscales(handles);
        enablescales(handles);
        set(handles.examplethresh,'String','e.g. 0.1')
    end
    if get(handles.peakAlignMethodB, 'Value')
        enablealignmethod(handles);
    end
end

if (get(handles.peakAlignMethodB, 'Value')==0)
    disablealignmethod(handles);
else
    enablealignmethod(handles);
end

if get(handles.doSorting, 'Value')
    enableminnr(handles);
else
    disableminnr(handles);
end

function loadmat(dir, handles)

load(dir);

global tags;
tags = {'pathOut' paths.pathOut;
    'pathRaw' paths.pathRaw;
    'pathFigs' paths.pathFigs;
    'patientID' paths.patientID;
    'filesToProcess' num2str(filesToProcess);
    'groundChannels' num2str(groundChannels);
    'extractionThreshold' extractionThreshold;
    'rawFileVersionA' (paramsIn.rawFileVersion == 1);
    'rawFileVersionB' (paramsIn.rawFileVersion == 2);
    'rawFileVersionC' (paramsIn.rawFileVersion == 3);
    'samplingFreq' paramsIn.samplingFreq;
    'doDetection' paramsIn.doDetection;
    'doSorting' paramsIn.doSorting;
    'doFigures' paramsIn.doFigures;
    'noProjectionTest' (paramsIn.noProjectionTest == 0);
    'doRawGraphs' (paramsIn.doRawGraphs);
    'doGroundNormalization' paramsIn.doGroundNormalization == 1;
    'outputFormat' (paramsIn.outputFormat);
    'defaultAlignMethodA' (paramsIn.defaultAlignMethod == 1);
    'defaultAlignMethodB' (paramsIn.defaultAlignMethod == 2);
    'defaultAlignMethodC' (paramsIn.defaultAlignMethod == 3);
    'peakAlignMethodA' (paramsIn.peakAlignMethod == 2 );
    'peakAlignMethodB' (paramsIn.peakAlignMethod == 1 );
    'peakAlignMethodC' (paramsIn.peakAlignMethod == 3 );
    'peakAlignMethodD' (paramsIn.peakAlignMethod == 4 );
    'detectionMethodA' (paramsIn.detectionMethod == 2);
    'detectionMethodB' (paramsIn.detectionMethod == 3);
    'detectionMethodC' (paramsIn.detectionMethod == 4);
    'detectionMethodD' (paramsIn.detectionMethod == 1);
    'detectionMethodE' (paramsIn.detectionMethod == 5);
    'waveletName' dp.waveletName;
    'scalesRange' num2str(dp.scalesRange);
    'kernelSize' dp.kernelSize;
    'minNrSpikes' paramsIn.minNrSpikes;
    'displayFigures' paramsIn.displayFigures;
    'timestampspath' paths.timestampspath;
    'blockNrRawFig' paramsIn.blockNrRawFig
    'rawFileVersionD' (paramsIn.rawFileVersion == 4);
    };
    
setfieldvalues(tags, handles);

function enablesamplingrate(handles)
set(handles.samplingrate,'ForegroundColor', [0 0 0])
set(handles.samplingFreq,'ForegroundColor', [0 0 0])
set(handles.samplingrate,'Enable', 'on')
set(handles.samplingFreq,'Enable', 'on')

function disablesamplingrate(handles)
set(handles.samplingrate,'ForegroundColor', [.4 .4 .4])
set(handles.samplingFreq,'ForegroundColor', [.4 .4 .4])
set(handles.samplingrate,'Enable', 'off')
set(handles.samplingFreq,'Enable', 'off')

function enablefigurepath(handles)
set(handles.figurespath,'ForegroundColor', [0 0 0])
set(handles.pathFigs,'ForegroundColor', [0 0 0])
set(handles.figureformat,'ForegroundColor', [0 0 0])
set(handles.outputFormat,'ForegroundColor', [0 0 0])
set(handles.figurespath,'Enable', 'on')
set(handles.pathFigs,'Enable', 'on')
set(handles.figureformat,'Enable', 'on')
set(handles.outputFormat,'Enable', 'on')

function disablefigurepath(handles)
set(handles.figurespath,'ForegroundColor', [.4 .4 .4])
set(handles.pathFigs,'ForegroundColor', [.4 .4 .4])
set(handles.figureformat,'ForegroundColor', [.4 .4 .4])
set(handles.outputFormat,'ForegroundColor', [.4 .4 .4])
set(handles.figurespath,'Enable', 'off')
set(handles.pathFigs,'Enable', 'off')
set(handles.figureformat,'Enable', 'off')
set(handles.outputFormat,'Enable', 'off')

function enablemethod(handles)
set(handles.method,'ForegroundColor', [0 0 0])
set(handles.detectionMethodA,'ForegroundColor', [0 0 0])
set(handles.detectionMethodB,'ForegroundColor', [0 0 0])
set(handles.detectionMethodC,'ForegroundColor', [0 0 0])
set(handles.detectionMethodD,'ForegroundColor', [0 0 0])
set(handles.detectionMethodE,'ForegroundColor', [0 0 0])
set(handles.method,'Enable', 'on')
set(handles.detectionMethodA,'Enable', 'on')
set(handles.detectionMethodB,'Enable', 'on')
set(handles.detectionMethodC,'Enable', 'on')
set(handles.detectionMethodD,'Enable', 'on')
set(handles.detectionMethodE,'Enable', 'on')

function disablemethod(handles)
set(handles.method,'ForegroundColor', [0 0 0])
set(handles.detectionMethodA,'ForegroundColor', [0 0 0])
set(handles.detectionMethodB,'ForegroundColor', [0 0 0])
set(handles.detectionMethodC,'ForegroundColor', [0 0 0])
set(handles.detectionMethodD,'ForegroundColor', [0 0 0])
set(handles.detectionMethodE,'ForegroundColor', [0 0 0])
set(handles.method,'Enable', 'off')
set(handles.detectionMethodA,'Enable', 'off')
set(handles.detectionMethodB,'Enable', 'off')
set(handles.detectionMethodC,'Enable', 'off')
set(handles.detectionMethodD,'Enable', 'off')
set(handles.detectionMethodE,'Enable', 'off')

function disablethreshold(handles)
set(handles.extractionThreshold,'ForegroundColor', [.4 .4 .4])
set(handles.extractionthreshold1,'ForegroundColor', [.4 .4 .4])
set(handles.examplethresh,'ForegroundColor',[.4 .4 .4])
set(handles.extractionThreshold,'Enable', 'off')
set(handles.extractionthreshold1,'Enable', 'off')
set(handles.examplethresh,'Enable','off')

function enablethreshold(handles)
set(handles.extractionThreshold,'ForegroundColor', [0 0 0])
set(handles.extractionthreshold1,'ForegroundColor', [0 0 0])
set(handles.examplethresh,'ForegroundColor',[0 0 0])
set(handles.extractionThreshold,'Enable', 'on')
set(handles.extractionthreshold1,'Enable', 'on')
set(handles.examplethresh,'Enable','on')

function disablewavelet(handles)
set(handles.waveletName,'ForegroundColor', [.4 .4 .4])
set(handles.waveletname1,'ForegroundColor', [.4 .4 .4])
set(handles.waveletName,'Enable', 'off')
set(handles.waveletname1,'Enable', 'off')

function enablewavelet(handles)
set(handles.waveletName,'ForegroundColor', [0 0 0])
set(handles.waveletname1,'ForegroundColor', [0 0 0])
set(handles.waveletName,'Enable', 'on')
set(handles.waveletname1,'Enable', 'on')

function disappearwavelet(handles)
set(handles.waveletName,'Visible', 'off')
set(handles.waveletname1,'Visible', 'off')

function reappearwavelet(handles)
set(handles.waveletName,'Visible', 'on')
set(handles.waveletname1,'Visible', 'on')

function disablescales(handles)
set(handles.scalesRange,'ForegroundColor', [.4 .4 .4])
set(handles.scalesrange1,'ForegroundColor', [.4 .4 .4])
set(handles.scalesRange,'Enable', 'off')
set(handles.scalesrange1,'Enable', 'off')

function enablescales(handles)
set(handles.scalesRange,'ForegroundColor', [0 0 0])
set(handles.scalesrange1,'ForegroundColor', [0 0 0])
set(handles.scalesRange,'Enable', 'on')
set(handles.scalesrange1,'Enable', 'on')

function disappearscales(handles)
set(handles.scalesRange,'Visible', 'off')
set(handles.scalesrange1,'Visible', 'off')

function reappearscales(handles)
set(handles.scalesRange,'Visible', 'on')
set(handles.scalesrange1,'Visible', 'on')

function disablekernel(handles)
set(handles.kernelSize,'ForegroundColor', [.4 .4 .4])
set(handles.kernelsize1,'ForegroundColor', [.4 .4 .4])
set(handles.kernelSize,'Enable', 'off')
set(handles.kernelsize1,'Enable', 'off')

function enablekernel(handles)
set(handles.kernelSize,'ForegroundColor', [0 0 0])
set(handles.kernelsize1,'ForegroundColor', [0 0 0])
set(handles.kernelSize,'Enable', 'on')
set(handles.kernelsize1,'Enable', 'on')

function disappearkernel(handles)
set(handles.kernelSize,'Visible', 'off')
set(handles.kernelsize1,'Visible', 'off')

function reappearkernel(handles)
set(handles.kernelSize,'Visible', 'on')
set(handles.kernelsize1,'Visible', 'on')

function disablepeakalignmethod(handles)
set(handles.peakalignmethod,'ForegroundColor', [.4 .4 .4])
set(handles.peakAlignMethodA,'ForegroundColor', [.4 .4 .4])
set(handles.peakAlignMethodB,'ForegroundColor', [.4 .4 .4])
set(handles.peakAlignMethodC,'ForegroundColor', [.4 .4 .4])
set(handles.peakAlignMethodD,'ForegroundColor', [.4 .4 .4])
set(handles.peakalignmethod,'Enable', 'off')
set(handles.peakAlignMethodA,'Enable', 'off')
set(handles.peakAlignMethodB,'Enable', 'off')
set(handles.peakAlignMethodC,'Enable', 'off')
set(handles.peakAlignMethodD,'Enable', 'off')

function enablepeakalignmethod(handles)
set(handles.peakalignmethod,'ForegroundColor', [0 0 0])
set(handles.peakAlignMethodA,'ForegroundColor', [0 0 0])
set(handles.peakAlignMethodB,'ForegroundColor', [0 0 0])
set(handles.peakAlignMethodC,'ForegroundColor', [0 0 0])
set(handles.peakAlignMethodD,'ForegroundColor', [0 0 0])
set(handles.peakalignmethod,'Enable', 'on')
set(handles.peakAlignMethodA,'Enable', 'on')
set(handles.peakAlignMethodB,'Enable', 'on')
set(handles.peakAlignMethodC,'Enable', 'on')
set(handles.peakAlignMethodD,'Enable', 'on')

function disablealignmethod(handles)
set(handles.alignmethod,'ForegroundColor', [.4 .4 .4])
set(handles.defaultAlignMethodA,'ForegroundColor', [.4 .4 .4])
set(handles.defaultAlignMethodB,'ForegroundColor', [.4 .4 .4])
set(handles.defaultAlignMethodC,'ForegroundColor', [.4 .4 .4])
set(handles.alignmethod,'Enable', 'off')
set(handles.defaultAlignMethodA,'Enable', 'off')
set(handles.defaultAlignMethodB,'Enable', 'off')
set(handles.defaultAlignMethodC,'Enable', 'off')

function enablealignmethod(handles)
set(handles.alignmethod,'ForegroundColor', [0 0 0])
set(handles.defaultAlignMethodA,'ForegroundColor', [0 0 0])
set(handles.defaultAlignMethodB,'ForegroundColor', [0 0 0])
set(handles.defaultAlignMethodC,'ForegroundColor', [0 0 0])
set(handles.alignmethod,'Enable', 'on')
set(handles.defaultAlignMethodA,'Enable', 'on')
set(handles.defaultAlignMethodB,'Enable', 'on')
set(handles.defaultAlignMethodC,'Enable', 'on')

function enableminnr(handles)
set(handles.minNrSpikes,'ForegroundColor', [0 0 0])
set(handles.minnr,'ForegroundColor', [0 0 0])
set(handles.minNrSpikes,'Enable', 'on')
set(handles.minnr,'Enable', 'on')

function disableminnr(handles)
set(handles.minNrSpikes,'ForegroundColor', [.4 .4 .4])
set(handles.minnr,'ForegroundColor', [.4 .4 .4])
set(handles.minNrSpikes,'Enable', 'off')
set(handles.minnr,'Enable', 'off')

%adds a slash/backslash to the end of paths to make sure paths are complete
function pathStr = fixPathString( pathStr)
if iscell(pathStr)
    pathStr = pathStr{1};
end
if length(pathStr)>0
    if (strcmp(pathStr(end),'/')==0)&&(strcmp(pathStr(end),'\')==0)
        pathStr = [pathStr '/'];
    end
end

%% Open GUI


function GUI_OpeningFcn(hObject, eventdata, handles, varargin)

global DEFAULTDIRECTORY;
S = mfilename('fullpath');
DEFAULTDIRECTORY = [S(1:(end-5)) 'params\default.mat'];

global tags;
tags = {'pathOut' [];
    'pathRaw' [];
    'pathFigs' [];
    'patientID' [];
    'filesToProcess' [];
    'groundChannels' [];
    'extractionThreshold' [];
    'rawFileVersionA' [];
    'rawFileVersionB' [];
    'rawFileVersionC' [];
    'samplingFreq' [];
    'doDetection' [];
    'doSorting' [];
    'doFigures' [];
    'noProjectionTest' [];
    'doRawGraphs' [];
    'doGroundNormalization' [];
    'outputFormat' [];
    'defaultAlignMethodA' [];
    'defaultAlignMethodB' [];
    'defaultAlignMethodC' [];
    'peakAlignMethodA' [];
    'peakAlignMethodB' [];
    'peakAlignMethodC' [];
    'peakAlignMethodD' [];
    'detectionMethodA' [];
    'detectionMethodB' [];
    'detectionMethodC' [];
    'detectionMethodD' [];
    'detectionMethodE' [];
    'waveletName' [];
    'scalesRange' [];
    'kernelSize' [];
    'minNrSpikes' [];
    'displayFigures' [];
    'timestampspath' [];
    'blockNrRawFig' [];
    };

if exist(DEFAULTDIRECTORY,'file')
    loadmat(DEFAULTDIRECTORY, handles);
end
loaddirectories(handles);




%% make sure the right fields are enabled/disabled    
openingbehavior(handles);

% Choose default command line output for GUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);
  

%% all the callbacks


function varargout = GUI_OutputFcn(hObject, eventdata, handles)

% Get default command line output from handles structure
varargout{1} = handles.output;


function pathOut_Callback(hObject, eventdata, handles)
set(handles.pathOut,'String', fixPathString( get(handles.pathOut,'String')));

function pathOut_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function filesToProcess_Callback(hObject, eventdata, handles)


function filesToProcess_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function groundChannels_Callback(hObject, eventdata, handles)


function groundChannels_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function rawFileVersionA_Callback(hObject, eventdata, handles)
set(handles.rawFileVersionC,'Value',0)
set(handles.rawFileVersionB,'Value',0)
set(handles.rawFileVersionD,'Value',0)
disablesamplingrate(handles);

function rawFileVersionB_Callback(hObject, eventdata, handles)
set(handles.rawFileVersionA,'Value',0)
set(handles.rawFileVersionC,'Value',0)
set(handles.rawFileVersionD,'Value',0)
disablesamplingrate(handles);

function rawFileVersionC_Callback(hObject, eventdata, handles)
set(handles.rawFileVersionA,'Value',0)
set(handles.rawFileVersionB,'Value',0)
set(handles.rawFileVersionD,'Value',0)
enablesamplingrate(handles);

function rawFileVersionD_Callback(hObject, eventdata, handles)
set(handles.rawFileVersionA,'Value',0)
set(handles.rawFileVersionB,'Value',0)
set(handles.rawFileVersionC,'Value',0)
enablesamplingrate(handles);

function samplingFreq_Callback(hObject, eventdata, handles)

function samplingFreq_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function patientID_Callback(hObject, eventdata, handles)


function patientID_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function doFigures_Callback(hObject, eventdata, handles)

if get(handles.doFigures,'Value') || get(handles.doRawGraphs,'Value')
    enablefigurepath(handles);
else
    disablefigurepath(handles);
end

function doRawGraphs_Callback(hObject, eventdata, handles)

if get(handles.doFigures,'Value') || get(handles.doRawGraphs,'Value')
    enablefigurepath(handles);
else
    disablefigurepath(handles);
end

function pathFigs_Callback(hObject, eventdata, handles)
set(handles.pathFigs,'String', fixPathString( get(handles.pathFigs,'String')));

function pathFigs_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function pathRaw_Callback(hObject, eventdata, handles)
set(handles.pathRaw,'String', fixPathString( get(handles.pathRaw,'String')));

function pathRaw_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function outputFormat_Callback(hObject, eventdata, handles)


function outputFormat_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function detectionMethodA_Callback(hObject, eventdata, handles)

set(handles.detectionMethodD,'Value',0)
set(handles.detectionMethodB,'Value',0)
set(handles.detectionMethodC,'Value',0)
set(handles.detectionMethodE,'Value',0)
set(handles.examplethresh,'String','e.g. 4')
disablewavelet(handles);
disablekernel(handles);
disablescales(handles);

function detectionMethodB_Callback(hObject, eventdata, handles)

set(handles.detectionMethodD,'Value',0)
set(handles.detectionMethodA,'Value',0)
set(handles.detectionMethodC,'Value',0)
set(handles.detectionMethodE,'Value',0)
set(handles.examplethresh,'String','e.g. 4')
disablewavelet(handles);
disablekernel(handles);
disablescales(handles);

function detectionMethodC_Callback(hObject, eventdata, handles)

set(handles.detectionMethodB,'Value',0)
set(handles.detectionMethodA,'Value',0)
set(handles.detectionMethodE,'Value',0)
set(handles.detectionMethodD,'Value',0)
set(handles.examplethresh,'String','e.g. 4')
disablewavelet(handles);
disablekernel(handles);
disablescales(handles);

function detectionMethodD_Callback(hObject, eventdata, handles)

set(handles.detectionMethodE,'Value',0)
set(handles.detectionMethodB,'Value',0)
set(handles.detectionMethodA,'Value',0)
set(handles.detectionMethodC,'Value',0)
set(handles.examplethresh,'String','e.g. 5')
reappearkernel(handles);
enablekernel(handles);
disappearscales(handles);
disappearwavelet(handles);

function detectionMethodE_Callback(hObject, eventdata, handles)

set(handles.detectionMethodA,'Value',0)
set(handles.detectionMethodB,'Value',0)
set(handles.detectionMethodC,'Value',0)
set(handles.detectionMethodD,'Value',0)
set(handles.examplethresh,'String','e.g. 0.1')
disappearkernel(handles);
reappearscales(handles);
reappearwavelet(handles);
enablewavelet(handles);
enablescales(handles);


function extractionThreshold_Callback(hObject, eventdata, handles)


function kernelSize_Callback(hObject, eventdata, handles)


function kernelSize_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function scalesRange_Callback(hObject, eventdata, handles)

function scalesRange_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
function extractionThreshold_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function waveletName_Callback(hObject, eventdata, handles)


function waveletName_CreateFcn(hObject, eventdata, handles)

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function peakAlignMethodA_Callback(hObject, eventdata, handles)
set(handles.peakAlignMethodB,'Value',0)
set(handles.peakAlignMethodC,'Value',0)
set(handles.peakAlignMethodD,'Value',0)
disablealignmethod(handles);

function peakAlignMethodB_Callback(hObject, eventdata, handles)
set(handles.peakAlignMethodA,'Value',0)
set(handles.peakAlignMethodC,'Value',0)
set(handles.peakAlignMethodD,'Value',0)
enablealignmethod(handles);

function peakAlignMethodC_Callback(hObject, eventdata, handles)
set(handles.peakAlignMethodB,'Value',0)
set(handles.peakAlignMethodD,'Value',0)
set(handles.peakAlignMethodA,'Value',0)
disablealignmethod(handles);

function peakAlignMethodD_Callback(hObject, eventdata, handles)
set(handles.peakAlignMethodB,'Value',0)
set(handles.peakAlignMethodC,'Value',0)
set(handles.peakAlignMethodA,'Value',0)
disablealignmethod(handles);

function defaultAlignMethodA_Callback(hObject, eventdata, handles)

set(handles.defaultAlignMethodB,'Value',0)
set(handles.defaultAlignMethodC,'Value',0)

function defaultAlignMethodB_Callback(hObject, eventdata, handles)

set(handles.defaultAlignMethodA,'Value',0)
set(handles.defaultAlignMethodC,'Value',0)

function defaultAlignMethodC_Callback(hObject, eventdata, handles)

set(handles.defaultAlignMethodA,'Value',0)
set(handles.defaultAlignMethodB,'Value',0)

function doDetection_Callback(hObject, eventdata, handles)

if (get(handles.doDetection,'Value')==0)
    disablemethod(handles);
    disablethreshold(handles);
    disablewavelet(handles);
    disablekernel(handles);
    disablescales(handles);
    disablepeakalignmethod(handles);
    disablealignmethod(handles);
else
    enablemethod(handles);
    enablethreshold(handles);
    enablepeakalignmethod(handles);
    if get(handles.detectionMethodD, 'Value')||get(handles.detectionMethodE, 'Value')
        enablescales(handles);
        enablekernel(handles);
        enablewavelet(handles);
    end
    if get(handles.peakAlignMethodB, 'Value')
        enablealignmethod(handles);
    end
end


function merge_Callback(hObject, eventdata, handles)
global FIGUREPATH
FIGUREPATH = get(handles.pathFigs,'String');
MergeGUI;

function define_Callback(hObject, eventdata, handles)
global FIGUREPATH
FIGUREPATH = get(handles.pathFigs,'String');
DefineUsableClustersGUI;

function noProjectionTest_Callback(hObject, eventdata, handles)

function doGroundNormalization_Callback(hObject, eventdata, handles)

function doSorting_Callback(hObject, eventdata, handles)

if get(handles.doSorting, 'Value')
    enableminnr(handles);
else
    disableminnr(handles);
end

function saveparams_Callback(hObject, eventdata, handles)
savedir = get(handles.saveparams, 'String');
if iscell(savedir)
    savedir = savedir{1};
end
if isempty(strfind(savedir,'mat'))
    set(handles.saveparams,'String',[savedir '.mat']);
end

function saveparams_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function loadparams_Callback(hObject, eventdata, handles)
loaddir = get(handles.loadparams, 'String');
if iscell(loaddir)
    loaddir = loaddir{1};
end
if isempty(strfind(loaddir,'mat'))
    set(handles.loadparams,'String',[loaddir '.mat']);
end

function loadparams_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function displayFigures_Callback(hObject, eventdata, handles)


%% loading (similar to the gui opening cell)
function loadparams1_Callback(hObject, eventdata, handles)

loaddir = get(handles.loadparams, 'String');
if iscell(loaddir)
    loaddir = loaddir{1};
end
if exist(loaddir,'file')
    loadmat(loaddir,handles);
else
    warning(['load file does not exist:' loaddir]);
end

openingbehavior(handles);

%% saving (similar to the start sorting cell)
function saveparams1_Callback(hObject, eventdata, handles)
global tags
tags = getfieldvalues(tags,handles);
[paths, paramsIn, dp, filesToProcess, groundChannels, extractionThreshold] = assignparameters(tags);

savedir = get(handles.saveparams, 'String');
if iscell(savedir)
    savedir = savedir{1};
end

if (exist(savedir,'dir')== 0)
    save (savedir,'paths', 'filesToProcess', 'groundChannels','extractionThreshold', 'paramsIn', 'dp')
end
save (savedir,'paths', 'filesToProcess', 'groundChannels','extractionThreshold', 'paramsIn', 'dp','-append')
savedirectories(handles,savedir);

display('parameters saved successfully')

%% starting sorting
function Sort_Callback(hObject, eventdata, handles)

set(handles.Sort,'String','Sorting...');
set(handles.Sort,'Enable','off');
drawnow;

global tags;
tags = getfieldvalues(tags,handles);
[paths, paramsIn, dp, filesToProcess, groundChannels, extractionThreshold] = assignparameters(tags);

global DEFAULTDIRECTORY;

if (exist(DEFAULTDIRECTORY,'file')==0)
   save(DEFAULTDIRECTORY,'paths', 'filesToProcess', 'groundChannels', 'extractionThreshold', 'paramsIn', 'dp')
end

try
    save(DEFAULTDIRECTORY,'paths', 'filesToProcess', 'groundChannels', 'extractionThreshold', 'paramsIn', 'dp','-append')
    savedirectories(handles,DEFAULTDIRECTORY);

    GUI_script;
catch
    set(handles.Sort,'String','Sort');
    set(handles.Sort,'Enable','on');
    
    tmp=lasterror;
    warning(['error message was:' tmp.message]);
    for i=1:size(tmp.stack)
        disp(['file ' tmp.stack(i).file ' line ' num2str(tmp.stack(i).line)]);
    end
    
    rethrow(tmp);
end
set(handles.Sort,'String','Sort');
set(handles.Sort,'Enable','on');

function SetRawPath_Callback(hObject, eventdata, handles)
tmp = uigetdir('','Set path where raw files are located');
if tmp~=0
    set(handles.pathRaw,'String', fixPathString(tmp) );
end

function SetDataPath_Callback(hObject, eventdata, handles)
tmp = uigetdir('','Set path where results will be stored');
if tmp~=0
    set(handles.pathOut,'String', fixPathString(tmp) );
end

function SetFiguresPath_Callback(hObject, eventdata, handles)
tmp = uigetdir('','Set path where figures will be stored');
if tmp~=0
    set(handles.pathFigs,'String', fixPathString(tmp) );
end

function SetTimestampsFile_Callback(hObject, eventdata, handles)
tmp = uigetdir('','Set path where timestampsInclude.txt is located.');
if tmp~=0
    set(handles.timestampspath,'String', fixPathString(tmp) );
end

function SetLoadParamsPath_Callback(hObject, eventdata, handles)
[tmp1,tmp2] = uigetfile('*.mat','Pick params file to load');
if tmp1~=0
    set(handles.loadparams,'String', [tmp2 tmp1] );
end

function SetSaveParamsPath_Callback(hObject, eventdata, handles)
[tmp1,tmp2] = uiputfile('*.mat','Set params file to save');
if tmp1~=0
    set(handles.saveparams,'String', [tmp2 tmp1] );
end
