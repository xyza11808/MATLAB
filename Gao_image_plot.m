function varargout = Gao_image_plot(varargin)
% GAO_IMAGE_PLOT MATLAB code for Gao_image_plot.fig
%      GAO_IMAGE_PLOT, by itself, creates a new GAO_IMAGE_PLOT or raises the existing
%      singleton*.
%
%      H = GAO_IMAGE_PLOT returns the handle to a new GAO_IMAGE_PLOT or the handle to
%      the existing singleton*.
%
%      GAO_IMAGE_PLOT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAO_IMAGE_PLOT.M with the given input arguments.
%
%      GAO_IMAGE_PLOT('Property','Value',...) creates a new GAO_IMAGE_PLOT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Gao_image_plot_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Gao_image_plot_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Gao_image_plot

% Last Modified by GUIDE v2.5 19-Jul-2019 23:46:13

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Gao_image_plot_OpeningFcn, ...
                   'gui_OutputFcn',  @Gao_image_plot_OutputFcn, ...
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


% --- Executes just before Gao_image_plot is made visible.
function Gao_image_plot_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Gao_image_plot (see VARARGIN)
global ImdataStrcs
% Choose default command line output for Gao_image_plot
handles.output = hObject;

ImdataStrcs.folder_path = '';
ImdataStrcs.fNumber = 0;
ImdataStrcs.fImDataAll = [];
ImdataStrcs.dffImDataAll = [];
ImdataStrcs.DfDataStd = [];
ImdataStrcs.Baseline_Time = 0;
ImdataStrcs.Stim_duration = 0;
ImdataStrcs.FrameRate = 0;
ImdataStrcs.Target_TimeAfterStimOn = 0;
ImdataStrcs.Target_StimDur = 0;
ImdataStrcs.Threshold_ratio = 3;
ImdataStrcs.AboveThresData = [];
ImdataStrcs.BlurImData = [];
ImdataStrcs.BaseGrayFig = [];
ImdataStrcs.FinalFigs = [];
ImdataStrcs.MaskColorUsed = [1,0,0];
ImdataStrcs.GrayScale = [3000,7000];
ImdataStrcs.BlurScale = 6;
ImdataStrcs.RespWindffData = [];
ImdataStrcs.ContinueMapScale = [0 1];

ImdataStrcs.IsAllParaInputs = [0,0,0];
ImdataStrcs.IsTagTimeGiven = [0,0,0];
set(handles.Blur_scale_tag,'String','6');
set(handles.Gray_scale_text_tag,'String','3000,7000');
set(handles.RedMap_tag,'Value',0);
set(handles.Green_map_tag,'Value',1);
set(handles.ContMap_plot_tag,'Value',0);

set(handles.Colormap_Color_scale_tag,'String','0,1');
set(handles.Colormap_Color_scale_tag,'visible','off');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Gao_image_plot wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Gao_image_plot_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in Load_path_tag.
function Load_path_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Load_path_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
fPath = uigetdir(pwd,'Please select your data folder');
if isempty(dir(fullfile(fPath,'*.tif')))
    yy = warndlg('Current folder have no tif files.','Error folder selection');
    delete(yy);
    return;
else
    ImdataStrcs.folder_path = fPath;
    Allfiles = dir(fullfile(fPath,'*.tif'));
    nfNumbers = length(Allfiles);
    ImdataStrcs.fNumber = nfNumbers;
    set(handles.NumFrames_text_tag,'String',sprintf('%d Frames',nfNumbers));
    set(handles.ImPath_edit_tag,'String',fPath);
end
fprintf('Loading all %d frames...\n',nfNumbers);
% loading tif files
warning off
ttf = Tiff(fullfile(fPath,Allfiles(1).name),'r');
ImHeight = getTag(ttf,'ImageLength');
ImWidth = getTag(ttf,'ImageWidth');

cfData = zeros(ImHeight,ImWidth,nfNumbers);
for cfs = 1 : nfNumbers
    cfName = Allfiles(cfs).name;
    ctf = Tiff(fullfile(fPath,cfName));
    cfData(:,:,cfs) = double(read(ctf));
