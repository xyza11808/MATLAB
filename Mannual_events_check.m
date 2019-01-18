function varargout = Mannual_events_check(varargin)
% MANNUAL_EVENTS_CHECK MATLAB code for Mannual_events_check.fig
%      MANNUAL_EVENTS_CHECK, by itself, creates a new MANNUAL_EVENTS_CHECK or raises the existing
%      singleton*.
%
%      H = MANNUAL_EVENTS_CHECK returns the handle to a new MANNUAL_EVENTS_CHECK or the handle to
%      the existing singleton*.
%
%      MANNUAL_EVENTS_CHECK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MANNUAL_EVENTS_CHECK.M with the given input arguments.
%
%      MANNUAL_EVENTS_CHECK('Property','Value',...) creates a new MANNUAL_EVENTS_CHECK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Mannual_events_check_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Mannual_events_check_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Mannual_events_check

% Last Modified by GUIDE v2.5 02-Jan-2019 22:35:47

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Mannual_events_check_OpeningFcn, ...
                   'gui_OutputFcn',  @Mannual_events_check_OutputFcn, ...
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


% --- Executes just before Mannual_events_check is made visible.
function Mannual_events_check_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Mannual_events_check (see VARARGIN)
global SessROISummary
SessROISummary.Path = '';
SessROISummary.ROIData = [];
SessROISummary.nROIs = [];
SessROISummary.CurrentROI = 1;
SessROISummary.ROIEventsData = [];
SessROISummary.ROIfig = [];
SessROISummary.AutoEventData = {};
SessROISummary.cROIEventStrc = [];
SessROISummary.AddEventStart = [];
SessROISummary.AddEventEnd = [];
SessROISummary.cROInanTrace = [];
SessROISummary.ModifiedEventData = {};
SessROISummary.IsEventsAdded = 0;
SessROISummary.TempStartEndLine = {[],[]};
SessROISummary.IsCurrentROIFigChange = 0;
% Choose default command line output for Mannual_events_check
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Mannual_events_check wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Mannual_events_check_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function SessPath_tag_Callback(hObject, eventdata, handles)
% hObject    handle to SessPath_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SessROISummary
% Hints: get(hObject,'String') returns contents of SessPath_tag as text
%        str2double(get(hObject,'String')) returns contents of SessPath_tag as a double
InputPath = get(hObject,'String');
if ~isdir(InputPath) || ~exist(fullfile(InputPath,'Peak_ROI_plots','ROIEventsSave.mat'),'file')
    warning('The input path is not a valid path.');
    return;
end
cd(InputPath);
SessROISummary.Path = InputPath;
cSessData = load(fullfile(InputPath,'ROIdataSummary.mat'));
SessROISummary.ROIData = cSessData.DeltaFROIData;
nROIs = size(SessROISummary.ROIData,1);
SessROISummary.nROIs = nROIs;
set(handles.TotalROIString,'String',num2str(nROIs));
set(handles.cROI_tag,'String',num2str(SessROISummary.CurrentROI));

AutoEventsDataStrc = load(fullfile(InputPath,'Peak_ROI_plots','ROIEventsSave.mat'));
SessROISummary.AutoEventData = AutoEventsDataStrc.ROIPeakDataAll;
SessROISummary.ModifiedEventData = SessROISummary.AutoEventData;


% --- Executes during object creation, after setting all properties.
function SessPath_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SessPath_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to cROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cROI_tag as text
%        str2double(get(hObject,'String')) returns contents of cROI_tag as a double


% --- Executes during object creation, after setting all properties.
function cROI_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in AddStart_tag.
function AddStart_tag_Callback(hObject, eventdata, handles)
% hObject    handle to AddStart_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SessROISummary
set(handles.MessageTextTag,'String',sprintf('Please click on the start position, then press return.'));
if ishandle(SessROISummary.ROIfig)
    figure(SessROISummary.ROIfig);
