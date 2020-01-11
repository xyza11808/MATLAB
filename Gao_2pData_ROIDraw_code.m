function varargout = Gao_2pData_ROIDraw_code(varargin)
% GAO_2PDATA_ROIDRAW_CODE MATLAB code for Gao_2pData_ROIDraw_code.fig
%      GAO_2PDATA_ROIDRAW_CODE, by itself, creates a new GAO_2PDATA_ROIDRAW_CODE or raises the existing
%      singleton*.
%
%      H = GAO_2PDATA_ROIDRAW_CODE returns the handle to a new GAO_2PDATA_ROIDRAW_CODE or the handle to
%      the existing singleton*.
%
%      GAO_2PDATA_ROIDRAW_CODE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GAO_2PDATA_ROIDRAW_CODE.M with the given input arguments.
%
%      GAO_2PDATA_ROIDRAW_CODE('Property','Value',...) creates a new GAO_2PDATA_ROIDRAW_CODE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Gao_2pData_ROIDraw_code_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Gao_2pData_ROIDraw_code_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Gao_2pData_ROIDraw_code

% Last Modified by GUIDE v2.5 23-Dec-2019 21:18:02

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @Gao_2pData_ROIDraw_code_OpeningFcn, ...
                   'gui_OutputFcn',  @Gao_2pData_ROIDraw_code_OutputFcn, ...
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


% --- Executes just before Gao_2pData_ROIDraw_code is made visible.
function Gao_2pData_ROIDraw_code_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Gao_2pData_ROIDraw_code (see VARARGIN)
global ROIDataSummary
% Choose default command line output for Gao_2pData_ROIDraw_code
handles.output = hObject;

ROIDataSummary.DataPath = '';
ROIDataSummary.DataFolder = '';
ROIDataSummary.AlignData = {};
ROIDataSummary.ROIinfo = struct('ROIpos',[],'ROImask',[]);
ROIDataSummary.ROIData = {};
ROIDataSummary.TotalROI = 0;
ROIDataSummary.CurrentROI = 0;
ROIDataSummary.TotalSession = 0;
ROIDataSummary.CurrentSess = 0;
ROIDataSummary.imFig = [];
ROIDataSummary.FrameColorScale = [0 3000];
ROIDataSummary.ImType = [1,0]; % mean image, [0,1] means max-delta image
set(handles.Mean_im_type_tag,'value',1);
set(handles.MaxDelta_im_tag,'value',0);
ROIDataSummary.PlotImData = [];
ROIDataSummary.IsMultiAdd = 0;
ROIDataSummary.SessNames = {};
ROIDataSummary.DffData = [];
ROIDataSummary.SelectDffData = [];
ROIDataSummary.LeftRightTrNum = [0,0];
ROIDataSummary.FrameRate = 5;
ROIDataSummary.OnsetTime = 6;
ROIDataSummary.ROIInfoSavePath = [];
ROIDataSummary.cSessData = [];

set(handles.FrameRate_edit_tag,'String','5');
set(handles.StimOnset_edit_tag,'String','6');

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes Gao_2pData_ROIDraw_code wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Gao_2pData_ROIDraw_code_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in LoadAlignData_tag.
function LoadAlignData_tag_Callback(hObject, eventdata, handles)
% hObject    handle to LoadAlignData_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
ROIDataSummary.DataPath = '';
ROIDataSummary.DataFolder = '';
ROIDataSummary.AlignData = {};
ROIDataSummary.ROIData = {};
ROIDataSummary.imFig = [];
ROIDataSummary.PlotImData = [];

[fn,fp,fi] = uigetfile('AlignedData.mat','Please select the aligned data mat file');
if ~fi
    return;
else
    ROIDataSummary.DataPath = fullfile(fp,fn);
    ROIDataSummary.DataFolder = fp;
    cd(fp);
    fprintf('Loading file: %s...\n',ROIDataSummary.DataPath);
    LoadAlignData = load(ROIDataSummary.DataPath);
    fprintf('Loading complete!\n');
    ROIDataSummary.AlignData = LoadAlignData.AlignedTifs;
    ROIDataSummary.SessNames = LoadAlignData.TiffolderNames;
    ROIDataSummary.TotalSession = length(ROIDataSummary.AlignData);
    if ROIDataSummary.TotalSession < 1
        error('Empty input data!');
    end
    ROIDataSummary.CurrentSess = 1;
    set(handles.TotalSessNum_tag,'string',num2str(ROIDataSummary.TotalSession));
    set(handles.CurrentSess_tag,'string',num2str(ROIDataSummary.CurrentSess));
    
    ROIDataSummary.cSessData = ROIDataSummary.AlignData{ROIDataSummary.CurrentSess};
