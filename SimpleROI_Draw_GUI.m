function varargout = SimpleROI_Draw_GUI(varargin)
% SIMPLEROI_DRAW_GUI MATLAB code for SimpleROI_Draw_GUI.fig
%      SIMPLEROI_DRAW_GUI, by itself, creates a new SIMPLEROI_DRAW_GUI or raises the existing
%      singleton*.
%
%      H = SIMPLEROI_DRAW_GUI returns the handle to a new SIMPLEROI_DRAW_GUI or the handle to
%      the existing singleton*.
%
%      SIMPLEROI_DRAW_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SIMPLEROI_DRAW_GUI.M with the given input arguments.
%
%      SIMPLEROI_DRAW_GUI('Property','Value',...) creates a new SIMPLEROI_DRAW_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before SimpleROI_Draw_GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to SimpleROI_Draw_GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help SimpleROI_Draw_GUI

% Last Modified by GUIDE v2.5 12-Jun-2019 22:21:17

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @SimpleROI_Draw_GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @SimpleROI_Draw_GUI_OutputFcn, ...
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


% --- Executes just before SimpleROI_Draw_GUI is made visible.
function SimpleROI_Draw_GUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to SimpleROI_Draw_GUI (see VARARGIN)
global ROIDataSummary
% Choose default command line output for SimpleROI_Draw_GUI
handles.output = hObject;

ROIDataSummary.SessPath = '';
ROIDataSummary.SessFileName = '';
ROIDataSummary.MaxFrameScale = [0,0];
ROIDataSummary.UsedFrameScale = [0,0];
ROIDataSummary.TotalROINum = 0;
ROIDataSummary.CurrentROINum = 0;
ROIDataSummary.ROIDataSum = struct('ROIpos',[],'ROIMask',[]);
ROIDataSummary.TotalImData = [];
ROIDataSummary.FigHandle = [];
ROIDataSummary.UsedImType = [1,0];
ROIDataSummary.UsedImData = [];
ROIDataSummary.ImDataShowScale = [0,200];
ROIDataSummary.IsMultiAdd = 0;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes SimpleROI_Draw_GUI wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = SimpleROI_Draw_GUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function cPath_edit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to cPath_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cPath_edit_tag as text
%        str2double(get(hObject,'String')) returns contents of cPath_edit_tag as a double


% --- Executes during object creation, after setting all properties.
function cPath_edit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cPath_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in LoadFile_tag.
function LoadFile_tag_Callback(hObject, eventdata, handles)
% hObject    handle to LoadFile_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
[fn,fp,fi] = uigetfile('*.tif','Please select the file you want to draw ROIs');
if ~fi
    set(handles.Message_box_tag,'String','Please select your tif file.');
    return;
end
ROIDataSummary.SessPath = fp;
ROIDataSummary.SessFileName = fn;
set(handles.cPath_edit_tag,'String',fullfile(fp,fn));
set(handles.Message_box_tag,'String',fullfile(fp,fn));

[im,~] = load_scim_data(fullfile(fp,fn));
ROIDataSummary.TotalImData = im;
clearvars im

ROIDataSummary.MaxFrameScale = [1,size(ROIDataSummary.TotalImData,3)];
set(handles.MinFrame_scale_tag,'String',num2str(ROIDataSummary.MaxFrameScale(1)));
set(handles.MaxFrame_scale_tag,'String',num2str(ROIDataSummary.MaxFrameScale(2)));
if ROIDataSummary.MaxFrameScale(2) > 500
    ROIDataSummary.UsedFrameScale = [1,400];
else
    ROIDataSummary.UsedFrameScale = [1,ROIDataSummary.MaxFrameScale(2)];
end
set(handles.UsedMinFrame_tag,'String',num2str(ROIDataSummary.UsedFrameScale(1)));
set(handles.UsedMaxFrame_tag,'String',num2str(ROIDataSummary.UsedFrameScale(2)));



function UsedMinFrame_tag_Callback(hObject, eventdata, handles)
% hObject    handle to UsedMinFrame_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
% Hints: get(hObject,'String') returns contents of UsedMinFrame_tag as text
%        str2double(get(hObject,'String')) returns contents of UsedMinFrame_tag as a double
InputFrameIndex = str2double(get(hObject,'String'));
if InputFrameIndex < 1
    InputFrameIndex = 1;
elseif InputFrameIndex > (ROIDataSummary.MaxFrameScale(2)-1)
    set(handles.Message_box_tag,'String','The input used frame scale min value should be less than max frame.');
    return;
