function varargout = Figure_axes_setGUI(varargin)
% FIGURE_AXES_SETGUI MATLAB code for Figure_axes_setGUI.fig
%      FIGURE_AXES_SETGUI, by itself, creates a new FIGURE_AXES_SETGUI or raises the existing
%      singleton*.
%
%      H = FIGURE_AXES_SETGUI returns the handle to a new FIGURE_AXES_SETGUI or the handle to
%      the existing singleton*.
%
%      FIGURE_AXES_SETGUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FIGURE_AXES_SETGUI.M with the given input arguments.
%
%      FIGURE_AXES_SETGUI('Property','Value',...) creates a new FIGURE_AXES_SETGUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Figure_axes_setGUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Figure_axes_setGUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Figure_axes_setGUI

% Last Modified by GUIDE v2.5 05-Jan-2018 22:18:21

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Figure_axes_setGUI_OpeningFcn, ...
                   'gui_OutputFcn',  @Figure_axes_setGUI_OutputFcn, ...
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


% --- Executes just before Figure_axes_setGUI is made visible.
function Figure_axes_setGUI_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Figure_axes_setGUI (see VARARGIN)
global FigureAxes

FigureAxes.figHandle = [];
FigureAxes.AxesPos = {};
FigureAxes.MaxAxesNum = 12;
FigureAxes.InputFigNum = [];
FigureAxes.FPosition = [];
FigureAxes.AxesHandle = {};
FigureAxes.MaxAxesPos = {};
% using a default 3*4 layout
for cc = 1 : FigureAxes.MaxAxesNum
    [Row,Col] = ind2sub([3,4],cc);
    ccStartPoint = [0.05+0.3*(Row-1),0.98-0.24*Col];
    FigureAxes.MaxAxesPos{cc} = [ccStartPoint,0.28,0.22];
end
if nargin > 3
    if ~isempty(varargin{1})
        InputStrc = varargin{1};
        if isstruct(InputStrc)
            if isfield(InputStrc,'AxesHandle') && isfield(InputStrc,'AxesPos') && isfield(InputStrc,'figHandle')
                FigureAxes.AxesHandle = InputStrc.AxesHandle;
                FigureAxes.AxesPos = InputStrc.AxesPos;
                FigureAxes.figHandle = InputStrc.figHandle;
                FigureAxes.FPosition = InputStrc.FPosition;
                InputNum = length(FigureAxes.AxesHandle);
                FigureAxes.InputFigNum = InputNum;
                for cA = 1 : InputNum
                    cRealPos = FigureAxes.AxesPos{cA};
                    set(eval(sprintf('handles.axes%d_pos',cA)),'String',sprintf('%.4f,%.4f,%.4f,%.4f',...
                        cRealPos(1),cRealPos(2),cRealPos(3),cRealPos(4)));
                    set(eval(sprintf('handles.axes%d_pos',cA)),'Visible','on');
                    set(eval(sprintf('handles.Axes%d_text',cA)),'Visible','on');
                    set(handles.FigNumInput,'String',num2str(InputNum));
                end
                for ExtraA = InputNum+1:FigureAxes.MaxAxesNum
                    set(eval(sprintf('handles.axes%d_pos',ExtraA)),'Visible','off');
                    set(eval(sprintf('handles.Axes%d_text',ExtraA)),'Visible','off');
                end

                UpdateFigureAxes(handles);
            end
        else
            if isnumeric(InputStrc)
                if InputStrc>0 && InputStrc<12   % within maxium range
                    set(handles.FigNumInput,'String',num2str(InputStrc));
                    FigNumInput_Callback(hObject, eventdata, handles);
                end
            end
        end
    end
end
% Choose default command line output for Figure_axes_setGUI
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Figure_axes_setGUI wait for user response (see UIRESUME)
uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Figure_axes_setGUI_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
OutAxesData = struct();
OutAxesData.AxesHandle = FigureAxes.AxesHandle;
OutAxesData.AxesPos = FigureAxes.AxesPos;
OutAxesData.figHandle = FigureAxes.figHandle;
OutAxesData.FPosition = FigureAxes.FPosition;
% Get default command line output from handles structure
varargout{1} = OutAxesData;
% delete(handles.figure1);
% if isequal(get(hObject, 'waitstatus'), 'waiting')
%     % The GUI is still in UIWAIT, us UIRESUME
%     uiresume(hObject);
% else
%     % The GUI is no longer waiting, just close it
%     delete(hObject);
% end