end


function CurrentSess_tag_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentSess_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
% Hints: get(hObject,'String') returns contents of CurrentSess_tag as text
%        str2double(get(hObject,'String')) returns contents of CurrentSess_tag as a double
InputSess = str2double(get(hObject,'String'));
if InputSess < 1 || InputSess > ROIDataSummary.TotalSession
    error('Input out of range.');
else
    ROIDataSummary.CurrentSess = InputSess;
    ROIDataSummary.cSessData = ROIDataSummary.AlignData{InputSess};
    ShowImage_tag_Callback(handles.ShowImage_tag, eventdata, handles)
end

% --- Executes during object creation, after setting all properties.
function CurrentSess_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentSess_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function C_ROI_edit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to C_ROI_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
cV = str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of C_ROI_edit_tag as text
%        str2double(get(hObject,'String')) returns contents of C_ROI_edit_tag as a double
if ~isnumeric(cV) || length(cV) ~= 1
    warning('Error input values.\n');
    return;
else
    if cV < 0 || cV > ROIDataSummary.TotalROI
        warning('Input values out of range.\n');
        return;
    else
        ROIDataSummary.CurrentROI = cV;
        UpdatesROIPlots;
    end
end


% --- Executes during object creation, after setting all properties.
function C_ROI_edit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to C_ROI_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Add_ROI_tag.
function Add_ROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Add_ROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
if ROIDataSummary.IsMultiAdd
    warning('Possible Multi click on ROI add button.');
    return;
else
    ROIDataSummary.IsMultiAdd = 1;
    ROIDataSummary.TotalROI = ROIDataSummary.TotalROI + 1;
    ROIDataSummary.CurrentROI = ROIDataSummary.TotalROI;
    set(handles.TotalROI_num_text_tag,'String',num2str(ROIDataSummary.TotalROI));
    set(handles.C_ROI_edit_tag,'String',num2str(ROIDataSummary.TotalROI));
    cROI = ROIDataSummary.CurrentROI;
    
    if isempty(ROIDataSummary.imFig) || ~sum(ishandle(ROIDataSummary.imFig))
        warning('Please calculate the background image first.');
        return;
    end
    figure(ROIDataSummary.imFig);
    
    % draw ROIs
    ROIDraw=1;
    while ROIDraw
        h_ROI=imfreehand;
        h_mask=createMask(h_ROI);
        h_position=getPosition(h_ROI);
        choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes','Re-draw','Cancle','Yes');
        switch choice
            case 'Yes'
                ROIDataSummary.ROIinfo(cROI).ROImask=h_mask;
                ROIDataSummary.ROIinfo(cROI).ROIpos=h_position;

                delete(h_ROI);
                ROIDataSummary.IsMultiAdd = 0;
                ROIDraw=0;
                UpdatesROIPlots;
                
            case 'Cancle'
                delete(h_ROI);
                ROIDraw=0;
                ROIDataSummary.TotalROI = ROIDataSummary.TotalROI - 1;
                ROIDataSummary.CurrentROI = ROIDataSummary.TotalROI;
                set(handles.TotalROI_num_text_tag,'String',num2str(ROIDataSummary.TotalROI));
                set(handles.C_ROI_edit_tag,'String',num2str(ROIDataSummary.TotalROI));
                ROIDataSummary.IsMultiAdd = 0;
            case 'Re-draw'
                delete(h_ROI);
            otherwise
                warning('Quit ROI drawing.');
                delete(h_ROI);
                ROIDraw=0;
        end
    end

end

% --- Executes on button press in Edit_ROI_tag.
function Edit_ROI_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Edit_ROI_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
cROI = ROIDataSummary.CurrentROI;
if isempty(ROIDataSummary.imFig) || ~sum(ishandle(ROIDataSummary.imFig))
    ShowImage_tag_Callback(hObject, eventdata, handles);