else
    set(handles.MessageTextTag,'String','No ROI trace was opened.');
    return;
end
[xx,~] = ginput;
InputxPos = round(xx(end));
figure(SessROISummary.ROIfig);
if ~isnan(SessROISummary.cROInanTrace(InputxPos))
    set(handles.MessageTextTag,'String','Current range seems within existed events.');
    return;
end
cAxYlims = get(gca,'ylim');
if ~isempty(SessROISummary.AddEventStart)
    delete(SessROISummary.TempStartEndLine{1});
    SessROISummary.TempStartEndLine{1} = [];
end
ll1 = line([InputxPos InputxPos],cAxYlims,'Color',[.7 .7 .7],'linewidth',0.8,'linestyle','--');
SessROISummary.AddEventStart = InputxPos;
SessROISummary.TempStartEndLine{1} = ll1;
SessROISummary.AddEventEnd = [];

% --- Executes on button press in AddEnd_tag.
function AddEnd_tag_Callback(hObject, eventdata, handles)
% hObject    handle to AddEnd_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SessROISummary
set(handles.MessageTextTag,'String',sprintf('Please click on the end position, then press return.'));
if isempty(SessROISummary.AddEventStart)
    set(handles.MessageTextTag,'String',sprintf('Please select a start index first.'));
    return;
end

if ishandle(SessROISummary.ROIfig)
    figure(SessROISummary.ROIfig);
else
    set(handles.MessageTextTag,'String','No ROI trace was opened.');
    return;
end
[xx,~] = ginput;
InputxPos = round(xx(end));
if InputxPos < SessROISummary.AddEventStart + 5
    set(handles.MessageTextTag,'String',sprintf('The end index should larger than start at least 5 frames'));
    return;
end
% figure(SessROISummary.ROIfig);
if ~isnan(SessROISummary.cROInanTrace(InputxPos))
    set(handles.MessageTextTag,'String','Current range seems within existed events.');
    return;
end
cAxYlims = get(gca,'ylim');
if ~isempty(SessROISummary.AddEnd_tag)
    delete(SessROISummary.TempStartEndLine{2});
    SessROISummary.TempStartEndLine{2} = [];
end
ll2 = line([InputxPos InputxPos],cAxYlims,'Color',[.7 .7 .7],'linewidth',0.8,'linestyle','--');
SessROISummary.AddEventEnd = InputxPos;
SessROISummary.TempStartEndLine{2} = ll2;

% --- Executes on button press in PreROI_tag.
function PreROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to PreROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SessROISummary
ccROI = SessROISummary.CurrentROI - 1;
if ccROI < 1
    return;
else
    SessROISummary.CurrentROI = ccROI;
    set(handles.cROI_tag,'String',num2str(ccROI));
    load_cROI_tag_Callback(hObject, eventdata, handles);
end
    

% --- Executes on button press in NextROI_tag.
function NextROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to NextROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SessROISummary
ccROI = SessROISummary.CurrentROI + 1;
if ccROI > SessROISummary.nROIs
    return;
else
    SessROISummary.CurrentROI = ccROI;
    set(handles.cROI_tag,'String',num2str(ccROI));
    load_cROI_tag_Callback(hObject, eventdata, handles);
end
    

% --- Executes on button press in PlotThres_tag.
function PlotThres_tag_Callback(hObject, eventdata, handles)
% hObject    handle to PlotThres_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SessROISummary
figure(SessROISummary.ROIfig);
cROIData = SessROISummary.ROIData(SessROISummary.CurrentROI,:);
Thres = mad(cROIData)*1.4826;
nFrames = numel(cROIData);
line([1 nFrames],[Thres Thres],'Color',[1 0.7 0.2],'linewidth',1.4,'linestyle','--');