function FigNumInput_Callback(hObject, eventdata, handles)
% hObject    handle to FigNumInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes

InputNum = str2double(get(handles.FigNumInput,'String'));
if ~isnumeric(InputNum)
    warning('Input should be a numeric number less than %d.\n',FigureAxes.MaxAxesNum);
    return;
elseif InputNum<0 || InputNum>FigureAxes.MaxAxesNum
    warning('Input number outof index range.\n');
    return;
end
FigureAxes.InputFigNum = InputNum;
FigureAxes.AxesPos = {};
FigureAxes.AxesHandle = {};
for cA = 1 : InputNum
    cAPos = eval(sprintf('get(handles.axes%d_pos,''String'')',cA));
    if isempty(cAPos)
        cRealPos = FigureAxes.MaxAxesPos{cA};
    else
        caPos = strsplit(cAPos,',');
        cRealPos = str2double(caPos);
    end
    FigureAxes.AxesPos{cA} = cRealPos;
    set(eval(sprintf('handles.axes%d_pos',cA)),'String',sprintf('%.4f,%.4f,%.4f,%.4f',...
        cRealPos(1),cRealPos(2),cRealPos(3),cRealPos(4)));
    set(eval(sprintf('handles.axes%d_pos',cA)),'Visible','on');
    set(eval(sprintf('handles.Axes%d_text',cA)),'Visible','on');
end
for ExtraA = InputNum+1:FigureAxes.MaxAxesNum
    set(eval(sprintf('handles.axes%d_pos',ExtraA)),'Visible','off');
    set(eval(sprintf('handles.Axes%d_text',ExtraA)),'Visible','off');
end
    
UpdateFigureAxes(handles)
% fprintf(5);
% Hints: get(hObject,'String') returns contents of FigNumInput as text
%        str2double(get(hObject,'String')) returns contents of FigNumInput as a double



% --- Executes during object creation, after setting all properties.
function FigNumInput_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FigNumInput (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white','FontSize',12);
end



function axes1_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes1_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 1;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);
% Hints: get(hObject,'String') returns contents of axes1_pos as text
%        str2double(get(hObject,'String')) returns contents of axes1_pos as a double


% --- Executes during object creation, after setting all properties.
function axes1_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes1_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes2_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes2_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 2;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);
% Hints: get(hObject,'String') returns contents of axes2_pos as text
%        str2double(get(hObject,'String')) returns contents of axes2_pos as a double


% --- Executes during object creation, after setting all properties.
function axes2_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes2_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes3_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes3_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 3;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);

% Hints: get(hObject,'String') returns contents of axes3_pos as text
%        str2double(get(hObject,'String')) returns contents of axes3_pos as a double


% --- Executes during object creation, after setting all properties.
function axes3_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes3_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes4_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes4_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 4;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);

% Hints: get(hObject,'String') returns contents of axes4_pos as text
%        str2double(get(hObject,'String')) returns contents of axes4_pos as a double


% --- Executes during object creation, after setting all properties.
function axes4_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes4_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes5_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes5_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 5;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);

% Hints: get(hObject,'String') returns contents of axes5_pos as text
%        str2double(get(hObject,'String')) returns contents of axes5_pos as a double


% --- Executes during object creation, after setting all properties.
function axes5_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes5_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes6_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes6_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 6;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);

% Hints: get(hObject,'String') returns contents of axes6_pos as text
%        str2double(get(hObject,'String')) returns contents of axes6_pos as a double


% --- Executes during object creation, after setting all properties.
function axes6_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes6_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes7_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes7_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 7;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);

% Hints: get(hObject,'String') returns contents of axes7_pos as text
%        str2double(get(hObject,'String')) returns contents of axes7_pos as a double


% --- Executes during object creation, after setting all properties.
function axes7_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes7_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes8_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes8_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 8;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);

% Hints: get(hObject,'String') returns contents of axes8_pos as text
%        str2double(get(hObject,'String')) returns contents of axes8_pos as a double


