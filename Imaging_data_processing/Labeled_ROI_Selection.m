function varargout = Labeled_ROI_Selection(varargin)
% LABELED_ROI_SELECTION MATLAB code for Labeled_ROI_Selection.fig
%      LABELED_ROI_SELECTION, by itself, creates a new LABELED_ROI_SELECTION or raises the existing
%      singleton*.
%
%      H = LABELED_ROI_SELECTION returns the handle to a new LABELED_ROI_SELECTION or the handle to
%      the existing singleton*.
%
%      LABELED_ROI_SELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in LABELED_ROI_SELECTION.M with the given input arguments.
%
%      LABELED_ROI_SELECTION('Property','Value',...) creates a new LABELED_ROI_SELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Labeled_ROI_Selection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Labeled_ROI_Selection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Labeled_ROI_Selection

% Last Modified by GUIDE v2.5 08-Sep-2016 21:06:11

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Labeled_ROI_Selection_OpeningFcn, ...
                   'gui_OutputFcn',  @Labeled_ROI_Selection_OutputFcn, ...
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


% --- Executes just before Labeled_ROI_Selection is made visible.
function Labeled_ROI_Selection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Labeled_ROI_Selection (see VARARGIN)
global CurrentGUIdata
CurrentGUIdata.filePath = '';
CurrentGUIdata.filename = '';
CurrentGUIdata.ImageData = [];
CurrentGUIdata.ChannelNum = [];
CurrentGUIdata.ChannelIndex = {};
CurrentGUIdata.MeanImageData = [];
CurrentGUIdata.RGBPlotData = [];
CurrentGUIdata.LabeledROIs = [];
CurrentGUIdata.ROIinfos = [];

