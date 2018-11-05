function varargout = SameNeuron_acrossSess_check(varargin)
% SAMENEURON_ACROSSSESS_CHECK MATLAB code for SameNeuron_acrossSess_check.fig
%      SAMENEURON_ACROSSSESS_CHECK, by itself, creates a new SAMENEURON_ACROSSSESS_CHECK or raises the existing
%      singleton*.
%
%      H = SAMENEURON_ACROSSSESS_CHECK returns the handle to a new SAMENEURON_ACROSSSESS_CHECK or the handle to
%      the existing singleton*.
%
%      SAMENEURON_ACROSSSESS_CHECK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SAMENEURON_ACROSSSESS_CHECK.M with the given input arguments.
%
%      SAMENEURON_ACROSSSESS_CHECK('Property','Value',...) creates a new SAMENEURON_ACROSSSESS_CHECK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SameNeuron_acrossSess_check_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SameNeuron_acrossSess_check_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SameNeuron_acrossSess_check

% Last Modified by GUIDE v2.5 02-Nov-2018 12:45:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SameNeuron_acrossSess_check_OpeningFcn, ...
                   'gui_OutputFcn',  @SameNeuron_acrossSess_check_OutputFcn, ...
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


% --- Executes just before SameNeuron_acrossSess_check is made visible.
function SameNeuron_acrossSess_check_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SameNeuron_acrossSess_check (see VARARGIN)
global GUIdataSummary
% Choose default command line output for SameNeuron_acrossSess_check
handles.output = hObject;

GUIdataSummary.Sess1Path = '';
GUIdataSummary.Sess2Path = '';
GUIdataSummary.Sess3Path = '';
GUIdataSummary.Sess4Path = '';
GUIdataSummary.ROINum = 1;
GUIdataSummary.TotalROINum = [0,0,0,0]; % total ROINum for each session
GUIdataSummary.SessMorphPath = {'';'';'';''}; % ROI morph path for each session
GUIdataSummary.SessColorPlotPath = {'';'';'';''}; % ROI colorplot path for each session
GUIdataSummary.SessBehavPlotPath = {'';'';'';''}; % ROI behav path for each session
GUIdataSummary.OpenedFig = [];
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SameNeuron_acrossSess_check wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SameNeuron_acrossSess_check_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


function load_sessionPlots(handles,SessIndex,CommonROIs)
global GUIdataSummary
cSessTunPath = GUIdataSummary.(sprintf('Sess%dPath',SessIndex));
cSessMorphPath = GUIdataSummary.SessMorphPath{SessIndex};
cSessTotalROI = GUIdataSummary.TotalROINum;
cSessBehavPath = GUIdataSummary.SessBehavPlotPath{SessIndex};
if CommonROIs > cSessTotalROI
    warning('Current ROINumber %d is larger than max ROINumber %d.\n',CommonROIs, cSessTotalROI(SessIndex));
    return;
end
cRTunCurvePath = fullfile(cSessTunPath,sprintf('ROI%d Tunning curve comparison plot.png',CommonROIs));
cRMorphPath = fullfile(cSessMorphPath,sprintf('ROI%d morph plot save.png',CommonROIs));
cRBehavPath = fullfile(cSessBehavPath,'Behav_fit plot.png');

if exist(cRTunCurvePath,'file')
    cRTunPlotid = imread(cRTunCurvePath);
    axes(handles.(sprintf('Sess%dTunCurve_tag',SessIndex)));
    imshow(cRTunPlotid);
end
if exist(cRMorphPath,'file')
    cRMorphid = imread(cRMorphPath);
    axes(handles.(sprintf('Sess%dROIMorph_tag',SessIndex)));
    imshow(cRMorphid);
end
if exist(cRBehavPath,'file')
    cBehavid = imread(cRBehavPath);
    axes(handles.(sprintf('Sess%dBehav_tag',SessIndex)));
    imshow(cBehavid);
end
    


function SessPathEdit_Fun(hObject, eventdata, handles, SessIndex)
global GUIdataSummary
InputString = get(hObject,'String');
if isempty(InputString)
    return;
end
if ~isdir(InputString)
    fprintf('Current Input is not a valid folder,quit function.\n');
    return;
elseif isempty(strfind(InputString,'result_save\plot_save'))
    fprintf('Current Input is not a valid 2p data path,quit function.\n');
    return;