end
warning on
ImdataStrcs.fImDataAll = cfData;
fprintf('Read %d frames complete!\n',nfNumbers);


function ImPath_edit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to ImPath_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImPath_edit_tag as text
%        str2double(get(hObject,'String')) returns contents of ImPath_edit_tag as a double


% --- Executes during object creation, after setting all properties.
function ImPath_edit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImPath_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Time_befStim_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Time_befStim_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
cInput = str2double(get(hObject,'String'));
if isempty(cInput) || cInput <= 0
    return;
else
    ImdataStrcs.Baseline_Time = cInput;
    ImdataStrcs.IsAllParaInputs(1) = 1;
end
% Hints: get(hObject,'String') returns contents of Time_befStim_tag as text
%        str2double(get(hObject,'String')) returns contents of Time_befStim_tag as a double


% --- Executes during object creation, after setting all properties.
function Time_befStim_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Time_befStim_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StimDur_edit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to StimDur_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
cInput = str2double(get(hObject,'String'));
if isempty(cInput) || cInput <= 0
    return;
else
    ImdataStrcs.Stim_duration = cInput;
    ImdataStrcs.IsAllParaInputs(2) = 1;
end
% Hints: get(hObject,'String') returns contents of StimDur_edit_tag as text
%        str2double(get(hObject,'String')) returns contents of StimDur_edit_tag as a double


% --- Executes during object creation, after setting all properties.
function StimDur_edit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StimDur_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function FrameRate_edit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to FrameRate_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
cInput = str2double(get(hObject,'String'));
if isempty(cInput) || cInput <= 0
    return;
else
    ImdataStrcs.FrameRate = cInput;
    ImdataStrcs.IsAllParaInputs(3) = 1;
end
% Hints: get(hObject,'String') returns contents of FrameRate_edit_tag as text
%        str2double(get(hObject,'String')) returns contents of FrameRate_edit_tag as a double


% --- Executes during object creation, after setting all properties.
function FrameRate_edit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameRate_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ThresRatio_tag_Callback(hObject, eventdata, handles)
% hObject    handle to ThresRatio_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
cInput = str2double(get(hObject,'String'));
if isempty(cInput) || cInput <= 0
    return;
else
    ImdataStrcs.Threshold_ratio = cInput;
    ImdataStrcs.IsTagTimeGiven(3) = 1;
end
% Hints: get(hObject,'String') returns contents of ThresRatio_tag as text
%        str2double(get(hObject,'String')) returns contents of ThresRatio_tag as a double


% --- Executes during object creation, after setting all properties.
function ThresRatio_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ThresRatio_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TimeAfter_stimOn_tag_Callback(hObject, eventdata, handles)
% hObject    handle to TimeAfter_stimOn_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
cInput = str2double(get(hObject,'String'));
if isempty(cInput) || cInput < 0
    return;
else
    if cInput >= (ImdataStrcs.Stim_duration - (2/ImdataStrcs.FrameRate))
        warning('Input time is out of stimulus duration range.\n');
        return;
    else
        ImdataStrcs.Target_TimeAfterStimOn = cInput;
        ImdataStrcs.IsTagTimeGiven(1) = 1;
    end
end
% Hints: get(hObject,'String') returns contents of TimeAfter_stimOn_tag as text
%        str2double(get(hObject,'String')) returns contents of TimeAfter_stimOn_tag as a double


% --- Executes during object creation, after setting all properties.
function TimeAfter_stimOn_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TimeAfter_stimOn_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Target_Dur_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Target_Dur_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
cInput = str2double(get(hObject,'String'));
if isempty(cInput) || cInput <= 0
    warning('Target duration shoudl be larger than 0.\n');
    return;
else
    if (cInput+ImdataStrcs.Target_TimeAfterStimOn) > ImdataStrcs.Stim_duration
        warning('Input time is out of stimulus duration range.\n');
        return;
    else
        ImdataStrcs.Target_StimDur = cInput;
        ImdataStrcs.IsTagTimeGiven(2) = 1;
    end