% --- Executes on button press in load_cROI_tag.
function load_cROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to load_cROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SessROISummary
AutoROIeventsPath = fullfile(SessROISummary.Path,'Peak_ROI_plots');
ccROI = SessROISummary.CurrentROI;
if ishandle(SessROISummary.ROIfig)
    close(SessROISummary.ROIfig);
    SessROISummary.ROIfig = [];
end
cROIEventPlotTemp = fullfile(AutoROIeventsPath,sprintf('ROI%d events finding plotsNew.fig',ccROI));
cROIEventPlot = fullfile(AutoROIeventsPath,sprintf('ROI%d events finding plots.fig',ccROI));
if exist(cROIEventPlotTemp,'file')
    hf = openfig(cROIEventPlotTemp);
else
    hf = openfig(cROIEventPlot);
end

SessROISummary.ROIfig = hf;
SessROISummary.cROIEventStrc = SessROISummary.ModifiedEventData{ccROI};
cROIRawData = SessROISummary.ROIData(ccROI,:);
SessROISummary.cROInanTrace = nan(numel(cROIRawData),1);
if ~isempty(SessROISummary.cROIEventStrc)
    ExistsROIPeakNum = length(SessROISummary.cROIEventStrc.PeakIndex);
    for cROIEvent = 1 : ExistsROIPeakNum
        cPeakRange = SessROISummary.cROIEventStrc.PeakIndexRange(cROIEvent,:);
        SessROISummary.cROInanTrace(cPeakRange(1):cPeakRange(2)) = cROIRawData(cPeakRange(1):cPeakRange(2));
    end
end
SessROISummary.TempStartEndLine = {[],[]};
SessROISummary.AddEventStart = [];
SessROISummary.AddEventEnd = [];
SessROISummary.IsCurrentROIFigChange = 0;

% --- Executes on button press in AddEvent_tag.
function AddEvent_tag_Callback(hObject, eventdata, handles)
% hObject    handle to AddEvent_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SessROISummary

choice = questdlg('Are you sure to add current event?', ...
	'Add choice', ...
	'Yes','No','Clear','Yes');

switch choice
    case 'Yes'
        set(handles.MessageTextTag,'String','Adding current events...');
    case 'No'
        return;
    case 'Clear'
        delete(SessROISummary.TempStartEndLine{1});
        delete(SessROISummary.TempStartEndLine{2});
        SessROISummary.AddEventStart = [];
        SessROISummary.AddEventEnd = [];
        return;
end


if isempty(SessROISummary.AddEventStart) || isempty(SessROISummary.AddEventEnd)
    set(handles.MessageTextTag,'String','Either added event start or end points is missing');
    return;
