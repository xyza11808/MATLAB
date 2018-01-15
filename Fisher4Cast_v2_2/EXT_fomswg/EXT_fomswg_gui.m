% ------------------------------------------------------------------------
% Copyright (C) 2008-2010
% Bruce Bassett Yabebal Fantaye  Renee Hlozek  Jacques Kotze
%
%
%
% This file is part of Fisher4Cast.
%
% Fisher4Cast is free software: you can redistribute it and/or modify
% it under the terms of the Berkeley Software Distribution (BSD) license.
%
% Fisher4Cast is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% BSD license for more details.
% ------------------------------------------------------------------------
function varargout = EXT_fomswg_gui(varargin)
% EXT_FOMSWG_GUI M-file for EXT_fomswg_gui.fig
%      EXT_FOMSWG_GUI, by itself, creates a new EXT_FOMSWG_GUI or raises the existing
%      singleton*.
%
%      H = EXT_FOMSWG_GUI returns the handle to a new EXT_FOMSWG_GUI or the handle to
%      the existing singleton*.
%
%      EXT_FOMSWG_GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EXT_FOMSWG_GUI.M with the given input arguments.
%
%      EXT_FOMSWG_GUI('Property','Value',...) creates a new EXT_FOMSWG_GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before EXT_fomswg_gui_OpeningFunction gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to EXT_fomswg_gui_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help EXT_fomswg_gui

% Last Modified by GUIDE v2.5 22-Apr-2010 12:26:28

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @EXT_fomswg_gui_OpeningFcn, ...
                   'gui_OutputFcn',  @EXT_fomswg_gui_OutputFcn, ...
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


% --- Executes just before EXT_fomswg_gui is made visible.
function EXT_fomswg_gui_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to EXT_fomswg_gui (see VARARGIN)
set(handles.uipanel1,'SelectionChangeFcn',@radio_buttongroup_SelectionChangeFcn);
% Choose default command line output for EXT_fomswg_gui
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes EXT_fomswg_gui wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = EXT_fomswg_gui_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function radio_buttongroup_SelectionChangeFcn(hObject, eventdata)
 
%retrieve GUI data, i.e. the handles structure
handles = guidata(hObject);
handles.default = 1;
if isfield(handles,'input_file')
    handles = rmfield(handles,'input_file');
end
switch get(eventdata.NewValue,'Tag')   % Get Tag of selected object
    case 'radiobutton1'
      %execute this code when fontsize08_radiobutton is selected
      %set(handles.default, 0)%set(handles.display_staticText,'FontSize',8);
      handles.default = 0;
      handles.input_file = 'uiimport';
    case 'radiobutton2'
      %execute this code when fontsize12_radiobutton is selected
      handles.default = 1;%set(handles.display_staticText,'FontSize',12);
    case 'radiobutton3'
      %execute this code when fontsize12_radiobutton is selected
      handles.default = 2;%set(handles.display_staticText,'FontSize',12); 
    case 'radiobutton4'
      %execute this code when fontsize12_radiobutton is selected
      handles.default = 3;%set(handles.display_staticText,'FontSize',12); 
    case 'radiobutton5'
      %execute this code when fontsize12_radiobutton is selected
      handles.default = 4;%set(handles.display_staticText,'FontSize',12); 
    case 'radiobutton6'
      %execute this code when fontsize12_radiobutton is selected
      handles.default = 5;%set(handles.display_staticText,'FontSize',12); 
    case 'radiobutton7'
      %execute this code when fontsize12_radiobutton is selected
      handles.default = 6;%set(handles.display_staticText,'FontSize',12); 
    case 'radiobutton8'
      %execute this code when fontsize12_radiobutton is selected
      handles.default = 7;%set(handles.display_staticText,'FontSize',12); 
    case 'radiobutton9'
      %execute this code when fontsize12_radiobutton is selected
      handles.default = 8;%set(handles.display_staticText,'FontSize',12); 
    otherwise
       % Code for when there is no match.
 
end
%updates the handles structure
guidata(hObject, handles);

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'default')
    handles.default = 1;
end
if handles.default == 0
    output = EXT_fomswg(handles.input_file)
else
    output = EXT_fomswg(handles.default)
end
set(handles.display_output_1,'String',output.input_data,'FontSize',8);
set(handles.edit2,'String',output.sig_w0,'FontSize',8);
set(handles.edit3,'String',output.sig_wa,'FontSize',8);
set(handles.edit4,'String',output.zp,'FontSize',8);
set(handles.edit5,'String',output.DETF_FoM,'FontSize',8);
set(handles.edit6,'String',output.sig_wp,'FontSize',8);
set(handles.edit7,'String',output.sig_w_const,'FontSize',8);
set(handles.edit8,'String',output.sig_gamma,'FontSize',8);
set(handles.edit9,'String',output.FoM_gamma,'FontSize',8);

function display_output_1_Callback(hObject, eventdata, handles)
% hObject    handle to display_output_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of display_output_1 as text
%        str2double(get(hObject,'String')) returns contents of
%        display_output_1 as a double


% --- Executes during object creation, after setting all properties.
function display_output_1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to display_output_1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit3 as text
%        str2double(get(hObject,'String')) returns contents of edit3 as a double


% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



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



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double


% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if ~isfield(handles,'default')
    handles.default = 1;
end
if handles.default == 0
    output = EXT_fomswg(handles.input_file)
else
    output = EXT_fomswg(handles.default)
end
set(handles.display_output_1,'String',output.input_data,'FontSize',8);
set(handles.edit2,'String',output.sig_w0,'FontSize',8);
set(handles.edit3,'String',output.sig_wa,'FontSize',8);
set(handles.edit4,'String',output.zp,'FontSize',8);
set(handles.edit5,'String',output.DETF_FoM,'FontSize',8);
set(handles.edit6,'String',output.sig_wp,'FontSize',8);
set(handles.edit7,'String',output.sig_w_const,'FontSize',8);
set(handles.edit8,'String',output.sig_gamma,'FontSize',8);
set(handles.edit9,'String',output.FoM_gamma,'FontSize',8);
if get(handles.checkbox1,'Value')
    figure(1);
    addpath ../;  
    EXT_fomswg_plot_ellipse(output.Marg_F);
end
if get(handles.checkbox2,'Value')
    figure(2)
    if isfield(output,'PC_all')
        EXT_fomswg_plot_PC(output.PC_all);
    elseif isfield(output,'PC_all_gamma')
        EXT_fomswg_plot_PC(output.PC_all_gamma);
    else
        errordlg('PC_all could not be found in the output structure. Please try plot the PC''s from the appropriate saved file in OUTPUT/');
        return;
    end  
end
if get(handles.checkbox1,'Value')==0 && get(handles.checkbox2,'Value')==0
    errordlg('One of the checkboxes must be selected in order to produce a plot.');
    return;
end

function edit8_Callback(hObject, eventdata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit8 as text
%        str2double(get(hObject,'String')) returns contents of edit8 as a double


% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, evendata, handles)
% hObject    handle to edit8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit9_Callback(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit9 as text
%        str2double(get(hObject,'String')) returns contents of edit9 as a double


% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox2