end
% Hints: get(hObject,'String') returns contents of Target_Dur_tag as text
%        str2double(get(hObject,'String')) returns contents of Target_Dur_tag as a double


% --- Executes during object creation, after setting all properties.
function Target_Dur_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Target_Dur_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ShowRes_tag.
function ShowRes_tag_Callback(hObject, eventdata, handles)
% hObject    handle to ShowRes_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
if sum(ImdataStrcs.IsAllParaInputs) < 3
    warning('Please input the stimulus parameters before plot.\n');
    return;
else
    BaselineFrameNum = round(ImdataStrcs.Baseline_Time * ImdataStrcs.FrameRate);
    BaselineFrameValues = mean(ImdataStrcs.fImDataAll(:,:,1:BaselineFrameNum),3);
    ImdataStrcs.BaseGrayFig = BaselineFrameValues;
    DfImData = (ImdataStrcs.fImDataAll - repmat(BaselineFrameValues,1,1,ImdataStrcs.fNumber))./...
        repmat(BaselineFrameValues,1,1,ImdataStrcs.fNumber);
    ImdataStrcs.DfDataStd = std(DfImData(:,:,1:BaselineFrameNum),[],3);
    ImdataStrcs.dffImDataAll = DfImData;
end
if ~ImdataStrcs.IsTagTimeGiven(3)
    ImdataStrcs.Threshold_ratio = 3;
    set(handles.ThresRatio_tag,'String','3');
end
if ~ImdataStrcs.IsTagTimeGiven(1)
    ImdataStrcs.Target_TimeAfterStimOn = 0;
    set(handles.TimeAfter_stimOn_tag,'String','0');
end
if ~ImdataStrcs.IsTagTimeGiven(2)
    ImdataStrcs.Target_StimDur = ImdataStrcs.Stim_duration;
    set(handles.Target_Dur_tag,'String',num2str(ImdataStrcs.Target_StimDur));
end
% calculate the response frames and compare with threshold
% ######################################################
TarStartPos = BaselineFrameNum+1+round(ImdataStrcs.Target_TimeAfterStimOn*ImdataStrcs.FrameRate);
AvgRespWinResp = mean(DfImData(:,:,TarStartPos:(TarStartPos + round(ImdataStrcs.Target_StimDur*ImdataStrcs.FrameRate))),3);
ImdataStrcs.RespWindffData = AvgRespWinResp;

Thres = ImdataStrcs.DfDataStd * ImdataStrcs.Threshold_ratio; % define threhold
ImdataStrcs.AboveThresData = double(AvgRespWinResp > Thres);
ImdataStrcs.BlurImData = double(imgaussfilt(ImdataStrcs.AboveThresData, ImdataStrcs.BlurScale) > 0.5);
ImdataStrcs.RawMaskData = zeros(size(ImdataStrcs.BlurImData));
RespDataSmooth = imgaussfilt(ImdataStrcs.AboveThresData, 2);
ImdataStrcs.RawMaskData(logical(ImdataStrcs.BlurImData)) = RespDataSmooth(logical(ImdataStrcs.BlurImData));

% ahowing images 
if isempty(ImdataStrcs.FinalFigs)
    ImdataStrcs.FinalFigs = figure('position',[100 100 380 300]);
else
    if ~ishandle(ImdataStrcs.FinalFigs)
        ImdataStrcs.FinalFigs = figure('position',[100 100 380 300]);
    else
        figure(ImdataStrcs.FinalFigs);
        clf;
    end