else
    figure(ROIDataSummary.imFig);
    
     % draw ROIs
    ROIDraw=1;
    while ROIDraw
        h_ROI=imfreehand;
        h_mask=createMask(h_ROI);
        h_position=getPosition(h_ROI);
        choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes','Re-draw','Cancle','Yes');
        switch choice
            case 'Yes'
                ROIDataSummary.ROIinfo(cROI).ROImask=h_mask;
                ROIDataSummary.ROIinfo(cROI).ROIpos=h_position;
                delete(h_ROI);
                ROIDraw=0;
                UpdatesROIPlots;
            case 'Cancle'
                delete(h_ROI);
                ROIDraw=0;
                
            case 'Re-draw'
                delete(h_ROI);
            otherwise
                warning('Quit ROI drawing.');
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
cROI = ROIDataSummary.CurrentROI;
choice = questdlg(sprintf('Are you sure to delete ROI%d?',cROI),'confirm ROI deletion',...
    'Yes','No','Cancle','Yes');
switch choice
    case 'Yes'
        if (ROIDataSummary.TotalROI < 1)
            return;
        end
       
       ROIDataSummary.TotalROI = ROIDataSummary.TotalROI - 1;
       ROIDataSummary.ROIinfo(cROI) = [];
       if cROI == 1
           ROIDataSummary.CurrentROI = 1;
       else
            ROIDataSummary.CurrentROI = cROI - 1;
       end
       
       set(handles.TotalROI_num_text_tag,'String',num2str(ROIDataSummary.TotalROI));
       set(handles.C_ROI_edit_tag,'String',num2str(ROIDataSummary.CurrentROI));
       UpdatesROIPlots;
       
    case 'No'
        return;
        
    case 'Cancle'
        return;
        
    otherwise
        warning('Quit ROI deletion.');
end

% --- Executes on button press in Frame_scale_tag.
function Frame_scale_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Frame_scale_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function FrameScale_edit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to FrameScale_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
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
    ROIDataSummary.FrameColorScale = InputNum;
    ShowImage_tag_Callback(hObject, eventdata, handles)
end


% --- Executes during object creation, after setting all properties.
function FrameScale_edit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FrameScale_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'string','0,3000');

% --- Executes on button press in ShowImage_tag.
function ShowImage_tag_Callback(hObject, eventdata, handles)
% hObject    handle to ShowImage_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
if isempty(ROIDataSummary.cSessData)
    warning('No data can be used for plots.');
    return;
end
UsedData = ROIDataSummary.cSessData;

if ROIDataSummary.ImType(1)
    % mean image plots
    ROIDataSummary.PlotImData = squeeze(mean(UsedData,3));
elseif ROIDataSummary.ImType(2)
    % maxDelta image plots
    MeanIm = squeeze(mean(UsedData,3));
    Im_max = max(double(im_mov_avg(UsedData,3)),[],3);
    ROIDataSummary.PlotImData = Im_max - MeanIm;
end

UpdatesROIPlots;

function UpdatesROIPlots
global ROIDataSummary

if isempty(ROIDataSummary.imFig) || ~sum(ishandle(ROIDataSummary.imFig))
    ROIDataSummary.imFig = figure('position',[100 100 1100 950]);
else
    figure(ROIDataSummary.imFig);
    clf;
end
imagesc(ROIDataSummary.PlotImData,ROIDataSummary.FrameColorScale);
colormap gray
if ROIDataSummary.TotalROI >= 1
    for cR = 1 : ROIDataSummary.TotalROI
        cRPos = ROIDataSummary.ROIinfo(cR).ROIpos;
        MeanPos = mean(cRPos);
        if cR == ROIDataSummary.CurrentROI
            line(cRPos(:,1),cRPos(:,2),'Color','r','linewidth',1.5);
            text(MeanPos(1),MeanPos(2),num2str(cR),'Color','c','FontSize',12);
        else
            line(cRPos(:,1),cRPos(:,2),'Color','r','linewidth',1);
            text(MeanPos(1),MeanPos(2),num2str(cR),'Color','c','FontSize',8);
        end
    end
end