end
set(handles.(sprintf('Sess%dROIEdit_tag',SessIndex)),'String',num2str(GUIdataSummary.ROINum));
TunCurvePath = fullfile(InputString,'Tunning_fun_plot_New1s','ROI* Tunning curve comparison plot.png');
NumFiles = dir(TunCurvePath);
set(handles.(sprintf('Sess%d_totalROI_tag',SessIndex)),'String',num2str(length(NumFiles)));
GUIdataSummary.TotalROINum(SessIndex) = length(NumFiles);
GUIdataSummary.(sprintf('Sess%dPath',SessIndex)) = fullfile(InputString,'Tunning_fun_plot_New1s');
[~,EndInds] = regexp(InputString,'result_save');
ROIposfilePath = InputString(1:EndInds);
GUIdataSummary.SessMorphPath{SessIndex} = fullfile(ROIposfilePath,'ROI_morph_plot');
GUIdataSummary.SessColorPlotPath{SessIndex} = fullfile(InputString,'All BehavType Colorplot');
Anminfo = SessInfoExtraction(InputString);
set(handles.(sprintf('Sess%dInfo_tag',SessIndex)),'String',...
    sprintf('Batch:%s Anm:%s \nDate:%s Field:%s\n',...
        Anminfo.BatchNum,Anminfo.AnimalNum,Anminfo.SessionDate,Anminfo.TestNum));
TempBehavPath = fullfile(InputString,'RandP_data_plots');
GUIdataSummary.SessBehavPlotPath{SessIndex} = TempBehavPath;
if ~exist(fullfile(GUIdataSummary.SessMorphPath{SessIndex},'MorphDataAll.mat'),'file')
    fprintf('ROI morph file seems not exists, please check the input path.\n');
    GUIdataSummary.SessMorphPath{SessIndex} = '';
    return;
end


function SessColorplot_openFun(hObject, eventdata, handles, SessIndex)
global GUIdataSummary
cUsedPath = fullfile(GUIdataSummary.SessColorPlotPath{SessIndex});
cColorPlotid = fullfile(cUsedPath,sprintf('ROI%d all behavType color plot.png',GUIdataSummary.ROINum));
hf = figure('position',[10 10 1500 900]);
imshow(cColorPlotid);
clc
GUIdataSummary.OpenedFig = hf;


function Sess1PathEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess1PathEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SessPathEdit_Fun(hObject, eventdata, handles,1);

% Hints: get(hObject,'String') returns contents of Sess1PathEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of Sess1PathEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function Sess1PathEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sess1PathEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sess1Load_tag.
function Sess1Load_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess1Load_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary
if isempty(GUIdataSummary.Sess1Path)
    warning('Please input a valid session path before loading images.\n');
    return;
else
    load_sessionPlots(handles,1,GUIdataSummary.ROINum);
end


function Sess1ROIEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess1ROIEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary
ComROIs = str2double(get(hObject,'String'));
if isempty(ComROIs)
    return;
end
set(hObject,'BackgroundColor','white');
GUIdataSummary.ROINum = ComROIs;
SyncROIplot_updates(hObject, eventdata, handles);


function SyncROIplot_updates(hObject, eventdata, handles)
global GUIdataSummary
ComROIs = GUIdataSummary.ROINum;
for USess = 1 : 4
    if GUIdataSummary.TotalROINum(USess)
        set(handles.(sprintf('Sess%dROIEdit_tag',USess)),'BackgroundColor','white');
        set(handles.(sprintf('Sess%dROIEdit_tag',USess)),'String',num2str(ComROIs));
        if ComROIs >  GUIdataSummary.TotalROINum(USess)
            fprintf('Input ROI number is larger than total ROINum for session %d.\n',USess);
            cla(handles.(sprintf('Sess%dTunCurve_tag',USess)));
            cla(handles.(sprintf('Sess%dROIMorph_tag',USess)));
            cla(handles.(sprintf('Sess%dBehav_tag',USess)));
            set(handles.(sprintf('Sess%dROIEdit_tag',USess)),'BackgroundColor','red');
            continue;
        end
        eval(sprintf('Sess%dLoad_tag_Callback(hObject, eventdata, handles);',USess));
    end
end
        
        
% Hints: get(hObject,'String') returns contents of Sess1ROIEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of Sess1ROIEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function Sess1ROIEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sess1ROIEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sess1ShowColorPlot_tag.
function Sess1ShowColorPlot_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess1ShowColorPlot_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SessColorplot_openFun(hObject, eventdata, handles, 1);


function Sess2PathEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess2PathEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SessPathEdit_Fun(hObject, eventdata, handles, 2);
% Hints: get(hObject,'String') returns contents of Sess2PathEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of Sess2PathEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function Sess2PathEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sess2PathEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sess2Load_tag.
function Sess2Load_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess2Load_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary
if isempty(GUIdataSummary.Sess2Path)
    warning('Please input a valid session path before loading images.\n');
    return;
else
    load_sessionPlots(handles,2,GUIdataSummary.ROINum);
end



function Sess2ROIEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess2ROIEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary
ComROIs = str2double(get(hObject,'String'));
if isempty(ComROIs)
    return;