end
if ~ImdataStrcs.MaskColorUsed(3)
    RedMaps = [1,1,1;1,0.2,0.2];
    GrMap = [1,1,1;0.2,1,0.2];
    
    if ImdataStrcs.MaskColorUsed(1)
        cMap = GrMap;
    else
        cMap = RedMaps;
    end
    
    ax1=axes;
    h_backf=imagesc(ImdataStrcs.BaseGrayFig,ImdataStrcs.GrayScale);
    Cpos=get(ax1,'position');
    view(2);
    ax2=axes;
    h_frontf=imagesc(ImdataStrcs.BlurImData,[0 1]);
    set(h_frontf,'alphadata',(ImdataStrcs.BlurImData~=0)*0.4);
    % set(h_backf,'alphadata',SumROImask~=0);
    linkaxes([ax1,ax2]);
    ax2.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];
    colormap(ax2,cMap);
    colormap(ax1,'gray');
    set(ax1,'box','off');
    axis(ax1, 'off');
    
    title(ax1,sprintf('TAftOnset %.2fs Dur %.2fs',ImdataStrcs.Target_TimeAfterStimOn,ImdataStrcs.Target_StimDur));
else
    ax1=axes;
    h_backf=imagesc(ImdataStrcs.BaseGrayFig,ImdataStrcs.GrayScale);
    Cpos=get(ax1,'position');
    view(2);
    ax2=axes;
    h_frontf=imagesc(ImdataStrcs.RawMaskData ,ImdataStrcs.ContinueMapScale);
    set(h_frontf,'alphadata',(ImdataStrcs.BlurImData ~= 0)*0.5);
    % set(h_backf,'alphadata',SumROImask~=0);
    linkaxes([ax1,ax2]);
    ax2.Visible = 'off';
    ax2.XTick = [];
    ax2.YTick = [];
    colormap(ax2,'jet');
    colormap(ax1,'gray');
    set(ax1,'box','off');
    axis(ax1, 'off');
    
    title(ax1,sprintf('TAftOnset %.2fs Dur %.2fs',ImdataStrcs.Target_TimeAfterStimOn,ImdataStrcs.Target_StimDur));
end


% --- Executes on button press in Save_result_tag.
function Save_result_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Save_result_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
% save all results
fprintf('Save current results in path:\n%s\n',ImdataStrcs.folder_path);
AllSavedDatas = ImdataStrcs;
AllSavedDatas = rmfield(AllSavedDatas,{'FinalFigs','fImDataAll','dffImDataAll'});
save(fullfile(ImdataStrcs.folder_path,'ImResultAll.mat'),'AllSavedDatas','-v7.3');
if isempty(ImdataStrcs.FinalFigs)
    ShowRes_tag_Callback(hObject, eventdata, handles);
end
MaskColorStr = {'Green','Red','Cont'};
cStr = sprintf('%sMask Af%dms Dur%dms',MaskColorStr{logical(ImdataStrcs.MaskColorUsed)},...
    ImdataStrcs.Target_TimeAfterStimOn*1000,ImdataStrcs.Target_StimDur*1000);
Save_path = fullfile(ImdataStrcs.folder_path,cStr);
saveas(ImdataStrcs.FinalFigs,Save_path);
saveas(ImdataStrcs.FinalFigs,Save_path,'png');
saveas(ImdataStrcs.FinalFigs,Save_path,'pdf');
fprintf('Save all files.\n');

% --- Executes on button press in View_dff_im_tag.
function View_dff_im_tag_Callback(hObject, eventdata, handles)
% hObject    handle to View_dff_im_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
if sum(ImdataStrcs.IsAllParaInputs) < 3
    warning('Please input the stimulus parameters before plot.\n');
    return;
else
    BaselineFrameNum = round(ImdataStrcs.Baseline_Time * ImdataStrcs.FrameRate);
    BaselineFrameValues = mean(ImdataStrcs.fImDataAll(:,:,1:BaselineFrameNum),3);
    DfImData = (ImdataStrcs.fImDataAll - repmat(BaselineFrameValues,1,1,ImdataStrcs.fNumber))./...
        repmat(BaselineFrameValues,1,1,ImdataStrcs.fNumber);
    hViewf = figure;
    for cfs = 1 : ImdataStrcs.fNumber
        ccData = squeeze(DfImData(:,:,cfs));
        figure(hViewf);
        imagesc(ccData,[-0.1 1]);
        colormap gray
        title(num2str(cfs/ImdataStrcs.FrameRate,'%.3fs'));
        pause(0.1);
    end