% Choose default command line output for Labeled_ROI_Selection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Labeled_ROI_Selection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Labeled_ROI_Selection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in FileLoad.
function FileLoad_Callback(hObject, eventdata, handles)
% hObject    handle to FileLoad (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CurrentGUIdata
[fn,fp,fi] = uigetfile('*.tif','Please select an multi-channel tif file');
CurrentGUIdata.filePath = fp;
CurrentGUIdata.filename = fn;
if fi
    cd(fp);
    fprintf('Loading file %s ...\n',fn);
    [im_data,im_header] = load_scim_data(fullfile(fp,fn));
    CurrentGUIdata.ImageData = im_data;
    [FrameRow,FrameCol,FrameNUm] = size(im_data);
    im_dataDouble = double(im_data);
    ChannelNUm = length(im_header.SI4.channelsSave);
    CurrentGUIdata.ChannelNum = ChannelNUm;
    if ChannelNUm < 2
        fprintf('Not a multichannel tif file, quit analysis.\n');
        return;
    end
    StartFrameIndex = str2num(get(handles.FrameScale1,'String'));
    EndFrameIndex = str2num(get(handles.FrameScale2,'String'));
    ChannelFrames = cell(ChannelNUm,1);  % used to storage the frame index for each channel
    MeanChannelData = zeros(FrameRow,FrameCol,ChannelNUm);
    for Nchannel = 1 : ChannelNUm 
        TotalFileNumber = Nchannel:ChannelNUm:FrameNUm;
        SelectFramesInds = TotalFileNumber > StartFrameIndex & TotalFileNumber < EndFrameIndex;
        ChannelFrames(Nchannel) = {TotalFileNumber(SelectFramesInds)};
        MeanChannelData(:,:,Nchannel) = squeeze(mean(im_dataDouble(:,:,ChannelFrames{Nchannel}),3));
    end
    CurrentGUIdata.ChannelIndex = ChannelFrames;
    CurrentGUIdata.MeanImageData = MeanChannelData;
end

% --- Executes on button press in OpenInImageJ.
function OpenInImageJ_Callback(hObject, eventdata, handles)
% hObject    handle to OpenInImageJ (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CurrentGUIdata
ImageJpath = get(handles.ImageJPath,'String');
FilePath = fullfile(CurrentGUIdata.filePath,CurrentGUIdata.filename);
if exist(FilePath,'file')
    system([ImageJpath ' ' FilePath]);
end


function ImageJPath_Callback(hObject, eventdata, handles)
% hObject    handle to ImageJPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
InputPath = get(hObject,'String');
if exist(InputPath,'file')
    set(hObject,'String',InputPath);
else
    set(hObject,'String','Invalid file path');
end
% Hints: get(hObject,'String') returns contents of ImageJPath as text
%        str2double(get(hObject,'String')) returns contents of ImageJPath as a double


% --- Executes during object creation, after setting all properties.
function ImageJPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImageJPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

if exist('D:\Fiji.app\ImageJ-win64.exe','file')
    set(hObject,'String','D:\Fiji.app\ImageJ-win64.exe');
end

% --- Executes on button press in ImageJPBro.
function ImageJPBro_Callback(hObject, eventdata, handles)
% hObject    handle to ImageJPBro (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[fn,fp,fi] = uigetfile('*.exe','Please select your ImageJ app file path');
if fi
    FullPathImagej = fullfile(fp,fn);
    set(handles.ImageJPath,'String',FullPathImagej);
end


% --- Executes on button press in FigPlotShow.
function FigPlotShow_Callback(hObject, eventdata, handles)
% hObject    handle to FigPlotShow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CurrentGUIdata
GreenChannelScale = [str2num(get(handles.GreenScaleMin,'String')),str2num(get(handles.GreenScaleMax,'String'))];
RedChannelScale = [str2num(get(handles.RedScaleMin,'String')),str2num(get(handles.RedScaleMax,'String'))];
BlueChannelScale = [str2num(get(handles.BlueScaleMin,'String')),str2num(get(handles.BlueScaleMax,'String'))];
MeanChannelData = CurrentGUIdata.MeanImageData;
[FrameRow,FrameCol,~] = size(MeanChannelData);

GreenDataset = squeeze(MeanChannelData(:,:,1));
GreenCDataset = (GreenDataset - GreenChannelScale(1))/(GreenChannelScale(2) - GreenChannelScale(1));
GreenCDataset(GreenCDataset < 0) = 0;
GreenCDataset(GreenCDataset > 1) = 1;
RedDataset = squeeze(MeanChannelData(:,:,2));
RedCDataset = (RedDataset - RedChannelScale(1))/(RedChannelScale(2) - RedChannelScale(1));
RedCDataset(RedCDataset < 0) = 0;
RedCDataset(RedCDataset > 1) = 1;
if CurrentGUIdata.ChannelNum < 3
    BlueCDataset = zeros(FrameRow,FrameCol);
else
    BlueDataset = squeeze(MeanChannelData(:,:,3));
    BlueCDataset = (BlueDataset - BlueChannelScale(1))/(BlueChannelScale(2) - BlueChannelScale(1));
    BlueCDataset(BlueCDataset < 0) = 0;
    BlueCDataset(BlueCDataset > 1) = 1;
end
ImageData(:,:,1) = RedCDataset;
ImageData(:,:,2) = GreenCDataset;
ImageData(:,:,3) = BlueCDataset;
CurrentGUIdata.RGBPlotData = ImageData;
axes(handles.ImageAxes);
imagesc(ImageData);


function FrameScale1_Callback(hObject, eventdata, handles)
% hObject    handle to FrameScale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CurrentGUIdata
im_data = CurrentGUIdata.ImageData;
im_dataDouble = double(im_data);
[FrameRow,FrameCol,FrameNUm] = size(im_data);
ChannelNUm = CurrentGUIdata.ChannelNum;
StartFrameIndex = str2num(get(handles.FrameScale1,'String'));
EndFrameIndex = str2num(get(handles.FrameScale2,'String'));
ChannelFrames = cell(ChannelNUm,1);  % used to storage the frame index for each channel
MeanChannelData = zeros(FrameRow,FrameCol,ChannelNUm);
for Nchannel = 1 : ChannelNUm 
    TotalFileNumber = Nchannel:ChannelNUm:FrameNUm;
    SelectFramesInds = TotalFileNumber > StartFrameIndex & TotalFileNumber < EndFrameIndex;
    ChannelFrames(Nchannel) = {TotalFileNumber(SelectFramesInds)};
    MeanChannelData(:,:,Nchannel) = squeeze(mean(im_dataDouble(:,:,ChannelFrames{Nchannel}),3));
end
CurrentGUIdata.ChannelIndex = ChannelFrames;
CurrentGUIdata.MeanImageData = MeanChannelData;

FigPlotShow_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of FrameScale1 as text
%        str2double(get(hObject,'String')) returns contents of FrameScale1 as a double


% --- Executes during object creation, after setting all properties.
function FrameScale1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameScale1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','1');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FrameScale2_Callback(hObject, eventdata, handles)
% hObject    handle to FrameScale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CurrentGUIdata
im_data = CurrentGUIdata.ImageData;
im_dataDouble = double(im_data);
[FrameRow,FrameCol,FrameNUm] = size(im_data);
ChannelNUm = CurrentGUIdata.ChannelNum;
StartFrameIndex = str2num(get(handles.FrameScale1,'String'));
EndFrameIndex = str2num(get(handles.FrameScale2,'String'));
ChannelFrames = cell(ChannelNUm,1);  % used to storage the frame index for each channel
MeanChannelData = zeros(FrameRow,FrameCol,ChannelNUm);
for Nchannel = 1 : ChannelNUm 
    TotalFileNumber = Nchannel:ChannelNUm:FrameNUm;
    SelectFramesInds = TotalFileNumber > StartFrameIndex & TotalFileNumber < EndFrameIndex;
    ChannelFrames(Nchannel) = {TotalFileNumber(SelectFramesInds)};
    MeanChannelData(:,:,Nchannel) = squeeze(mean(im_dataDouble(:,:,ChannelFrames{Nchannel}),3));
end
CurrentGUIdata.ChannelIndex = ChannelFrames;
CurrentGUIdata.MeanImageData = MeanChannelData;

FigPlotShow_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of FrameScale2 as text
%        str2double(get(hObject,'String')) returns contents of FrameScale2 as a double


% --- Executes during object creation, after setting all properties.
function FrameScale2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameScale2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','300');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PlotROIposition.
function PlotROIposition_Callback(hObject, eventdata, handles)
% hObject    handle to PlotROIposition (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CurrentGUIdata
if ~isempty(CurrentGUIdata.RGBPlotData) && ~isempty(CurrentGUIdata.ROIinfos)
    ROIcenter = ROI_insite_label(CurrentGUIdata.ROIinfos,0);
    numROIs = size(ROIcenter,1);
    h_merge = figure('position',[200 100 1000 850]);
    imagesc(CurrentGUIdata.RGBPlotData);
    fprintf('Please select the target ROIs and press return whie finished.\n');
    nLabelROIs = 1;
    LabeledROIindex = [];
    while ishandle(h_merge)
        [cols,rows] = ginput(1);
        if ~isempty(rows)
            text(cols,rows,num2str(nLabelROIs),'color','b','FontSize',14);
            axes(handles.ImageAxes);
            text(cols,rows,num2str(nLabelROIs),'color','b','FontSize',14);
            CROI2AllROIdis = sum((ROIcenter - repmat([cols,rows],numROIs,1)).^2,2);
            [~,I] = min(CROI2AllROIdis);
            LabeledROIindex(nLabelROIs) = I;
            nLabelROIs = nLabelROIs + 1;
            figure(h_merge);
        else
            close(h_merge);
        end
    end
    CurrentGUIdata.LabeledROIs = LabeledROIindex;
    
elseif isempty(CurrentGUIdata.ROIinfos)
    fprintf('No ROIinfo data is given, Please select your ROIinfo file.\n');
    ROIinfoload_Callback(hObject, eventdata, handles);
end
    

% --- Executes on button press in SaveResult.
function SaveResult_Callback(hObject, eventdata, handles)
% hObject    handle to SaveResult (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CurrentGUIdata
AllROIinfo = CurrentGUIdata.ROIinfos;
ROIlabeledIndex = CurrentGUIdata.LabeledROIs;
MeanImageData = CurrentGUIdata.MeanImageData;
SavePath = CurrentGUIdata.filePath;
cd(SavePath);
fprintf('Saving result to %s...\n',[SavePath '\LabeedROIres.mat']);
save LabeedROIres.mat AllROIinfo ROIlabeledIndex MeanImageData -v7.3
% fprintf('Saving result to %s...\n',[SavePath '\LabeedROIres.mat']);



function GreenScaleMax_Callback(hObject, eventdata, handles)
% hObject    handle to GreenScaleMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FigPlotShow_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of GreenScaleMax as text
%        str2double(get(hObject,'String')) returns contents of GreenScaleMax as a double

function GreenScaleMin_Callback(hObject, eventdata, handles)
% hObject    handle to GreenScaleMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FigPlotShow_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of GreenScaleMax as text
%        str2double(get(hObject,'String')) returns contents of GreenScaleMax as a double

% --- Executes during object creation, after setting all properties.
function GreenScaleMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GreenScaleMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','-10');


% --- Executes during object creation, after setting all properties.
function GreenScaleMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GreenScaleMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','300');


function RedScaleMin_Callback(hObject, eventdata, handles)
% hObject    handle to RedScaleMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FigPlotShow_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of RedScaleMin as text
%        str2double(get(hObject,'String')) returns contents of RedScaleMin as a double


% --- Executes during object creation, after setting all properties.
function RedScaleMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RedScaleMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','-10');


function RedScaleMax_Callback(hObject, eventdata, handles)
% hObject    handle to RedScaleMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FigPlotShow_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of RedScaleMax as text
%        str2double(get(hObject,'String')) returns contents of RedScaleMax as a double


% --- Executes during object creation, after setting all properties.
function RedScaleMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RedScaleMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','300');


function BlueScaleMin_Callback(hObject, eventdata, handles)
% hObject    handle to BlueScaleMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FigPlotShow_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of BlueScaleMin as text
%        str2double(get(hObject,'String')) returns contents of BlueScaleMin as a double


% --- Executes during object creation, after setting all properties.
function BlueScaleMin_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlueScaleMin (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','-10');


function BlueScaleMax_Callback(hObject, eventdata, handles)
% hObject    handle to BlueScaleMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
FigPlotShow_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of BlueScaleMax as text
%        str2double(get(hObject,'String')) returns contents of BlueScaleMax as a double


% --- Executes during object creation, after setting all properties.
function BlueScaleMax_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BlueScaleMax (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','300');


% --- Executes on button press in ROIinfoload.
function ROIinfoload_Callback(hObject, eventdata, handles)
% hObject    handle to ROIinfoload (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CurrentGUIdata
[ffn,ffp,ffi] = uigetfile('*.mat','please select your ROIinfo file');
if ffi
    xxxx=load(fullfile(ffp,ffn));
    if isfield(xxxx,'ROIinfo')
        ROInfos = xxxx.ROIinfo(1);
    elseif isfield(xxxx,'ROIinfoBU')
        ROInfos = xxxx.ROIinfoBU;
    else
        error('Error file selected, quit analysis.');
    end
    CurrentGUIdata.ROIinfos = ROInfos;
end