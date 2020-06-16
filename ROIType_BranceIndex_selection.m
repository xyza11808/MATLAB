function varargout = ROIType_BranceIndex_selection(varargin)
% ROITYPE_BRANCEINDEX_SELECTION MATLAB code for ROIType_BranceIndex_selection.fig
%      ROITYPE_BRANCEINDEX_SELECTION, by itself, creates a new ROITYPE_BRANCEINDEX_SELECTION or raises the existing
%      singleton*.
%
%      H = ROITYPE_BRANCEINDEX_SELECTION returns the handle to a new ROITYPE_BRANCEINDEX_SELECTION or the handle to
%      the existing singleton*.
%
%      ROITYPE_BRANCEINDEX_SELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROITYPE_BRANCEINDEX_SELECTION.M with the given input arguments.
%
%      ROITYPE_BRANCEINDEX_SELECTION('Property','Value',...) creates a new ROITYPE_BRANCEINDEX_SELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROIType_BranceIndex_selection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROIType_BranceIndex_selection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROIType_BranceIndex_selection

% Last Modified by GUIDE v2.5 16-Jun-2020 11:45:49

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROIType_BranceIndex_selection_OpeningFcn, ...
                   'gui_OutputFcn',  @ROIType_BranceIndex_selection_OutputFcn, ...
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


% --- Executes just before ROIType_BranceIndex_selection is made visible.
function ROIType_BranceIndex_selection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROIType_BranceIndex_selection (see VARARGIN)

global ROIAndBranchInfoData

ROIAndBranchInfoData.ROIinfoPath = {'',''}; % folder_path and folder_name
ROIAndBranchInfoData.ROIinfoData = [];
ROIAndBranchInfoData.FrameDataPath = {'',''}; % folder_path and folder_name
ROIAndBranchInfoData.FrameDataMeanMax = [];
ROIAndBranchInfoData.ROIInputNum = 0;
ROIAndBranchInfoData.ROIExtraInfo = struct('ROIIndex',[],'ROI_RespType','','ROI_BranchIndex', [],'ROIMask',[],'ROIPos',[]);
ROIAndBranchInfoData.cROIExtraInfo = ROIAndBranchInfoData.ROIExtraInfo;
ROIAndBranchInfoData.TotalROINum = 0;
ROIAndBranchInfoData.SessTrialNum = 0;
ROIAndBranchInfoData.ROIMaskMerged = [];
ROIAndBranchInfoData.MeanOrMaxFig = [1, 0];
ROIAndBranchInfoData.ImageScale = [0, 100];
ROIAndBranchInfoData.FigHandle = [];
ROIAndBranchInfoData.IsOldReplace = 0;

% Choose default command line output for ROIType_BranceIndex_selection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ROIType_BranceIndex_selection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROIType_BranceIndex_selection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ROIInfo_path_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ROIInfo_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
% Hints: get(hObject,'String') returns contents of ROIInfo_path_edit as text
%        str2double(get(hObject,'String')) returns contents of ROIInfo_path_edit as a double
InputString = get(hObject,'String');
if ~exist(InputString,'file')
    pathpartsInds = strfind(InputString,filesep);
    try 
        InfoDatas = load(pathpartsInds,'ROIinfoBU');
    catch
        warning('No target data found in input path, please check your input string');
        return;
    end
    ROIAndBranchInfoData.ROIinfoPath = {InputString(1:pathpartsInds(end)-1), ...
        InputString((pathpartsInds(end)+1) : end)};
    ROIAndBranchInfoData.ROIinfoData = InfoDatas.ROIinfoBU;
end
    
    
% --- Executes during object creation, after setting all properties.
function ROIInfo_path_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIInfo_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FrameData_path_edit_Callback(hObject, eventdata, handles)
% hObject    handle to FrameData_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
% Hints: get(hObject,'String') returns contents of FrameData_path_edit as text
%        str2double(get(hObject,'String')) returns contents of FrameData_path_edit as a double
InputString = get(hObject,'String');
if ~exist(InputString,'file')
    pathpartsInds = strfind(InputString,filesep);
    try 
        InfoDatas = load(pathpartsInds,'FrameProjSave');
    catch
        warning('No target data found in input path, please check your input string');
        return;
    end
    ROIAndBranchInfoData.FrameDataPath = {InputString(1:pathpartsInds(end)-1), ...
        InputString((pathpartsInds(end)+1) : end)};
    ROIAndBranchInfoData.FrameDataMeanMax = InfoDatas.FrameProjSave;
end

% --- Executes during object creation, after setting all properties.
function FrameData_path_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameData_path_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_Index_edit_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_Index_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
% Hints: get(hObject,'String') returns contents of ROI_Index_edit as text
%        str2double(get(hObject,'String')) returns contents of ROI_Index_edit as a double
InputNum = str2double(get(hObject,'String'));
if isnumeric(InputNum)
    if InputNum <= 0 || InputNum >=  ROIAndBranchInfoData.TotalROINum
        warning('Input ROI index out of range');
        return;
    end