end


% --- Executes on button press in RedMap_tag.
function RedMap_tag_Callback(hObject, eventdata, handles)
% hObject    handle to RedMap_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
if get(hObject,'Value')
    set(handles.Green_map_tag,'Value',0);
    ImdataStrcs.MaskColorUsed = [0,1,0];
else
    set(handles.Green_map_tag,'Value',1);
    ImdataStrcs.MaskColorUsed = [1,0,0];
end
set(handles.ContMap_plot_tag,'Value',0);
set(handles.Colormap_Color_scale_tag,'visible','off');
ShowRes_tag_Callback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of RedMap_tag


% --- Executes during object creation, after setting all properties.
function RedMap_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RedMap_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in Green_map_tag.
function Green_map_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Green_map_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
if get(hObject,'Value')
    set(handles.RedMap_tag,'Value',0);
    ImdataStrcs.MaskColorUsed = [1,0,0];
else
    set(handles.RedMap_tag,'Value',1);
    ImdataStrcs.MaskColorUsed = [0,1,0];
end
set(handles.ContMap_plot_tag,'Value',0);
set(handles.Colormap_Color_scale_tag,'visible','off');
ShowRes_tag_Callback(hObject, eventdata, handles);
% Hint: get(hObject,'Value') returns toggle state of Green_map_tag


% --- Executes during object creation, after setting all properties.
function Green_map_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Green_map_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called



function Gray_scale_text_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Gray_scale_text_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
Scales = str2num(get(hObject,'String'));
if length(Scales) ~= 2 || diff(Scales) <= 0
    return;
else
    ImdataStrcs.GrayScale = Scales;
end
% Hints: get(hObject,'String') returns contents of Gray_scale_text_tag as text
%        str2double(get(hObject,'String')) returns contents of Gray_scale_text_tag as a double


% --- Executes during object creation, after setting all properties.
function Gray_scale_text_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Gray_scale_text_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function Blur_scale_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Blur_scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
cInput = str2double(get(hObject,'String'));
if isempty(cInput)
    set(handles.Blur_scale_tag,'String',num2str(ImdataStrcs.BlurScale));
    return;
end
if cInput <= 0 || numel(cInput) > 1
    warning('Input should be a positive value and no longer than 1.\n');
    set(handles.Blur_scale_tag,'String',num2str(ImdataStrcs.BlurScale));
    return;
else
    ImdataStrcs.BlurScale = cInput;
end
% Hints: get(hObject,'String') returns contents of Blur_scale_tag as text
%        str2double(get(hObject,'String')) returns contents of Blur_scale_tag as a double


% --- Executes during object creation, after setting all properties.
function Blur_scale_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Blur_scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ContMap_plot_tag.
function ContMap_plot_tag_Callback(hObject, eventdata, handles)
% hObject    handle to ContMap_plot_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
% Hint: get(hObject,'Value') returns toggle state of ContMap_plot_tag
ImdataStrcs.MaskColorUsed = [0,0,1];
set(handles.Colormap_Color_scale_tag,'visible','on');
ShowRes_tag_Callback(hObject, eventdata, handles);
set(handles.RedMap_tag,'Value',0);
set(handles.Green_map_tag,'Value',0);


function Colormap_Color_scale_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Colormap_Color_scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ImdataStrcs
cInput = str2num(get(hObject,'String'));
if length(cInput) < 2 || diff(cInput) <= 0
    warning('Error input scale.\n');
    return;
else
    ImdataStrcs.ContinueMapScale = cInput;
    if ImdataStrcs.MaskColorUsed(3)
        ContMap_plot_tag_Callback(hObject, eventdata, handles);
    end
end
% Hints: get(hObject,'String') returns contents of Colormap_Color_scale_tag as text
%        str2double(get(hObject,'String')) returns contents of Colormap_Color_scale_tag as a double


% --- Executes during object creation, after setting all properties.
function Colormap_Color_scale_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Colormap_Color_scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
