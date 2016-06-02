function varargout = ROI_inds_selection(varargin)
% ROI_INDS_SELECTION MATLAB code for ROI_inds_selection.fig
%      ROI_INDS_SELECTION, by itself, creates a new ROI_INDS_SELECTION or raises the existing
%      singleton*.
%
%      H = ROI_INDS_SELECTION returns the handle to a new ROI_INDS_SELECTION or the handle to
%      the existing singleton*.
%
%      ROI_INDS_SELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ROI_INDS_SELECTION.M with the given input arguments.
%
%      ROI_INDS_SELECTION('Property','Value',...) creates a new ROI_INDS_SELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before ROI_inds_selection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to ROI_inds_selection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help ROI_inds_selection

% Last Modified by GUIDE v2.5 12-Jun-2015 14:20:22

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @ROI_inds_selection_OpeningFcn, ...
                   'gui_OutputFcn',  @ROI_inds_selection_OutputFcn, ...
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


% --- Executes just before ROI_inds_selection is made visible.
function ROI_inds_selection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to ROI_inds_selection (see VARARGIN)

% Choose default command line output for ROI_inds_selection
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes ROI_inds_selection wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = ROI_inds_selection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
% varargout{1} = getappdata(handles.complete_button,'selection_inds');
varargout{1} = handles.output;
% Hint: delete(hObject) closes the figure
delete(handles.figure1);


function low_left_input_Callback(hObject, eventdata, handles)
% hObject    handle to low_left_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of low_left_input as text
%        str2double(get(hObject,'String')) returns contents of low_left_input as a double
val_string=get(hObject,'String');
if isempty(val_string)
    val=1;
    set(hObject,'string','1');
else
    val=str2double(val_string);
    if isempty(val)
        val=1;
    end
end
setappdata(handles.low_left_input,'low_left_input',val);

% --- Executes during object creation, after setting all properties.
function low_left_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_left_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'string','1');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function high_left_input_Callback(hObject, eventdata, handles)
% hObject    handle to high_left_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of high_left_input as text
%        str2double(get(hObject,'String')) returns contents of high_left_input as a double
val_string=get(hObject,'String');
if isempty(val_string)
    error('Error high range input for ROI selection.\n');
else
    val=str2double(val_string);
end
setappdata(handles.high_left_input,'high_left_input',val);

% --- Executes during object creation, after setting all properties.
function high_left_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to high_left_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'string','');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function low_right_input_Callback(hObject, eventdata, handles)
% hObject    handle to low_right_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of low_right_input as text
%        str2double(get(hObject,'String')) returns contents of low_right_input as a double
val_string=get(hObject,'String');
if isempty(val_string)
    val=1;
    set(hObject,'string','1');
else
    val=str2double(val_string);
    if isempty(val)
        val=1;
    end
end
setappdata(handles.low_right_input,'low_right_input',val);

% --- Executes during object creation, after setting all properties.
function low_right_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to low_right_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'string','1');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function high_right_input_Callback(hObject, eventdata, handles)
% hObject    handle to high_right_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of high_right_input as text
%        str2double(get(hObject,'String')) returns contents of high_right_input as a double
val_string=get(hObject,'String');
if isempty(val_string)
    error('Error high range input for ROI selection.\n');
else
    val=str2double(val_string);
end
setappdata(handles.high_right_input,'high_right_input',val);

% --- Executes during object creation, after setting all properties.
function high_right_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to high_right_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'string','');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in reset_button.
function reset_button_Callback(hObject, eventdata, handles)
% hObject    handle to reset_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
choice=questdlg('Are you sure to reset all input?','reset confirm','Yes','No','No');
switch choice
    case 'Yes'
        set(handles.low_left_input,'string','1');
        set(handles.high_left_input,'string','');
        set(handles.high_right_input,'string','');
        set(handles.low_right_input,'string','1');
    case 'No'
        disp('Cancel reset selection.\n');
end

% --- Executes on button press in complete_button.
function complete_button_Callback(hObject, eventdata, handles)
% hObject    handle to complete_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
low_left_inds=getappdata(handles.low_left_input,'low_left_input');
high_left_inds=getappdata(handles.high_left_input,'high_left_input');
low_right_inds=getappdata(handles.low_right_input,'low_right_input');
high_right_inds=getappdata(handles.high_right_input,'high_right_input');
selection_inds=[low_left_inds high_left_inds low_right_inds high_right_inds];
setappdata(handles.complete_button,'selection_inds',selection_inds);
handles.output=selection_inds;
guidata(handles.figure1,handles)
ROI_inds_selection_OutputFcn(hObject, eventdata, handles);

% --- Executes during object deletion, before destroying properties.
function complete_button_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to complete_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject,'waitstatus'),'waiting')
    uiresume(hObject);
else
% Hint: delete(hObject) closes the figure
delete(hObject);
end
