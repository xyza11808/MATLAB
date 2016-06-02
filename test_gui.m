function varargout = test_gui(varargin)
% TEST_GUI MATLAB code for test_gui.fig
%      TEST_GUI, by itself, creates a new TEST_GUI or raises the existing
%      singleton*.
%
%      H = TEST_GUI returns the handle to a new TEST_GUI or the handle to
%      the existing singleton*.
%
%      TEST_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_GUI.M with the given input arguments.
%
%      TEST_GUI('Property','Value',...) creates a new TEST_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before test_gui_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to test_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help test_gui

% Last Modified by GUIDE v2.5 02-Feb-2015 10:46:12

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @test_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @test_gui_OutputFcn, ...
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


% --- Executes just before test_gui is made visible.
function test_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to test_gui (see VARARGIN)
% set(handles.test_gui,'title','test gui for haha');
axis(handles.display_axes);
cla;

% Choose default command line output for test_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes test_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = test_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function figure1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function x_low_input_Callback(hObject, eventdata, handles)
% hObject    handle to x_low_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x_low=str2double(get(hObject,'String'));
setappdata(handles.x_low_input,'x_low',x_low);
% Hints: get(hObject,'String') returns contents of x_low_input as text
%        str2double(get(hObject,'String')) returns contents of x_low_input as a double


% --- Executes during object creation, after setting all properties.
function x_low_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_low_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');
% setappdata
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function x_high_input_Callback(hObject, eventdata, handles)
% hObject    handle to x_high_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
x_high=str2double(get(hObject,'String'));
setappdata(handles.x_high_input,'x_high',x_high);
% Hints: get(hObject,'String') returns contents of x_high_input as text
%        str2double(get(hObject,'String')) returns contents of x_high_input as a double


% --- Executes during object creation, after setting all properties.
function x_high_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to x_high_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in calculate.
function calculate_Callback(hObject, eventdata, handles)
% hObject    handle to calculate (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% x_low=get(handles.x_low_input,'Value');
% x_high=get(handles.x_high_input,'Value');
x_low=getappdata(handles.x_low_input,'x_low');
x_high=getappdata(handles.x_high_input,'x_high');
t=get(handles.dynamic_freq,'value');

if x_low<x_high
    step=(x_high-x_low)/100;
    x=x_low:step:x_high;
elseif x_low==x_high
%     step=0;
    x=[x_low,x_high];
else
    step=(x_low-x_high)/100;
    x=x_high:step:stepx_low;
end
y=sin(x+t);
plot(x,y,'-o','color','r');


% --- Executes on mouse press over axes background.
function display_axes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to display_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function period_input_Callback(hObject, eventdata, handles)
% hObject    handle to period_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
period=str2double(get(hObject,'String'));
setappdata(handles.period_input,'period',period);
max_p=period;
set(handles.dynamic_freq,'Min',0);
set(handles.dynamic_freq,'Max',max_p);
set(handles.dynamic_freq,'SliderStep',[0.01 0.5]);
% Hints: get(hObject,'String') returns contents of period_input as text
%        str2double(get(hObject,'String')) returns contents of period_input as a double


% --- Executes during object creation, after setting all properties.
function period_input_CreateFcn(hObject, eventdata, handles)
% hObject    handle to period_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','');
% setappdata(handles.period_input,'period',10);
% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function dynamic_freq_Callback(hObject, eventdata, handles)
% hObject    handle to dynamic_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
val=get(hObject,'value');
set(handles.step_value,'string',num2str(val));
calculate_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function dynamic_freq_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dynamic_freq (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% max_p=getappdata(handles.period_input,'period');

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
