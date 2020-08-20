function varargout = PupilScaleSelection(varargin)
% PUPILSCALESELECTION MATLAB code for PupilScaleSelection.fig
%      PUPILSCALESELECTION, by itself, creates a new PUPILSCALESELECTION or raises the existing
%      singleton*.
%
%      H = PUPILSCALESELECTION returns the handle to a new PUPILSCALESELECTION or the handle to
%      the existing singleton*.
%
%      PUPILSCALESELECTION('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in PUPILSCALESELECTION.M with the given input arguments.
%
%      PUPILSCALESELECTION('Property','Value',...) creates a new PUPILSCALESELECTION or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before PupilScaleSelection_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to PupilScaleSelection_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help PupilScaleSelection

% Last Modified by GUIDE v2.5 13-Aug-2020 17:41:31

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @PupilScaleSelection_OpeningFcn, ...
                   'gui_OutputFcn',  @PupilScaleSelection_OutputFcn, ...
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


% --- Executes just before PupilScaleSelection is made visible.
function PupilScaleSelection_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to PupilScaleSelection (see VARARGIN)

% Choose default command line output for PupilScaleSelection
handles.output = hObject;
global PupilDetectionDatas

PupilDetectionDatas.filePath = '';
PupilDetectionDatas.fileName = '';
PupilDetectionDatas.RawVideoData = [];
PupilDetectionDatas.TotalFrameNum = 0;
PupilDetectionDatas.CurrentFrameNum = 1;

PupilDetectionDatas.TargetRegCoord = [];
PupilDetectionDatas.TargetRegionData = [];
PupilDetectionDatas.PupilBrightThres = [];
PupilDetectionDatas.PupilBrightscale = [];

PupilDetectionDatas.PupilSizeData = [];
PupilDetectionDatas.hRawAx = [];
PupilDetectionDatas.hUpperAxis = handles.TargetRegAxes;
PupilDetectionDatas.hLowerAxis = handles.UpperAxisTag;
PupilDetectionDatas.hGround = [];
PupilDetectionDatas.Thres_pupilMask = [];

PupilDetectionDatas.ax2 = [];


PupilDetectionDatas.cTargetRegionFrame = [];
PupilDetectionDatas.Thres_pupilData = [];

PupilDetectionDatas.Gau2dFitParas = [];
PupilDetectionDatas.FittedData = {};
PupilDetectionDatas.com = [];
PupilDetectionDatas.Thres_pupilBrightData = [];
PupilDetectionDatas.PupilBrightcom = [];

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes PupilScaleSelection wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = PupilScaleSelection_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function VideoPathEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to VideoPathEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilDetectionDatas

InputString = get(hObject,'String');
if ~exist(InputString,'file')
    return;
end
pathparts = strsplit(InputString,filesep);
zz = pathparts(1:end-1);
% fileFolderPath = fullfile(zz{:});
% FileName = pathparts{end};
PupilDetectionDatas.filePath = fullfile(zz{:});
PupilDetectionDatas.fileName = FileName;
[PupilDetectionDatas.RawVideoData, PupilDetectionDatas.PupilBrightscale] = ...
    readVideoFun(fullfile(PupilDetectionDatas.filePath, ...
    PupilDetectionDatas.fileName));
PupilDetectionDatas.TotalFrameNum = size(PupilDetectionDatas.RawVideoData, 3);
PupilDetectionDatas.CurrentFrameNum = 1;
set(handles.TotalFrame_tag,'String',num2str(PupilDetectionDatas.TotalFrameNum));
set(handles.cFrameEdit_tag,'String',num2str(1));
set(handles.MinScaleedit_tag, 'String', num2str(PupilDetectionDatas.PupilBrightscale(1)));
set(handles.MaxScaleedit_tag, 'String', num2str(PupilDetectionDatas.PupilBrightscale(2)));
set(handles.ThresSlider_tag, 'min', PupilDetectionDatas.PupilBrightscale(1),'max',...
    PupilDetectionDatas.PupilBrightscale(2), 'SliderStep',[0.02, 5],'value',mean(PupilDetectionDatas.PupilBrightscale));
set(handles.CurrentScaleEdit_tag, 'String', num2str(PupilDetectionDatas.PupilBrightscale(1)));
PupilDetectionDatas.PupilBrightscale = PupilDetectionDatas.PupilBrightscale;
PupilDetectionDatas.PupilBrightThres = mean(PupilDetectionDatas.PupilBrightscale);


function [AllFrameData, Frame_Scale] = readVideoFun(FullPath)
% read video image
fobj = VideoReader(FullPath);
AllFrameData = zeros(fobj.Height, fobj.Width, round(fobj.Duration * fobj.FrameRate)); 
FrameScales = zeros(round(fobj.Duration * fobj.FrameRate), 2);
k = 1;
while hasFrame(fobj)
    vidframe = readFrame(fobj);
    cFrame = squeeze(mean(double(vidframe),3));
    AllFrameData(:,:,k) = cFrame;
    FrameScales(k,:) = [min(cFrame(:)) max(cFrame(:))];
    k = k +1;
end
Frame_Scale = [min(FrameScales(:,1)), max(FrameScales(:,2))];
% Hints: get(hObject,'String') returns contents of VideoPathEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of VideoPathEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function VideoPathEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to VideoPathEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in FileSelectBut_tag.
function FileSelectBut_tag_Callback(hObject, eventdata, handles)
% hObject    handle to FileSelectBut_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilDetectionDatas
[fn,fp,fi] = uigetfile('*.*','Please select the video file');
if ~fi
    return;
end
InputString = fullfile(fp,fn);
if ~exist(InputString,'file')
    return;
end
set(handles.VideoPathEdit_tag,'String',fullfile(fp,fn));
% fileFolderPath = fullfile(zz{:});
% FileName = pathparts{end};
PupilDetectionDatas.filePath = fp;
PupilDetectionDatas.fileName = fn;
[PupilDetectionDatas.RawVideoData, PupilDetectionDatas.PupilBrightscale] = readVideoFun(fullfile(fp, fn));
PupilDetectionDatas.TotalFrameNum = size(PupilDetectionDatas.RawVideoData, 3);
PupilDetectionDatas.CurrentFrameNum = 1;
set(handles.TotalFrame_tag,'String',num2str(PupilDetectionDatas.TotalFrameNum));
set(handles.cFrameEdit_tag,'String',num2str(1));
set(handles.MinScaleedit_tag, 'String', num2str(PupilDetectionDatas.PupilBrightscale(1)));
set(handles.MaxScaleedit_tag, 'String', num2str(PupilDetectionDatas.PupilBrightscale(2)));
set(handles.ThresSlider_tag, 'min', PupilDetectionDatas.PupilBrightscale(1),'max',...
    PupilDetectionDatas.PupilBrightscale(2), 'SliderStep',[0.02, 5],'value',mean(PupilDetectionDatas.PupilBrightscale));
set(handles.CurrentScaleEdit_tag, 'String', num2str(PupilDetectionDatas.PupilBrightscale(1)));
PupilDetectionDatas.PupilBrightscale = PupilDetectionDatas.PupilBrightscale;
PupilDetectionDatas.PupilBrightThres = mean(PupilDetectionDatas.PupilBrightscale);


% --- Executes on slider movement.
function ThresSlider_tag_Callback(hObject, eventdata, handles)
% hObject    handle to ThresSlider_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilDetectionDatas
InputValue = get(hObject,'Value');

PupilDetectionDatas.PupilBrightThres = InputValue;

if ~isempty(PupilDetectionDatas.TargetRegAxes) && ~isempty(PupilDetectionDatas.Thres_pupilMask)
    GeneMask_tag_Callback([], eventdata, handles);
end
set(handles.CurrentScaleEdit_tag,'String',num2str(InputValue, '%.2f'));

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function ThresSlider_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThresSlider_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function MinScaleedit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to MinScaleedit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilDetectionDatas
if ~isempty(PupilDetectionDatas.PupilBrightscale)
    InputValue = str2double(get(hObject,'String'));
    if InputValue > PupilDetectionDatas.PupilBrightscale(2)
        warning('The input value must be smaller than max value');
        set(hObject,'String',num2str(PupilDetectionDatas.PupilBrightscale(1)));
        return;
    end
        PupilDetectionDatas.PupilBrightscale(1) = InputValue;
end

if ~isempty(PupilDetectionDatas.TargetRegionData)
    set(PupilDetectionDatas.TargetRegAxes,'clim', PupilDetectionDatas.PupilBrightscale);
end

% Hints: get(hObject,'String') returns contents of MinScaleedit_tag as text
%        str2double(get(hObject,'String')) returns contents of MinScaleedit_tag as a double


% --- Executes during object creation, after setting all properties.
function MinScaleedit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MinScaleedit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function MaxScaleedit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to MaxScaleedit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilDetectionDatas
if ~isempty(PupilDetectionDatas.PupilBrightscale)
    InputValue = str2double(get(hObject,'String'));
    if InputValue < PupilDetectionDatas.PupilBrightscale(1)
        warning('The input value must be larger than min value');
        set(hObject,'String',num2str(PupilDetectionDatas.PupilBrightscale(2)));
        return;
    end
        PupilDetectionDatas.PupilBrightscale(2) = InputValue;
end

if ~isempty(PupilDetectionDatas.TargetRegionData)
    set(PupilDetectionDatas.TargetRegAxes,'clim', PupilDetectionDatas.PupilBrightscale);
end

% Hints: get(hObject,'String') returns contents of MaxScaleedit_tag as text
%        str2double(get(hObject,'String')) returns contents of MaxScaleedit_tag as a double


% --- Executes during object creation, after setting all properties.
function MaxScaleedit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MaxScaleedit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function CurrentScaleEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentScaleEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilDetectionDatas
InputValue = str2double(get(hObject,'String'));
if isempty(InputValue)
    return;
end
Sliderscale = PupilDetectionDatas.PupilBrightscale;
if InputValue < Sliderscale(1) || InputValue > Sliderscale(2)
    warning('The input value is out of range.');
    set(hObject,'String', num2str(PupilDetectionDatas.PupilBrightThres));
else
    PupilDetectionDatas.PupilBrightThres = InputValue;
end
if ~isempty(handles.TargetRegAxes) && ~isempty(PupilDetectionDatas.Thres_pupilMask)
    GeneMask_tag_Callback([], eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of CurrentScaleEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of CurrentScaleEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function CurrentScaleEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentScaleEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cFrameEdit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to cFrameEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilDetectionDatas
cFrameIn = str2double(get(hObject,'String'));
if cFrameIn < 1 || cFrameIn > PupilDetectionDatas.TotalFrameNum
    warning('Input out of range');
    set(hObject,'String',num2str(PupilDetectionDatas.CurrentFrameNum));
    return;
end
PupilDetectionDatas.CurrentFrameNum = cFrameIn;
ShowFrame_tag_Callback(handles.ShowFrame_tag, eventdata, handles);
% Hints: get(hObject,'String') returns contents of cFrameEdit_tag as text
%        str2double(get(hObject,'String')) returns contents of cFrameEdit_tag as a double


% --- Executes during object creation, after setting all properties.
function cFrameEdit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cFrameEdit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in TargetRegionSelect_tag.
function TargetRegionSelect_tag_Callback(hObject, eventdata, handles)
% hObject    handle to TargetRegionSelect_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilDetectionDatas
if isempty(PupilDetectionDatas.RawVideoData)
    warning('Please load video data before target region selection');
    return;
end
if isempty(PupilDetectionDatas.hRawAx)
    ShowFrame_tag_Callback([], eventdata, handles);
end
axes(PupilDetectionDatas.hRawAx);
if isempty(PupilDetectionDatas.TargetRegCoord)
    [x, y] = ginput(4); % target around the eye area
    PupilDetectionDatas.TargetRegCoord = round([min(x) max(x); min(y) max(y)]);
    ShowFrame_tag_Callback([], eventdata, handles);
    
end
yy = PupilDetectionDatas.TargetRegCoord;
PupilDetectionDatas.TargetRegionData = PupilDetectionDatas.RawVideoData(yy(2,1):yy(2,2), ...
    yy(1,1):yy(1,2), :);

PupilDetectionDatas.cTargetRegionFrame = squeeze(PupilDetectionDatas.TargetRegionData(:,:,...
        PupilDetectionDatas.CurrentFrameNum));
% PupilDetectionDatas.PupilBrightscale = [min(PupilDetectionDatas.cTargetRegionFrame(:)), ...
%     max(PupilDetectionDatas.cTargetRegionFrame(:))];
% set(handles.MinScaleedit_tag,'String',num2str('%d', PupilDetectionDatas.PupilBrightscale(1)));
% set(handles.MaxScaleedit_tag,'String',num2str('%d', PupilDetectionDatas.PupilBrightscale(1)));

axes(handles.TargetRegAxes);
cla(handles.TargetRegAxes);
PupilDetectionDatas.hGround = imagesc(handles.TargetRegAxes, PupilDetectionDatas.cTargetRegionFrame, ...
    PupilDetectionDatas.PupilBrightscale);
if ~isempty(PupilDetectionDatas.Thres_pupilMask)
    AddMaskOnTop(PupilDetectionDatas.Thres_pupilMask, [0,0,0; 0,0,1]);
    updateCenterMask(handles.TargetRegAxes);

end

function updateCenterMask(TargetAxes)
global PupilDetectionDatas
% calculate the mask

% find pixels less than input threshold, normalize and than reverse
% PupilDetectionDatas.Thres_pupilMask = PupilDetectionDatas.cTargetRegionFrame < ...
%     PupilDetectionDatas.PupilBrightThres;
PupilDetectionDatas.Thres_pupilData = 1 - PupilDetectionDatas.cTargetRegionFrame/ 255; % normalize and reverse
PupilDetectionDatas.Thres_pupilData(~PupilDetectionDatas.Thres_pupilMask) = 0;

% calculate the center of mass
PupilDetectionDatas.com = comFun(PupilDetectionDatas.Thres_pupilData);
PupilInitWidth = [size(PupilDetectionDatas.Thres_pupilData, 1)/4, ...
    size(PupilDetectionDatas.Thres_pupilData, 2)/4];
[FitParas,resnorm,residual,exitflag, FitDataCell] = Fit2DGauFun(PupilDetectionDatas.Thres_pupilData, ...
'RotGau2D', PupilDetectionDatas.com, PupilInitWidth);
PupilDetectionDatas.Gau2dFitParas = FitParas;
PupilDetectionDatas.FittedData = FitDataCell;

MaskedDataRev = PupilDetectionDatas.Thres_pupilData;
[X,Y] = meshgrid(1:size(MaskedDataRev,2), 1:size(MaskedDataRev,1));
figure; 
hold on
surface(X, Y, MaskedDataRev,'EdgeColor','r','Facecolor','interp');
surface(FitDataCell{1}(:,:,1), FitDataCell{1}(:,:,2), FitDataCell{2},'EdgeColor','none','Facecolor','interp','FaceAlpha',0.5);

[xline, yline] = ellipseFun(FitParas([2,4]), FitParas([3,5])*2, [], FitParas(6));

axes(TargetAxes);
plot(xline, yline,'r','linewidth',1.2)
ComData = PupilDetectionDatas.com;
plot(ComData(1), ComData(2),'g.','MarkerSize', 20);
[AxisPointsx, AxisPointsy] = ellipseFun(FitParas([2,4]), FitParas([3,5])*1.5, [0 pi/2], FitParas(6));
line([ComData(1), AxisPointsx(1)], [ComData(2), AxisPointsy(1)],'Color','g','linewidth',1.6);
line([ComData(1), AxisPointsx(2)], [ComData(2), AxisPointsy(2)],'Color','m','linewidth',1.6);

% calculate the bright site com
PupilDetectionDatas.Thres_pupilBrightData = PupilDetectionDatas.cTargetRegionFrame/ 255; % normalize and reverse
PupilDetectionDatas.Thres_pupilBrightData(~PupilDetectionDatas.Thres_pupilMask) = 0;
PupilDetectionDatas.PupilBrightcom = comFun(PupilDetectionDatas.Thres_pupilBrightData);
plot(PupilDetectionDatas.PupilBrightcom(1), PupilDetectionDatas.PupilBrightcom(2),'b.','MarkerSize', 20);


function AddMaskOnTop(Mask, Color)
global PupilDetectionDatas
ax1 = PupilDetectionDatas.hLowerAxis;
hold(ax1, 'on');
Ax1Pos = get(ax1,'position');
set(PupilDetectionDatas.hUpperAxis, 'position', Ax1Pos);
% PupilDetectionDatas.ax2 = axes('position', Ax1Pos);
hold(PupilDetectionDatas.hUpperAxis, 'on');
hFront = imagesc(PupilDetectionDatas.hUpperAxis, Mask);
colormap(PupilDetectionDatas.hUpperAxis, Color);
set(hFront, 'alphadata', 0.5*(Mask > 0));
linkaxes([PupilDetectionDatas.hLowerAxis, PupilDetectionDatas.hUpperAxis]);
PupilDetectionDatas.hUpperAxis.Visible = 'off';
PupilDetectionDatas.hUpperAxis.XTick = [];
PupilDetectionDatas.hUpperAxis.YTick = [];
PupilDetectionDatas.hUpperAxis.YDir = 'Reverse';
set(PupilDetectionDatas.hLowerAxis,'box','off');
axis(PupilDetectionDatas.hLowerAxis, 'off');
% PupilDetectionDatas.UpperMaskAx = ax2;


% --- Executes on button press in GeneMask_tag.
function GeneMask_tag_Callback(hObject, eventdata, handles)
% hObject    handle to GeneMask_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilDetectionDatas
if isempty(PupilDetectionDatas.cTargetRegionFrame) || ... 
    isempty(PupilDetectionDatas.PupilBrightThres)
    return;
end
PupilDetectionDatas.Thres_pupilMask = PupilDetectionDatas.cTargetRegionFrame < ...
    PupilDetectionDatas.PupilBrightThres;

axes(handles.TargetRegAxes);
cla(handles.TargetRegAxes);
PupilDetectionDatas.hGround = imagesc(handles.TargetRegAxes, PupilDetectionDatas.cTargetRegionFrame, ...
    PupilDetectionDatas.PupilBrightscale);

AddMaskOnTop(PupilDetectionDatas.Thres_pupilMask, [0,0,0; 0,0,1]);

updateCenterMask(handles.TargetRegAxes);


% --- Executes on button press in ShowFrame_tag.
function ShowFrame_tag_Callback(hObject, eventdata, handles)
% hObject    handle to ShowFrame_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global PupilDetectionDatas
PupilDetectionDatas.cFData = squeeze(PupilDetectionDatas.RawVideoData(:,:,PupilDetectionDatas.CurrentFrameNum));
PupilDetectionDatas.hRawAx = handles.ImageShowTag;
cla(PupilDetectionDatas.hRawAx);
imagesc(PupilDetectionDatas.hRawAx, PupilDetectionDatas. cFData, [0 255]);
colormap gray
if ~isempty(PupilDetectionDatas.TargetRegCoord) % 2*2 matrix, first row is x coordinates, second is y
    patch_x = [PupilDetectionDatas.TargetRegCoord(1,:), fliplr(PupilDetectionDatas.TargetRegCoord(1,:))];
    patch_y = [PupilDetectionDatas.TargetRegCoord(2,:);PupilDetectionDatas.TargetRegCoord(2,:)];
    patch_y = patch_y(:);
    patch(patch_x, patch_y,1,'FaceColor','none','EdgeColor','g','linewidth',2.4);
end
% if ~isempty(PupilDetectionDatas.TargetRegCoord)
%     TargetRegionSelect_tag_Callback(handles.TargetRegionSelect_tag, eventdata, handles);
% end

% --- Executes on button press in SaveRes_tag.
function SaveRes_tag_Callback(hObject, eventdata, handles)
% hObject    handle to SaveRes_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on mouse press over axes background.
function TargetRegAxes_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to TargetRegAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