end
ROIDataSummary.UsedFrameScale(1) = InputFrameIndex;
set(handles.UsedMinFrame_tag,'String',num2str(ROIDataSummary.UsedFrameScale(1)));
if diff(ROIDataSummary.UsedFrameScale) < 1
    ROIDataSummary.UsedFrameScale(2) = InputFrameIndex + 1;
    set(handles.UsedMaxFrame_tag,'String',num2str(ROIDataSummary.UsedFrameScale(2)));
end
ShowSelectImage_tag_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function UsedMinFrame_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UsedMinFrame_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function UsedMaxFrame_tag_Callback(hObject, eventdata, handles)
% hObject    handle to UsedMaxFrame_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
% Hints: get(hObject,'String') returns contents of UsedMaxFrame_tag as text
%        str2double(get(hObject,'String')) returns contents of UsedMaxFrame_tag as a double
cInput = str2double(get(hObject,'String'));
if ~isempty(cInput)
    if cInput > ROIDataSummary.UsedFrameScale(1) && cInput < ROIDataSummary.MaxFrameScale(2)
        ROIDataSummary.UsedFrameScale(2) = cInput;
        ShowSelectImage_tag_Callback(hObject, eventdata, handles);
    else
        set(handles.Message_box_tag,'String','Error input value');
        return;
    end
    
end

% --- Executes during object creation, after setting all properties.
function UsedMaxFrame_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UsedMaxFrame_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TotalROINum_tag_Callback(hObject, eventdata, handles)
% hObject    handle to TotalROINum_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TotalROINum_tag as text
%        str2double(get(hObject,'String')) returns contents of TotalROINum_tag as a double


% --- Executes during object creation, after setting all properties.
function TotalROINum_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TotalROINum_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','String','0');
end



function CurrentROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
cInputROI = str2double(get(hObject,'String'));
if ~isempty(cInputROI)
    if cInputROI > ROIDataSummary.TotalROINum
        set(handles.Message_box_tag,'String','Input ROI number is out of range.');
    else
        ROIDataSummary.CurrentROINum = cInputROI;
    end
end
UpdatesROIPlots(ROIDataSummary.CurrentROINum);



function UpdatesROIPlots(CurrentROI,varargin)
global ROIDataSummary
if isempty(ROIDataSummary.FigHandle) || ~ishghandle(ROIDataSummary.FigHandle)
    set(handles.Message_box_tag,'String','Plot the image first.');
else
    figure(ROIDataSummary.FigHandle);
    clf(ROIDataSummary.FigHandle);
    imagesc(ROIDataSummary.UsedImData,ROIDataSummary.ImDataShowScale);
    colormap gray
    if ROIDataSummary.TotalROINum > 0
        for cR = 1 : ROIDataSummary.TotalROINum
            cRpos = ROIDataSummary.ROIDataSum(cR).ROIpos;
            line(cRpos(:,1),cRpos(:,2),'LineWidth',1.5,'color','r');
            CenterPos = mean(cRpos);
            if cR == CurrentROI
                text(CenterPos(1),CenterPos(2),num2str(cR),'color','c','HorizontalAlignment','center','fontSize',18);
            else
                text(CenterPos(1),CenterPos(2),num2str(cR),'color','c','HorizontalAlignment','center','fontSize',14);
            end
        end
    end
end


% --- Executes during object creation, after setting all properties.
function CurrentROI_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','String','0');
end


% --- Executes on button press in Add_ROI_tag.
function Add_ROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Add_ROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
if ROIDataSummary.IsMultiAdd
    set(handles.Message_box_tag,'String','Possible multiple AddROI button click.');
    return;
else
    ROIDataSummary.IsMultiAdd = 1;
    ROIDataSummary.TotalROINum = ROIDataSummary.TotalROINum + 1;
    ROIDataSummary.CurrentROINum = ROIDataSummary.TotalROINum;
    set(handles.TotalROINum_tag,'String',num2str(ROIDataSummary.TotalROINum));
    set(handles.CurrentROI_tag,'String',num2str(ROIDataSummary.TotalROINum));
    cROI = ROIDataSummary.CurrentROINum;
    figure(ROIDataSummary.FigHandle);
    
    % draw ROIs
    ROIDraw=1;
    while ROIDraw
        h_ROI=imfreehand;
        h_mask=createMask(h_ROI);
        h_position=getPosition(h_ROI);
        choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes','Re-draw','Cancle','Yes');
        switch choice
            case 'Yes'
                ROIDataSummary.ROIDataSum(cROI).ROIMask=h_mask;
                ROIDataSummary.ROIDataSum(cROI).ROIpos=h_position;
                delete(h_ROI);
                ROIDataSummary.IsMultiAdd = 0;
                ROIDraw=0;
                UpdatesROIPlots(ROIDataSummary.CurrentROINum);
            case 'Cancle'
                delete(h_ROI);
                ROIDraw=0;
                ROIDataSummary.TotalROINum = ROIDataSummary.TotalROINum - 1;
                ROIDataSummary.CurrentROINum = ROIDataSummary.TotalROINum;
                set(handles.TotalROINum_tag,'String',num2str(ROIDataSummary.TotalROINum));
                set(handles.CurrentROI_tag,'String',num2str(ROIDataSummary.TotalROINum));
                
            case 'Re-draw'
                delete(h_ROI);
            otherwise
                set(handles.Message_box_tag,'String','Quit ROI drawing.');
                delete(h_ROI);
                ROIDraw=0;
    %             close all;
        end
    end

