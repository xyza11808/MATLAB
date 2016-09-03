function varargout = RandomNameGene(varargin)
% RANDOMNAMEGENE MATLAB code for RandomNameGene.fig
%      RANDOMNAMEGENE, by itself, creates a new RANDOMNAMEGENE or raises the existing
%      singleton*.
%
%      H = RANDOMNAMEGENE returns the handle to a new RANDOMNAMEGENE or the handle to
%      the existing singleton*.
%
%      RANDOMNAMEGENE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in RANDOMNAMEGENE.M with the given input arguments.
%
%      RANDOMNAMEGENE('Property','Value',...) creates a new RANDOMNAMEGENE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before RandomNameGene_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to RandomNameGene_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help RandomNameGene

% Last Modified by GUIDE v2.5 05-May-2016 00:33:26

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @RandomNameGene_OpeningFcn, ...
                   'gui_OutputFcn',  @RandomNameGene_OutputFcn, ...
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


% --- Executes just before RandomNameGene is made visible.
function RandomNameGene_OpeningFcn(hObject, eventdata, handles, varargin)
global names
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to RandomNameGene (see VARARGIN)

% Choose default command line output for RandomNameGene
handles.output = hObject;
names.StudentOnlyNames = {'������','����','�����','����','�����','��԰','��˳��','�δ���','����Ȼ'};
names.StaffInNames = {'������','����','�����','����','�����','��԰','��˳��',...
    'panda','������','��ӭӭ','����Ȼ'};
names.PIInNames = {'������','����','�����','����','�����','��԰','��˳��',...
    'XuNL','�δ���','����Ȼ'};
names.NameWeight = [];
names.isProgRun = 0;
set(handles.StudentCheck,'value',0);
set(handles.StaffCheck,'value',0);
set(handles.PICheck,'value',1);
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes RandomNameGene wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = RandomNameGene_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function NameDYN_Callback(hObject, eventdata, handles)
% hObject    handle to NameDYN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of NameDYN as text
%        str2double(get(hObject,'String')) returns contents of NameDYN as a double


% --- Executes during object creation, after setting all properties.
function NameDYN_CreateFcn(hObject, eventdata, handles)
% hObject    handle to NameDYN (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in StudentCheck.
function StudentCheck_Callback(hObject, eventdata, handles)
% hObject    handle to StudentCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StudentCheck
set(handles.PICheck,'value',0)
set(handles.StaffCheck,'value',0)

% --- Executes on button press in StaffCheck.
function StaffCheck_Callback(hObject, eventdata, handles)
% hObject    handle to StaffCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of StaffCheck
set(handles.StudentCheck,'value',0);
set(handles.PICheck,'value',0)

% --- Executes on button press in PICheck.
function PICheck_Callback(hObject, eventdata, handles)
% hObject    handle to PICheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of PICheck
set(handles.StudentCheck,'value',0);
set(handles.StaffCheck,'value',0)

% --- Executes on button press in StartGene.
function StartGene_Callback(hObject, eventdata, handles)
global names
% hObject    handle to StartGene (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.ConfigText,'string','');
if get(handles.StudentCheck,'value')
    cNames = names.StudentOnlyNames;
elseif get(handles.StaffCheck,'value')
      cNames = names.StaffInNames;
elseif get(handles.PICheck,'value')
     cNames = names.PIInNames;
else
    warndlg('No name type being choosed, using PIInNames list');
    cNames = names.PIInNames;
    set(handles.PICheck,'value',1);
end

nameLength = length(cNames);
if nameLength == length(names.NameWeight)
    if ~names.isProgRun
        names.NameWeight = ones(nameLength,1)/nameLength;
    end
else
    names.NameWeight = ones(nameLength,1)/nameLength;
end

rng('shuffle');
for n = 1 : 80
    y = randsample(nameLength,1,true,names.NameWeight);
    SampleName = cNames{y};
    set(handles.NameDYN,'string',SampleName);
    pause(0.01);
end
names.isProgRun = 1;
DecreaseWeight = names.NameWeight(y) - 1/(nameLength+1);  % new weight for selected person's weight
if DecreaseWeight < 0
    DecreaseWeight = 0.0001;
end
ChangedWeight = names.NameWeight(y) - DecreaseWeight;
ChangeWeight = zeros(nameLength,1) + ChangedWeight/(nameLength-1);
ChangeWeight(y) = 0;
names.NameWeight = ChangeWeight + names.NameWeight;
names.NameWeight(y) = DecreaseWeight;
% names.NameWeight'
% sum(names.NameWeight)
set(handles.ConfigText,'string','!!!CONGRATULATION!!!');

% ####################
% convert m file function into exe file
% mbuild -setup
% mcc -m RandomNameGene 
% ######################

function ConfigText_CreateFcn(hObject, eventdata, handles)