% --- Executes on button press in Mean_im_type_tag.
function Mean_im_type_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Mean_im_type_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
% Hint: get(hObject,'Value') returns toggle state of MaxDelta_im_tag
cV = get(hObject,'Value');
if cV
    set(handles.MaxDelta_im_tag,'value',0);
    ROIDataSummary.ImType = [1,0];
%     set(handles.MaxDelta_im_tag,'value',0);
    
else
    set(handles.MaxDelta_im_tag,'value',1);
    ROIDataSummary.ImType = [0,1];
end

if ~isempty(ROIDataSummary.imFig) || sum(ishandle(ROIDataSummary.imFig))
    ShowImage_tag_Callback(hObject, eventdata, handles);
end     

% --- Executes on button press in MaxDelta_im_tag.
function MaxDelta_im_tag_Callback(hObject, eventdata, handles)
% hObject    handle to MaxDelta_im_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
% Hint: get(hObject,'Value') returns toggle state of MaxDelta_im_tag
cV = get(hObject,'Value');
if cV
    set(handles.Mean_im_type_tag,'value',0);
    ROIDataSummary.ImType = [0,1];
%     set(handles.MaxDelta_im_tag,'value',0);
    
else
    set(handles.Mean_im_type_tag,'value',1);
    ROIDataSummary.ImType = [1,0];
end

if ~isempty(ROIDataSummary.imFig) && sum(ishandle(ROIDataSummary.imFig))
    ShowImage_tag_Callback(hObject, eventdata, handles);
end     


% --- Executes on button press in SaveROIData_tag.
function SaveROIData_tag_Callback(hObject, eventdata, handles)
% hObject    handle to SaveROIData_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
% extract ROI data and save
fprintf('Extracting ROI datas ...\n');

AllSess_ROIdata = cellfun(@(x) ExtractROIDatas(x,ROIDataSummary.ROIinfo),...
    ROIDataSummary.AlignData,'UniformOutput',false);
ROIDataSummary.ROIData = AllSess_ROIdata;
if isempty(ROIDataSummary.ROIInfoSavePath)
    ROISaveDir = uigetdir(pwd,'Please select ROIinfo save path');
    ROIDataSummary.ROIInfoSavePath = ROISaveDir;
end
ROISavedPath = fullfile(ROIDataSummary.ROIInfoSavePath,'ROIData_save.mat');
ROIInfos = ROIDataSummary.ROIinfo;
save(ROISavedPath,'AllSess_ROIdata','ROIInfos','-v7.3');
fprintf('ROI data saved in %s.\n',ROISavedPath);


% --- Executes on button press in SessNumAdd_tag.
function SessNumAdd_tag_Callback(hObject, eventdata, handles)
% hObject    handle to SessNumAdd_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
NewSess = ROIDataSummary.CurrentSess + 1;
if NewSess > ROIDataSummary.TotalSession
    NewSess = 1;
end
% ROIDataSummary.CurrentSess = NewSess;
set(handles.CurrentSess_tag,'string',num2str(NewSess));
CurrentSess_tag_Callback(handles.CurrentSess_tag, eventdata, handles);


% --- Executes on button press in SessNumMinus_tag.
function SessNumMinus_tag_Callback(hObject, eventdata, handles)
% hObject    handle to SessNumMinus_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
NewSess = ROIDataSummary.CurrentSess - 1;
if NewSess < 0
    NewSess = ROIDataSummary.TotalSession;
end
% ROIDataSummary.CurrentSess = NewSess;
set(handles.CurrentSess_tag,'string',num2str(NewSess));
CurrentSess_tag_Callback(handles.CurrentSess_tag, eventdata, handles);


% --- Executes on button press in ROIPlot_and_save_tag.
function ROIPlot_and_save_tag_Callback(hObject, eventdata, handles)
% hObject    handle to ROIPlot_and_save_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
if isempty(ROIDataSummary.ROIinfo(1).ROIpos)
    warning('Empty ROIs for plot.');
else
    if ROIDataSummary.TotalROI > 0
%         if isempty(ROIDataSummary.ROIData)
            % extract ROI data first
            AllSess_ROIdata = cellfun(@(x) ExtractROIDatas(x,ROIDataSummary.ROIinfo),...
                ROIDataSummary.AlignData,'UniformOutput',false);
            ROIDataSummary.ROIData = AllSess_ROIdata;