end



% --- Executes on button press in Delete_ROI_tag.
function Delete_ROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Delete_ROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
cROI = ROIDataSummary.CurrentROINum;
choice = questdlg(sprintf('Are you sure to delete ROI%d?',cROI),'confirm ROI deletion',...
    'Yes','No','Cancle','Yes');
switch choice
    case 'Yes'
        if isempty(ROIDataSummary.ROIDataSum)
            return;
        end
       
       ROIDataSummary.ROIDataSum(cROI) = [];
       ROIDataSummary.TotalROINum = ROIDataSummary.TotalROINum - 1;
       if cROI == 1
           ROIDataSummary.CurrentROINum = 1;
       else
            ROIDataSummary.CurrentROINum = cROI - 1;
       end
       set(handles.TotalROINum_tag,'String',num2str(ROIDataSummary.TotalROINum));
       set(handles.CurrentROI_tag,'String',num2str(ROIDataSummary.CurrentROINum));
       set(handles.Message_box_tag,'String',sprintf('Delete ROI %d.',cROI));
       UpdatesROIPlots(ROIDataSummary.CurrentROINum);
       
    case 'No'
        return;
        
    case 'Cancle'
        return;
        
    otherwise
        set(handles.Message_box_tag,'String','Quit ROI deletion.');
end

% --- Executes on button press in ShowSelectImage_tag.
function ShowSelectImage_tag_Callback(hObject, eventdata, handles)
% hObject    handle to ShowSelectImage_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
if diff(ROIDataSummary.UsedFrameScale) < 1
    set(handles.Message_box_tag,'String','Please set the used frame range before usage');
    return;
end
UsedFrameData = ROIDataSummary.TotalImData(:,:,ROIDataSummary.UsedFrameScale(1):ROIDataSummary.UsedFrameScale(2));

if ROIDataSummary.UsedImType(1) % use the averaged image for ROI plots 
    im_mean = mean(UsedFrameData,3);
    ROIDataSummary.UsedImData = im_mean;
else  
    ims=im_mov_avg(UsedFrameData,3);
    im_Max=max(ims,[],3);
    im_mean = mean(UsedFrameData,3);
    max_delta=double(im_Max)-im_mean;
    ROIDataSummary.UsedImData = max_delta;
end

if isempty(ROIDataSummary.FigHandle) || ~ishghandle(ROIDataSummary.FigHandle)
    ROIDataSummary.FigHandle = figure('position',[50 100 980 900]);
else
    clf(ROIDataSummary.FigHandle);
end

figure(ROIDataSummary.FigHandle);
imagesc(ROIDataSummary.UsedImData,ROIDataSummary.ImDataShowScale);
colormap gray

UpdatesROIPlots(ROIDataSummary.CurrentROINum);



% --- Executes on button press in UseMeanIm_tag.
function UseMeanIm_tag_Callback(hObject, eventdata, handles)
% hObject    handle to UseMeanIm_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
cV = get(hObject,'Value');
if ~cV
    if ~get(handles.UseMaxMean_tag,'Value')
        set(handles.Message_box_tag,'String','At least one option should be positive.');
    end
    set(hObject,'Value',1);
    ROIDataSummary.UsedImType = [1,0];
else
    set(handles.UseMaxMean_tag,'Value',0);
    ROIDataSummary.UsedImType = [1,0];
end
ShowSelectImage_tag_Callback(hObject, eventdata, handles);     
% Hint: get(hObject,'Value') returns toggle state of UseMeanIm_tag


