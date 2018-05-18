function varargout = VisualCellMorphCheck(varargin)
% VISUALCELLMORPHCHECK MATLAB code for VisualCellMorphCheck.fig
%      VISUALCELLMORPHCHECK, by itself, creates a new VISUALCELLMORPHCHECK or raises the existing
%      singleton*.
%
%      H = VISUALCELLMORPHCHECK returns the handle to a new VISUALCELLMORPHCHECK or the handle to
%      the existing singleton*.
%
%      VISUALCELLMORPHCHECK('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in VISUALCELLMORPHCHECK.M with the given input arguments.
%
%      VISUALCELLMORPHCHECK('Property','Value',...) creates a new VISUALCELLMORPHCHECK or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before VisualCellMorphCheck_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to VisualCellMorphCheck_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help VisualCellMorphCheck

% Last Modified by GUIDE v2.5 12-Apr-2018 17:52:44

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @VisualCellMorphCheck_OpeningFcn, ...
                   'gui_OutputFcn',  @VisualCellMorphCheck_OutputFcn, ...
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


% --- Executes just before VisualCellMorphCheck is made visible.
function VisualCellMorphCheck_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to VisualCellMorphCheck (see VARARGIN)
global VisualObjData
VisualObjData.RefPath = '';
VisualObjData.TargetPath = '';
VisualObjData.cROI = 1;
VisualObjData.ROINum = [1,1];
VisualObjData.RefROIDataAll = [];
VisualObjData.TargetROIDataAll = [];
VisualObjData.RefROIData = [];
VisualObjData.TargetROIData = [];
VisualObjData.ROIIsCheck = ones(min(VisualObjData.ROINum),1);
VisualObjData.ROICorrP = [];

% Choose default command line output for VisualCellMorphCheck
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes VisualCellMorphCheck wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = VisualCellMorphCheck_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function RefPath_Callback(hObject, eventdata, handles)
% hObject    handle to RefPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VisualObjData
cStr = get(hObject,'String');
if ~isempty(cStr)
    if isdir(cStr)
        VisualObjData.RefPath = cStr;
        RefMorphf = fullfile(cStr,'MorphDataAll.mat');
        if exist(RefMorphf,'file')
            cDataMorphStrc = load(RefMorphf);
            VisualObjData.RefROIDataAll = cDataMorphStrc.ROIMorphData;
            VisualObjData.ROINum(1) = size(cDataMorphStrc.ROIMorphData,1);
            
            % plot ROI data
            cROI = str2num(get(handles.ROINum,'String'));
            if cROI < 1 || cROI > size(cDataMorphStrc.ROIMorphData,1)
                warning('ROI index out of range');
            else
                cROIData = cDataMorphStrc.ROIMorphData{cROI,1};
                cROIBoarders = cDataMorphStrc.ROIMorphData{cROI,2};
                VisualObjData.RefROIData = cROIData;
                ROIClim = [0 prctile(cROIData(:),90)];
                axes(handles.RefROIMorphAxes);
                imagesc(cROIData,ROIClim);
                colormap gray
                line(cROIBoarders(:,1),cROIBoarders(:,2),'Color','r','linewidth',2);
            end
        else
            warning('Target path file: %s not exists',RefMorphf);
        end
    else
        warning('Target path: %s not a path',cStr);
    end
end
if ~isempty(VisualObjData.RefROIDataAll) && ~isempty(VisualObjData.TargetROIDataAll)
    VisualObjData.ROIIsCheck = ones(min(VisualObjData.ROINum),1);
    set(handles.ROIsameCheck,'Value',VisualObjData.ROIIsCheck(VisualObjData.cROI));
    ROICorrCheckTest(handles);
end
% Hints: get(hObject,'String') returns contents of RefPath as text
%        str2double(get(hObject,'String')) returns contents of RefPath as a double


% --- Executes during object creation, after setting all properties.
function RefPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RefPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');

% --- Executes on button press in RefPBrowser.
function RefPBrowser_Callback(hObject, eventdata, handles)
% hObject    handle to RefPBrowser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NewDirs = uigetdir(pwd,'Please select the reference ROI morph data path');
set(handles.RefPath,'String',NewDirs);
RefPath_Callback(handles.RefPath, eventdata, handles);


function TargetPath_Callback(hObject, eventdata, handles)
% hObject    handle to TargetPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VisualObjData
cStr = get(hObject,'String');
if ~isempty(cStr)
    if isdir(cStr)
        VisualObjData.TargetPath = cStr;
        TargetMorphf = fullfile(cStr,'MorphDataAll.mat');
        if exist(TargetMorphf,'file')
            cDataMorphStrc = load(TargetMorphf);
            VisualObjData.TargetROIDataAll = cDataMorphStrc.ROIMorphData;
            VisualObjData.ROINum(2) = size(cDataMorphStrc.ROIMorphData,1);
            
            % plot ROI data
            cROI = str2num(get(handles.ROINum,'String'));
            if cROI < 1 || cROI > size(cDataMorphStrc.ROIMorphData,1)
                warning('ROI index out of range');
            else
                cROIData = cDataMorphStrc.ROIMorphData{cROI,1};
                cROIBoarders = cDataMorphStrc.ROIMorphData{cROI,2};
                VisualObjData.TargetROIData = cROIData;
                ROIClim = [0 prctile(cROIData(:),90)];
                axes(handles.TargROIMorphAxes);
                imagesc(cROIData,ROIClim);
                colormap gray
                line(cROIBoarders(:,1),cROIBoarders(:,2),'Color','r','linewidth',2);
            end
        else
            warning('Target path file: %s not exists',TargetMorphf);
        end
    else
        warning('Target path: %s not a path',cStr);
    end
end
if ~isempty(VisualObjData.RefROIDataAll) && ~isempty(VisualObjData.TargetROIDataAll)
    VisualObjData.ROIIsCheck = ones(min(VisualObjData.ROINum),1);
    set(handles.ROIsameCheck,'Value',VisualObjData.ROIIsCheck(VisualObjData.cROI));
    ROICorrCheckTest(handles);
end
% Hints: get(hObject,'String') returns contents of TargetPath as text
%        str2double(get(hObject,'String')) returns contents of TargetPath as a double


% --- Executes during object creation, after setting all properties.
function TargetPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TargetPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','');

% --- Executes on button press in TargetPBrowser.
function TargetPBrowser_Callback(hObject, eventdata, handles)
% hObject    handle to TargetPBrowser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
NewDirs = uigetdir(pwd,'Please select the target ROI morph data path');
set(handles.TargetPath,'String',NewDirs);
TargetPath_Callback(handles.TargetPath, eventdata, handles);


function ROINum_Callback(hObject, eventdata, handles)
% hObject    handle to ROINum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VisualObjData
% Hints: get(hObject,'String') returns contents of ROINum as text
%        str2double(get(hObject,'String')) returns contents of ROINum as a double
cInputNum = str2num(get(hObject,'String'));
if ~isempty(cInputNum)
    if cInputNum >= 1 && cInputNum <= min(VisualObjData.ROINum)
        VisualObjData.cROI = cInputNum;
        if ~isempty(VisualObjData.RefROIDataAll)
            cROIRefData = VisualObjData.RefROIDataAll(cInputNum,:);
            VisualObjData.RefROIData = cROIRefData{1};
            axes(handles.RefROIMorphAxes);
            ROIClim = [0,prctile(cROIRefData{1}(:),80)];
            imagesc(cROIRefData{1},ROIClim);
            colormap gray
            line(cROIRefData{2}(:,1),cROIRefData{2}(:,2),'Color','r','Linewidth',2);
        end
        if ~isempty(VisualObjData.TargetROIDataAll)
            cROITargData = VisualObjData.TargetROIDataAll(cInputNum,:);
            VisualObjData.TargetROIData = cROITargData{1};
            axes(handles.TargROIMorphAxes);
            ROIclim = [0,prctile(cROITargData{1}(:),80)];
            imagesc(cROITargData{1},ROIclim);
            colormap gray
            line(cROITargData{2}(:,1),cROITargData{2}(:,2),'Color','r','Linewidth',2);
        end
    end
end


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
set(hObject,'String','1');

% --- Executes on button press in ROINumDe.
function ROINumDe_Callback(hObject, eventdata, handles)
% hObject    handle to ROINumDe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VisualObjData
cROI = VisualObjData.cROI;
cROINew = cROI - 1;
MaxROIV = min(VisualObjData.ROINum);
if cROINew < 1
    cROINew = MaxROIV;
end
VisualObjData.cROI = cROINew;
set(handles.ROINum,'string',num2str(cROINew));
ROINum_Callback(handles.ROINum, eventdata, handles);
ROICorrCheckTest(handles);


% --- Executes on button press in ROINumIe.
function ROINumIe_Callback(hObject, eventdata, handles)
% hObject    handle to ROINumIe (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VisualObjData
cROI = VisualObjData.cROI;
cROINew = cROI + 1;
MaxROIV = min(VisualObjData.ROINum);
if cROINew > MaxROIV
    cROINew = 1;
end
VisualObjData.cROI = cROINew;
set(handles.ROINum,'string',num2str(cROINew));
ROINum_Callback(handles.ROINum, eventdata, handles);
ROICorrCheckTest(handles);


function ROICorrCheckTest(handles,varargin)
% function to determin ROI data morphology correlation and check or not
global VisualObjData
if ~isempty(VisualObjData.RefROIData) && ~isempty(VisualObjData.TargetROIData)
    RefData = VisualObjData.RefROIData;
    TagData = VisualObjData.TargetROIData;
    if numel(RefData) == numel(TagData)
        [Corr,P] = corrcoef(RefData(:),TagData(:));
        set(handles.ROICorrData,'string',num2str(Corr(1,2),'%.4f'));
        set(handles.Corr_p_value,'string',num2str(P(1,2),'%.3e'));
        VisualObjData.ROICorrP(VisualObjData.cROI,:) = [Corr(1,2),P(1,2)];
    else
        set(handles.ROICorrData,'string','NaN');
        set(handles.Corr_p_value,'string','NaN');
        VisualObjData.ROICorrP(VisualObjData.cROI,:) = [NaN,NaN];
    end
end
set(handles.ROIsameCheck,'value',VisualObjData.ROIIsCheck(VisualObjData.cROI));


% --- Executes on button press in ROIsameCheck.
function ROIsameCheck_Callback(hObject, eventdata, handles)
% hObject    handle to ROIsameCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VisualObjData
cValue = get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of ROIsameCheck
VisualObjData.ROIIsCheck(VisualObjData.cROI) = cValue;


function ROICorrData_Callback(hObject, eventdata, handles)
% hObject    handle to ROICorrData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ROICorrData as text
%        str2double(get(hObject,'String')) returns contents of ROICorrData as a double


% --- Executes during object creation, after setting all properties.
function ROICorrData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROICorrData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Corr_p_value_Callback(hObject, eventdata, handles)
% hObject    handle to Corr_p_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of Corr_p_value as text
%        str2double(get(hObject,'String')) returns contents of Corr_p_value as a double


% --- Executes during object creation, after setting all properties.
function Corr_p_value_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Corr_p_value (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in DataSave.
function DataSave_Callback(hObject, eventdata, handles)
% hObject    handle to DataSave (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global VisualObjData
RefInfo = SessInfoExtraction(VisualObjData.RefPath);
TagInfo = SessInfoExtraction(VisualObjData.TargetPath);
SaveName = sprintf('Sess_%s_%s_%s_%sSave.mat',RefInfo.SessionDate,RefInfo.TestNum,...
    TagInfo.SessionDate,TagInfo.TestNum);
SaveDataDir = uigetdir(pwd,'Please select current data savage path');
UsedROINum = zeros(min(VisualObjData.ROINum),2);
for ccroi = 1 : UsedROINum
    cROIRefData = VisualObjData.RefROIDataAll{ccroi,1};
    cROITagData = VisualObjData.TargetROIDataAll{ccroi,1};
    if numel(cROIRefData) == numel(cROITagData)
        [Corrs,ps] = corrcoef(cROIRefData(:),cROITagData(:));
        UsedROINum(ccroi,:) = [Corrs(1,2),ps(1,2)];
    else
        UsedROINum(ccroi,:) = [NaN,NaN];
    end
end
VisualObjData.ROICorrP = UsedROINum;
cd(SaveDataDir);
save(fullfile(SaveDataDir,SaveName),'VisualObjData','-v7.3');
fprintf('File Saved in: %s.\n',fullfile(SaveDataDir,SaveName));


% --- Executes on key press with focus on figure1 and none of its controls.
function figure1_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key   %'uparrow','downarrow','leftarrow','rightarrow'.
    case 'rightarrow'
        ROINumIe_Callback(hObject, eventdata, handles);
    case 'leftarrow'
        ROINumDe_Callback(hObject, eventdata, handles);
%     case 'downarrow'
%         TwoStepNextTrial_Callback(hObject, eventdata, handles);
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