else
    if SessROISummary.AddEventStart >= SessROISummary.AddEventEnd - 5
        set(handles.MessageTextTag,'String','The start and end point is too close for an event');
        return;
    end
    cROIRawData = SessROISummary.ROIData(SessROISummary.CurrentROI,:);
    AddEventRange = [SessROISummary.AddEventStart, SessROISummary.AddEventEnd];
    AddEventRawData = cROIRawData(AddEventRange(1):AddEventRange(2));
    [cPeakAmp,cPeakInds] = max(AddEventRawData);
    AddEventIndex = SessROISummary.AddEventStart + cPeakInds - 1;
    if ~isempty(SessROISummary.cROIEventStrc)
        SessROISummary.cROIEventStrc.PeakIndex = [SessROISummary.cROIEventStrc.PeakIndex;AddEventIndex];
        SessROISummary.cROIEventStrc.PeakIndexRange = [SessROISummary.cROIEventStrc.PeakIndexRange;AddEventRange];
        SessROISummary.cROIEventStrc.PeakHalfWidth = [SessROISummary.cROIEventStrc.PeakHalfWidth;diff(AddEventRange)/2];
        SessROISummary.cROIEventStrc.Area = [SessROISummary.cROIEventStrc.Area;sum(AddEventRawData)];
        SessROISummary.cROIEventStrc.PeakAmp = [SessROISummary.cROIEventStrc.PeakAmp;cPeakAmp];
    else
        SessROISummary.cROIEventStrc.PeakIndex = AddEventIndex;
        SessROISummary.cROIEventStrc.PeakIndexRange = AddEventRange;
        SessROISummary.cROIEventStrc.PeakHalfWidth = diff(AddEventRange)/2;
        SessROISummary.cROIEventStrc.Area = sum(AddEventRawData);
        SessROISummary.cROIEventStrc.PeakAmp = cPeakAmp;
    end
    figure(SessROISummary.ROIfig);
    hold on
    plot(AddEventRange(1):AddEventRange(2),AddEventRawData,'m','linewidth',1.4);
    plot(AddEventIndex,cROIRawData(AddEventIndex),'co');
    
    SessROISummary.ModifiedEventData{SessROISummary.CurrentROI} = SessROISummary.cROIEventStrc;
    SessROISummary.IsEventsAdded = 1;
    SessROISummary.cROInanTrace(AddEventRange(1):AddEventRange(2)) = AddEventRawData; 
    SessROISummary.IsCurrentROIFigChange = 1;
    
    delete(SessROISummary.TempStartEndLine{1});
    delete(SessROISummary.TempStartEndLine{2});
    SessROISummary.TempStartEndLine = {[],[]}; 
    SessROISummary.AddEventStart = [];
    SessROISummary.AddEventEnd = [];
    
    saveas(SessROISummary.ROIfig,fullfile(SessROISummary.Path,'Peak_ROI_plots',sprintf('ROI%d events finding plotsNew.fig',...
        SessROISummary.CurrentROI)));
    saveas(SessROISummary.ROIfig,fullfile(SessROISummary.Path,'Peak_ROI_plots',sprintf('ROI%d events finding plotsNew.png',...
        SessROISummary.CurrentROI)));
    
end


function MessageTextTag_Callback(hObject, eventdata, handles)
% hObject    handle to MessageTextTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of MessageTextTag as text
%        str2double(get(hObject,'String')) returns contents of MessageTextTag as a double


% --- Executes during object creation, after setting all properties.
function MessageTextTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MessageTextTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[1 0.7 0.5]);
end
set(hObject,'BackgroundColor',[1 0.8 0.6]);


% --- Executes on button press in SaveAll_tag.
function SaveAll_tag_Callback(hObject, eventdata, handles)
% hObject    handle to SaveAll_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global SessROISummary

if SessROISummary.IsEventsAdded
    set(handles.MessageTextTag,'String','Saving modified events data...');
    ROIPeakDataAll = SessROISummary.ModifiedEventData;
    save(fullfile(SessROISummary.Path,'Peak_ROI_plots','ROIEventsSaveAdded.mat'),'ROIPeakDataAll','-v7.3');
else
    set(handles.MessageTextTag,'String','No event was added for current session.');
end
 % delete temp files
 cPlotFolder = fullfile(SessROISummary.Path,'Peak_ROI_plots');
 TempFiles = dir(fullfile(SessROISummary.Path,'Peak_ROI_plots','ROI* events finding plotsNew.png'));
 nTempFile = length(TempFiles);
 for cf = 1 : nTempFile
     cTempfiles = fullfile(TempFiles(cf).folder,TempFiles(cf).name);
     cUpdatedFile = fullfile(TempFiles(cf).folder,[TempFiles(cf).name(1:end-7),'.png']);
     movefile(cTempfiles, cUpdatedFile, 'f');
     
     cTempfilesfig = fullfile(TempFiles(cf).folder,[TempFiles(cf).name(1:end-4),'.fig']);
     cUpdatedFilefig = fullfile(TempFiles(cf).folder,[TempFiles(cf).name(1:end-7),'.fig']);
     movefile(cTempfilesfig, cUpdatedFilefig, 'f');
 end
     
     
    