end
set(hObject,'BackgroundColor','white');
GUIdataSummary.ROINum = ComROIs;
SyncROIplot_updates(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of Sess2ROIEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of Sess2ROIEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function Sess2ROIEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sess2ROIEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sess2ShowColorPlot_tag.
function Sess2ShowColorPlot_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess2ShowColorPlot_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SessColorplot_openFun(hObject, eventdata, handles, 2);


function Sess3PathEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess3PathEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SessPathEdit_Fun(hObject, eventdata, handles, 3);
% Hints: get(hObject,'String') returns contents of Sess3PathEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of Sess3PathEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function Sess3PathEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sess3PathEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sess3Load_tag.
function Sess3Load_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess3Load_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary
if isempty(GUIdataSummary.Sess3Path)
    warning('Please input a valid session path before loading images.\n');
    return;
else
    load_sessionPlots(handles,3,GUIdataSummary.ROINum);
end



function Sess3ROIEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess3ROIEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary
ComROIs = str2double(get(hObject,'String'));
if isempty(ComROIs)
    return;
end
set(hObject,'BackgroundColor','white');
GUIdataSummary.ROINum = ComROIs;
SyncROIplot_updates(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of Sess3ROIEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of Sess3ROIEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function Sess3ROIEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sess3ROIEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sess3ShowColorPlot_tag.
function Sess3ShowColorPlot_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess3ShowColorPlot_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SessColorplot_openFun(hObject, eventdata, handles, 3);


function Sess4PathEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess4PathEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SessPathEdit_Fun(hObject, eventdata, handles,4);
% Hints: get(hObject,'String') returns contents of Sess4PathEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of Sess4PathEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function Sess4PathEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sess4PathEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sess4Load_tag.
function Sess4Load_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess4Load_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary
if isempty(GUIdataSummary.Sess4Path)
    warning('Please input a valid session path before loading images.\n');
    return;
else
    load_sessionPlots(handles,4,GUIdataSummary.ROINum);
end



function Sess4ROIEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess4ROIEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary
ComROIs = str2double(get(hObject,'String'));
if isempty(ComROIs)
    return;
end
set(hObject,'BackgroundColor','white');
GUIdataSummary.ROINum = ComROIs;
SyncROIplot_updates(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of Sess4ROIEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of Sess4ROIEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function Sess4ROIEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Sess4ROIEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Sess4ShowColorPlot_tag.
function Sess4ShowColorPlot_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Sess4ShowColorPlot_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
SessColorplot_openFun(hObject, eventdata, handles, 4);


% --- Executes on button press in ROINumPlus.
function ROINumPlus_Callback(hObject, eventdata, handles)
% hObject    handle to ROINumPlus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary

GUIdataSummary.ROINum = GUIdataSummary.ROINum + 1;
SyncROIplot_updates(hObject, eventdata, handles);

% --- Executes on button press in ROINumMinus.
function ROINumMinus_Callback(hObject, eventdata, handles)
% hObject    handle to ROINumMinus (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary

GUIdataSummary.ROINum = GUIdataSummary.ROINum - 1;
if GUIdataSummary.ROINum < 1
    GUIdataSummary.ROINum = 1;
end
SyncROIplot_updates(hObject, eventdata, handles);


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
global GUIdataSummary
switch eventdata.Key   %'uparrow','downarrow','leftarrow','rightarrow'.
    case 'rightarrow'
        ROINumPlus_Callback(hObject, eventdata, handles)
    case 'leftarrow'
        ROINumMinus_Callback(hObject, eventdata, handles)
    case 'space'
        if ishandle(GUIdataSummary.OpenedFig)
            delete(GUIdataSummary.OpenedFig);
        end
        GUIdataSummary.OpenedFig = [];
%     case 'uparrow'
%         TwoStepPreTrial_Callback(hObject, eventdata, handles);
%     case 'a'
%         % add new ROI
%         ROI_add_Callback(hObject, eventdata, handles);
%     case 's'
%         % set ROI
%         Set_ROI_button_Callback(hObject, eventdata, handles)
    otherwise
%         fprintf('Key pressed without response.\n');
end


% --- Executes on key press with focus on Sess3ShowColorPlot_tag and none of its controls.
function Sess3ShowColorPlot_tag_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Sess3ShowColorPlot_tag (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
figure1_KeyPressFcn(hObject, eventdata, handles);


% --- Executes on key press with focus on Sess1ShowColorPlot_tag and none of its controls.
function Sess1ShowColorPlot_tag_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Sess1ShowColorPlot_tag (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
figure1_KeyPressFcn(hObject, eventdata, handles);

% --- Executes on key press with focus on Sess2ShowColorPlot_tag and none of its controls.
function Sess2ShowColorPlot_tag_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Sess2ShowColorPlot_tag (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
figure1_KeyPressFcn(hObject, eventdata, handles);

% --- Executes on key press with focus on Sess4ShowColorPlot_tag and none of its controls.
function Sess4ShowColorPlot_tag_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to Sess4ShowColorPlot_tag (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
figure1_KeyPressFcn(hObject, eventdata, handles);


% --- Executes on key press with focus on ROINumPlus and none of its controls.
function ROINumPlus_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ROINumPlus (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
figure1_KeyPressFcn(hObject, eventdata, handles);

% --- Executes on key press with focus on ROINumMinus and none of its controls.
function ROINumMinus_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to ROINumMinus (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.UICONTROL)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
figure1_KeyPressFcn(hObject, eventdata, handles);