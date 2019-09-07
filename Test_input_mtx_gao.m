function varargout = Test_input_mtx_gao(varargin)
% TEST_INPUT_MTX_GAO MATLAB code for Test_input_mtx_gao.fig
%      TEST_INPUT_MTX_GAO, by itself, creates a new TEST_INPUT_MTX_GAO or raises the existing
%      singleton*.
%
%      H = TEST_INPUT_MTX_GAO returns the handle to a new TEST_INPUT_MTX_GAO or the handle to
%      the existing singleton*.
%
%      TEST_INPUT_MTX_GAO('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in TEST_INPUT_MTX_GAO.M with the given input arguments.
%
%      TEST_INPUT_MTX_GAO('Property','Value',...) creates a new TEST_INPUT_MTX_GAO or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Test_input_mtx_gao_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Test_input_mtx_gao_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Test_input_mtx_gao

% Last Modified by GUIDE v2.5 06-Sep-2019 13:39:57

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Test_input_mtx_gao_OpeningFcn, ...
                   'gui_OutputFcn',  @Test_input_mtx_gao_OutputFcn, ...
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


% --- Executes just before Test_input_mtx_gao is made visible.
function Test_input_mtx_gao_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Test_input_mtx_gao (see VARARGIN)
global cApData
% Choose default command line output for Test_input_mtx_gao
handles.output = hObject;

cApData.ColNum = 3;
cApData.RowNum = 4;
cApData.TableData = zeros(4,3);
cApData.ScaleNum = 50;
cApData.PlotData = [];
cApData.ImShowScale = [0,1];
cApData.ImFig = [];

InitialData = cell(4,3);
InitialData(:) = {0};
set(handles.Data_table_tag,'Data',InitialData);
set(handles.Scale_edit_tag,'string','50');
set(handles.ImShow_scale_tag,'String','0,1');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Test_input_mtx_gao wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Test_input_mtx_gao_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function Col_Num_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Col_Num_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cApData
cV = str2double(get(hObject,'String'));
% cApData.ColNum = cV;
if ~isnumeric(cV) || length(cV) ~= 1
    warning('Error Input values.');
    return;
else
    cApData.ColNum = cV;
%     cApData.RowNum = cV;
    set(handles.Data_table_tag,'Data',num2cell(zeros(cApData.RowNum,cApData.ColNum)));
    cApData.TableData = zeros(cApData.RowNum,cApData.ColNum);
end

set(handles.Data_table_tag,'ColumnEditable',true(1,cV));


% --- Executes during object creation, after setting all properties.
function Col_Num_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Col_Num_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','3');


function Row_Num_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Row_Num_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cApData

cV = str2double(get(hObject,'String'));
if ~isnumeric(cV) || length(cV) ~= 1
    warning('Error Input values.');
    return;
else
    % cApData.ColNum = cV;
    cApData.RowNum = cV;
    set(handles.Data_table_tag,'Data',num2cell(zeros(cApData.RowNum,cApData.ColNum)));
    cApData.TableData = zeros(cApData.RowNum,cApData.ColNum);
end


% --- Executes during object creation, after setting all properties.
function Row_Num_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Row_Num_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','4');


% --- Executes when entered data in editable cell(s) in Data_table_tag.
function Data_table_tag_CellEditCallback(hObject, eventdata, handles)
% hObject    handle to Data_table_tag (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.CONTROL.TABLE)
%	Indices: row and column indices of the cell(s) edited
%	PreviousData: previous data for the cell(s) edited
%	EditData: string(s) entered by the user
%	NewData: EditData or its converted form set on the Data property. Empty if Data was not changed
%	Error: error string when failed to convert EditData to appropriate value for Data
% handles    structure with handles and user data (see GUIDATA)
global cApData
if ischar(eventdata.NewData)
    InputData = str2double(eventdata.NewData);
else
    InputData = eventdata.NewData;
end

if ~isnumeric(InputData) || length(InputData) ~= 1
    warning('Error Input for current section.');
    return;
else
    TableDatas = cell2mat(eventdata.Source.Data);
    cApData.TableData = TableDatas;
    cApData.ImShowScale(1) = min(cApData.ImShowScale(1),min(TableDatas(:)));
    cApData.ImShowScale(2) = max(cApData.ImShowScale(2),max(TableDatas(:)));
    set(handles.ImShow_scale_tag,'string',sprintf('%.1f , %.1f',cApData.ImShowScale(1),cApData.ImShowScale(2)));
end


% --- Executes during object creation, after setting all properties.
function Data_table_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Data_table_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
% global cApData
set(hObject,'ColumnEditable',true(1,3));



function Scale_edit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Scale_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cApData
% Hints: get(hObject,'String') returns contents of Scale_edit_tag as text
%        str2double(get(hObject,'String')) returns contents of Scale_edit_tag as a double
cV = str2double(get(hObject,'String'));
if ~isnumeric(cV) || length(cV) ~= 1 || cV <=0
    warning('Error Input values');
    return;
else
    cApData.ScaleNum = cV;
    Gene_plot_tag_Callback(handles.Gene_plot_tag, eventdata, handles);
end

% --- Executes during object creation, after setting all properties.
function Scale_edit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Scale_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Gene_plot_tag.
function Gene_plot_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Gene_plot_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cApData
data = cApData.TableData;
%// Define integer grid of coordinates for the above data
[X,Y] = meshgrid(1:size(data,2), 1:size(data,1));

FineStep = 1/cApData.ScaleNum;
%// Define a finer grid of points
xSteps = 1:FineStep:size(data,2);
ySteps = 1:FineStep:size(data,1);
[X2,Y2] = meshgrid(xSteps, ySteps);
%// Interpolate the data and show the output
cApData.PlotData = interp2(X, Y, data, X2, Y2, 'linear');
if isempty(cApData.ImFig) || ~ishandle(cApData.ImFig)
    cApData.ImFig = figure;
else
    figure(cApData.ImFig);
    clf;
end

hold on
imagesc(xSteps,ySteps,cApData.PlotData, cApData.ImShowScale);
colorbar;

% MassCent = round(centerOfMass(cApData.PlotData));
xx = 1:numel(xSteps);
yy = 1:numel(ySteps);
[UsedXX,UsedYY] = meshgrid(xx, yy);
Com_x = mean(cApData.PlotData(:).*UsedXX(:)) / mean(cApData.PlotData(:));
Com_y = mean(cApData.PlotData(:).*UsedYY(:)) / mean(cApData.PlotData(:));
plot(xSteps(round(Com_x)),ySteps(round(Com_y)),'o','MarkerSize',16,'linewidth',2,'Color',[.6 .6 .6]);

set(gca,'ydir','reverse','ytick',1:size(data,1),'xtick',1:size(data,2));
set(gca,'xlim',[1,size(data,2)],'ylim',[1,size(data,1)]);



% --- Executes on button press in Save_result_tag.
function Save_result_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Save_result_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cApData
saveFolder = uigetdir(pwd,'Please select you figurte save path');
FullsavePath = fullfile(saveFolder,'Color_plot_save');
MatsavePath = fullfile(saveFolder,'Color_plot_data.mat');
try
    saveas(cApData.ImFig,FullsavePath);
    saveas(cApData.ImFig,FullsavePath,'png');
    PlotDatas.Data = cApData.PlotData;
    PlotDatas.PlotData = cApData.ImShowScale;
    PlotDatas.Scales = cApData.ImShowScale;
    save(MatsavePath,'PlotDatas','-v7.3');
catch
    fprintf('Please generate the fig first!\n');
end

function ImShow_scale_tag_Callback(hObject, eventdata, handles)
% hObject    handle to ImShow_scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global cApData
InputNum = str2num(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of FrameScale_edit_tag as text
%        str2double(get(hObject,'String')) returns contents of FrameScale_edit_tag as a double
if numel(InputNum) ~= 2
    warning('Error input values.');
    return;
else
    if diff(InputNum) <= 0
        warning('The input value should be monotonically increase.');
        return;
    end
    cApData.ImShowScale = InputNum;
    Gene_plot_tag_Callback(handles.Gene_plot_tag, eventdata, handles);
end

% --- Executes during object creation, after setting all properties.
function ImShow_scale_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImShow_scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
