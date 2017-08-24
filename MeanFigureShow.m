function varargout = MeanFigureShow(varargin)
% MEANFIGURESHOW MATLAB code for MeanFigureShow.fig
%      MEANFIGURESHOW, by itself, creates a new MEANFIGURESHOW or raises the existing
%      singleton*.
%
%      H = MEANFIGURESHOW returns the handle to a new MEANFIGURESHOW or the handle to
%      the existing singleton*.
%
%      MEANFIGURESHOW('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MEANFIGURESHOW.M with the given input arguments.
%
%      MEANFIGURESHOW('Property','Value',...) creates a new MEANFIGURESHOW or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MeanFigureShow_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MeanFigureShow_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MeanFigureShow

% Last Modified by GUIDE v2.5 03-Jul-2017 18:44:14

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MeanFigureShow_OpeningFcn, ...
                   'gui_OutputFcn',  @MeanFigureShow_OutputFcn, ...
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


% --- Executes just before MeanFigureShow is made visible.
function MeanFigureShow_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MeanFigureShow (see VARARGIN)
clearvars -global DataStrc
global DataStrc
% Choose default command line output for MeanFigureShow
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

DataStrc.DataAll = [];
DataStrc.FrameSize = [];
DataStrc.nTrs = [];
DataStrc.NorFrameData = []; % normalized each trial's maxDelta frame by its mean
DataStrc.ROISurSize = [];
DataStrc.MeanFData = [];
DataStrc.MaxDeltaData = [];
DataStrc.ROIpos = {};
% UIWAIT makes MeanFigureShow wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = MeanFigureShow_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



% --- Executes on button press in FrameDataLoad.
function FrameDataLoad_Callback(hObject, eventdata, handles)
% hObject    handle to FrameDataLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global DataStrc
[fn,fp,fi] = uigetfile('SessionFrameProj.mat','Please select the mat file contains frame data of each trial');
if fi
    cd(fp);
    fpath = fullfile(fp,fn);
    set(handles.DataPathText,'string',fpath);
    LoadData = load(fpath);
    DataStrc.DataAll = LoadData.FrameProjSave;
    DataStrc.FrameSize = size(DataStrc.DataAll(1).MaxFrame);
    DataStrc.nTrs = length(DataStrc.DataAll);
    FSize = DataStrc.FrameSize;
    NorFrameData = zeros(DataStrc.nTrs,FSize(1),FSize(2));
    for nnTr = 1 : DataStrc.nTrs
        cTrFrameMaxD = double(DataStrc.DataAll(nnTr).MaxFrame);
        cNorFrame = cTrFrameMaxD/mean(mean(cTrFrameMaxD));
        NorFrameData(nnTr,:,:) = cNorFrame;
    end
    MeanNorFrame = squeeze(mean(NorFrameData));
    MaxNorFrame = squeeze(max(NorFrameData));
    MaxDeltaF = MaxNorFrame - MeanNorFrame;
    DataStrc.MeanFData = MeanNorFrame;
    DataStrc.MaxDeltaData = MaxDeltaF;
    axes(handles.SessionAxes);
    set(handles.SessionAxes,'YDir','normal');
%     hold on;
    imagesc(MaxDeltaF);
    set(handles.SessionAxes,'YDir','reverse');
    axis off
    set(gca,'xlim',[1,FSize(1)],'ylim',[1,FSize(2)]);
    colormap gray
    cFrameScale = get(handles.SessionAxes,'clim');
    set(handles.climSlide,'Max',cFrameScale(2));
    set(handles.climSlide,'Min',cFrameScale(1));
    set(handles.climSlide,'value',cFrameScale(2));
    if isempty(DataStrc.ROIpos)
        LoadROIdata_Callback(hObject, eventdata, handles)
    end
    if ~isempty(get(handles.ROINum,'string'))
        cROInum = str2num(get(handles.ROINum,'string'));
        cROIpos = DataStrc.ROIpos{cROInum};
        line(cROIpos(:,1),cROIpos(:,2),'r','linewidth',1.5);
        ROIcenter = mean(cROIpos);
        text(ROIcenter(1),ROIcenter(2),num2str(cROInum),'color','g','FontSize',12);
        
        ROIsizeRange = str2num(get(handles.ROIsize,'string'));
        DataStrc.ROISurSize = ROIsizeRange;
        yRange = ROIcenter(1) + [ROIsizeRange*(-1),ROIsizeRange];
        xRange = ROIcenter(2) + [ROIsizeRange*(-1),ROIsizeRange];
        yRange = min(yRange,FSize(1));
        yRange = max(yRange,1);
        xRange = min(xRange,FSize(1));
        xRange = max(xRange,1);
        MeanData = MeanNorFrame(xRange(1):xRange(2),yRange(1):yRange(2));
        MaxData = MaxDeltaF(xRange(1):xRange(2),yRange(1):yRange(2));
        
        axes(handles.MeanFigureAxes);
        imagesc(MeanData,cFrameScale);
        
        axes(handles.MaxDFigureAxes);
        imagesc(MaxData,cFrameScale);
    end
    
end

function DataPathText_Callback(hObject, eventdata, handles)
% hObject    handle to DataPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of DataPathText as text
%        str2double(get(hObject,'String')) returns contents of DataPathText as a double


% --- Executes during object creation, after setting all properties.
function DataPathText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to DataPathText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','');


% --- Executes on slider movement.
function climSlide_Callback(hObject, eventdata, handles)
global DataStrc
% hObject    handle to climSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
climRange = [get(hObject,'Min'),get(hObject,'Value')];
if diff(climRange) == 0
    climRange(2) = climRange(2)+1;
end
set(handles.SessionAxes,'clim',climRange);
set(handles.MeanFigureAxes,'clim',climRange);
set(handles.MaxDFigureAxes,'clim',climRange);


% --- Executes during object creation, after setting all properties.
function climSlide_CreateFcn(hObject, eventdata, handles)
% hObject    handle to climSlide (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
set(hObject,'value',1);
set(hObject,'Max',1);
set(hObject,'Min',0);



function ROINum_Callback(hObject, eventdata, handles)
global DataStrc
% hObject    handle to ROINum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROINum as text
%        str2double(get(hObject,'String')) returns contents of ROINum as a double
ROInum = str2num(get(hObject,'String'));
DataStrc.ROISurSize = str2double(get(handles.ROIsize,'String'));
ROIsizeRange = DataStrc.ROISurSize;
FSize = DataStrc.FrameSize;
cROInum = str2num(get(handles.ROINum,'string'));
cROIpos = DataStrc.ROIpos{cROInum};
cFrameScale=[];
cFrameScale(1) = get(handles.climSlide,'Min');
cFrameScale(2) = get(handles.climSlide,'Value');
ROIcenter = round(mean(cROIpos));
yRange = round(ROIcenter(1) + [ROIsizeRange*(-1),ROIsizeRange]);
xRange = round(ROIcenter(2) + [ROIsizeRange*(-1),ROIsizeRange]);
yRange = min(yRange,FSize(1));
yRange = max(yRange,1);
xRange = min(xRange,FSize(1));
xRange = max(xRange,1);
MeanData = DataStrc.MeanFData(xRange(1):xRange(2),yRange(1):yRange(2));
MaxData = DataStrc.MaxDeltaData(xRange(1):xRange(2),yRange(1):yRange(2));

axes(handles.SessionAxes);
set(handles.SessionAxes,'YDir','normal');
%     hold on;
imagesc(DataStrc.MaxDeltaData,cFrameScale);
set(handles.SessionAxes,'YDir','reverse');
axis off
set(gca,'xlim',[1,FSize(1)],'ylim',[1,FSize(2)]);
colormap gray

axes(handles.SessionAxes);
set(handles.SessionAxes,'YDir','reverse');
% hold on;
% cROIpos = DataStrc.ROIpos{cROInum};
line(cROIpos(:,1),cROIpos(:,2),'color','r','linewidth',1.5);
ROIcenter = mean(cROIpos);
text(ROIcenter(1),ROIcenter(2),num2str(cROInum),'color','g','FontSize',12);

axes(handles.MeanFigureAxes);
imagesc(MeanData,cFrameScale);

axes(handles.MaxDFigureAxes);
imagesc(MaxData,cFrameScale);


% --- Executes during object creation, after setting all properties.
function ROINum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROINum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadROIdata.
function LoadROIdata_Callback(hObject, eventdata, handles)
global DataStrc
% hObject    handle to LoadROIdata (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn,fp,fi] = uigetfile('*.mat','Please select the ROI info mat file');
if fi
    ffpath = fullfile(fp,fn);
    fDataStc = load(ffpath);
    if isfield(fDataStc,'ROIinfoBU')
        ROIposAll = fDataStc.ROIinfoBU.ROIpos;
    elseif isfield(fDataStc,'ROIinfo')
        ROIposAll = fDataStc.ROIinfo(1).ROIpos;
    else
        error('Unrecognized mat file data contains');
    end
    DataStrc.ROIpos = ROIposAll;
end
    

function ROIsize_Callback(hObject, eventdata, handles)
global DataStrc
% hObject    handle to ROIsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROIsize as text
%        str2double(get(hObject,'String')) returns contents of ROIsize as a double
DataStrc.ROISurSize = str2double(get(hObject,'String'));
ROIsizeRange = DataStrc.ROISurSize;
FSize = DataStrc.FrameSize;
cROInum = str2num(get(handles.ROINum,'string'));
cROIpos = DataStrc.ROIpos{cROInum};
cFrameScale=[];
cFrameScale(1) = get(handles.climSlide,'Min');
cFrameScale(2) = get(handles.climSlide,'Value');
ROIcenter = round(mean(cROIpos));
xRange = ROIcenter(1) + [ROIsizeRange*(-1),ROIsizeRange];
yRange = ROIcenter(2) + [ROIsizeRange*(-1),ROIsizeRange];
xRange = min(xRange,FSize(1));
xRange = max(xRange,1);
yRange = min(yRange,FSize(1));
yRange = max(yRange,1);
MeanData = DataStrc.MeanFData(xRange(1):xRange(2),yRange(1):yRange(2));
MaxData = DataStrc.MaxDeltaData(xRange(1):xRange(2),yRange(1):yRange(2));

axes(handles.MeanFigureAxes);
imagesc(MeanData,cFrameScale);

axes(handles.MaxDFigureAxes);
imagesc(MaxData,cFrameScale);

% --- Executes during object creation, after setting all properties.
function ROIsize_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIsize (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','20');