% --- Executes on button press in UseMaxMean_tag.
function UseMaxMean_tag_Callback(hObject, eventdata, handles)
% hObject    handle to UseMaxMean_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
cV = get(hObject,'Value');
if ~cV
    if ~get(handles.UseMeanIm_tag,'Value')
        set(handles.Message_box_tag,'String','At least one option should be positive.');
    end
    set(hObject,'Value',1);
    ROIDataSummary.UsedImType = [0,1];
else
    set(handles.UseMeanIm_tag,'Value',0);
    ROIDataSummary.UsedImType = [0,1];
end
ShowSelectImage_tag_Callback(hObject, eventdata, handles);


function ImScale_min_Callback(hObject, eventdata, handles)
% hObject    handle to ImScale_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
% Hints: get(hObject,'String') returns contents of ImScale_min as text
%        str2double(get(hObject,'String')) returns contents of ImScale_min as a double
InputData = str2double(get(hObject,'String'));
if ~isempty(InputData)
    if InputData > ROIDataSummary.ImDataShowScale(2)
        set(handles.Message_box_tag,'String','The min value should be less than max value');
        return;
    else
        ROIDataSummary.ImDataShowScale(1) = InputData;
    end
end
UpdatesROIPlots(ROIDataSummary.CurrentROINum);

% --- Executes during object creation, after setting all properties.
function ImScale_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImScale_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','0');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ImScale_max_Callback(hObject, eventdata, handles)
% hObject    handle to ImScale_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
% Hints: get(hObject,'String') returns contents of ImScale_min as text
%        str2double(get(hObject,'String')) returns contents of ImScale_min as a double
InputData = str2double(get(hObject,'String'));
if ~isempty(InputData)
    
    if InputData - ROIDataSummary.ImDataShowScale(1) < 1
        set(handles.Message_box_tag,'String','The max value of the scale should be larger than min value');
        return;
    else
        ROIDataSummary.ImDataShowScale(2) = InputData;
    end
end
UpdatesROIPlots(ROIDataSummary.CurrentROINum);

% --- Executes during object creation, after setting all properties.
function ImScale_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImScale_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','200');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in SaveRes_tag.
function SaveRes_tag_Callback(hObject, eventdata, handles)
% hObject    handle to SaveRes_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
if isempty(ROIDataSummary.SessPath)
    set(handles.Message_box_tag,'String','No files being loaded.');
    return;
end

if isempty(ROIDataSummary.ROIDataSum)
    set(handles.Message_box_tag,'String','No ROI data exists.');
    return;
end
ROIInfoDatas = ROIDataSummary.ROIDataSum;

save(fullfile(ROIDataSummary.SessPath,'ROIinfoData.mat'),'ROIInfoDatas','-v7.3');
set(handles.Message_box_tag,'String',sprintf('ROI file saves in: %s.',...
    fullfile(ROIDataSummary.SessPath,'ROIinfoData.mat')));


% --- Executes during object creation, after setting all properties.
function UseMeanIm_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UseMeanIm_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',1);


% --- Executes during object creation, after setting all properties.
function UseMaxMean_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to UseMaxMean_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0);


% --- Executes on button press in Load_ROI_tag.
function Load_ROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Load_ROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
if isempty(ROIDataSummary.FigHandle) || isempty(ROIDataSummary.UsedImData)
    return;
end
choice = questdlg('Are you sure to load external ROIs?','confirm ROI load',...
    'Yes','No','Cancle','Yes');
switch choice
    case 'Yes'
        [fn,fp,fi] = uigetfile('*.mat','Please select the external ROI data file');
       if ~fi
           return;
       end
       fPath = fullfile(fp,fn);
       try 
           CData = load(fPath,'ROIInfoDatas');
           set(handles.Message_box_tag,'String',sprintf('DLoading ROI data from %s.',fullfile(fp,fn)));
           GivenROINum = length(CData.ROIInfoDatas);
           if GivenROINum > 0
               ROIDataSummary.ROIDataSum = CData.ROIInfoDatas;
               ROIDataSummary.TotalROINum = GivenROINum;
               ROIDataSummary.CurrentROINum = GivenROINum;
               set(handles.TotalROINum_tag,'String',num2str(ROIDataSummary.TotalROINum));
               set(handles.CurrentROI_tag,'String',num2str(ROIDataSummary.CurrentROINum));
               UpdatesROIPlots(ROIDataSummary.CurrentROINum);
           else
               set(handles.Message_box_tag,'String','Input data file have zero ROIs');
               return;
           end
       catch
           set(handles.Message_box_tag,'String','The select file do not have target fields.');
           return;
       end
       
    case 'No'
        return;
        
    case 'Cancle'
        return;
        
    otherwise
        set(handles.Message_box_tag,'String','Quit ROI deletion.');
end