%     ROIAndBranchInfoData.cROIExtraInfo.ROIIndex = InputNum;
    set(handles.ROI_Index_edit,'String',num2str(InputNum));
    
end


% --- Executes during object creation, after setting all properties.
function ROI_Index_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_Index_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in ROI_RespType_menu.
function ROI_RespType_menu_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_RespType_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns ROI_RespType_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from ROI_RespType_menu


% --- Executes during object creation, after setting all properties.
function ROI_RespType_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_RespType_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'String', {'Sensory', 'Choice', 'Mixed', 'Task', 'Others'});

% --- Executes on selection change in Branch_Index_menu.
function Branch_Index_menu_Callback(hObject, eventdata, handles)
% hObject    handle to Branch_Index_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
% Hints: contents = cellstr(get(hObject,'String')) returns Branch_Index_menu contents as cell array
%        contents{get(hObject,'Value')} returns selected item from Branch_Index_menu
SelectRespType = contents{get(hObject,'Value')};
ROIAndBranchInfoData.cROIExtraInfo.ROI_RespType = SelectRespType;


% --- Executes during object creation, after setting all properties.
function Branch_Index_menu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Branch_Index_menu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Plot_generation.
function Plot_generation_Callback(hObject, eventdata, handles)
% hObject    handle to Plot_generation (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
ROISummationValues = zeros(ROIAndBranchInfoData.SessTrialNum,2); % mean and max
for cTr = 1 : ROIAndBranchInfoData.SessTrialNum
    cTrMeanIm = ROIAndBranchInfoData.FrameDataMeanMax(cTr).MeanFrame;
    cTrMaxIm = ROIAndBranchInfoData.FrameDataMeanMax(cTr).MaxFrame;
    ROISummationValues(cTr,:) = [mean(cTrMeanIm(ROIAndBranchInfoData.ROIMaskMerged)),...
        mean(cTrMaxIm(ROIAndBranchInfoData.ROIMaskMerged))];
end

[~,Inds] = max(ROISummationValues);
if ROIAndBranchInfoData.MeanOrMaxFig(1) % mean image was selected
    % plot ROIs on mean image
    MaxV_Image = ROIAndBranchInfoData.FrameDataMeanMax(Inds(1)).MeanFrame;
elseif ROIAndBranchInfoData.MeanOrMaxFig(2) % max image was selected
    % plot ROIs on max image
    MaxV_Image = ROIAndBranchInfoData.FrameDataMeanMax(Inds(2)).MaxFrame;
else
    erro('Error image type selection');
end

if ishandle(ROIAndBranchInfoData.FigHandle)
    figure(ROIAndBranchInfoData.FigHandle);
    clf;
else
    ROIAndBranchInfoData.FigHandle = figure('position',[100 100 540 400]);
end
imagesc(MaxV_Image, ROIAndBranchInfoData.ImageScale);
TypeStrs =  {'Sensory', 'Choice', 'Mixed', 'Task', 'Others'};
TypeColors = {[0.1 0.8 0.1], 'b', 'r', [1 0.7 0.2], 'm'}; % dark-green; blue; red; brown; magenta
colormap gray
if ROIAndBranchInfoData.ROIInputNum > 0
    % added ROI lines
    AllROIBranchIndex = arrayfun(@(x) x.ROI_BranchIndex, ROIAndBranchInfoData.ROIExtraInfo);
    BranchIndexType = unique(AllROIBranchIndex);
    BranchTypeNum = length(BranchIndexType);
    BranchColors = autumn(BranchTypeNum);
    for cR = 1 : ROIAndBranchInfoData.ROIInputNum
        cR_realIndex = ROIAndBranchInfoData.ROIExtraInfo(cR).ROIIndex;
        cR_Branch = ROIAndBranchInfoData.ROIExtraInfo(cR).ROI_BranchIndex;
        cR_pos = ROIAndBranchInfoData.ROIExtraInfo(cR).ROIPos;
        cR_RespType = ROIAndBranchInfoData.ROIExtraInfo(cR).ROI_RespType;
        cR_RespType_Inds = strcmpi(cR_RespType, TypeStrs);
        cR_lineColor = TypeColors{cR_RespType_Inds};
        cR_center = mean(cR_pos);
        cBranch_colorInds = cR_Branch == BranchIndexType;
        line(cR_pos(:,1), cR_pos(:,2), 'Color', cR_lineColor, 'linewidth', 2.4);
        text(cR_center(1), cR_center(2), num2str(cR_realIndex),'Color',BranchColors(cBranch_colorInds,:),'FontSize',12);
    end
end

    
% --- Executes on button press in Save_result_button.
function Save_result_button_Callback(hObject, eventdata, handles)
% hObject    handle to Save_result_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
SavePath = fullfile(ROIAndBranchInfoData.ROIinfoPath{1},'ROIRespAndBranchIndex.mat');
ROIBranchANDrespSave = ROIAndBranchInfoData.ROIExtraInfo;
save(SavePath,'ROIBranchANDrespSave','-v7.3');
fprintf('Data saved in path:\n %s.\n', SavePath);

% --- Executes on button press in Save_ROI_InputInfo.
function Save_ROI_InputInfo_Callback(hObject, eventdata, handles)
% hObject    handle to Save_ROI_InputInfo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
ROIAndBranchInfoData.cROIExtraInfo.ROIIndex = str2num(get(handles.ROI_Index_edit,'string'));

if ROIAndBranchInfoData.ROIInputNum > 0
        ExistROIRealInds = arrayfun(@(x) x.ROIIndex, ROIAndBranchInfoData.ROIExtraInfo);
        if sum(ExistROIRealInds == ROIAndBranchInfoData.cROIExtraInfo.ROIIndex)
            Answer = questdlg('The input ROI index have already exist, do you want to modify old info?',...
                'Input confirm','Yes','No','cancel','No');
            switch Answer
                case 'Yes'
                    fprintf('Change the old ROI values.\n');
                    ROIAndBranchInfoData.IsOldReplace = 1;
                case 'No'
                    ROIAndBranchInfoData.IsOldReplace = 0;
                    
                    return;
                case 'Cancel'
                    ROIAndBranchInfoData.IsOldReplace = 0;
                    set(handles.ROI_Index_edit,'string','');
                    return;
                otherwise
                    return;
            end
        end
end
    

if ROIAndBranchInfoData.IsOldReplace
    AllROI_realIndex = arrayfun(@(x) x.ROIIndex, ROIAndBranchInfoData.ROIExtraInfo);
    ROIAndBranchInfoData.ROIInputNum = find(AllROI_realIndex ==  ROIAndBranchInfoData.cROIExtraInfo.ROIIndex);
else
    ROIAndBranchInfoData.ROIInputNum = ROIAndBranchInfoData.ROIInputNum + 1;
end

AllMenuString = get(handles.ROI_RespType_menu,'string');
MenuListInds = get(handles.ROI_RespType_menu,'value');
ROIAndBranchInfoData.cROIExtraInfo.ROI_RespType = AllMenuString{MenuListInds};
ROIAndBranchInfoData.cROIExtraInfo.ROI_BranchIndex = str2num(get(handles.BranchIndex_edit,'string'));

fprintf('Add ROI%d infomation data into summary dataset index %d...\n', ...
    ROIAndBranchInfoData.cROIExtraInfo.ROIIndex, ROIAndBranchInfoData.ROIInputNum);
ROIAndBranchInfoData.cROIExtraInfo.ROIMask = ROIAndBranchInfoData.ROIinfoData.ROImask{ROIAndBranchInfoData.cROIExtraInfo.ROIIndex};
ROIAndBranchInfoData.cROIExtraInfo.ROIPos = ROIAndBranchInfoData.ROIinfoData.ROIpos{ROIAndBranchInfoData.cROIExtraInfo.ROIIndex};

ROIAndBranchInfoData.ROIExtraInfo(ROIAndBranchInfoData.ROIInputNum) = ...
    ROIAndBranchInfoData.cROIExtraInfo;

if ROIAndBranchInfoData.ROIInputNum == 1
    ROIAndBranchInfoData.ROIMaskMerged = ROIAndBranchInfoData.cROIExtraInfo.ROIMask;
else
    ROIAndBranchInfoData.ROIMaskMerged = ROIAndBranchInfoData.cROIExtraInfo.ROIMask ...
        + ROIAndBranchInfoData.ROIMaskMerged;
    ROIAndBranchInfoData.ROIMaskMerged = ROIAndBranchInfoData.ROIMaskMerged > 0;
end
if ROIAndBranchInfoData.IsOldReplace
    ROIAndBranchInfoData.IsOldReplace = 0;
    ROIAndBranchInfoData.ROIInputNum = length(ROIAndBranchInfoData.ROIExtraInfo);
end

% --- Executes on button press in Mean_im_button.
function Mean_im_button_Callback(hObject, eventdata, handles)
% hObject    handle to Mean_im_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
% Hint: get(hObject,'Value') returns toggle state of Mean_im_button
cV = get(hObject,'Value');
if cV
    ROIAndBranchInfoData.MeanOrMaxFig = [1, 0];
    set(handles.Max_im_button,'value',0);
else
    ROIAndBranchInfoData.MeanOrMaxFig = [0, 1];
    set(handles.Max_im_button,'value',1);
end
if ishandle(ROIAndBranchInfoData.FigHandle)
    Plot_generation_Callback(hObject, eventdata, handles);
end

% --- Executes on button press in Max_im_button.
function Max_im_button_Callback(hObject, eventdata, handles)
% hObject    handle to Max_im_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
% Hint: get(hObject,'Value') returns toggle state of Max_im_button
cV = get(hObject,'Value');
if ~cV
    ROIAndBranchInfoData.MeanOrMaxFig = [1, 0];
    set(handles.Mean_im_button,'value',1);
else
    ROIAndBranchInfoData.MeanOrMaxFig = [0, 1];
    set(handles.Mean_im_button,'value',0);
end
if ishandle(ROIAndBranchInfoData.FigHandle)
    Plot_generation_Callback(hObject, eventdata, handles);
end

% --- Executes on button press in ROIinfo_select_button.
function ROIinfo_select_button_Callback(hObject, eventdata, handles)
% hObject    handle to ROIinfo_select_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
[fn,fp,fi] = uigetfile('*.mat','Please select your ROIinfo mat file');
if ~fi
    return;
end
FullPath = fullfile(fp,fn);
try 
    InfoDatas = load(FullPath, 'ROIinfoBU');
catch
    warning('No target data found in input path, please check your input string');
    return;
end
ROIAndBranchInfoData.ROIinfoPath = {fp, fn};
ROIAndBranchInfoData.ROIinfoData = InfoDatas.ROIinfoBU;
ROIAndBranchInfoData.TotalROINum = length(ROIAndBranchInfoData.ROIinfoData.ROImask);
set(handles.ROIInfo_path_edit,'String',FullPath);

% --- Executes on button press in FrameDataPath_select_B.
function FrameDataPath_select_B_Callback(hObject, eventdata, handles)
% hObject    handle to FrameDataPath_select_B (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
[fn,fp,fi] = uigetfile('*.mat','Please select your ROIinfo mat file');
if ~fi
    return;
end
FullPath = fullfile(fp,fn);
try 
    InfoDatas = load(FullPath, 'FrameProjSave');
catch
    warning('No target data found in input path, please check your input string');
    return;
end
ROIAndBranchInfoData.FrameDataPath = {fp, fn};
ROIAndBranchInfoData.FrameDataMeanMax = InfoDatas.FrameProjSave;
ROIAndBranchInfoData.SessTrialNum = length(ROIAndBranchInfoData.FrameDataMeanMax);
set(handles.FrameData_path_edit,'string',FullPath);

function BranchIndex_edit_Callback(hObject, eventdata, handles)
% hObject    handle to BranchIndex_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
% Hints: get(hObject,'String') returns contents of BranchIndex_edit as text
%        str2double(get(hObject,'String')) returns contents of BranchIndex_edit as a double
InputValue = str2double(get(hObject,'String'));
if ~isnumeric(InputValue)
    error('The input branch index value is not suitable');
end
% ROIAndBranchInfoData.cROIExtraInfo.ROI_BranchIndex = InputValue;

% --- Executes during object creation, after setting all properties.
function BranchIndex_edit_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BranchIndex_edit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function Mean_im_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Mean_im_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',1);


% --- Executes during object creation, after setting all properties.
function Max_im_button_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Max_im_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0);



function Frame_show_scale_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Frame_show_scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData
% Hints: get(hObject,'String') returns contents of Frame_show_scale_tag as text
%        str2double(get(hObject,'String')) returns contents of Frame_show_scale_tag as a double
InputValue = str2num(get(hObject,'String'));
if ~isnumeric(InputValue) || length(InputValue) ~= 2 || diff(InputValue) <= 0
    
    set(handles.Frame_show_scale_tag,'string',sprintf('%d,%d',...
        ROIAndBranchInfoData.ImageScale(1),ROIAndBranchInfoData.ImageScale(2)));
    error('The input scale is not suitable');
else
    ROIAndBranchInfoData.ImageScale = InputValue;
end

if ishandle(ROIAndBranchInfoData.FigHandle)
    Plot_generation_Callback(hObject, eventdata, handles);
end
    

% --- Executes during object creation, after setting all properties.
function Frame_show_scale_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Frame_show_scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject, 'string', '0,100');


% --- Executes on button press in Save_image_tag.
function Save_image_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Save_image_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIAndBranchInfoData

if ~ishandle(ROIAndBranchInfoData.FigHandle)
    Plot_generation_Callback(hObject, eventdata, handles);
end
saveas(ROIAndBranchInfoData.FigHandle, 'ROIType_branchIndex_plot');
saveas(ROIAndBranchInfoData.FigHandle, 'ROIType_branchIndex_plot', 'png');
saveas(ROIAndBranchInfoData.FigHandle, 'ROIType_branchIndex_plot', 'pdf');

    
    


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