% --- Executes during object creation, after setting all properties.
function axes8_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes8_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes9_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes9_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 9;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);

% Hints: get(hObject,'String') returns contents of axes9_pos as text
%        str2double(get(hObject,'String')) returns contents of axes9_pos as a double


% --- Executes during object creation, after setting all properties.
function axes9_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes9_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes10_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes10_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 10;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);
% Hints: get(hObject,'String') returns contents of axes10_pos as text
%        str2double(get(hObject,'String')) returns contents of axes10_pos as a double


% --- Executes during object creation, after setting all properties.
function axes10_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes10_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes11_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes11_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 11;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);

% Hints: get(hObject,'String') returns contents of axes11_pos as text
%        str2double(get(hObject,'String')) returns contents of axes11_pos as a double


% --- Executes during object creation, after setting all properties.
function axes11_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes11_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function axes12_pos_Callback(hObject, eventdata, handles)
% hObject    handle to axes12_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global FigureAxes
cANum = 12;
cAPos = get(hObject,'String');
if isempty(cAPos)
    cRealPos = FigureAxes.MaxAxesPos{cANum};
else
    caPos = strsplit(cAPos,',');
    cRealPos = str2double(caPos);
end
if ~isempty(FigureAxes.AxesHandle{cANum})
%     set(FigureAxes.AxesHandle{cANum},'position',cRealPos);
    FigureAxes.AxesPos{cANum} = cRealPos;
else
%    FigureAxes.AxesHandle{cANum} = axes('position',cRealPos);
   FigureAxes.AxesPos{cANum} = cRealPos;
end
UpdateFigureAxes(handles);
% Hints: get(hObject,'String') returns contents of axes12_pos as text
%        str2double(get(hObject,'String')) returns contents of axes12_pos as a double


% --- Executes during object creation, after setting all properties.
function axes12_pos_CreateFcn(hObject, eventdata, handles)
% hObject    handle to axes12_pos (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in FigTypeTags.
function FigTypeTags_Callback(hObject, eventdata, handles)
% hObject    handle to FigTypeTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
UpdateFigureAxes(handles)
% Hints: contents = cellstr(get(hObject,'String')) returns FigTypeTags contents as cell array
%        contents{get(hObject,'Value')} returns selected item from FigTypeTags


% --- Executes during object creation, after setting all properties.
function FigTypeTags_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FigTypeTags (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'A4';'A4 Hor';'Square'},'Value',1,'FontSize',12);


function UpdateFigureAxes(handles,varargin)
global FigureAxes
Fig_Type = get(handles.FigTypeTags,'String');
cFigType = Fig_Type{get(handles.FigTypeTags,'Value')};
switch cFigType
    case 'A4'
        FigPos = [50 50 707.1 1000];
    case 'A4 Hor'
        FigPos = [50 50 1414 1000];
    case 'Square'
        FigPos = [50 50 950 950];
    otherwise
        FigPos = [50 50 707.1 1000];
        warning('Unknowing figPos type, using default A4 data');
end
if isempty(FigureAxes.figHandle) || ~ishandle(FigureAxes.figHandle)
    hf = figure('position',FigPos);
    FigureAxes.figHandle = hf;
    figure(hf);
else
    clf(FigureAxes.figHandle,'reset');
    set(FigureAxes.figHandle,'position',FigPos);
    figure(FigureAxes.figHandle);
end
FigureAxes.FPosition = FigPos;
nAxes = length(FigureAxes.AxesPos);
if nAxes > 0
    for n = 1 : nAxes
        cAxesPos = FigureAxes.AxesPos{n};
        ca = axes('position',cAxesPos);
        FigureAxes.AxesHandle{n} = ca;
        annotation('textbox',[cAxesPos(1),cAxesPos(2),cAxesPos(3)*0.6,cAxesPos(4)*0.5],'String',sprintf('Axes%d',n),...
            'FitBoxToText','on','EdgeColor','none');
%         title(ca,sprintf('Axes%d',n));
    end
%     for cn = nAxes+1:FigureAxes.MaxAxesNum
%         FigureAxes.AxesHandle{cn} = [];
%         
end
