function varargout = testGUI1(varargin)
% TESTGUI1 MATLAB code for testGUI1.fig
%      TESTGUI1, by itself, creates a new TESTGUI1 or raises the existing
%      singleton*.
%
%      H = TESTGUI1 returns the handle to a new TESTGUI1 or the handle to
%      the existing singleton*.
%
%      TESTGUI1('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TESTGUI1.M with the given input arguments.
%
%      TESTGUI1('Property','Value',...) creates a new TESTGUI1 or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before testGUI1_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to testGUI1_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help testGUI1

% Last Modified by GUIDE v2.5 25-Oct-2014 21:24:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @testGUI1_OpeningFcn, ...
                   'gui_OutputFcn',  @testGUI1_OutputFcn, ...
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


% --- Executes just before testGUI1 is made visible.
function testGUI1_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to testGUI1 (see VARARGIN)

surf(handles.currentdata)

% Choose default command line output for testGUI1
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes testGUI1 wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = testGUI1_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in togglebutton1.
function togglebutton1_Callback(hObject, eventdata, handles)
% hObject    handle to togglebutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
plot_state=get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of togglebutton1


% --- Executes on selection change in list.
function list_Callback(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns list contents as cell array
%        contents{get(hObject,'Value')} returns selected item from list
if (plot_state==1)
    str=get(hObject,'String');
    val=get(hObject,'Value'); 
switch str{val};
    case 'apple'
        handles.currentdata=peaks(35);
        surf(handles.currentdata);
    case 'banana'
         handles.currentdata=membrane;
         mesh(handles.currentdata);
    case 'orange'
        [x,y]=meshgrid(-8:.5:8);
        r=sqrt(x.^2+y.^2)+eps;
        sinc=sin(r)./r;
        handles.currentdata=sinc;
        contour(handles.currentdata);
end
end

guidata(hObject,handles)

% --- Executes during object creation, after setting all properties.
function list_CreateFcn(hObject, eventdata, handles)
% hObject    handle to list (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end