%         end
        % calculate dff
        SessFrameNum = cellfun(@(x) size(x,2),ROIDataSummary.ROIData);
        SessMinFrame = min(SessFrameNum);
        AllROI_dffData = zeros(ROIDataSummary.TotalROI,ROIDataSummary.TotalSession,SessMinFrame);
        for cROI = 1 : ROIDataSummary.TotalROI
            cROIData = cellfun(@(x) (x(cROI,:))',ROIDataSummary.ROIData,'UniformOutput',0);
            cRDataTrace = cell2mat(cROIData);
            cRf0 = prctile(cRDataTrace,8);
            
            cR_FixedLenResp = cellfun(@(x) x(cROI,1:SessMinFrame),ROIDataSummary.ROIData,'UniformOutput',0);
            cRDffMtx = (cell2mat(cR_FixedLenResp) - cRf0)/cRf0;
            AllROI_dffData(cROI,:,:) = cRDffMtx;
        end
        ROIDataSummary.DffData = AllROI_dffData;
        ROIRespData = struct();
        StimOnsetFrame = ROIDataSummary.FrameRate * ROIDataSummary.OnsetTime;
        if ROIDataSummary.TotalSession > 2
            LeftTTF = contains(ROIDataSummary.SessNames,'left','IgnoreCase',true);
            RightTTF = contains(ROIDataSummary.SessNames,'right','IgnoreCase',true);
            ROIDataSummary.LeftRightTrNum = [sum(LeftTTF),sum(RightTTF)];

            LeftIndex = find(LeftTTF);
            RightIndex = find(RightTTF);

            ROIDataSummary.SelectDffData = ROIDataSummary.DffData(:,[LeftIndex(:);RightIndex(:)],:);

            TotalTrNum = sum(ROIDataSummary.LeftRightTrNum);

            if ~isdir('./ROI_plot/')
                mkdir('./ROI_plot/');
            end
            cd('./ROI_plot/');
            
            for cR = 1 : ROIDataSummary.TotalROI
                hf = figure('position',[100 100 850 340]);
                cRData = squeeze(ROIDataSummary.SelectDffData(cR,:,:));
                subplot(121)
                imagesc(cRData,[0 max(0.5,max(cRData(:)))]);
                colorbar;
                title(num2str(cR,'ROI%d'));
                set(gca,'ytick',[(1+ROIDataSummary.LeftRightTrNum(1))/2,...
                    ROIDataSummary.LeftRightTrNum(1)+ROIDataSummary.LeftRightTrNum(2)/2],...
                    'yticklabel',{'Left','Right'});
                line([0.5 SessMinFrame+0.5],[0.5 0.5]+ROIDataSummary.LeftRightTrNum(1),'Color','r',...
                    'linewidth',1.8);

                line([0.5 0.5]+StimOnsetFrame,[0.5 sum(ROIDataSummary.LeftRightTrNum)+0.5],'Color','c',...
                    'linewidth',1.5);


                subplot(122)
                hold on
                MeanTraceLeft = mean(cRData(1:ROIDataSummary.LeftRightTrNum(1),:));
                SEMTraceLeft = std(cRData(1:ROIDataSummary.LeftRightTrNum(1),:))/sqrt(ROIDataSummary.LeftRightTrNum(1));
                MeanTraceRight = mean(cRData((1+ROIDataSummary.LeftRightTrNum(1)):end,:));
                SEMTraceRight = std(cRData((1+ROIDataSummary.LeftRightTrNum(1)):end,:))/sqrt(ROIDataSummary.LeftRightTrNum(2));

                Patchx = [1:SessMinFrame,SessMinFrame:-1:1];
                LeftPattch = [MeanTraceLeft+SEMTraceLeft,fliplr(MeanTraceLeft-SEMTraceLeft)];
                RightPatch = [MeanTraceRight+SEMTraceRight,fliplr(MeanTraceRight-SEMTraceRight)];
                patch(Patchx,LeftPattch,1,'Facecolor',[0.3 0.8 0.3],'edgecolor','none','facealpha',0.6);
                patch(Patchx,RightPatch,1,'Facecolor',[0.8 0.3 0.3],'edgecolor','none','facealpha',0.6);
                plot(1:SessMinFrame,MeanTraceLeft,'b','linewidth',1.5);
                plot(1:SessMinFrame,MeanTraceRight,'r','linewidth',1.5);
                yscales = get(gca,'ylim');
                line([StimOnsetFrame StimOnsetFrame],yscales,'Color',[.5 .5 .5],'linewidth',1.5);
                xlabel('Frames');
                ylabel('\DeltaF/F');
                title(num2str(cR,'ROI%d'));
                set(gca,'Fontsize',10);

                saveas(hf,sprintf('ROI%d plot save',cR));
                saveas(hf,sprintf('ROI%d plot save',cR),'png');
                close(hf);
                
            end
            ROIRespData.MeanTraceLeft = MeanTraceLeft;
            ROIRespData.SEMTraceLeft = SEMTraceLeft;
            ROIRespData.MeanTraceRight = MeanTraceRight;
            
            cd ..;
        else
            ROIDataSummary.DffData = squeeze(AllROI_dffData);
            hf = figure('position',[100 100 400 320]);
%             imagesc(ROIDataSummary.DffData,[0 1]);
            imagesc(ROIDataSummary.DffData,[0 max(0.2,prctile(ROIDataSummary.DffData(:),99))]);
            colorbar;
            
            line([0.5 0.5]+StimOnsetFrame,[0.5 ROIDataSummary.TotalROI+0.5],'Color','m',...
                    'linewidth',1.5);
            xlabel('Frames');
            ylabel('\DeltaF/F');
            title('All ROIs color plot');
            set(gca,'Fontsize',10);
        end
        
        ROIRespData.FrameRate = ROIDataSummary.FrameRate;
        ROIRespData.OnsetTime = ROIDataSummary.OnsetTime;
        ROIRespData.SelectData = ROIDataSummary.SelectDffData;
        ROIRespData.LRTrNum = ROIDataSummary.LeftRightTrNum;
        
        cd(ROIDataSummary.DataFolder);
        save SelectTrData.mat ROIRespData -v7.3
        
    end
end

function FrameRate_edit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to FrameRate_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
cV = str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of FrameRate_edit_tag as text
%        str2double(get(hObject,'String')) returns contents of FrameRate_edit_tag as a double
if ~isnumeric(cV) || length(cV) > 1
    warning('Error input values.');
else
    if cV <= 0
        warning('Input frame rate should be larger than 0.\n');
    else
        ROIDataSummary.FrameRate = cV;
    end
end     


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



function StimOnset_edit_tag_Callback(hObject, eventdata, handles)
% hObject    handle to StimOnset_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary
cV = str2double(get(hObject,'String'));
% Hints: get(hObject,'String') returns contents of FrameRate_edit_tag as text
%        str2double(get(hObject,'String')) returns contents of FrameRate_edit_tag as a double
if ~isnumeric(cV) || length(cV) > 1
    warning('Error input values.');
else
    if cV <= 0
        warning('Input stim time should be larger than 0.\n');
    else
        ROIDataSummary.OnsetTime = cV;
    end
end     


% --- Executes during object creation, after setting all properties.
function StimOnset_edit_tag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StimOnset_edit_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in Load_ROIdata_tag.
function Load_ROIdata_tag_Callback(hObject, eventdata, handles)
% hObject    handle to Load_ROIdata_tag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global ROIDataSummary

% load ROI info data
[fn,fp,fi] = uigetfile('*.mat','Please select ROIinfo data');
if fi
    matfilepath = fullfile(fp,fn);
    fprintf('Loading ROIinfo data from:%s...\n',matfilepath);
    matDataStrc = load(matfilepath);
    if isfield(matDataStrc,'ROIInfos')
        
        ROIDatass = matDataStrc.ROIInfos;
        ROIDataSummary.ROIinfo = ROIDatass;
        ROIDataSummary.TotalROI = length(ROIDataSummary.ROIinfo);
        ROIDataSummary.CurrentROI = ROIDataSummary.TotalROI;
        set(handles.TotalROI_num_text_tag,'String',num2str(ROIDataSummary.TotalROI));
        set(handles.C_ROI_edit_tag,'String',num2str(ROIDataSummary.CurrentROI));
%         UpdatesROIPlots;
        fprintf('Load complete!\n');
    else
        warning('Error selected mat file.');
    end
end
