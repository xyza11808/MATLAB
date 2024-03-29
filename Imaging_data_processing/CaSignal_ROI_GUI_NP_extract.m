function varargout = CaSignal_ROI_GUI_NP_extract(varargin)
% CaSignal_ROI_GUI_NP_extract M-file for CaSignal_ROI_GUI_NP_extract.fig
%      CaSignal_ROI_GUI_NP_extract, by itself, creates a new CaSignal_ROI_GUI_NP_extract or raises the existing
%      singleton*.
%
%      H = CaSignal_ROI_GUI_NP_extract returns the handle to a new CaSignal_ROI_GUI_NP_extract or the handle to
%      the existing singleton*.
%
%      CaSignal_ROI_GUI_NP_extract('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CaSignal_ROI_GUI_NP_extract.M with the given input arguments.
%
%      CaSignal_ROI_GUI_NP_extract('Property','Value',...) creates a new CaSignal_ROI_GUI_NP_extract or raises the
% CaSignal_ROI_GUI_NP_extract M-file for CaSignal_ROI_GUI_NP_extract.fig
%      CaSignal_ROI_GUI_NP_extract, by itself, creates a new CaSignal_ROI_GUI_NP_extract or raises the existing
%      singleton*.
%
%      H = CaSignal_ROI_GUI_NP_extract returns the handle to a new CaSignal_ROI_GUI_NP_extract or the handle to
%      the existing singleton*.
%
%      CaSignal_ROI_GUI_NP_extract('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CaSignal_ROI_GUI_NP_extract.M with the given input arguments.
%
%      CaSignal_ROI_GUI_NP_extract('Property','Value',...) creates a new CaSignal_ROI_GUI_NP_extract or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before CaSignal_ROI_GUI_NP_extract_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to CaSignal_ROI_GUI_NP_extract_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help CaSignal_ROI_GUI_NP_extract

% Last Modified by GUIDE v2.5 14-Oct-2017 02:34:57

% Begin initialization code - DO NOT EDIT

gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @CaSignal_ROI_GUI_NP_extract_OpeningFcn, ...
                   'gui_OutputFcn',  @CaSignal_ROI_GUI_NP_extract_OutputFcn, ...
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


% --- Executes just before CaSignal_ROI_GUI_NP_extract is made visible.
function CaSignal_ROI_GUI_NP_extract_OpeningFcn(hObject, eventdata, handles, varargin)
clearvars -global
global CaSignal % ROIinfo ICA_ROIs
% Choose default command line output for CaSignal_ROI_GUI_NP_extract
handles.output = hObject;
usrpth = 'D:\'; % usrpth = usrpth(1:end-1);
if exist([usrpth filesep 'nx_CaSingal.info'],'file')
    load([usrpth filesep 'nx_CaSingal.info'], '-mat');
    set(handles.DataPathEdit, 'String',info.DataPath);
    set(handles.AnimalNameEdit, 'String', info.AnimalName);
    set(handles.ExpDate,'String',info.ExpDate);
    set(handles.SessionName, 'String',info.SessionName);
    if isfield(info, 'SoloDataPath')
        set(handles.SoloDataPath, 'String', info.SoloDataPath);
        set(handles.SoloDataFileName, 'String', info.SoloDataFileName);
        set(handles.SoloSessionName, 'String', info.SoloSessionName);
        set(handles.SoloStartTrialNo, 'String', info.SoloStartTrialNo);
        set(handles.SoloEndTrialNo, 'String', info.SoloEndTrialNo);
    end
else
    set(handles.DataPathEdit, 'String', 'M:\2p_data\');
    set(handles.SoloDataPath, 'String', 'M:\2p_data\');
end
% Initialize handles
    % Open and Display section
set(handles.dispModeGreen, 'Value', 1);
set(handles.dispModeRed, 'Value', 0);
set(handles.dispModeImageInfoButton, 'Value', 0);
set(handles.dispModeWithROI, 'Value', 1);
% set(handles.LUTminEdit, 'Value', 0);
% set(handles.LUTmaxEdit, 'Value', 500);
% set(handles.LUTminSlider, 'Value', 0);
% set(handles.LUTmaxSlider, 'Value', 0.5);
set(handles.CurrentImageFilenameText, 'String', 'Current Image Filename');
    % ROI section
set(handles.nROIsText, 'String', '0');
set(handles.CurrentROINoEdit, 'String', '1');
set(handles.ROITypeMenu, 'Value', 9);
    % Analysis mode
set(handles.AnalysisModeDeltaFF, 'Value', 1);
set(handles.AnalysisModeBGsub, 'Value', 0);
set(handles.batchStartTrial, 'String', '1');
set(handles.batchEndTrial, 'String', '1');
% set(handles.ROI_Edit_button, 'Value', 0);
set(handles.CurrentFrameNoEdit,'String',1);
set(handles.setTargetMaxDelta,'Value',0);
set(handles.setTargetCurrentFrame,'Value',0);
set(handles.setTargetMean,'Value',0);
set(handles.NewROITag,'Value',1);
set(handles.OldROITag,'Value',0);
set(handles.MissROITag,'Value',0);
set(handles.ROI_draw_freehand, 'Value',1);
set(handles.ROI_draw_poly, 'Value',0);
set(handles.IsConAcqCheck, 'Value',0);

CaSignal.CaTrials = struct([]);
CaSignal.ROIinfo = struct('ROImask',{}, 'ROIpos',{}, 'ROItype',{},'BGpos',[],...
        'BGmask', [], 'ROI_def_trialNo',[], 'Method','','Ringmask',[],'LabelNPmask',{},'ROIdefinePath',{},'SourcePath',{});
CaSignal.ROIinfoBack = CaSignal.ROIinfo;
% CaSignal.ICA_ROIs = struct('ROImask',{}, 'ROIpos',{}, 'ROItype',{},'Method','ICA');
CaSignal.ImageArray = [];
CaSignal.nFrames = 0;
% handles.userdata.CaTrials = [];
CaSignal.h_info_fig = NaN;
CaSignal.FrameNum = 1;
CaSignal.imSize = [];
CaSignal.h_img = NaN;
CaSignal.Scale = [0 1000];
CaSignal.ROIsummask=[];
% ROIinfo = {};
% ICA_ROIs = struct;
CaSignal.ROIplot = NaN;
CaSignal.avgCorrCoef_trials = [];
CaSignal.CorrMapTrials = [];
CaSignal.CorrMapROINo = [];
CaSignal.AspectRatio_mode = 'Square';
CaSignal.ICA_figs = nan(1,2);
CaSignal.CurrentTrialNo = [];
CaSignal.Last_TrialNo = [];
CaSignal.results_path = [];
CaSignal.results_fname = [];
CaSignal.ROIinfo_fname = [];
CaSignal.IsROIinfoLoad = 0;
CaSignal.IsDoubleSetROI = 0;
CaSignal.CurrentAnaTrial=[0,0,0];
CaSignal.PlotData=cell(1,2);
CaSignal.HigherVersionWarning = 0;
CaSignal.ROINPlabel = [];
CaSignal.EmptyROIsImport = [];
CaSignal.OpenWithImagJ = 1;
CaSignal.IsTrialExcluded = [];
CaSignal.ROIdefineTr = [];
CaSignal.ROIStateIndicate = [];
CaSignal.ROIInfoPath = '';
CaSignal.ContAcqCheck = 0;
CaSignal.IsAutozoom = 0;
CaSignal.IsROIUpdated = []; % value will be 1 if ROI was newly added or modified from loaded file
CaSignal.AllTrMeanIm = {};
CaSignal.AllTrMaxIm = {};
fprintf('Matlab Two-photon imaging data analysis GUI.\n');
fprintf('           Version :  2.04.10             \n');
% Update handles structure
guidata(hObject, handles);

% UIWAIT makes CaSignal_ROI_GUI_NP_extract wait for user response (see UIRESUME)
% uiwait(handles.figure1);
% --- Outputs from this function are returned to the command line.
function varargout = CaSignal_ROI_GUI_NP_extract_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

function CaTrial = init_CaTrial(filename, TrialNo, header)
% Initialize the struct data for the current trial
CaTrial.DataPath = pwd;
CaTrial.FileName = filename;
CaTrial.FileName_prefix = filename(1:end-7);
CaTrial.TrialNo = TrialNo;
if ~isempty(header)
    if isfield(header, 'acq')
        CaTrial.DaqInfo = header;
        CaTrial.nFrames = header.acq.numberOfFrames;
        CaTrial.FrameTime = header.acq.msPerLine*header.acq.linesPerFrame;
    elseif isfield(header, 'SI4')
        CaTrial.DaqInfo = header.SI4;
        CaTrial.nFrames = header.SI4.acqNumFrames;
        CaTrial.FrameTime = header.SI4.scanFramePeriod;
    elseif isfield(header, 'SI')
        CaTrial.DaqInfo = header.SI;
        CaTrial.nFrames = header.SI.hStackManager.framesPerSlice;
        CaTrial.FrameTime = header.SI.hRoiManager.scanFramePeriod;
    else
        CaTrial.nFrames = header.n_frame;
        CaTrial.FrameTime = [];
        CaTrial.nFrames = nan;
    end
    if CaTrial.FrameTime < 1 % some earlier version of ScanImage use sec as unit for msPerLine
        CaTrial.FrameTime = CaTrial.FrameTime*1000;
    end
else
    CaTrial.DaqInfo = [];
    CaTrial.nFrames = [];
    CaTrial.FrameTime = [];
end
CaTrial.nROIs = 0;
CaTrial.BGmask = []; % Logical matrix for background ROI
CaTrial.AnimalName = '';
CaTrial.ExpDate = '';
CaTrial.SessionName = '';
CaTrial.dff = [];
CaTrial.f_raw = [];
CaTrial.RingF = [];
CaTrial.ROINPlabel = [];
CaTrial.SegNPData = [];
% CaTrial.meanImage = [];
CaTrial.RegTargetFrNo = [];
% CaTrial.ROIinfo = struct('ROImask',{}, 'ROIpos',{}, 'ROItype',{},'Method','');
CaTrial.ROIinfo = struct('ROImask',{}, 'ROIpos',{}, 'ROItype',{},'BGpos',[],...
        'BGmask', [], 'ROI_def_trialNo',[], 'Method','','Ringmask',[],'LabelNPmask',[],'ROIdefinePath',{},'SourcePath',{});
CaTrial.ROIinfoBack = CaTrial.ROIinfo ;
CaTrial.SoloDataPath = '';
CaTrial.SoloFileName = '';
CaTrial.SoloSessionName = '';
CaTrial.SoloTrialNo = [];
CaTrial.SoloStartTrialNo = [];
CaTrial.SoloEndTrialNo = [];
CaTrial.behavTrial = [];
CaTrial.ROIstateIndic = [];
CaTrial.ImportROIpath = '';
% CaTrial.ROIType = '';

% --- Executes on button press in open_image_file_button.
function open_image_file_button_Callback(hObject, eventdata, handles, filename)
global CaSignal % ROIinfo ICA_ROIs
% CaSignal_ROI_GUI_NP_extract_OpeningFcn(hObject, eventdata, handles);
datapath = get(handles.DataPathEdit,'String');
if exist(datapath, 'dir')
    cd(datapath);
% else
%     warning([datapath ' not exist!'])
%     if exist('M:\2p_data','dir')
%         cd('M:\2p_data');
%     end
end
if ~exist('filename', 'var')
%     clearvars -global;
%     CaSignal_ROI_GUI_NP_extract_OpeningFcn(hObject, eventdata, handles);
    [filename, pathName] = uigetfile('*.tif', 'Load Image File');
    if isequal(filename, 0) || isequal(pathName,0)
        return
    end
    cd(pathName);
    % incase of more than 1000 trials
    [StartInds, endInds] = regexp(filename, '_\d{3,4}.tif');
    FileName_prefix = filename(1:StartInds);
%     FileName_prefix = filename(1:StartInds-1);
    CaSignal.data_files = dir([FileName_prefix '*.tif']);
    CaSignal.IsTrialExcluded = false(length(CaSignal.data_files),1);  % default all trials will be used for future analysis
    CaSignal.ROIdefineTr = zeros(length(CaSignal.data_files),1);  % define of ROI defined trials
    CaSignal.data_file_names = {};
    for i = 1:length(CaSignal.data_files)
        CaSignal.data_file_names{i} = CaSignal.data_files(i).name;
    end
end
datapath = pwd;
set(handles.DataPathEdit,'String',datapath);
set(handles.batchEndTrial,'string',num2str(length(CaSignal.data_files)));
CaSignal.data_path = datapath;

FileName_prefix = filename(1:end-7);

disp(['Loading image file ' filename ' ...']);
set(handles.msgBox, 'String', ['Loading image file ' filename ' ...']);
% [im, header] = imread_multi(filename, 'g');
% read all frames, disregard number of channels, since green channel has
% been already selected during the process of registration.
[im, header] = load_scim_data(filename); 
% t_elapsed = toc;
set(handles.msgBox, 'String', ['Loaded file ' filename]);
% check if continued-acquisition session
if isfield(header,'SI4')
    if isempty(header.SI4.triggerNextTrigSrc)
        CaSignal.ContAcqCheck = 0;
    else
        CaSignal.ContAcqCheck = 1;
    end
elseif isfield(header,'SI')
    if isempty(header.SI.hScan2D.trigNextEdge)
        CaSignal.ContAcqCheck = 0;
    else
        CaSignal.ContAcqCheck = 1;
    end
end
if CaSignal.ContAcqCheck
    set(handles.IsConAcqCheck,'value',1);
else
    set(handles.IsConAcqCheck,'value',0);
end

TrialNo = find(strcmp(filename, CaSignal.data_file_names));
set(handles.CurrentTrialNo,'String', int2str(TrialNo));
CaSignal.CurrentTrialNo = TrialNo;
if CaSignal.CurrentTrialNo == 1 && isempty(CaSignal.ROIStateIndicate)
    CaSignal.ROIStateIndicate(1,:) = [1,0,0];
end
    
info = imfinfo(filename);
CaSignal.ImInfo = info;

if isfield(info(1), 'ImageDescription')
    CaSignal.ImageDescription = strrep(info(1).ImageDescription,'   ',''); % used by Turboreg
else
    CaSignal.ImageDescription = header;
end
CaSignal.ImageArray = im;
CaSignal.imSize = size(im);

if ~CaSignal.ContAcqCheck
    if isfield(header,'SI4')
        AcqFrameNum = header.SI4.acqNumFrames;
        if AcqFrameNum ~= size(im,3)
            fprintf('Current trial frame number(%d) is different from required trial(%d).\n',size(im,3),AcqFrameNum);
            CaSignal.IsTrialExcluded(TrialNo) = true;
            set(handles.ExcludeCTr,'value',1);
        end
    elseif isfield(header,'SI')
        AcqFrameNum = header.SI.hStackManager.framesPerSlice;
        if AcqFrameNum ~= size(im,3)
            fprintf('Current trial frame number(%d) is different from required trial(%d).\n',size(im,3),AcqFrameNum);
            CaSignal.IsTrialExcluded(TrialNo) = true;
            set(handles.ExcludeCTr,'value',1);
        end
    end
    
end

set(handles.cTrFNumDisp,'String',num2str(size(im,3)));
if ~isempty(CaSignal.CaTrials)
    if length(CaSignal.CaTrials)<TrialNo || isempty(CaSignal.CaTrials(TrialNo).FileName)
        CaSignal.CaTrials(TrialNo) = init_CaTrial(filename, TrialNo, header);
    end
    if ~strcmp(CaSignal.CaTrials(TrialNo).FileName_prefix, FileName_prefix)
        CaSignal.CaTrials_INIT = 1;
    else
        CaSignal.CaTrials_INIT = 0;
    end
else
    CaSignal.CaTrials_INIT = 1;
end


if CaSignal.CaTrials_INIT == 1
   CaSignal.CaTrials = []; % ROIinfo = {};
    if exist(CaSignal.results_fname,'file')
        load(CaSignal.results_fname, '-mat');
        CaSignal.CaTrials = CaTrials;
    else
        A = init_CaTrial(filename, TrialNo, header);
        A(TrialNo) = A;
        if TrialNo ~= 1
            names = fieldnames(A);
            for i = 1:length(names)
                A(1).(names{i})=[];
            end
        end
        CaSignal.CaTrials = A;
    end
    
    if exist(CaSignal.ROIinfo_fname,'file')
        load(CaSignal.ROIinfo_fname, '-mat');
        if iscell(ROIinfo)
            f1 = fieldnames(ROIinfo{TrialNo}); f2 = fieldnames(CaSignal.ROIinfo);
            for i = 1:length(ROIinfo)
                for j = 1:length(f1)
                    CaSignal.ROIinfo(i).(f2{strcmpi(f2,f1{j})}) = ROIinfo{i}.(f1{j});
                end
            end
        else
            CaSignal.ROIinfo = ROIinfo;
        end
    end
else
    if get(handles.import_ROI_from_Trial_checkbox, 'Value') == 1
        import_ROIinfo_from_trial_Callback(handles.import_ROIinfo_from_trial, eventdata, handles);
    end
end

% if exist([CaSignal.results_path filesep FileName_prefix(1:end-7) '[dftShift].mat'],'file')
%     load([CaSignal.results_path filesep FileName_prefix(1:end-7) '[dftShift].mat']);
%     CaSignal.dftreg_shift = shift;
% else
%     CaSignal.dftreg_shift = [];
% end

% Collect info to be displayed in a separate figure

% if get(handles.dispModeImageInfoButton,'Value') == 1
if isfield(header,'acq')
    CaSignal.info_disp = {sprintf('numFramesPerTrial: %d', header.acq.numberOfFrames), ...
    ['Zoom: ' num2str(header.acq.zoomFactor)],...
    ['numOfChannels: ' num2str(header.acq.numberOfChannelsAcquire)],...
    sprintf('ImageDimXY: %d,  %d', header.acq.pixelsPerLine, header.acq.linesPerFrame),...
    sprintf('Frame Rate: %d', header.acq.frameRate), ...
    ['msPerLine: ' num2str(header.acq.msPerLine)],...
    ['fillFraction: ' num2str(header.acq.fillFraction)],...
    ['motor_absX: ' num2str(header.motor.absXPosition)],...
    ['motor_absY: ' num2str(header.motor.absYPosition)],...
    ['motor_absZ: ' num2str(header.motor.absZPosition)],...
    ['num_zSlice: ' num2str(header.acq.numberOfZSlices)],...
    ['zStep: ' num2str(header.acq.zStepSize)] ...
    ['triggerTime: ' header.internal.triggerTimeString]...
    };
elseif isfield(header,'SI4')
    CaSignal.info_disp = header.SI4;
elseif isfield(header,'SI')
    CaSignal.info_disp = header.SI;
end
%     dispModeImageInfoButton_Callback(hObject, eventdata, handles)
% end;
%% Initialize UI values
set(handles.TotTrialNum, 'String', int2str(length(CaSignal.data_file_names)));
set(handles.CurrentImageFilenameText, 'String',  filename);
if CaSignal.CaTrials_INIT == 1
    set(handles.DataPathEdit, 'String', pwd);
    set(handles.AnimalNameEdit, 'String', CaSignal.CaTrials(TrialNo).AnimalName);
    set(handles.ExpDate,'String',CaSignal.CaTrials(TrialNo).ExpDate);
    set(handles.SessionName, 'String',CaSignal.CaTrials(TrialNo).SessionName);
    if isfield(CaSignal.CaTrials(TrialNo), 'SoloDataFileName')
        set(handles.SoloDataPath, 'String', CaSignal.CaTrials(TrialNo).SoloDataPath);
        set(handles.SoloDataFileName, 'String', CaSignal.CaTrials(TrialNo).SoloDataFileName);
        set(handles.SoloSessionName, 'String', CaSignal.CaTrials(TrialNo).SoloSessionName);
        set(handles.SoloStartTrialNo, 'String', num2str(CaSignal.CaTrials(TrialNo).SoloStartTrialNo));
        set(handles.SoloEndTrialNo, 'String', num2str(CaSignal.CaTrials(TrialNo).SoloEndTrialNo));
    end
end

nFrames = size(im, 3);
set(handles.FrameSlider, 'SliderStep', [1/nFrames 1/nFrames]);
set(handles.FrameSlider, 'Value', 1/nFrames);
if length(CaSignal.ROIinfo) >= TrialNo
    set(handles.nROIsText, 'String', int2str(length(CaSignal.ROIinfo(TrialNo).ROIpos)));
end
CaSignal.nFrames = nFrames;
set(handles.batchPrefixEdit, 'String', FileName_prefix);
%    handles = get_exp_info(hObject, eventdata, handles);
% CaSignal.CaTrials(TrialNo).meanImage = mean(im,3);

% update target info for TurboReg
% setTargetCurrentFrame_Callback(handles.setTargetCurrentFrame, eventdata, handles);
% setTargetMaxDelta_Callback(handles.setTargetMaxDelta, eventdata,handles);
% setTargetMean_Callback(handles.setTargetMaxDelta, eventdata, handles);

CaSignal.avgCorrCoef_trials = [];

% The trialNo to load ROIinfo from
TrialNo_load = str2double(get(handles.import_ROIinfo_from_trial,'String'));
if TrialNo_load > 0 && length(CaSignal.ROIinfo)>= TrialNo_load
    CaSignal.ROIinfo(TrialNo) = CaSignal.ROIinfo(TrialNo_load);
    nROIs = length(CaSignal.ROIinfo(TrialNo).ROIpos);
    CaSignal.CaTrials(TrialNo).nROIs = nROIs;
    set(handles.nROIsText, 'String', num2str(nROIs));
end
PosTrImDataPath = fullfile(CaSignal.CaTrials.DataPath,'NotUsedNow','summarized.mat');
if exist(PosTrImDataPath,'file')
    TrImDataStrc = load(PosTrImDataPath);
    CaSignal.AllTrMeanIm = TrImDataStrc.MeanDataAll;
    CaSignal.AllTrMaxIm = TrImDataStrc.MaxDataAll;
end

handles = update_image_axes(handles,im);
update_projection_images(handles);
% set(handles.figure1, 'WindowScrollWheelFcn',{@figScroll, handles.figure1, eventdata, handles});
guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%% Start of Independent functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function handles = get_exp_info(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
filename = CaSignal.data_file_names{TrialNo};

if ~isempty(CaSignal.CaTrials(TrialNo).ExpDate)
    ExpDate = CaSignal.CaTrials(TrialNo).ExpDate;
    set(handles.ExpDate, 'String', ExpDate);
else
    CaSignal.CaTrials(TrialNo).ExpDate = get(handles.ExpDate, 'String');
end;


if ~isempty(CaSignal.CaTrials(TrialNo).AnimalName)
    AnimalName = CaSignal.CaTrials(TrialNo).AnimalName;
    set(handles.AnimalNameEdit, 'String', AnimalName);
else
    CaSignal.CaTrials(TrialNo).AnimalName = get(handles.AnimalNameEdit, 'String');
end


if ~isempty(CaSignal.CaTrials(TrialNo).SessionName)
    SessionName = CaSignal.CaTrials(TrialNo).SessionName;
    set(handles.SessionName, 'String', SessionName);
else
    CaSignal.CaTrials(TrialNo).SessionName = get(handles.SessionName, 'String');
end



function handles = update_image_axes(handles,varargin)
% update image display, called by most of call back functions
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String')); 
LUTmin = str2double(get(handles.LUTminEdit,'String'));
LUTmax = str2double(get(handles.LUTmaxEdit,'String'));
sc = [LUTmin LUTmax];
cmap = 'gray';
fr = str2double(get(handles.CurrentFrameNoEdit,'String'));
if fr > CaSignal.nFrames && CaSignal.nFrames > 0
    fr = CaSignal.nFrames;
end
if ~isempty(varargin)
    CaSignal.ImageArray = varargin{1};
end
CaSignal.Scale = sc;
CaSignal.FrameNum = fr;
im = CaSignal.ImageArray;
im_size = size(im);
switch CaSignal.AspectRatio_mode
    case 'Square'
        s1 = im_size(2)/max(im_size(1:2));
        s2 = im_size(1)/max(im_size(1:2));
        asp_ratio = [s1 s2 1]; 
    case 'Image'
        asp_ratio = [1 1 1];
end
axes(handles.Image_disp_axes);
% hold on;
% if (isfield(CaSignal, 'h_img')&& ishandle(CaSignal.h_img))
%     delete(CaSignal.h_img);
% end;
% CaSignal.h_img = imagesc(im(:,:,fr), sc);
CaSignal.h_img = imshow(im(:,:,fr), sc);
set(handles.Image_disp_axes, 'DataAspectRatio', asp_ratio);  %'XTickLabel','','YTickLabel','');
time_str = sprintf('%.3f  sec',CaSignal.CaTrials(1).FrameTime*fr/1000);
set(handles.frame_time_disp, 'String', time_str);
% colormap(gray);
if get(handles.dispModeWithROI,'Value') == 1 && length(CaSignal.ROIinfo) >= TrialNo && ~isempty(CaSignal.ROIinfo(TrialNo).ROIpos)
    update_ROI_plot(handles);
end

% set(handles.figure1, 'WindowScrollWheelFcn',{@figScroll, hObject, eventdata, handles});

guidata(handles.figure1, handles);


function update_ROI_plot(handles)
global CaSignal % ROIinfo ICA_ROIs

CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
TrialNo = str2double(get(handles.CurrentTrialNo,'String')); 

if get(handles.dispModeWithROI,'Value') == 1
    axes(handles.Image_disp_axes);
    % delete existing ROI plots
    if any(ishandle(CaSignal.ROIplot))
        try
            delete(CaSignal.ROIplot(ishandle(CaSignal.ROIplot)));
        end
    end
    CaSignal.ROIplot = plot_ROIs(handles);
end
if isfield(CaSignal.ROIinfo, 'BGpos') && ~isempty(CaSignal.ROIinfo(TrialNo).BGpos)
    BGpos = CaSignal.ROIinfo(TrialNo).BGpos;
    CaSignal.BGplot = line(BGpos(:,1),BGpos(:,2), 'Color', 'b', 'LineWidth', 2);
end
% set(handles.figure1, 'WindowScrollWheelFcn',{@figScroll, handles.figure1, eventdata, handles});
guidata(handles.figure1,handles);

function h_roi_plots = plot_ROIs(handles)
%%
global CaSignal % ROIinfo ICA_ROIs
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
ROIstateAll = CaSignal.ROIStateIndicate;
h_roi_plots = [];
roi_pos = {};
%     if get(handles.ICA_ROI_anal, 'Value') == 1 && isfield(ICA_ROIs, 'ROIpos');
%         roi_pos = ICA_ROIs.ROIpos;
%     elseif length(ROIinfo) >= TrialNo && ~isempty(ROIinfo{TrialNo})
%
%         roi_pos = ROIinfo{TrialNo}.ROIpos;
%     end

if length(CaSignal.ROIinfo) >= TrialNo
    roi_pos = CaSignal.ROIinfoBack(1).ROIpos;
end
for i = 1:length(roi_pos) % num ROIs
    cROIstate = ROIstateAll(i,:);
    if i == CurrentROINo
        lw = 2;
        fsize = 24;
        Colors = 'r';
    else
        lw = 1;
        fsize = 15;
        Colors = 'c';
    end
    if ~isempty(roi_pos{i})
        %             if length(CaSignal.ROIplot)>=i & ~isempty(CaSignal.ROIplot(i))...
        %                     & ishandle(CaSignal.ROIplot(i))
        %                 delete(CaSignal.ROIplot(i));
        %             end
        if cROIstate(1) % new ROI plots
            h_roi_plots(i) = line(roi_pos{i}(:,1),roi_pos{i}(:,2), 'Color', [0.8 0 0], 'LineWidth', lw);
        elseif cROIstate(2)
            h_roi_plots(i) = line(roi_pos{i}(:,1),roi_pos{i}(:,2), 'Color', 'g', 'LineWidth', lw);
        elseif cROIstate(3)
            h_roi_plots(i) = line(roi_pos{i}(:,1),roi_pos{i}(:,2), 'Color', [1 0 1], 'LineWidth', lw);
        else
            h_roi_plots(i) = line(roi_pos{i}(:,1),roi_pos{i}(:,2), 'Color', [0.8 0 0], 'LineWidth', lw);
        end
        text(median(roi_pos{i}(:,1)), median(roi_pos{i}(:,2)), num2str(i),'Color',Colors,'FontSize',fsize);
        set(h_roi_plots(i), 'LineWidth', lw);
    end
end

function handles = update_projection_images(handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
% CaSignal.CurrentAnaTrial=[0,0,0];
if get(handles.dispMeanMode, 'Value')==1
    if ~isfield(CaSignal, 'h_mean_fig') || ~ishandle(CaSignal.h_mean_fig)
        CaSignal.h_mean_fig = figure('Name','Mean Image','Position',[20   70   1000   900],'WindowKeyPressFcn',...
            {@figure1_WindowKeyPressFcn,handles});
        CaSignal.CurrentAnaTrial(1)=0;
%         CaSignal.CurrentAnaTrial=TrialNo;
    else
        figure(CaSignal.h_mean_fig)
    end
    if CaSignal.CurrentAnaTrial(1)~=TrialNo
        if isempty(CaSignal.AllTrMeanIm)
            im = CaSignal.ImageArray;

            mean_im = mean(im,3);
            CaSignal.PlotData(1)={mean_im};
        else
            CaSignal.PlotData(1)=CaSignal.AllTrMeanIm(TrialNo);
        end
        CaSignal.CurrentAnaTrial(1)=TrialNo;
    end
    sc = CaSignal.Scale;
    imagesc(CaSignal.PlotData{1}, sc);
    colormap(gray);
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    update_projection_image_ROIs(handles);
end
if get(handles.dispMaxDelta,'Value')==1
    if ~isfield(CaSignal, 'h_maxDelta_fig') || ~ishandle(CaSignal.h_maxDelta_fig)
        CaSignal.h_maxDelta_fig = figure('Name','max Delta Image','Position',[130   20   1000   900],'WindowKeyPressFcn',...
            {@figure1_WindowKeyPressFcn,handles});
         CaSignal.CurrentAnaTrial(2)=0;
    else
        figure(CaSignal.h_maxDelta_fig);
    end
    if CaSignal.CurrentAnaTrial(2)~=TrialNo
        if isempty(CaSignal.AllTrMaxIm) || isempty(CaSignal.AllTrMeanIm)
            im = CaSignal.ImageArray;
            sc = CaSignal.Scale; 
            mean_im = uint16(mean(im,3));
            im = im_mov_avg(im,3);
            max_im = max(im,[],3);
            CaSignal.MaxDelta = max_im - mean_im;
        else
            CaSignal.MaxDelta = CaSignal.AllTrMaxIm{TrialNo} - CaSignal.AllTrMeanIm{TrialNo};
        end
        
        CaSignal.CurrentAnaTrial(2)=TrialNo;
    end
    sc = CaSignal.Scale; 
    imagesc(CaSignal.MaxDelta, sc); 
    colormap(gray); 
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    update_projection_image_ROIs(handles);
end
if get(handles.dispMaxMode,'Value')==1
    if ~isfield(CaSignal, 'h_max_fig') || ~ishandle(CaSignal.h_max_fig)
        CaSignal.h_max_fig = figure('Name','Max Projection Image','Position',[200   90   1000   900],'WindowKeyPressFcn',...
            {@figure1_WindowKeyPressFcn,handles});
         CaSignal.CurrentAnaTrial(3)=0;
    else
        figure(CaSignal.h_max_fig)
    end
    if CaSignal.CurrentAnaTrial(3)~=TrialNo
        if isempty(CaSignal.AllTrMaxIm)
            im = CaSignal.ImageArray;

            im = im_mov_avg(im,5);
            max_im = max(im,[],3);
            CaSignal.PlotData(2)={max_im};
        else
            CaSignal.PlotData(2) = CaSignal.AllTrMaxIm(TrialNo);
        end
        CaSignal.CurrentAnaTrial(3)=TrialNo;
    end
    sc = CaSignal.Scale;
    imagesc(CaSignal.PlotData{2}, sc);
    colormap(gray); 
    set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    update_projection_image_ROIs(handles);
end
guidata(handles.figure1,handles);

% update ROI plotting in projecting image figure, called only by updata_projection image
function update_projection_image_ROIs(handles)
% global CaSignal ROIinfo ICA_ROIs
if get(handles.dispModeWithROI,'Value') == 1 
    plot_ROIs(handles);
end

function figScroll(src,evnt, hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
% callback function for mouse scroll
% 
im = CaSignal.ImageArray;
fr = str2double(get(handles.CurrentFrameNoEdit, 'String'));
sc = CaSignal.Scale;
nFrames = CaSignal.nFrames;
% axes(handles.Image_disp_axes);
if evnt.VerticalScrollCount > 0
    if fr < nFrames
        fr = fr + 1;
    end
    
elseif evnt.VerticalScrollCount < 0
    if fr > 1
        fr = fr - 1;
    end  
end

set(handles.FrameSlider,'Value', fr/nFrames);

CaSignal.FrameNum = fr;
set(handles.CurrentFrameNoEdit, 'String', num2str(fr));

CaSignal.h_img = imagesc(im(:,:,fr), sc);
colormap(gray);

handles = update_image_axes(handles);

% Update handles structure
% guidata(hObject, handles);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%% End of Independent functions %%%%%%%%%%%%%%%%%%%%%%%%%


function dispModeWithROI_Callback(hObject, eventdata, handles)
value = get(handles.dispModeWithROI,'Value');
handles = update_image_axes(handles);
handles = update_projection_images(handles);

function DataPathEdit_Callback(hObject, eventdata, handles)
handles.datapath = get(hObject, 'String');
guidata(hObject, handles);

function DataPathEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROI_add_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if ~CaSignal.IsDoubleSetROI
    nROIs = str2num(get(handles.nROIsText, 'String'));
    nROIs = nROIs + 1;
    set(handles.nROIsText, 'String', num2str(nROIs));
    CaSignal.ROIStateIndicate(nROIs,:) = [1,0,0]; %New, Old, Miss
    CurrentROINo = get(handles.CurrentROINoEdit,'String');
    % if strcmp(CurrentROINo, '0')
    %     set(handles.CurrentROINoEdit,'String', '1');
    % end;
    % Use this instead: automatically go to the last ROI added.
    set(handles.CurrentROINoEdit,'String', num2str(nROIs));
    CaSignal.IsDoubleSetROI = 1;
else
    warndlg('Multiple click on ROI add button','Multiple click warning');
end
guidata(hObject, handles);


function ROI_del_Callback(hObject, eventdata, handles,varargin)
global CaSignal % ROIinfo ICA_ROIs
if ~isempty(varargin)
    TrialNo=1;
    CurrentROINo=varargin{1};
else
    TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
    CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
end

if CurrentROINo > 0
    if length(CaSignal.ROIplot) >= CurrentROINo && ishandle(CaSignal.ROIplot(CurrentROINo))
        try
            delete(CaSignal.ROIplot(CurrentROINo))
            CaSignal.ROIplot(CurrentROINo)=[];
        end
    end
    %     if get(handles.ICA_ROI_anal,'Value') ==1 &&  length(ICA_ROIs.ROIpos) >= CurrentROINo
    %         ICA_ROIs.ROIpos(CurrentROINo) = [];
    %         ICA_ROIs.ROIMask(CurrentROINo) = [];
    %         try
    %         ICA_ROIs.ROIType(CurrentROINo) = [];
    %         end
    %     elseif length(ROIinfo{TrialNo}.ROIpos(CurrentROINo)) >= CurrentROINo
    %         ROIinfo{TrialNo}.ROIpos(CurrentROINo) = [];
    %         ROIinfo{TrialNo}.ROIMask(CurrentROINo) = [];
    %         ROIinfo{TrialNo}.ROIType(CurrentROINo) = [];
    %         CaSignal.CaTrials(TrialNo).nROIs = CaSignal.CaTrials(TrialNo).nROIs - 1;
    %         CaSignal.CaTrials(TrialNo).ROIinfo = ROIinfo{TrialNo};
    %%     end
    CaSignal.ROIinfo(TrialNo).ROIpos(CurrentROINo) = [];
    CaSignal.ROIinfo(TrialNo).ROImask(CurrentROINo) = [];
    CaSignal.ROIinfo(TrialNo).ROItype(CurrentROINo) = [];
    CaSignal.ROIinfo(TrialNo).Ringmask(CurrentROINo) = [];
    CaSignal.ROIinfo(TrialNo).ROI_def_trialNo(CurrentROINo) = [];
    
    
    CaSignal.ROIinfoBack(1).ROIpos(CurrentROINo) = [];
    CaSignal.ROIinfoBack(1).ROImask(CurrentROINo) = [];
    CaSignal.ROIinfoBack(1).ROItype(CurrentROINo) = [];
    CaSignal.ROIinfoBack(1).Ringmask(CurrentROINo) = [];
    CaSignal.ROIinfoBack(1).ROI_def_trialNo(CurrentROINo) = [];
    try
        CaSignal.ROIinfoBack(1).ROIdefinePath(CurrentROINo) = [];
        CaSignal.ROIinfo(TrialNo).ROIdefinePath(CurrentROINo) = [];
    catch
        fprintf('ROIdefPath unknow for delete.\n');
    end
    CaSignal.IsROIUpdated(CurrentROINo) = [];
    CaSignal.ROIStateIndicate(CurrentROINo,:) = [];
    %%
    CaSignal.CaTrials(TrialNo).nROIs = CaSignal.CaTrials(TrialNo).nROIs - 1;
    CaSignal.CaTrials(TrialNo).ROIinfo = CaSignal.ROIinfo(TrialNo);
    set(handles.nROIsText, 'String', num2str(CaSignal.CaTrials(TrialNo).nROIs));
    set(handles.CurrentROINoEdit,'String', int2str(CurrentROINo - 1));
    % TotROI = get(handles.nROIsText, 'String');
    % if strcmp(TotROI, '0');
    %     set(handles.CurrentROINoEdit,'String', '0');
    % end
    update_ROI_plot(handles);
    update_ROI_numbers(handles);
end
guidata(hObject, handles);



function update_ROI_numbers(handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'string'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
% if get(handles.ICA_ROI_anal,'value') ==1
%     nd = cellfun(@(x) isempty(x), ICA_ROIs.ROIpos);
%     try
%         ICA_ROIs.ROIpos(nd) = [];
%         ICA_ROIs.ROIMask(nd) = [];
%         ICA_ROIs.ROIType(nd) = [];
%     end
%     nROIs = length(ICA_ROIs.ROIpos);
% else
%     for i = 1:length(ROIinfo{TrialNo}.ROIpos)
%         if isempty(ROIinfo{TrialNo}.ROIpos{i})
%             ROIinfo{TrialNo}.ROIpos(i) = [];
%             ROIinfo{TrialNo}.ROIMask(i) = [];
%             ROIinfo{TrialNo}.ROIType(i) = [];
%         end
%     end
%     nROIs = length(ROIinfo{TrialNo}.ROIpos);
% end
% for i = 1:length(CaSignal.ROIinfo(TrialNo).ROIpos)
%     if isempty(CaSignal.ROIinfo(TrialNo).ROIpos{i})
%         CaSignal.ROIinfo(TrialNo).ROIpos(i) = [];
%         CaSignal.ROIinfo(TrialNo).ROImask(i) = [];
%         CaSignal.ROIinfo(TrialNo).ROItype(i) = [];
%     end
% end
    nROIs = length(CaSignal.ROIinfo(TrialNo).ROIpos);
set(handles.nROIsText, 'String', num2str(nROIs));
if CurrentROINo > nROIs
    CurrentROINo = nROIs;
elseif CurrentROINo < 1
    CurrentROINo = 1;
end
set(handles.CurrentROINoEdit, 'String', num2str(CurrentROINo));



function ROI_pre_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
% update_ROI_numbers(handles);
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
CurrentROINo = CurrentROINo - 1;
if CurrentROINo <= 0
    CurrentROINo = 1;
end;
set(handles.CurrentROINoEdit,'String',int2str(CurrentROINo));

str_menu = get(handles.ROITypeMenu,'String');
ROIType_str = CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo};
if ~isempty(ROIType_str)
    ROIType_num = find(strcmp(ROIType_str, str_menu));
    set(handles.ROITypeMenu,'Value', ROIType_num);
else
    ROIType_str = str_menu{get(handles.ROITypeMenu,'Value')};
    CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo} = ROIType_str;
end
TotalROIs = str2num(get(handles.nROIsText, 'String'));
if CurrentROINo < TotalROIs
    cROIstateIndex = CaSignal.ROIStateIndicate(CurrentROINo,:);
    set(handles.NewROITag,'Value',cROIstateIndex(1));
    set(handles.OldROITag,'Value',cROIstateIndex(2));
    set(handles.MissROITag,'Value',cROIstateIndex(3));
else
    set(handles.NewROITag,'Value',1);
    set(handles.OldROITag,'Value',0);
    set(handles.MissROITag,'Value',0);
end
% axes(handles.Image_disp_axes);
update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles);



function ROI_next_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
% update_ROI_numbers(handles);
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
CurrentROINo = CurrentROINo + 1;
if CurrentROINo > str2double(get(handles.nROIsText,'String')) 
    CurrentROINo = str2double(get(handles.nROIsText,'String')) ;
end;
set(handles.CurrentROINoEdit,'String',int2str(CurrentROINo));

str_menu = get(handles.ROITypeMenu,'String');
if length(CaSignal.ROIinfo(TrialNo).ROItype)>= CurrentROINo
    % ~isempty(ROIinfo{TrialNo}.ROIType{CurrentROINo})
    
    ROIType_str = CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo};
    if ~isempty(ROIType_str)
        ROIType_num = find(strcmp(ROIType_str, str_menu));
        set(handles.ROITypeMenu,'Value', ROIType_num);
    else
        ROIType_str = str_menu{get(handles.ROITypeMenu,'Value')};
        CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo} = ROIType_str;
    end
else
    CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo} = str_menu{get(handles.ROITypeMenu,'Value')};
end
TotalROIs = str2num(get(handles.nROIsText, 'String'));
if CurrentROINo < TotalROIs
    cROIstateIndex = CaSignal.ROIStateIndicate(CurrentROINo,:);
    set(handles.NewROITag,'Value',cROIstateIndex(1));
    set(handles.OldROITag,'Value',cROIstateIndex(2));
    set(handles.MissROITag,'Value',cROIstateIndex(3));
else
    set(handles.NewROITag,'Value',1);
    set(handles.OldROITag,'Value',0);
    set(handles.MissROITag,'Value',0);
end
update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles);


function CurrentROINoEdit_Callback(hObject, eventdata, handles)
global CaSignal
CurrentTrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2num(get(handles.CurrentROINoEdit,'String'));
TotalROIs = str2num(get(handles.nROIsText, 'String'));

if CurrentROINo < TotalROIs
    cROIstateIndex = CaSignal.ROIStateIndicate(CurrentROINo,:);
    set(handles.NewROITag,'Value',cROIstateIndex(1));
    set(handles.OldROITag,'Value',cROIstateIndex(2));
    set(handles.MissROITag,'Value',cROIstateIndex(3));
elseif CurrentROINo == TotalROIs
    set(handles.NewROITag,'Value',1);
    set(handles.OldROITag,'Value',0);
    set(handles.MissROITag,'Value',0);
elseif CurrentROINo > TotalROIs + 1
    warning('The input ROINum is much larger than total number, maybe an error input number.');
    return;
end

if get(handles.Go_to_ROI_def_trial_check_button, 'Value') == 1
    % Load the trial where the current ROI was defined.
    ROI_def_trialNo = CaSignal.ROIinfo(CurrentTrialNo).ROI_def_trialNo(CurrentROINo);
    filename = CaSignal.data_file_names{ROI_def_trialNo};
    if exist(filename,'file')
        open_image_file_button_Callback(hObject, eventdata, handles, filename);
    end
end

update_ROI_plot(handles);
guidata(hObject, handles);


function CurrentROINoEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function Go_to_ROI_def_trial_check_button_Callback(hObject, eventdata, handles)
CurrentROINoEdit_Callback(hObject, eventdata, handles);

function Set_ROI_button_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
str_menu = get(handles.ROITypeMenu,'String');
ROIType = str_menu{get(handles.ROITypeMenu,'Value')};
ROIsum=CaSignal.ROIsummask;
% ROI_updated_flag = 0; % to determine if update the trial No of ROI updating.
%% Draw an ROI after mouse press
if verLessThan('matlab','8.4')   %version('-release') can be used to check current matlab version
    waitforbuttonpress;
else
    if ~CaSignal.HigherVersionWarning
        warndlg('For matlab version higher than 2014a, only one figure can be used to draw ROIs','Higher version warning');
        CaSignal.HigherVersionWarning=1;
    end
        if isfield(CaSignal,'h_mean_fig') && isfield(CaSignal,'h_maxDelta_fig')
            Fchoice = questdlg('Select one image to plot ROI','Figure selection', 'Mean figure', 'Mex-delta', 'Mex-delta');
            switch Fchoice
                case 'Mean figure'
                    figure(CaSignal.h_mean_fig);
                case 'Mex-delta'
                    figure(CaSignal.h_maxDelta_fig);
                otherwise
                    fprintf('No choice selection. using max_delta figure.\n');
                    figure(CaSignal.h_maxDelta_fig);
            end
        elseif isfield(CaSignal,'h_mean_fig')
            figure(CaSignal.h_mean_fig);
        elseif isfield(CaSignal,'h_maxDelta_fig')
            figure(CaSignal.h_maxDelta_fig);
        elseif isfield(CaSignal,'h_max_fig')
            figure(CaSignal.h_max_fig);
        end
        
end
% uiwait;
% k=waitforbuttonpress;
% if k==1
%     uiresume(gcf);
% end
% define the way of drawing, freehand or ploygon
if get(handles.ROI_draw_freehand, 'Value') == 1
    DrawROI = @imfreehand;
elseif get(handles.ROI_draw_poly, 'Value') == 1
    DrawROI = @impoly;
else
    warndlg('ROI type undefined!','warning');
end
h_roi = feval(DrawROI);
finish_drawing = 0;
while finish_drawing == 0
    choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes', 'Re-draw', 'Cancel','Yes');
    switch choice
        case'Yes'
            pos = h_roi.getPosition;
            line(pos(:,1), pos(:,2),'color','g')
            BW = createMask(h_roi);
            delete(h_roi);
            finish_drawing = 1;
%             ROI_updated_flag = 1;
        case'Re-draw'
            delete(h_roi);
            h_roi = feval(DrawROI); 
            finish_drawing = 0;
        case'Cancel'
            delete(h_roi); 
            finish_drawing = 1;
%             ROI_updated_flag = 0;
            return
    end
end
CaSignal.ROIStateIndicate(CurrentROINo,:) = [1,0,0];
set(handles.NewROITag,'Value',1);
set(handles.OldROITag,'Value',0);
set(handles.MissROITag,'Value',0);
CaSignal.ROIdefineTr = CurrentROINo;
CaSignal.ROIinfo(TrialNo).ROIpos{CurrentROINo} = pos;
CaSignal.ROIinfo(TrialNo).ROImask{CurrentROINo} = BW;
FrameSize=CaSignal.imSize(1:2);
CenterXY=mean(pos);
if CurrentROINo == 1
    ROIsum = false(FrameSize);
end

[RingMask,ROIsum]= RingShapeMask(FrameSize,CenterXY,pos,[],ROIsum,BW);  %Neuropil data extraction

CaSignal.ROIsummask=ROIsum;
CaSignal.ROIinfo(TrialNo).Ringmask{CurrentROINo} = RingMask;
CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo} = ROIType;
CaSignal.ROIinfo(TrialNo).ROI_def_trialNo(CurrentROINo) = TrialNo; 
CaSignal.CaTrials(TrialNo).nROIs = length(CaSignal.ROIinfo(TrialNo).ROIpos);

%backUp ROI info
CaSignal.ROIinfoBack(1).ROIpos{CurrentROINo} = pos;
CaSignal.ROIinfoBack(1).ROImask{CurrentROINo} = BW;
% FrameSize=CaSignal.imSize;
% CenterXY=mean(pos);
% if CurrentROINo == 1
%     ROIsum = false(FrameSize);
% else
%    [RingMask,ROIsum]= RingShapeMask(FrameSize,CenterXY,pos,[],ROIsum,BW);
% end
CaSignal.ROIinfoBack(1).Ringmask{CurrentROINo} = RingMask;
CaSignal.ROIinfoBack(1).ROItype{CurrentROINo} = ROIType;
CaSignal.ROIinfoBack(1).ROI_def_trialNo(CurrentROINo) = TrialNo;
% CaSignal.ROIinfoBack(1).nROIs = length(CaSignal.ROIinfoBack(1).ROIpos);
CaSignal.IsDoubleSetROI = 0;
CaSignal.IsMultiSet = 0;
CaSignal.IsROIUpdated(CurrentROINo) = 1;

set(handles.import_ROIinfo_from_trial, 'String', num2str(TrialNo));
% 
% if get(handles.ICA_ROI_anal,'Value') == 1
%     CaSignal.ROIinfo(TrialNo).Method = 'ICA';
%     CaSignal.rois_by_IC{CaSignal.currentIC} = [CaSignal.rois_by_IC{CaSignal.currentIC}  CurrentROINo];
%     for jj = 1:length(CaSignal.ICA_figs)
%         if ishandle(CaSignal.ICA_figs(jj))
%             figure(CaSignal.ICA_figs(jj)),
%             plot_ROIs(handles);
%         end
%     end
% else
%     
% end
set(handles.nROIsText,'String', num2str(length(CaSignal.ROIinfo(TrialNo).ROIpos)));
axes(handles.Image_disp_axes);
if length(CaSignal.ROIplot) >= CurrentROINo
    if ishandle(CaSignal.ROIplot(CurrentROINo)) && CaSignal.ROIplot(CurrentROINo) > 0
        delete(CaSignal.ROIplot(CurrentROINo));
    else
        CaSignal.ROIplot(CurrentROINo) = [];
    end
end
guidata(hObject, handles);
%CaSignal.roi_line(CurrentROINo) = line(pos(:,1),pos(:,2), 'Color', 'r', 'LineWidth', 2);
update_ROI_plot(handles);
update_projection_images(handles);
ROITypeMenu_Callback(hObject, eventdata, handles);
guidata(hObject, handles);



% function ROI_Edit_button_Callback(hObject, eventdata, handles)
% global CaSignal % ROIinfo ICA_ROIs
% TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
% CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
% pos = CaSignal.ROIinfo(TrialNo).ROIpos{CurrentROINo};
% h_axes = handles.Image_disp_axes;
% 
% if get(hObject, 'Value')==1
%     CaSignal.current_poly_obj = impoly(h_axes, pos);
% elseif get(hObject, 'Value')== 0 
%     if isa(CaSignal.current_poly_obj, 'imroi')
%         pos = getPosition(CaSignal.current_poly_obj);
%         BW = createMask(CaSignal.current_poly_obj);
%         CaSignal.ROIinfo(TrialNo).ROIpos{CurrentROINo} = pos;
%         CaSignal.ROIinfo(TrialNo).ROImask{CurrentROINo} = BW;
%         axes(h_axes);
%         delete(CaSignal.current_poly_obj); % delete polygon object
%         if ishandle(CaSignal.ROIplot(CurrentROINo))
%             delete(CaSignal.ROIplot(CurrentROINo));
%         end
%         CaSignal.ROIplot(CurrentROINo) = [];
%         % CaSignal.roi_line(CurrentROINo) = line(pos(:,1),pos(:,2), 'Color', 'r', 'LineWidth', 2);
%          update_ROI_plot(handles);
%          handles = update_projection_images(handles);
%     end;
% end;
% guidata(hObject, handles);

% --- Executes on button press in import_ROIinfo_from_file.
function import_ROIinfo_from_file_Callback(hObject, eventdata, handles)
global CaSignal
choice = questdlg('Import ROIinfo from different file/session?', 'Import ROIs', 'Yes','No','Yes');
switch choice
    case 'Yes'
        [StartInds,endInds] = regexp(CaSignal.data_path,'test\d{2,3}rf');
        PosInfoPath = pwd;
        if ~isempty(StartInds)
            PosRelatePath = [CaSignal.data_path(1:endInds-2),CaSignal.data_path(endInds+1:end)];
            if isdir(PosRelatePath) %#ok<ISDIR>
                PosInfoPath = PosRelatePath;
            end
        end
        [fn, pth] = uigetfile(PosInfoPath,'*.mat');
        r = load([pth filesep fn]);
        CaSignal.ROIInfoPath = fullfile(pth,fn);
        if isfield(r,'ROIinfo')
            ROIinfo = r.ROIinfo(1);
        elseif isfield(r,'ROIinfoBU')
            ROIinfo = r.ROIinfoBU;
        end
        CaSignal.IsROIinfoLoad = 1;
        LoadPath = pth;
    case 'No'
        return
    otherwise
        fprintf('Quit ROIinfo loading processing.\n');
end
import_ROIinfo(ROIinfo, handles, LoadPath);


function import_ROIinfo_from_trial_Callback(hObject, eventdata, handles)
% get ROIinfo from the specified trial, and call import_ROIinfo function
global CaSignal
% The trialNo to load ROIinfo from
TrialNo_load = str2double(get(handles.import_ROIinfo_from_trial,'String'));
if ~isempty(CaSignal.ROIinfo)
    ROIinfo = CaSignal.ROIinfo(TrialNo_load);
    import_ROIinfo(ROIinfo, handles,hObject,eventdata);% getROIinfoButton_Callback(hObject, eventdata, handles)
else
    warning('No ROIs specified!');
end

function import_ROIinfo(ROIinfo, handles, varargin)
% update the ROIs of the current trial with the input "ROIinfo".
global CaSignal % ROIinfo ICA_ROIs
if isempty(varargin)
    InputPath = '';
else
    InputPath = varargin{1};
end
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));

FileName_prefix = CaSignal.CaTrials(TrialNo).FileName_prefix;
emptyROIs=[];
if isfield(ROIinfo,'Ringmask') && isfield(ROIinfo,'LabelNPmask')
    if ~isfield(ROIinfo,'ROIdefinePath')
        ROInumbers = length(ROIinfo.Ringmask);
        ROIinfo.SourcePath = {InputPath};
        ROIinfo.ROIdefinePath = repmat({'Source=1#'},ROInumbers,1);
    end
    CaSignal.ROIinfo(TrialNo) = ROIinfo;
    CaSignal.ROIinfoBack(1) = ROIinfo;
    if sum(cellfun(@isempty,CaSignal.ROIinfoBack.Ringmask))
        nROIs=length(ROIinfo.ROImask);
         FrameSize=CaSignal.imSize(1:2);
         
        for nnROI = 1 : nROIs
            BW=ROIinfo.ROImask{nnROI};
            pos=ROIinfo.ROIpos{nnROI};
            CenterXY=mean(pos);
            if nnROI == 1
                ROIsum = false(FrameSize);
            end
            [RingMask,ROIsum]= RingShapeMask(FrameSize,CenterXY,pos,[],ROIsum,BW);
            ROIinfo.Ringmask{nnROI}=RingMask;
        end
    end
    %
    CaSignal.ROIinfo(TrialNo) = ROIinfo;
    CaSignal.ROIinfoBack(1) = ROIinfo;
else
    nROIs=length(ROIinfo.ROImask);
    ROIinfo.LabelNPmask={};
    ROIinfo.Ringmask=cell(1,nROIs);
%     ROIinfo.LabelNPmask=cell(1,nROIs);
    FrameSize=CaSignal.imSize(1:2);
    for n=1:nROIs
        BW=ROIinfo.ROImask{n};
        pos=ROIinfo.ROIpos{n};
        if isempty(pos)
            fprintf('ROI%d is empty! Continue to next ROI.\n',n);
            emptyROIs=[emptyROIs n];
            continue;
        end
        CenterXY=mean(pos);
        if n==1
            ROIsum = false(FrameSize);
        end
        [RingMask,ROIsum]= RingShapeMask(FrameSize,CenterXY,pos,[],ROIsum,BW);
        ROIinfo.Ringmask{n}=RingMask;
%         ROIinfo.LabelNPmask{n}=
    end
    CaSignal.ROIsummask=ROIsum;
    if ~isfield(ROIinfo,'ROIdefinePath')
        ROInumbers = length(ROIinfo.Ringmask);
        ROIinfo.SourcePath = {InputPath};
        ROIinfo.ROIdefinePath = repmat({'Source=1#'},ROInumbers,1);
    end
    CaSignal.ROIinfo = ROIinfo;
    CaSignal.ROIinfoBack = ROIinfo;
end
CaSignal.EmptyROIsImport = emptyROIs;
% if ~isempty(emptyROIs)
%     for n=1:length(emptyROIs)
%         ROI_del_Callback(hObject, eventdata, handles, emptyROIs(n));
%     end
% end
    
% if exist('ROIinfoBU','var')
%     CaSignal.ROIinfo(TrialNo) = ROIinfoBU;
%     CaSignal.ROIinfoBack(1) = ROIinfoBU;
% end

% elseif exist(['ROIinfo_' FileName_prefix '.mat'],'file')
%     load([FileName_prefix 'ROIinfo.mat'], '-mat');
%     if length(CaSignal.ROIinfo)>= TrialNo_load
%         CaSignal.ROIinfo(TrialNo) = CaSignal.ROIinfo{TrialNo_load};
%     endcas
nROIs = length(CaSignal.ROIinfo(TrialNo).ROIpos);
CaSignal.ROIStateIndicate = [zeros(nROIs,1),ones(nROIs,1),zeros(nROIs,1)];
CaSignal.IsROIUpdated = zeros(nROIs,1);

CurrentROINo = str2double(get(handles.CurrentROINoEdit,'String'));
set(handles.NewROITag,'Value',CaSignal.ROIStateIndicate(CurrentROINo,1));
set(handles.OldROITag,'Value',CaSignal.ROIStateIndicate(CurrentROINo,2));
set(handles.MissROITag,'Value',CaSignal.ROIStateIndicate(CurrentROINo,3));
CaSignal.CaTrials(TrialNo).nROIs = nROIs;
set(handles.nROIsText, 'String', num2str(nROIs));
update_ROI_plot(handles);
handles = update_projection_images(handles);


function import_ROIinfo_from_trial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ROITypeMenu_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
Menu = get(handles.ROITypeMenu,'String');
% CaSignal.CaTrials(TrialNo).ROIType{CurrentROINo} = Menu{get(handles.ROITypeMenu,'Value')};
CaSignal.ROIinfo(TrialNo).ROItype{CurrentROINo} = Menu{get(handles.ROITypeMenu,'Value')};
CaSignal.ROIinfoBack(1).ROItype{CurrentROINo} = Menu{get(handles.ROITypeMenu,'Value')};
guidata(hObject, handles);

function CalculatePlotButton_Callback(hObject, eventdata, handles, im, plot_flag)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
% ROIMask = CaSignal.CaTrials(TrialNo).ROIMask;
% if get(handles.ICA_ROI_anal, 'Value') == 1
%     nROI_effective = length(ICA_ROIs.ROIMask);
%     ROImask = ICA_ROIs.ROIMask;
% else
%     nROI_effective = length(CaSignal.ROIinfo(TrialNo).ROIpos);
%     ROImask = CaSignal.ROIinfo(TrialNo).ROIMask;
% end

if nargin < 4
    im = CaSignal.ImageArray;
end    
if nargin < 5 %~exist('plot_flag','var')
    plot_flag = 1;
end

opt_subBG = get(handles.AnalysisModeBGsub,'Value');

[F, fRing,dff] = extract_roi_fluo(im, CaSignal.ROIinfo(TrialNo), opt_subBG);

CaSignal.CaTrials(TrialNo).dff = dff;
CaSignal.CaTrials(TrialNo).f_raw = F;
CaSignal.CaTrials(TrialNo).RingF = fRing;
ts = (1:CaSignal.CaTrials(TrialNo).nFrames).*CaSignal.CaTrials(TrialNo).FrameTime;
if plot_flag == 1
    if get(handles.check_plotAllROIs, 'Value') == 1
        roiNos = [];
    else
        roiNos = str2num(get(handles.roiNo_to_plot, 'String'));
    end
    CaSignal.h_CaTrace_fig = plot_CaTraces_ROIs(dff, ts, roiNos);
end
guidata(handles.figure1, handles);

function [F,RingF,dff] = extract_roi_fluo(im, ROIinfo, opt_subBG)

nROI_effective = length(ROIinfo.ROIpos);
if nROI_effective == 0
    disp('No effective ROI position exists');
end
ROImask = ROIinfo.ROImask;
ROIringMask = ROIinfo.Ringmask;
NumFrames = size(im,3);
F = zeros(nROI_effective, NumFrames);
RingF = zeros(nROI_effective, NumFrames);
dff = zeros(size(F));
%%
% t1 = tic;
for i = 1: nROI_effective
%     % old method
%     mask = repmat(ROImask{i}, [1 1 NumFrames]); % reproduce masks for every frame
%     % Using indexing and reshape function to increase speed
%     nPix = sum(sum(ROImask{i}));
%     % Using reshape to partition into different trials.
%     roi_img = reshape(im(mask), nPix, []);
%     % Raw intensity averaged from pixels of the ROI in each trial.
%     if nPix == 0
%         F(i,:) = 0;
%     else
%         F(i,:) = mean(roi_img, 1);
%     end
%     %neurual puil extraction
%     Ringmask = repmat(ROIringMask{i}, [1 1 size(im,3)]); % reproduce masks for every frame
%     % Using indexing and reshape function to increase speed
%     nPix_ring = sum(sum(ROIringMask{i}));
%     % Using reshape to partition into different trials.
%     roi_img_ring = reshape(im(Ringmask), nPix_ring, []);
%     % Raw intensity averaged from pixels of the ROI in each trial.
%     if nPix_ring == 0
%         RingF(i,:) = 0;
%     else
%         RingF(i,:) = mean(roi_img_ring, 1);
%     end
%     for i = 1: nROI_effective
        cRMaskInds = find(ROImask{i});
        cRRingMask = find(ROIringMask{i});
        if ~isempty(cRMaskInds)
            for cTrFrame = 1 : NumFrames
                cimFrame = squeeze(im(:,:,cTrFrame));
                F(i , cTrFrame) = mean(cimFrame(cRMaskInds));
                RingF(i, cTrFrame) = mean(cimFrame(cRRingMask)); %#ok<FNDSB>
            end
        end
        BG = 0;
        [N,X] = hist(F(i,:));
        F_mode = X((N==max(N)));
        baseline = mean(F_mode);
        dff(i,:) = (F(i,:)- baseline)./baseline*100;
%     end
    
    %%%%%%%%%%%%% Obsolete slower method to compute ROI pixel intensity %%%%%%%
    %     roi_img = mask .* double(im);                                       %
    %                                                                         %
    %     roi_img(roi_img<=0) = NaN;                                          %
    %    % F(:,i) = nanmean(nanmean(roi_img));                                %
    %     F(i,:) = nanmean(nanmean(roi_img));                                 %
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     if ~isempty(ROIinfo.BGmask)
%         BGmask = repmat(ROIinfo.BGmask,[1 1 size(im,3)]) ;
%         BG_img = BGmask.*double(im);
%         BG_img(BG_img==0) = NaN;
%         BG = reshape(nanmean(nanmean(BG_img)),1,[]); % 1-by-nFrames array
%     else
%         BG = 0;
%     end
    
%     if opt_subBG == 1
%         F(i,:) = F(i,:) - BG;
%     end
%         [N,X] = hist(F(i,:));
%         F_mode = X((N==max(N)));
%         baseline = mean(F_mode);
%         dff(i,:) = (F(i,:)- baseline)./baseline*100;
end
% t2 = toc(t1);
% disp(t2);

%%
function LabelSegNPData = SegNPdataExtraction(im,LabelNPmask,varargin)
%this function is used to extract segmental NP datat from Raw image and
%passed to matlab GUI

imsize=size(im);
LabelNum=length(LabelNPmask);
LabelNPData=zeros(LabelNum,imsize(3));

for Label = 1:LabelNum
%     LabelMask = LabelNPmask{Label};
% %     PixelNum = sum(sum(LabelMask));
%     D3IMMask = logical(repmat(LabelMask,1,1,imsize(3)));
%     ExtractData = double(im(D3IMMask));
%     D3IMData = reshape(ExtractData,[],imsize(3));
%     MeanNPData = mean(D3IMData);
%     LabelNPData(Label,:) = MeanNPData;
    
    LabelMaskInds = find(LabelNPmask{Label});
    for cImInds = 1 : imsize(3)
        cImData = squeeze(im(:,:,cImInds));
        LabelNPData(Label,cImInds) = mean(cImData(LabelMaskInds)); %#ok<*FNDSB>
    end
    
end

LabelSegNPData = LabelNPData;


%%
function doBatchButton_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
batchPrefix = get(handles.batchPrefixEdit, 'String');
Start_trial = str2double(get(handles.batchStartTrial, 'String'));
End_trial = str2double(get(handles.batchEndTrial,'String'));
% CaSignal.CaTrials = [];
% h = waitbar(0, 'Start Batch Analysis ...');
numberROIs=numel(CaSignal.ROIinfoBack(1).ROImask);
emptyROIs=[];
ALLROImaskR=CaSignal.ROIinfoBack(1).Ringmask;
ALLROImask = CaSignal.ROIinfoBack(1).ROImask;
for n=1:numberROIs
    
    if isempty(ALLROImaskR{n}) && isempty(ALLROImask{n})
        emptyROIs=[emptyROIs n];
    end
    if sum(sum(ALLROImask{n})) < 10
        warning('ROI%d seems have very few pixels, Please re-draw it.\n',n);
        return;
    end
end
if ~isempty(CaSignal.EmptyROIsImport)
    emptyROIs = unique([emptyROIs CaSignal.EmptyROIsImport]);
end
emptyROIs = sort(emptyROIs,'descend');
if ~isempty(emptyROIs)
    for n=1:length(emptyROIs)
        ROI_del_Callback(hObject, eventdata, handles, emptyROIs(n));
    end
end
%         ROI_del_Callback(hObject, eventdata, handles, n);
%         CaSignal.CaTrials(1).nROIs=CaSignal.CaTrials(1).nROIs-1;

filenames = CaSignal.data_file_names; 
nTROIs = numberROIs;
nTrials = length(CaSignal.CaTrials);

CaTrials_local = CaSignal.CaTrials;
ROIinfo_local = CaSignal.ROIinfoBack;
ROIpos = CaSignal.ROIinfoBack(1).ROIpos;
if isempty(ROIinfo_local.SourcePath)
    ROIinfo_local.SourcePath = {CaSignal.data_path};
else
    if ~iscell(ROIinfo_local.SourcePath)
        ROIinfo_local.SourcePath = {ROIinfo_local.SourcePath};
    else
        if ~ischar(ROIinfo_local.SourcePath{1})
            ROIinfo_local.SourcePath = ROIinfo_local.SourcePath{:};
        end
    end
end
% ################################################################
% update ROI defined information, upated 20171206
if sum(CaSignal.IsROIUpdated)
    cPath = CaSignal.data_path;
    AllROIState = zeros(nTROIs,1);
    if length(CaSignal.IsROIUpdated) > nTROIs
        error('matrix dimension disagree');
    end
    AllROIState(1:length(CaSignal.IsROIUpdated)) = CaSignal.IsROIUpdated;
    ModiROIs = find(AllROIState);
    nModiROIs = length(ModiROIs);
    UpperPath = UpperDataPathGene(ROIinfo_local.SourcePath);
    IscpathExist = strcmpi(UpperPath,cPath);
    if sum(IscpathExist)
        cPathIndex = find(IscpathExist);
    else
        cPathIndex = length(IscpathExist)+1;
        ROIinfo_local.SourcePath{cPathIndex} = cPath;
    end
    for cModiROI = 1 : nModiROIs
        cROI = ModiROIs(cModiROI);
        if cROI > length(ROIinfo_local.ROIdefinePath)  % newly added ROIs
            ROIinfo_local.ROIdefinePath{cROI} = sprintf('Source=%d#',cPathIndex);
        else
            ExistStr = ROIinfo_local.ROIdefinePath{cROI};
            if isempty(strfind(ExistStr,sprintf('Update=%d#',cPathIndex))) % if it already at the end, skip update defination string
                if ~strcmpi(ExistStr,sprintf('Source=%d#',cPathIndex)) % loaded same session ROI after calculation, but re-do ROI drawing
                    NewStr = sprintf('%sUpdate=%d#',strrep(ExistStr,'Update','modi'),cPathIndex);
                    ROIinfo_local.ROIdefinePath{cROI} = NewStr;
                end
            end
        end
    end
end
% end here
% ###############################################################

%#####################################
%recheck whether Ring back is overlapped with any ROI
ALLROImaskR=CaSignal.ROIinfoBack(1).Ringmask;
AdjustROImaskR=cell(length(ALLROImaskR),1);
ALLROImask=ROIinfo_local(1).ROImask;
% EmptyROIs=[];
if isempty(CaSignal.ROIsummask) || CaSignal.IsROIinfoLoad
    for n=1:nTROIs
        if n==1
            SumROI=ALLROImask{1};
        else
            if isempty(ALLROImask{n})
                addmask=false(size(SumROI));
                warning(['ROI' num2str(n) 'isempty.']);
%                 EmptyROIs=[EmptyROIs,n];
            else
                addmask=ALLROImask{n};
            end
            SumROI=SumROI+addmask;
            SumROI(SumROI>1)=1;
        end
    end
    CaSignal.ROIsummask=SumROI;
end
FrameSize=CaSignal.imSize(1:2);
[LabelNPmask,Labels]=SegNPGeneration(FrameSize,ROIpos,ALLROImask,CaSignal.ROIsummask);
CaSignal.SegNumber = length(LabelNPmask);
CaSignal.ROINPlabel=Labels;
% % CaSignal.ROIinfoBack(1).Ringmask(EmptyROIs)=[];
% ROIinfo_local(1).ROImask(EmptyROIs)=[];
% ROIinfo_local(1).Ringmask(EmptyROIs)=[];
% ROIinfo_local(1).ROIpos(EmptyROIs)=[];
% ROIinfo_local(1).ROItype(EmptyROIs)=[];
% ROIinfo_local(1).ROI_def_trialNo(EmptyROIs)=[];
% CaSignal.ROIinfoBack(1)=ROIinfo_local(1);
% 
% 
% nTROIs=nTROIs-length(EmptyROIs);
% ALLROImaskR(EmptyROIs)=[];

for n=1:nTROIs
    ROIRingMask = ALLROImaskR{n};
    if isempty(ROIRingMask)
        warning(['ROI' num2str(n) 'RingMask is empty.']);
        continue;
    end
    OverLapInds =(ROIRingMask+CaSignal.ROIsummask)>1;
    ROIRingMask(OverLapInds) = 0;
    AdjustROImaskR{n}=logical(ROIRingMask);
end
CaSignal.ROIinfoBack(1).Ringmask = AdjustROImaskR;
ROIinfo_local(1).Ringmask = AdjustROImaskR;
CaSignal.ROIinfo(1).Ringmask = AdjustROImaskR;
CaSignal.ROIinfoBack(1).LabelNPmask = LabelNPmask;
ROIinfo_local(1).LabelNPmask = LabelNPmask;
CaSignal.ROIinfo(1).LabelNPmask = LabelNPmask;
TotalStateIndic = CaSignal.ROIStateIndicate;
CaSignal.ROIinfoBack = ROIinfo_local;
%###########################################################################
    % Make sure the ROIinfo of the first trial of the batch is up to date
for TrialNo = Start_trial:End_trial
    
    if  ~isempty(ROIpos)
        CaSignal.ROIinfo(TrialNo) = CaSignal.ROIinfoBack;
        ROIinfo_local(TrialNo)=ROIinfo_local(1);
       CaTrials_local(TrialNo).nROIs = CaTrials_local(1).nROIs;
       CaTrials_local(TrialNo).ROIstateIndic = TotalStateIndic;
%        disp(['Trial Number ' num2str(TrialNo) ' and number of ROIs is' num2str(CaTrials_local(TrialNo).nROIs)]);
    end
%     handles = get_exp_info(hObject, eventdata, handles);
end
ROIinfoUsed = CaSignal.ROIinfoBack;

% CPUCores=str2num(getenv('NUMBER_OF_PROCESSORS')); %#ok<ST2NM>
% poolobj = gcp('nocreate');
% if isempty(poolobj)
%     parpool('local',CPUCores);
% %     poolobj = gcp('nocreate');
% end

try
    %%
    PopuMeanSave = cell((End_trial - Start_trial + 1),1);
    PopuMaxSave = cell((End_trial - Start_trial + 1),1);
    DffAll = cell(End_trial - Start_trial + 1,1);
    FRawAll = cell(End_trial - Start_trial + 1,1);
    RingFAll = cell(End_trial - Start_trial + 1,1);
    SegNPdataAll = cell(End_trial - Start_trial + 1,1);
    ROINPlabelAll = cell(End_trial - Start_trial + 1,1);
    if abs(Start_trial - End_trial) > 10
        parfor TrialNo = Start_trial:End_trial   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   parfor
            fname = filenames{TrialNo};
            if ~exist(fname,'file')
                [fname, pathname] = uigetfile('*.tif', 'Select Image Data file');
                cd(pathname);
            end
            msg_str1 = sprintf('Batch analyzing %d of total %d trials with %d ROIs...', ...
                TrialNo, End_trial-Start_trial+1, nTROIs);  
        %     disp(['Batch analyzing ' num2str(TrialNo) ' of total ' num2str(End_trial-Start_trial+1) ' trials...']);
            disp(msg_str1);
        %     waitbar((TrialNo-Start_trial+1)/(End_trial-Start_trial+1), h, msg_str1);
        %     set(handles.msgBox, 'String', msg_str1);
            [im, ~] = load_scim_data(fname);
            if isempty(im)
                disp(['Empty image data for trial  ' num2str(TrialNo) '...']);
                continue;
            end
            [mean_im,MAxDelta] = FigMeanMaxFrame(im);
            PopuMeanSave{TrialNo} = mean_im;
            PopuMaxSave{TrialNo} = MAxDelta;
        %     set(handles.CurrentTrialNo,'String', int2str(TrialNo));
            % if isempty(ROIinfo{TrialNo})

            % end
        %     update_image_axes(handles,im);
        %     CalculatePlotButton_Callback(handles.figure1, eventdata, handles, im, ROIinfo_local(TrialNo), 0);
            [F, fRing,dff] = extract_roi_fluo(im, ROIinfoUsed, 0);
            LabelSegNPData = SegNPdataExtraction(im,LabelNPmask);
        %     disp(['Currently calculated trial number ' num2str(TrialNo) '...']);
            if isempty(F)
                disp(['Empty fluo data for trial  ' num2str(TrialNo) '...']);
            end


            DffAll{TrialNo} = dff;
            FRawAll{TrialNo} = F;
            RingFAll{TrialNo} = fRing;
            SegNPdataAll{TrialNo} = LabelSegNPData;
            ROINPlabelAll{TrialNo} = Labels;

        %     handles = update_projection_images(handles);
        %     handles = get_exp_info(hObject, eventdata, handles);
        %     CaSignal.CaTrials(TrialNo).meanImage = mean(im,3);
        %     close(CaSignal.h_CaTrace_fig);
        %     set(handles.CurrentTrialNo, 'String', int2str(TrialNo));
        %     set(handles.CurrentImageFilenameText,'String',fname);
        %     set(handles.nROIsText,'String',int2str(length(ROIinfo{TrialNo}.ROIpos)));
        end

            %##########################################################################
        %% initialize catrials for each trials
        ftime = tic;
        parfor TrialNo = Start_trial:End_trial    %%%%%%%%%%%%%%%%%% parfor
            fname = filenames{TrialNo};
             [~,header] = load_scim_data(fname,[],[],0);
            if (nTrials < TrialNo || isempty( CaTrials_local(TrialNo).FileName))
                    trial_init = init_CaTrial(filenames{TrialNo},TrialNo,header);
                    CaTrials_local(TrialNo) = trial_init;
                    CaTrials_local(TrialNo).nROIs = nTROIs;
                    CaTrials_local(TrialNo).ROIstateIndic = TotalStateIndic;
            %         disp('Initial of Casignal Struct.\n');
            end
        end
    else
        for TrialNo = Start_trial:End_trial   %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   parfor
            fname = filenames{TrialNo};
            if ~exist(fname,'file')
                [fname, pathname] = uigetfile('*.tif', 'Select Image Data file');
                cd(pathname);
            end
            msg_str1 = sprintf('Batch analyzing %d of total %d trials with %d ROIs...', ...
                TrialNo, End_trial-Start_trial+1, nTROIs);  
        %     disp(['Batch analyzing ' num2str(TrialNo) ' of total ' num2str(End_trial-Start_trial+1) ' trials...']);
            disp(msg_str1);
        %     waitbar((TrialNo-Start_trial+1)/(End_trial-Start_trial+1), h, msg_str1);
        %     set(handles.msgBox, 'String', msg_str1);
            [im, ~] = load_scim_data(fname);
            if isempty(im)
                disp(['Empty image data for trial  ' num2str(TrialNo) '...']);
                continue;
            end
            [mean_im,MAxDelta] = FigMeanMaxFrame(im);
            PopuMeanSave{TrialNo} = mean_im;
            PopuMaxSave{TrialNo} = MAxDelta;
        %     set(handles.CurrentTrialNo,'String', int2str(TrialNo));
            % if isempty(ROIinfo{TrialNo})

            % end
        %     update_image_axes(handles,im);
        %     CalculatePlotButton_Callback(handles.figure1, eventdata, handles, im, ROIinfo_local(TrialNo), 0);
            [F, fRing,dff] = extract_roi_fluo(im, ROIinfoUsed, 0);
            LabelSegNPData = SegNPdataExtraction(im,LabelNPmask);
        %     disp(['Currently calculated trial number ' num2str(TrialNo) '...']);
            if isempty(F)
                disp(['Empty fluo data for trial  ' num2str(TrialNo) '...']);
            end


            DffAll{TrialNo} = dff;
            FRawAll{TrialNo} = F;
            RingFAll{TrialNo} = fRing;
            SegNPdataAll{TrialNo} = LabelSegNPData;
            ROINPlabelAll{TrialNo} = Labels;

        %     handles = update_projection_images(handles);
        %     handles = get_exp_info(hObject, eventdata, handles);
        %     CaSignal.CaTrials(TrialNo).meanImage = mean(im,3);
        %     close(CaSignal.h_CaTrace_fig);
        %     set(handles.CurrentTrialNo, 'String', int2str(TrialNo));
        %     set(handles.CurrentImageFilenameText,'String',fname);
        %     set(handles.nROIsText,'String',int2str(length(ROIinfo{TrialNo}.ROIpos)));
        end

        % ##########################################################################
        % initialize catrials for each trials
        ftime = tic;
        for TrialNo = Start_trial:End_trial    %%%%%%%%%%%%%%%%%% parfor
            fname = filenames{TrialNo};
             [~,header] = load_scim_data(fname,[],[],0);
            if (nTrials < TrialNo || isempty( CaTrials_local(TrialNo).FileName))
                    trial_init = init_CaTrial(filenames{TrialNo},TrialNo,header);
                    CaTrials_local(TrialNo) = trial_init;
                    CaTrials_local(TrialNo).nROIs = nTROIs;
                    CaTrials_local(TrialNo).ROIstateIndic = TotalStateIndic;
            %         disp('Initial of Casignal Struct.\n');
            end
        end
        
    end
    
    
    
    t = toc(ftime);
    fprintf('Header reading ends up in %.4f.\n',t);
    %##########################################################################
    ttt = tic;
    for TrialNo = Start_trial:End_trial
        
        CaTrials_local(TrialNo).dff = DffAll{TrialNo};
        CaTrials_local(TrialNo).f_raw = FRawAll{TrialNo};
        CaTrials_local(TrialNo).RingF = RingFAll{TrialNo};
        CaTrials_local(TrialNo).SegNPData = SegNPdataAll{TrialNo};
        CaTrials_local(TrialNo).ROINPlabel = ROINPlabelAll{TrialNo};
    end
    textra = toc(ttt);
    fprintf('Extra value assign ends up in %.4f.\n',textra);
    
catch ME
    fprintf('Cannot parallel all trials becaused of the error:\n%s\n.',ME.message);
    TempCaTrials_local = CaTrials_local(1);
    %%
    if ~isdir('./TempDataSaving/')
        mkdir('./TempDataSaving/');
    end
    BlockNum = 50;
     
    TrBlockInds = Start_trial:BlockNum:End_trial;
    if TrBlockInds(end) < End_trial
        TrBlockInds = [TrBlockInds,End_trial];
    end
    nBlocks = length(TrBlockInds) - 1;
    for nB = 1 : nBlocks
        fprintf('Runing block number %d.\n',nB);
        BlockStart = TrBlockInds(nB);
        if nB == nBlocks
            BlockEnd = TrBlockInds(nB+1);
        else
            BlockEnd = TrBlockInds(nB+1) - 1;
        end
        TempPopuMeanSave = cell(BlockStart-BlockEnd+1,1);
        TempPopuMaxSave = cell(BlockStart-BlockEnd+1,1);
        DataSaveStrc = struct('Dff',[],'Fraw',[],'RingF',[],'SegNPdata',[],'ROINPLabel',[]);
        BlockBase = BlockStart - 1;
        isTrInit = zeros((BlockEnd - BlockStart + 1),1);
        for nxnx = 1 : (BlockEnd - BlockStart + 1)
            TempCaTrials_local(nxnx) = CaTrials_local(1);
        end
%%         TempCaTrials_local = 
        for TrialNo = 1 : (BlockEnd - BlockStart + 1)    %%%%%%%%%%%%%%%%%%%%%%%% parfor
            nRealTrNo = TrialNo+BlockBase;
             fname = filenames{nRealTrNo};
            if ~exist(fname,'file')
                error('File not exists.');
            end
            msg_str1 = sprintf('Batch analyzing %d of total %d trials with %d ROIs...', ...
                nRealTrNo, End_trial-Start_trial+1, nTROIs);  
        %     disp(['Batch analyzing ' num2str(TrialNo) ' of total ' num2str(End_trial-Start_trial+1) ' trials...']);
            disp(msg_str1);
             [im, header] = load_scim_data(fname);
            if isempty(im)
                disp(['Empty image data for trial  ' num2str(TrialNo) '...']);
                continue;
            end
            if (nTrials < nRealTrNo || isempty(TempCaTrials_local(TrialNo).FileName))
                    trial_init = init_CaTrial(filenames{nRealTrNo},nRealTrNo,header);
                    TempCaTrials_local(TrialNo) = trial_init;
                    TempCaTrials_local(TrialNo).nROIs = nTROIs;
                    TempCaTrials_local(TrialNo).ROIstateIndic = TotalStateIndic;
                    isTrInit(TrialNo) = 1;
            %         disp('Initial of Casignal Struct.\n');
            end
           
            [mean_im,MAxDelta] = FigMeanMaxFrame(im);
            TempPopuMeanSave{TrialNo} = mean_im;
            TempPopuMaxSave{TrialNo} = MAxDelta;
            [F, fRing,dff] = extract_roi_fluo(im, ROIinfoUsed, 0);
             LabelSegNPData = SegNPdataExtraction(im,LabelNPmask);
            if isempty(F)
                disp(['Empty fluo data for trial  ' num2str(TrialNo) '...']);
            end
%             CaTrials_local(TrialNo).dff = dff;
%             CaTrials_local(TrialNo).f_raw = F;
%             CaTrials_local(TrialNo).RingF = fRing;
%             CaTrials_local(TrialNo).SegNPData = LabelSegNPData;
%             CaTrials_local(TrialNo).ROINPlabel = Labels;
            DataSaveStrc(TrialNo).Dff = dff;
            DataSaveStrc(TrialNo).Fraw = F;
            DataSaveStrc(TrialNo).RingF = fRing;
            DataSaveStrc(TrialNo).SegNPdata = LabelSegNPData;
            DataSaveStrc(TrialNo).ROINPLabel = Labels;
        end
        %%
         cd('./TempDataSaving/');
        save(sprintf('TempSaveData%d.mat',nB),'TempPopuMeanSave','TempPopuMaxSave','DataSaveStrc','BlockStart',...
            'TempCaTrials_local','BlockEnd','isTrInit','-v7.3');
        clear TempPopuMeanSave TempPopuMaxSave DataSaveStrc im F fRing dff TempCaTrials_local isTrInit;
%         clearvars TempPopuMeanSave TempPopuMaxSave DataSaveStrc TempCaTrials_local isTrInit
        cd ..;
    end
    %%
    % collecting saved dataset
    cd('./TempDataSaving/');
    PopuMeanSave = cell((End_trial - Start_trial + 1),1);
    PopuMaxSave = cell((End_trial - Start_trial + 1),1);
    for nBs = 1 : nBlocks
        BlockFname = sprintf('TempSaveData%d.mat',nBs);
        xx = load(BlockFname);
        cBlockStart = xx.BlockStart;
        cBlockEnd = xx.BlockEnd;
        BlockIndsAll = cBlockStart:cBlockEnd;
        TempBlockInds = (BlockIndsAll - cBlockStart) + 1;
        CaTrials_local((BlockIndsAll(logical(xx.isTrInit)))) = xx.TempCaTrials_local(TempBlockInds(logical(xx.isTrInit)));
        k = 1;
        for nTrs = cBlockStart:cBlockEnd
            PopuMeanSave{nTrs} = xx.TempPopuMeanSave{k};
            PopuMaxSave{nTrs} = xx.TempPopuMaxSave{k};
%             CaTrials_local(nTrs) = xx.TempCaTrials_local(k);
            CaTrials_local(nTrs).dff = xx.DataSaveStrc(k).Dff;
            CaTrials_local(nTrs).f_raw = xx.DataSaveStrc(k).Fraw;
            CaTrials_local(nTrs).RingF = xx.DataSaveStrc(k).RingF;
            CaTrials_local(nTrs).SegNPData = xx.DataSaveStrc(k).SegNPdata;
            CaTrials_local(nTrs).ROINPlabel = xx.DataSaveStrc(k).ROINPLabel;
            k = k + 1;
        end
    end
    cd ..;
    %%
end

%###################################################################################################
% delete(poolobj);
CaSignal.CaTrials = CaTrials_local;
PopuProjData = struct('MeanFrame',PopuMeanSave,'MaxFrame',PopuMaxSave);
CaSignal.PopuFrameProj = PopuProjData;

SaveResultsButton_Callback(hObject, eventdata, handles);
if isdir('./TempDataSaving/')
    rmdir('./TempDataSaving/','s');
end
disp(['Batch analysis completed for ' CaSignal.CaTrials(1).FileName_prefix]);
set(handles.msgBox, 'String', ['Batch analysis completed for ' CaSignal.CaTrials(1).FileName_prefix]);
% delete(gcp('nocreate'));
guidata(hObject, handles);

function [mean_im,MAxDelta] = FigMeanMaxFrame(im,varargin)
if nargin > 1
    span = varargin{1};
else
    span = 3;
end
mean_im = uint16(mean(double(im),3));
% Smoothim = im_mov_avg(im,span);
max_im = max(im_mov_avg(im,span),[],3);
MAxDelta = max_im - mean_im;
% clearvars Smoothim

function im_smth = im_mov_avg(im, span)

% Note, span has to be odd number

% - NX 3/11/2009

im = double(im);
mean_im = mean(im,3);

pad = zeros(size(im,1),size(im,2), (span-1)/2);
for i = 1: (span-1)/2
    pad(:,:,i) = mean_im;
end
temp = cat(3,pad,im,pad);

im_smth = zeros(size(im),'uint16');

for i = 1:size(im,3) % (span-1)/2+1 : size(im,3)+(span-1)/2
    im_smth(:,:,i) = mean(temp(:,:,i:i+span-1), 3);
end


function SaveResultsButton_Callback(hObject, eventdata, handles)
%% Save Results
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
FileName_prefix = CaSignal.CaTrials(TrialNo).FileName_prefix;
% CaSignal.CaTrials = CaSignal.CaTrials;
% ROIinfo = ROIinfo;

%% Now we are in data file path. Since analysis results are saved in a separate
% folder, we need to find that folder in order to laod or save analysis
% results. If that folder does not exist, a new folder will be created.
cd(CaSignal.data_path);
cd ..;
if exist('BadAlignF.mat','file')
    BADAlignFStrc = load('BadAlignF.mat');
    if iscell(BADAlignFStrc.BadAlignFrame)
        isFileBadAlign = cellfun(@isempty,BADAlignFStrc.BadAlignFrame);
        BadFileIndex = find(~isFileBadAlign);
        BadAlignFile = BADAlignFStrc.BadAlignFrame(~isFileBadAlign);
        nfiles = length(BadAlignFile);
        nBadInds = zeros(nfiles,1);
        for nfff = 1 : nfiles
            cfilename = BadAlignFile{nfff};
            if isnumeric(cfilename)
                nBadInds(nfff) = BadFileIndex(nfff);
            else
                nBadInds(nfff) = str2num(cfilename(end-6:end-4));
            end
        end
    else
        nBadInds = BADAlignFStrc.BadAlignFrame > 0;
    end
    
    CaSignal.IsTrialExcluded(nBadInds) = true;
end
cd(CaSignal.data_path);
%% CaSignal.results_path = strrep(datapath,[filesep 'data'],[filesep 'results']);
if get(handles.autosaving,'Value')
    CaSignal.results_path=[CaSignal.data_path,filesep,'result_save'];
    if ~isdir([CaSignal.data_path,filesep,'result_save'])
        mkdir([CaSignal.data_path,filesep,'result_save']);
    end
else
    if isempty(CaSignal.results_path) || ~exist(CaSignal.results_path,'dir')
        CaSignal.results_path = uigetdir([CaSignal.data_path filesep 'Analysis_Results']);
    end
end

if ~CaSignal.results_path
    if ~isdir([CaSignal.data_path,filesep,'result_save'])
        mkdir([CaSignal.data_path,filesep,'result_save']);
    end
    CaSignal.results_path=[CaSignal.data_path,filesep,'result_save'];
    disp('no other file path selected, use default result save path.\n');
end
% 
% mkdir(CaSignal.results_path);
% disp('results dir not exists! A new folder created:');
% disp(CaSignal.results_path);

CaSignal.results_fname = [CaSignal.results_path filesep 'CaTrials_' FileName_prefix '.mat'];
CaSignal.SIMsave_fname = [CaSignal.results_path filesep 'CaTrialsSIM_' FileName_prefix '.mat'];
CaSignal.ROIinfo_fname = [CaSignal.results_path filesep 'ROIinfo_', FileName_prefix '.mat'];   
CaSignal.ROIinfoback_fname = [CaSignal.results_path filesep 'ROIinfoBU_', FileName_prefix '.mat'];   
% [fname, pathname, ~] = uigetfile('*.mat', 'Saving Results To ...', CaSignal.results_fname);
% CaSignal.results_fname = fname;

ROIinfo = CaSignal.ROIinfo;
for i = 1:length(CaSignal.CaTrials)
    if length(CaSignal.ROIinfo) >= i
        CaSignal.CaTrials(i).ROIinfo = CaSignal.ROIinfo(i);
        CaSignal.CaTrials(i).ROIinfoBack = CaSignal.ROIinfoBack(1);
        CaSignal.CaTrials(i).ImportROIpath = CaSignal.ROIInfoPath;
    end
end
CaTrials = CaSignal.CaTrials;
ROIinfoBU=CaSignal.ROIinfoBack;

%%
% if ~CaSignal.ContAcqCheck
    % simplify saved data size
    SavedCaTrials.DataPath=CaTrials(1).DataPath;
    SavedCaTrials.FileName_prefix=CaTrials(1).FileName_prefix;

    SavedCaTrials.nFrames=CaTrials(1).nFrames;
    SavedCaTrials.FrameTime=CaTrials(1).FrameTime;
    SavedCaTrials.nROIs=CaTrials(1).nROIs;
    SavedCaTrials.ROIinfo=CaTrials(1).ROIinfo;
    SavedCaTrials.ROIinfoBack=CaTrials(1).ROIinfoBack;
    SavedCaTrials.ROIstateIndic = CaSignal.ROIStateIndicate;
    SavedCaTrials.ImportROIpath = CaSignal.ROIInfoPath;
    if isempty(CaSignal.ContAcqCheck) || ~CaSignal.ContAcqCheck
        RawData=zeros(length(CaTrials),CaTrials(1).nROIs,CaTrials(1).nFrames);
        ringData=zeros(length(CaTrials),CaTrials(1).nROIs,CaTrials(1).nFrames);
        if isfield(CaSignal,'SegNumber')
            SegNPdata=zeros(length(CaTrials),CaSignal.SegNumber,CaTrials(1).nFrames);
        end
        SavedCaTrials.IsContinueAcq = 0;
    else
        RawData = cell(length(CaTrials),1);
        ringData = cell(length(CaTrials),1);
        if isfield(CaSignal,'SegNumber')
            SegNPdata = cell(length(CaTrials),1);
        end
        SavedCaTrials.IsContinueAcq = 1;
    end
    try
        if isempty(CaTrials(1).f_raw) || isempty(CaTrials(1).RingF)
            RawData=[];
            ringData=[];
            SegNPdata=[];
        else
            if ~CaSignal.ContAcqCheck
                for n=1:length(CaTrials)
                    RawData(n,:,:)=CaTrials(n).f_raw;
                    ringData(n,:,:)=CaTrials(n).RingF;
                    SegNPdata(n,:,:)=CaTrials(n).SegNPData;
                    SavedCaTrials.DaqInfo{n}=CaTrials(n).DaqInfo;
                end
            else
               ExInds = CaSignal.IsTrialExcluded; 
               for n=1:length(CaTrials)
                   if ExInds(n)
                       DataSeq = CaTrials(n).f_raw;
                       if mean(mean(DataSeq(:,end-4:end))) < 10
                           RawData{n} = CaTrials(n).f_raw(:,1:end-10);
                           ringData{n} = CaTrials(n).RingF(:,1:end-10);
                           SegNPdata{n} = CaTrials(n).SegNPData(:,1:end-10);
                           SavedCaTrials.DaqInfo{n} = CaTrials(n).DaqInfo;
                           CaSignal.IsTrialExcluded(n) = false;
                       else
                           RawData{n} = CaTrials(n).f_raw(:,1:end-10);
                           ringData{n} = CaTrials(n).RingF(:,1:end-10);
                           SegNPdata{n} = CaTrials(n).SegNPData(:,1:end-10);
                           SavedCaTrials.DaqInfo{n} = CaTrials(n).DaqInfo;
                       end
                   else
                       RawData{n} = CaTrials(n).f_raw;
                       ringData{n} = CaTrials(n).RingF;
                       SegNPdata{n} = CaTrials(n).SegNPData;
                       SavedCaTrials.DaqInfo{n} = CaTrials(n).DaqInfo;
                   end
                end
            end
        end
        SavedCaTrials.f_raw=RawData;
        SavedCaTrials.RingF=ringData;
        SavedCaTrials.TrialNum=length(CaTrials);
        SavedCaTrials.SegNPdataAll=SegNPdata;
        SavedCaTrials.ROISegLabel=CaSignal.ROINPlabel;
        %simplified data storage
        save(CaSignal.SIMsave_fname,'SavedCaTrials','-v7.3');
        save(CaSignal.ROIinfoback_fname, 'ROIinfoBU','-v7.3');
    catch ME
        fprintf('Following Error occurs:\n%s;\n',ME.message);
        nFrame = CaSignal.nFrames;
        nFramesAll = zeros(length(CaTrials),1);
        for nTrial = 1 : length(CaTrials)
            nFramesAll(nTrial) = size(CaTrials(nTrial).f_raw,2);
        end
        AbnormTrInds = find(nFramesAll ~= nFrame);
        f_abTr = fopen('Trial with abnormal frames.txt','w');
        fprintf(f_abTr,'Trials with abnormal frame numbers: \r\n');
        for nx = 1 : length(AbnormTrInds)
            if nx == 1
                fprintf(f_abTr,'%d  ',AbnormTrInds(nx));
            else
                fprintf(f_abTr,',%d  ',AbnormTrInds(nx));
            end
        end
        fprintf(f_abTr,'.\n');
        fclose(f_abTr);
        save AbnormalInds.mat AbnormTrInds -v7.3
        fprintf('Can''t save current session data in simplified way, may be caused by some frame dropping at trial number %d.\n',AbnormTrInds);
        %redundant data storage
        save(CaSignal.results_fname, 'CaTrials','-v7.3');
        save(CaSignal.ROIinfo_fname, 'ROIinfo','-v7.3');
    end
% else
%     save(CaSignal.results_fname, 'CaTrials','-v7.3');
%     save(CaSignal.ROIinfoback_fname, 'ROIinfoBU','-v7.3');
% end
%%
% save(CaSignal.results_fname, 'CaTrials','ICA_results');

%redundant data storage
% save(CaSignal.results_fname, 'CaTrials','-v7.3');
% save(CaSignal.ROIinfo_fname, 'ROIinfo','-v7.3');

%simplified data storage
% save(CaSignal.SIMsave_fname,'SavedCaTrials','-v7.3');
% save(CaSignal.ROIinfoback_fname, 'ROIinfoBU','-v7.3');


% save exclude trial inds if any
if sum(double(CaSignal.IsTrialExcluded))
    fprintf('Excluded trial exists, saved to mat file for future analysis...\n');
    ExcludedTrInds = CaSignal.IsTrialExcluded;
    save(fullfile(CaSignal.results_path,'cSessionExcludeInds.mat'),'ExcludedTrInds','-v7.3');
end
if isfield(CaSignal,'PopuFrameProj')
   FrameProjSave = CaSignal.PopuFrameProj;
   save(fullfile(CaSignal.results_path,'SessionFrameProj.mat'),'FrameProjSave','-v7.3');
end

% save(fullfile(CaSignal.results_path, ['ICA_ROIs_', FileName_prefix '.mat']), 'ICA_ROIs');
msg_str = sprintf('CaTrials Saved, with %d trials, %d ROIs', length(CaSignal.CaTrials), CaSignal.CaTrials(TrialNo).nROIs);
disp(msg_str);
set(handles.msgBox, 'String', msg_str);
% save_gui_info(handles);


function autosaving_Callback(hObject, eventdata, handles)
% function autosaving_CreateFcn(hObject, eventdata, handles)
% set(handles.autosaving,'Value',1);

function batchStartTrial_Callback(hObject, eventdata, handles)

function batchStartTrial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function batchEndTrial_Callback(hObject, eventdata, handles)

function batchEndTrial_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dispModeGreen_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if CaSignal.CaTrials(TrialNo).DaqInfo.acq.numberOfChannelsAcquire == 1
    set(hObject,'Value',1);
end;

function dispModeImageInfoButton_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if get(hObject, 'Value') == 1
    CaSignal.h_info_fig = figure; set(gca, 'Visible', 'off');
    f_pos = get(CaSignal.h_info_fig, 'Position'); f_pos(3) = f_pos(3)/2;
    set(CaSignal.h_info_fig, 'Position', f_pos);
    info_disp = CaSignal.info_disp;
    for i = 1: length(info_disp),
        x = 0.01;
        y=1-i/length(info_disp);
        text(x,y,info_disp{i},'Interpreter','none');
    end
    guidata(hObject, handles);
else
    close(CaSignal.h_info_fig);
end


function nROIsText_CreateFcn(hObject, eventdata, handles)

function figure1_DeleteFcn(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
save_gui_info(handles);
clear CaSignal % ROIinfo ICA_ROIs
% close all;

function CurrentTrialNo_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
% To record the Current loaded trial number. Use this number to come back
% one step.
CaSignal.Last_TrialNo = CaSignal.CurrentTrialNo;
CaSignal.CurrentTrialNo = str2double(get(handles.CurrentTrialNo,'String'));

TrialNo = CaSignal.CurrentTrialNo;
if TrialNo>0
    filename = CaSignal.data_file_names{TrialNo};
    if exist(filename,'file')
        open_image_file_button_Callback(hObject, eventdata, handles,filename);
    end
end
cTrNum = CaSignal.CurrentTrialNo;
if CaSignal.IsTrialExcluded(cTrNum)
    set(handles.ExcludeCTr,'value',1);
else
    set(handles.ExcludeCTr,'value',0);
end

function PrevTrialButton_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
CaSignal.Last_TrialNo = CaSignal.CurrentTrialNo;
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if TrialNo>1
    filename = CaSignal.data_file_names{TrialNo-1};
    if exist(filename,'file')
        open_image_file_button_Callback(hObject, eventdata, handles,filename);
    end
else
     filename = CaSignal.data_file_names{length(CaSignal.data_file_names)};
     if exist(filename,'file')
        open_image_file_button_Callback(hObject, eventdata, handles,filename);
     end
end
cTrNum = CaSignal.CurrentTrialNo;
if CaSignal.IsTrialExcluded(cTrNum)
    set(handles.ExcludeCTr,'value',1);
else
    set(handles.ExcludeCTr,'value',0);
end


function NextTrialButton_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
CaSignal.Last_TrialNo = CaSignal.CurrentTrialNo;
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if  TrialNo+1 <= length(CaSignal.data_file_names) % exist(filename,'file')
    filename = CaSignal.data_file_names{TrialNo+1};
    open_image_file_button_Callback(hObject, eventdata, handles,filename);
else
    filename = CaSignal.data_file_names{1};
    open_image_file_button_Callback(hObject, eventdata, handles,filename);
end
cTrNum = CaSignal.CurrentTrialNo;
if CaSignal.IsTrialExcluded(cTrNum)
    set(handles.ExcludeCTr,'value',1);
else
    set(handles.ExcludeCTr,'value',0);
end

function TwoStepPreTrial_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
CaSignal.Last_TrialNo = CaSignal.CurrentTrialNo;
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if TrialNo>2
    filename = CaSignal.data_file_names{TrialNo-2};
    if exist(filename,'file')
        open_image_file_button_Callback(hObject, eventdata, handles,filename);
    end
else
    filename = CaSignal.data_file_names{length(CaSignal.data_file_names)};
    if exist(filename,'file')
        open_image_file_button_Callback(hObject, eventdata, handles,filename);
    end
end
cTrNum = CaSignal.CurrentTrialNo;
if CaSignal.IsTrialExcluded(cTrNum)
    set(handles.ExcludeCTr,'value',1);
else
    set(handles.ExcludeCTr,'value',0);
end

function TwoStepNextTrial_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
CaSignal.Last_TrialNo = CaSignal.CurrentTrialNo;
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
if  TrialNo+2 <= length(CaSignal.data_file_names) % exist(filename,'file')
    filename = CaSignal.data_file_names{TrialNo+2};
    open_image_file_button_Callback(hObject, eventdata, handles,filename);
else
    filename = CaSignal.data_file_names{1};
    open_image_file_button_Callback(hObject, eventdata, handles,filename);
end
cTrNum = CaSignal.CurrentTrialNo;
if CaSignal.IsTrialExcluded(cTrNum)
    set(handles.ExcludeCTr,'value',1);
else
    set(handles.ExcludeCTr,'value',0);
end

function go_to_last_trial_button_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
LastTrialNo = CaSignal.Last_TrialNo;
if  LastTrialNo > 0 % exist(filename,'file')
    filename = CaSignal.data_file_names{LastTrialNo};
    open_image_file_button_Callback(hObject, eventdata, handles,filename);
end
cTrNum = CaSignal.CurrentTrialNo;
if CaSignal.IsTrialExcluded(cTrNum)
    set(handles.ExcludeCTr,'value',1);
else
    set(handles.ExcludeCTr,'value',0);
end

function AnalysisModeBGsub_Callback(hObject, eventdata, handles)

function batchPrefixEdit_Callback(hObject, eventdata, handles)

function batchPrefixEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function AnimalNameEdit_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CaSignal.CaTrials(TrialNo).AnimalName = get(hObject, 'String');
guidata(hObject, handles);
save_gui_info(handles);

function AnimalNameEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function ExpDate_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CaSignal.CaTrials(TrialNo).ExpDate = get(hObject, 'String');
guidata(hObject, handles);
save_gui_info(handles);

function ExpDate_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function SessionName_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
CaSignal.CaTrials(TrialNo).SessionName = get(hObject, 'String');
guidata(hObject, handles);
save_gui_info(handles);

function SessionName_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function FrameSlider_Callback(hObject, eventdata, handles, varargin)
global CaSignal % ROIinfo ICA_ROIs
nFrames = CaSignal.nFrames;

if ~isempty(varargin)
    new_frameNum = varargin{1};
    if new_frameNum == 0, new_frameNum = 1; end;
    if new_frameNum > nFrames, new_frameNum = nFrames; end
    slider_value = new_frameNum/nFrames;
    set(hObject, 'Value', slider_value)
else
    slider_value = get(hObject,'Value');
    new_frameNum = ceil(nFrames*slider_value);
    if new_frameNum == 0, new_frameNum = 1; end;
end
set(handles.CurrentFrameNoEdit, 'String', num2str(new_frameNum));
handles = update_image_axes(handles);
guidata(hObject, handles);

% h_main_figure = gcf;
% ch = getkey2(h_main_figure);
% if ismember(ch, [28 29])
%     old_frameNum = str2num(get(handles.CurrentFrameNoEdit, 'String'));
% %     ch = getkey2(hf);
%     if ch == 29
%         new_frameNum = old_frameNum + 1;
%     elseif ch == 28
%         new_frameNum = old_frameNum - 1;
%     end
% %     disp(new_frameNum);
%     FrameSlider_Callback(hObject, eventdata, handles, new_frameNum)
%  end


function FrameSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function CurrentFrameNoEdit_Callback(hObject, eventdata, handles)

handles = update_image_axes(handles);

function CurrentFrameNoEdit_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LUTminEdit_Callback(hObject, eventdata, handles)

update_image_axes(handles);
update_projection_images(handles);

function LUTminEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LUTmaxEdit_Callback(hObject, eventdata, handles)

update_image_axes(handles);
update_projection_images(handles);


function LUTmaxEdit_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function LUTminSlider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value_min = get(hObject,'Value');
value_max = get(handles.LUTmaxSlider,'Value');
if value_min >= value_max
    value_min = value_max - 0.01;
    set(hObject, 'Value', value_min);
end;
set(handles.LUTminEdit, 'String', num2str(value_min*1000));
update_image_axes(handles);
update_projection_images(handles);
% guidata(hObject, handles);


function LUTminSlider_CreateFcn(hObject, eventdata, handles)

if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


function LUTmaxSlider_Callback(hObject, eventdata, handles)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
value_max = get(hObject,'Value');
value_min = get(handles.LUTminSlider, 'Value');
if value_max <= value_min
    value_max = value_min + 0.01;
    set(hObject, 'Value', value_max);
end;
set(handles.LUTmaxEdit, 'String', num2str(value_max*1000));
update_image_axes(handles);
update_projection_images(handles);
% guidata(hObject, handles);


function dispMeanMode_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if get(hObject, 'Value')==1
    handles = update_projection_images(handles);
else
    try
        if ishandle(CaSignal.h_mean_fig)
            delete(CaSignal.h_mean_fig);
        end;
    catch ME
    end
    CaSignal=rmfield(CaSignal,'h_mean_fig');
end
guidata(hObject, handles);


function dispMaxDelta_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if get(hObject, 'Value')==1
    handles = update_projection_images(handles);
else
    try
        if ishandle(CaSignal.h_maxDelta_fig)
            delete(CaSignal.h_maxDelta_fig);
        end;
    catch ME
    end
    CaSignal=rmfield(CaSignal,'h_maxDelta_fig');
end
guidata(hObject, handles);

function dispMaxMode_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if get(hObject, 'Value')==1
    handles = update_projection_images(handles);
else
    try
        if ishandle(CaSignal.h_max_fig)
            delete(CaSignal.h_max_fig);
        end;
    catch ME
    end
    CaSignal=rmfield(CaSignal,'h_max_fig');
end
guidata(hObject, handles);

function ROITypeMenu_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function dispModeGreen_CreateFcn(hObject, eventdata, handles)

function LUTmaxSlider_CreateFcn(hObject, eventdata, handles)
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in SaveFrameButton.
function SaveFrameButton_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
im = CaSignal.ImageArray;
fr = str2double(get(handles.CurrentFrameNoEdit,'String'));
dataFileName = get(handles.CurrentImageFilenameText, 'String');

[fname, pathName] = uiputfile([dataFileName(1:end-4) '_' int2str(fr) '.tif'], 'Save the current frame as');
if ~isequal(fname, 0)&& ~isequal(pathName, 0)
    imwrite(im(:,:,fr), [pathName fname], 'tif','WriteMode','overwrite','Compression','none');
end


% --- Executes on button press in setTargetForTrial.
function setTargetForTrial_Callback(hObject, eventdata, handles)



% --- Executes on button press in setTargetForSession.
function setTargetForSession_Callback(hObject, eventdata, handles)
% hObject    handle to setTargetForSession (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of setTargetForSession


% --- Executes on button press in setTargetCurrentFrame.
function setTargetCurrentFrame_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2num(get(handles.CurrentTrialNo, 'String'));
if get(hObject,'Value') == 1
    fr = str2num(get(handles.CurrentFrameNoEdit, 'String'));
    CaSignal.RegTarget = CaSignal.ImageArray(:,:,fr);
    CaSignal.CaTrials(TrialNo).RegTargetFrNo = fr;
    set(handles.setTargetMean, 'Value', 0);
    set(handles.setTargetMaxDelta, 'Value', 0);
end
guidata(hObject, handles);


% --- Executes on button press in setTargetMean.
function setTargetMean_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if get(hObject,'Value') == 1
    CaSignal.RegTarget = uint16(mean(CaSignal.ImageArray,3));
    set(handles.setTargetCurrentFrame, 'Value', 0);
    set(handles.setTargetMaxDelta, 'Value', 0);
end
guidata(hObject, handles);

% --- Executes on button press in setTargetMaxDelta.
function setTargetMaxDelta_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
if get(hObject,'Value') == 1
    if isfield(CaSignal, 'MaxDelta')&& ~isempty(CaSignal.MaxDelta)
        CaSignal.RegTarget = CaSignal.MaxDelta;
    else
        im = CaSignal.ImageArray;
        mean_im = uint16(mean(im,3));
        im = im_mov_avg(im,5);
        max_im = max(im,[],3);
        CaSignal.RegTarget = max_im - mean_im;
        set(handles.setTargetCurrentFrame, 'Value', 0);
        set(handles.setTargetMean, 'Value', 0);
    end 
end
guidata(hObject, handles);

% --- Executes on button press in RegCurrentTrial.
function RegCurrentTrial_Callback(hObject, eventdata, handles)
% Motion correction by for the current trial
% setTargetCurrentFrame_Callback(hObject, eventdata, handles);
% setTargetMaxDelta_Callback(hObject, eventdata, handles);
% setTargetMean_Callback(hObject, eventdata, handles);
global CaSignal%  ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
RegMethod_id = get(handles.RegMethodMenu,'Value');
RegMethod_string = get(handles.RegMethodMenu,'String');
switch get(handles.RegMethodMenu,'Value')
    case 2 % 'TurboReg'
        ImageReg = Turboreg_nx3(CaSignal.RegTarget, CaSignal.ImageArray,'translation',0);
    case {3 4} % 'dft_Reg'
        tg_img = CaSignal.RegTarget;
        src_img = CaSignal.ImageArray;
        for i=1:size(src_img,3);
            output(:,i) = dftregistration(fft2(double(tg_img)),fft2(double(src_img(:,:,i))),1);
        end
        shift = output(3:4,:);
%         if size(src_img,1) > CaSignal.CaTrials(TrialNo).DaqInfo.acq.linesPerFrame
%             % if the source image is already padded image from the original
%             % data, then do not padding
%             padding = [0 0 0 0];
%         else
%             % Otherwise, pad the image matrix according to the shift pixels
%             padding = [];
%         end
        padding = [0 0 0 0];
        ImageReg = ImageTranslation_nx(src_img,shift,padding,0);
        figure('Name','Image shiftings');
        dist_shifted = sqrt(shift(1,:).^2 + shift(2,:).^2);
        plot(dist_shifted);
        xlabel('# Frame'); ylabel('Shift Distance');
        disp(['mean shifting for all frames: ' num2str(mean(dist_shifted))]);
end;
disp(['Completed registration of the current trial using ' RegMethod_string{RegMethod_id}]);
CaSignal.ImageArray = ImageReg;
handles = update_image_axes(handles);
guidata(hObject,handles)

% --- Executes on button press in RegCurrentSession.
function RegCurrentSession_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
% setTargetCurrentFrame_Callback(hObject, eventdata, handles);
% setTargetMaxDelta_Callback(hObject, eventdata, handles);
% setTargetMean_Callback(hObject, eventdata, handles);
filename_base = get(handles.batchPrefixEdit, 'String');
targetImage = CaSignal.RegTarget;
sorce_filenames = CaSignal.data_file_names;
ref_trial_num = str2num(get(handles.CurrentTrialNo, 'String'));
shift = [];
switch get(handles.RegMethodMenu,'Value')
    case 2 % 'TurboReg'
        for i = 1:length(CaSignal.data_file_names)
            disp(['Registering data file: ' sorce_filenames{i} ' ...']);
            Turboreg_nx3(targetImage, sorce_filenames{i}, 'translation',1);
        end
        save(['dft_reg\' filename_base '[dftShift].mat'], 'shift','ref_trial_num');
    case 3 % 'dft_Reg'
        shift = batch_dft_reg(targetImage, sorce_filenames, 0);
        % save reg info
        save(['dft_reg\' filename_base '[dftShift].mat'], 'shift','ref_trial_num');
    case 4 % 'dft_Reg_padded', padding the orignal image to accomadate the maximum pixel shifts accross trials
        shift = batch_dft_reg(targetImage, sorce_filenames, 1);
end;
CaSignal.dftreg_shift = shift;
guidata(hObject,handles);

% --- Executes on button press in SaveRegImage.
function SaveRegImage_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
im = CaSignal.ImageArray;
currentFileName = get(handles.CurrentImageFilenameText, 'String');
im_describ = CaSignal.ImageDescription;
% if the current file is not the original data, then overwrite it,
% otherwise create another file for the registered image
switch get(handles.RegMethodMenu,'Value')
    case 2 % 'TurboReg'
        if isempty(findstr(pwd, 'turboreg'))
            saveName = [currentFileName(1:end-7) 'reg_' currentFileName(end-6:end)];
            savePath = [pwd filesep 'turboreg_corrected'];
        else
            saveName = currentFileName;
            savePath = pwd;
        end;
    case {3, 4}% 'dft_Reg'
        if isempty(findstr(pwd, 'dft_reg'))
            savePath = [pwd filesep 'dft_reg'];
            saveName = [currentFileName(1:end-7) '_dftReg_' currentFileName(end-6:end-4) '.tif'];
        else
            saveName = currentFileName;
            savePath = pwd;
        end
end
if ~exist(savePath, 'dir')
    mkdir(savePath);
end
for i = 1:size(im,3)
    if i == 1,
        imwrite(im(:,:,i),[savePath filesep saveName],'tif','Compression','none','Description',im_describ,'WriteMode','overwrite');
    else
        imwrite(im(:,:,i),[savePath filesep saveName],'tif','Compression','none','WriteMode','append');
    end
end
disp(['Registered image saved as ' saveName]);
set(handles.msgBox, 'String', ['Registered image saved as ' saveName]);


% --- Executes on button press in BG_poly_set.
function BG_poly_set_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
%    if isempty(CaSignal.CaTrials(TrialNo).BGmask)
waitforbuttonpress;
[BW,xi,yi] = roipoly;
CaSignal.ROIinfo(TrialNo).BGmask = BW;
CaSignal.ROIinfo(TrialNo).BGpos = [xi yi];
CaSignal.ROIinfoBack(1).BGmask = BW;
CaSignal.ROIinfoBack(1).BGpos = [xi yi];
% axes(CaSignal.image_disp_gui.Image_disp_axes);
% if isfield(CaSignal, 'BGplot')&& ishandle(CaSignal.BGplot)
%     delete(CaSignal.BGplot);
% end
% CaSignal.BGplot = line(xi, yi, 'Color','b', 'LineWidth',2);
update_ROI_plot(handles);       
guidata(hObject, handles);


% --- Executes during object creation, after setting all properties.
function AnalysisModeBGsub_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AnalysisModeBGsub (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in RegMethodMenu.
function RegMethodMenu_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function RegMethodMenu_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RegMethodMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on selection change in MotionEstmOptions.
function MotionEstmOptions_Callback(hObject, eventdata, handles)
% Hints: contents = get(hObject,'String') returns MotionEstmOptions contents as cell array
%        contents{get(hObject,'Value')} returns selected item from MotionEstmOptions
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
switch get(hObject,'Value')
    case 2 % plot cross correlation coef for the current trial
        img = CaSignal.ImageArray;
        xcoef = xcoef_img(img);
        figure('Name', ['xCorr. Coefficient for Trial ' num2str(TrialNo)], 'Position', [1200 300 480 300]);
        plot(xcoef); xlabel('Frame #'); ylabel('Corr. Coeff');
        disp(sprintf(['mean xCorr. Coefficient for trial ' num2str(TrialNo) ': %g'],mean(xcoef)));
    case 3 % Compute cross correlation across all trials
        n_trials = length(CaSignal.data_file_names);
        if isempty(CaSignal.avgCorrCoef_trials)
            xcoef_trials = zeros(n_trials,1);
            h_wait = waitbar(0, 'Calculating cross correlation coefficients for trial 0 ...');
            for i = 1:n_trials
                waitbar(i/n_trials, h_wait, ['Calculating cross correlation coefficients for trial ' num2str(i)]);
                img = load_scim_data(CaSignal.data_file_names{i}); 
                xcoef = xcoef_img(img);
                xcoef_trials(i) = mean(xcoef);
            end
            close(h_wait);
            CaSignal.avgCorrCoef_trials = xcoef_trials;
        else
            xcoef_trials = CaSignal.avgCorrCoef_trials;
        end
        figure('Name', 'xCorr. Coef across all trials', 'Position', [1200 300 480 300]);
        plot(xcoef_trials); xlabel('Trial #'); ylabel('mean Corr. Coeff');
    case 4
        
    case 5
        if ~isempty(CaSignal.dftreg_shift)
            for i = 1:str2num(get(handles.TotTrialNum, 'String'))
                avg_shifts(i) = max(mean(abs(CaSignal.dftreg_shift(:,:,i)),2));
            end
            figure;
            plot(avg_shifts,'LineWidth',2); 
            title('Motion estimation of all trials','FontSize',18);
            xlabel('Trial #', 'FontSize', 15); ylabel('Mean shift of all frames', 'FontSize', 15);
        end
end
guidata(hObject,handles);

% --- Executes during object creation, after setting all properties.
function MotionEstmOptions_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function save_gui_info(handles)
% global CaSignal ROIinfo ICA_ROIs
info.DataPath = pwd;
info.AnimalName = get(handles.AnimalNameEdit,'String');
info.ExpDate = get(handles.ExpDate,'String');
info.SessionName = get(handles.SessionName, 'String');
info.SoloDataPath = get(handles.SoloDataPath, 'String');
info.SoloDataFileName = get(handles.SoloDataFileName, 'String');
info.SoloSessionName = get(handles.SoloSessionName, 'String');
info.SoloStartTrialNo = get(handles.SoloStartTrialNo, 'String');
info.SoloEndTrialNo = get(handles.SoloEndTrialNo, 'String');

usrpth = 'D:\'; % usrpth = usrpth(1:end-1);
if strcmp(usrpth(end), ';')||strcmp(usrpth(end), ':'), usrpth(end) = []; end
save([usrpth filesep 'nx_CaSingal.info'], 'info');



function SoloStartTrialNo_Callback(hObject, eventdata, handles)
%

% --- Executes during object creation, after setting all properties.
function SoloStartTrialNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to solostarttrialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SoloEndTrialNo_Callback(hObject, eventdata, handles)
%

% --- Executes during object creation, after setting all properties.
function SoloEndTrialNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to soloendtrialno (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SoloDataPath_Callback(hObject, eventdata, handles)
%

% --- Executes during object creation, after setting all properties.
function SoloDataPath_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function SoloDataFileName_Callback(hObject, eventdata, handles)


% --- Executes during object creation, after setting all properties.
function SoloDataFileName_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in addBehavTrials.
function addBehavTrials_Callback(hObject, eventdata, handles)
global CaSignal %  ROIinfo ICA_ROIs

Solopath = get(handles.SoloDataPath,'String');
mouseName = get(handles.AnimalNameEdit, 'String');
sessionName = get(handles.SoloSessionName, 'String');
trialStartEnd(1) = str2num(get(handles.SoloStartTrialNo, 'String'));
trialStartEnd(2) = str2num(get(handles.SoloEndTrialNo, 'String'));
trailsToBeExcluded = str2num(get(handles.behavTrialNoToBeExcluded, 'String'));

[Solo_data, SoloFileName] = Solo.load_data_nx(mouseName, sessionName,trialStartEnd,Solopath);
set(handles.SoloDataFileName, 'String', SoloFileName);
behavTrialNums = trialStartEnd(1):trialStartEnd(2);
behavTrialNums(trailsToBeExcluded) = [];

if length(behavTrialNums) ~= str2num(get(handles.TotTrialNum, 'String'))
    error('Number of behavior trials NOT equal to Number of Ca Image Trials!')
end

for i = 1:length(behavTrialNums)
    behavTrials(i) = Solo.BehavTrial_nx(Solo_data,behavTrialNums(i),1);
    CaSignal.CaTrials(i).behavTrial = behavTrials(i);
end
disp([num2str(i) ' Behavior Trials added to CaSignal.CaTrials']);
set(handles.msgBox, 'String', [num2str(i) ' Behavior Trials added to CaSignal.CaTrials']);
guidata(hObject, handles)


function SoloSessionName_Callback(hObject, eventdata, handles)

Solopath = get(handles.SoloDataPath,'String');
mouseName = get(handles.AnimalNameEdit, 'String');
sessionName = get(handles.SoloSessionName, 'String');
trialStartEnd(1) = str2num(get(handles.SoloStartTrialNo, 'String'));
trialStartEnd(2) = str2num(get(handles.SoloEndTrialNo, 'String'));

[Solo_data, SoloFileName] = Solo.load_data_nx(mouseName, sessionName,trialStartEnd,Solopath);
set(handles.SoloDataFileName, 'String', SoloFileName);


% --- Executes during object creation, after setting all properties.
function SoloSessionName_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function dispModeImageInfoButton_CreateFcn(hObject, eventdata, handles)


% --- Executes on button press in ROI_move_left.
function ROI_move_left_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(CaSignal.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
move_unit = 1* max(aspect_ratio,1);
if get(handles.ROI_move_all_check, 'Value') == 1
    roi_num_to_move = 1: length(CaSignal.ROIinfo(TrialNo).ROIpos);
else
    roi_num_to_move = str2num(get(handles.CurrentROINoEdit,'String'));
end
for i = roi_num_to_move
    CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1)-move_unit;
    CaSignal.ROIinfoBack(1).ROIpos{i}(:,1) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1)-move_unit;
    x = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1);
    y = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2);
    CaSignal.ROIinfo(TrialNo).ROImask{i} = poly2mask(x,y,imsize(1),imsize(2));
    CaSignal.ROIinfoBack(1).ROImask{i} = CaSignal.ROIinfo(TrialNo).ROImask{i};
end;
update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles);


% --- Executes on button press in ROI_move_right.
function ROI_move_right_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs

TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(CaSignal.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
move_unit = 1* max(aspect_ratio,1);
if get(handles.ROI_move_all_check, 'Value') == 1
    roi_num_to_move = 1: length(CaSignal.ROIinfo(TrialNo).ROIpos);
else
    roi_num_to_move = str2num(get(handles.CurrentROINoEdit,'String'));
end
for i = roi_num_to_move
    CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1)+move_unit;
    CaSignal.ROIinfoBack(1).ROIpos{i}(:,1) = CaSignal.ROIinfoBack(1).ROIpos{i}(:,1) + move_unit;
    x = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1);
    y = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2);
    CaSignal.ROIinfo(TrialNo).ROImask{i} = poly2mask(x,y,imsize(1),imsize(2));
    CaSignal.ROIinfoBack(1).ROImask{i} = CaSignal.ROIinfo(TrialNo).ROImask{i};
end;
update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles)

% --- Executes on button press in ROI_move_up.
function ROI_move_up_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(CaSignal.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
move_unit = 1* max(1/aspect_ratio,1);
if get(handles.ROI_move_all_check, 'Value') == 1
    roi_num_to_move = 1: length(CaSignal.ROIinfo(TrialNo).ROIpos);
else
    roi_num_to_move = str2num(get(handles.CurrentROINoEdit,'String'));
end
for i = roi_num_to_move
    CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2)-move_unit;
     CaSignal.ROIinfoBack(1).ROIpos{i}(:,2) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2)-move_unit;
    x = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1);
    y = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2);
    CaSignal.ROIinfo(TrialNo).ROImask{i} = poly2mask(x,y,imsize(1),imsize(2));
    CaSignal.ROIinfoBack(1).ROImask{i} = CaSignal.ROIinfo(TrialNo).ROImask{i};
end;
update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles)


% --- Executes on button press in ROI_move_down.
function ROI_move_down_Callback(hObject, eventdata, handles)

global CaSignal % ROIinfo ICA_ROIs
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
imsize = size(CaSignal.ImageArray);
aspect_ratio = imsize(2)/imsize(1);
move_unit = 1* max(1/aspect_ratio,1);
if get(handles.ROI_move_all_check, 'Value') == 1
    roi_num_to_move = 1: length(CaSignal.ROIinfo(TrialNo).ROIpos);
else
    roi_num_to_move = str2num(get(handles.CurrentROINoEdit,'String'));
end
for i = roi_num_to_move
    CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2)+move_unit;
    CaSignal.ROIinfoBack(1).ROIpos{i}(:,2) = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2)+move_unit;
    x = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,1);
    y = CaSignal.ROIinfo(TrialNo).ROIpos{i}(:,2);
    CaSignal.ROIinfo(TrialNo).ROImask{i} = poly2mask(x,y,imsize(1),imsize(2));
    CaSignal.ROIinfoBack(1).ROImask{i} = CaSignal.ROIinfo(TrialNo).ROImask{i};
end

update_ROI_plot(handles);
handles = update_projection_images(handles);
guidata(hObject, handles)



function behavTrialNoToBeExcluded_Callback(hObject, eventdata, handles)
% hObject    handle to behavTrialNoToBeExcluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of behavTrialNoToBeExcluded as text
%        str2double(get(hObject,'String')) returns contents of behavTrialNoToBeExcluded as a double


% --- Executes during object creation, after setting all properties.
function behavTrialNoToBeExcluded_CreateFcn(hObject, eventdata, handles)
% hObject    handle to behavTrialNoToBeExcluded (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.

function dFF_array = get_dFF_roi(CaSignal, roiNo)

nTrials = numel(CaSignal.CaTrials);
dFF_array = [];
for i = 1:nTrials
    if ~isempty(CaSignal.CaTrials(i).dff)
        if size(CaSignal.CaTrials(i).dff,1) < roiNo
            return;
        else
            dFF_array = [dFF_array; CaSignal.CaTrials(i).dff(roiNo,:)];
        end
    end
end
    
% --- Executes during object creation, after setting all properties.
function Image_disp_axes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to Image_disp_axes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate Image_disp_axes


% --- Executes during object creation, after setting all properties.
function msgBox_CreateFcn(hObject, eventdata, handles)
% hObject    handle to msgBox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on selection change in dispAspectRatio.
function dispAspectRatio_Callback(hObject, eventdata, handles)
global CaSignal % ROIinfo ICA_ROIs
Str = get(hObject, 'String');
CaSignal.AspectRatio_mode = Str{get(hObject,'Value')};
guidata(hObject, handles);
handles = update_image_axes(handles);



% --- Executes during object creation, after setting all properties.
function dispAspectRatio_CreateFcn(hObject, eventdata, handles)
% hObject    handle to dispAspectRatio (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function frame_time_disp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to frame_time_disp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in export2avi_button.
function export2avi_button_Callback(hObject, eventdata, handles)

global CaSignal
TrialNo = str2double(get(handles.CurrentTrialNo,'String'));
fname = CaSignal.CaTrials(TrialNo).FileName;
[movieFileName, pathname] = uiputfile([fname(1:end-4) '.avi'], 'Export current trial to an avi movie');
movObj = VideoWriter([pathname filesep movieFileName]);
movObj.FrameRate = 15;

open(movObj);

for i = 1:CaSignal.CaTrials(TrialNo).nFrames
    set(handles.CurrentFrameNoEdit,'String',num2str(i));
    handles = update_image_axes(handles);
    F = getframe(handles.Image_disp_axes);
    writeVideo(movObj, F);
end
close(movObj);
% movie2avi(Mov,[pathname filesep movieFileName],'compression','none');


% --- Executes when selected object is changed in ROI_def.
function ROI_def_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in ROI_def 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


% --- Executes during object creation, after setting all properties.
% function ICA_ROI_anal_CreateFcn(hObject, eventdata, handles)
% % hObject    handle to ICA_ROI_anal (see GCBO)
% % eventdata  reserved - to be defined in a future version of MATLAB
% % handles    empty - handles not created until after all CreateFcns called

% --- Executes on button press in ICA_ROI_anal.
% function ICA_ROI_anal_Callback(hObject, eventdata, handles)
% 
% global CaSignal % ROIinfo ICA_ROIs    
% if get(hObject, 'Value') == 1
%     % load_saved_data_SVD
%     if isempty(CaSignal.ImageArray)
%         error('No Imaging Data loaded. Do this before running ICA!');
%     end
%     % Display mean ICA map
%     if isfield(CaSignal, 'ICA_components') && ~isempty(CaSignal.ICA_components)
%         CaSignal.rois_by_IC = cell(1, size(CaSignal.ICA_components,1)) ;
%         IC_to_remove = inputdlg('IC to remove', 'Remove bad ICs');
%         if ~isempty(IC_to_remove)
%             IC_to_remove = str2num(IC_to_remove{1});
%             CaSignal.ICA_components(IC_to_remove,:) = NaN;
%         end
%         CaSignal.ICA_figs(3) = disp_mean_IC_map(CaSignal.ICA_components);
%     end
%     if isfield(CaSignal, 'ica_data') && ~isempty(CaSignal.ica_data.Data)
%         usr_confirm = questdlg('Display Max Projection of all data is slow and memory intensive. Continue?');
%         if strcmpi(usr_confirm, 'Yes')
% %             Data = LoadData(pwd,CaSignal.CaTrials(1).FileName_prefix,1:50);
%             [CaSignal.ICA_data_norm_max, CaSignal.ICA_figs(4)] = disp_maxDelta_rawData(Data);
%             [CaSignal.ICA_data_norm_max, CaSignal.ICA_figs(4)] = disp_maxDelta_rawData(CaSignal.ica_data.Data);
%             set(gcf,'Name',sprintf('MaxDelta of raw Data (%d~%d)',CaSignal.ica_data.FileNums(1),CaSignal.ica_data.FileNums(end)));
%         end
%     end
%     
%     [fn, pth] = uigetfile('*.mat', 'Load DATA SVD');
%     if fn == 0
%         return
%     end
%     ica_data = load(fullfile(pth,fn));
%     ica_data.Data = ICA_LoadData(ica_data.DataDir, ica_data.FileBaseName, ica_data.FileNums);
%     CaSignal.ica_data = ica_data;
%     CaSignal.currentIC = 1;
% %     handles.ica_data = ica_data;
% %     handles.ICA_datafile = fullfile(pth,fn);
% %     ICA_ROIs = struct;
%     guidata(hObject, handles);
%     runICA_button_Callback(handles.runICA_button, eventdata, handles);
% end


% % --- Executes on button press in prevIC_button.
% function prevIC_button_Callback(hObject, eventdata, handles)
% global CaSignal % ROIinfo ICA_ROIs
% if get(handles.ICA_ROI_anal,'Value') == 1 && CaSignal.currentIC > 1
%     CaSignal.currentIC = CaSignal.currentIC - 1;
%     set(handles.current_ICnum_text, 'String', num2str(CaSignal.currentIC));
% %     guidata(hObject, handles);
%     disp_ICA(handles);
% end


% --- Executes on button press in nextIC_button.
% function nextIC_button_Callback(hObject, eventdata, handles)
% global CaSignal  % ROIinfo ICA_ROIs
% if get(handles.ICA_ROI_anal,'Value') == 1 && CaSignal.currentIC < size(CaSignal.ICA_components,1)
%     CaSignal.currentIC = CaSignal.currentIC + 1;
%     set(handles.current_ICnum_text, 'String', num2str(CaSignal.currentIC));
%     guidata(hObject, handles);
%     disp_ICA(handles);
% end

% --- Executes on button press in runICA_button.
% function runICA_button_Callback(hObject, eventdata, handles)
% global CaSignal % ROIinfo ICA_ROIs
% data = CaSignal.ica_data.Data;
% V = CaSignal.ica_data.V;
% S = CaSignal.ica_data.S;
% ICnum = str2num(get(handles.IC_num_edit,'String'));
% % CaSignal.ICnum = str2num(get(handles.IC_num_edit,'String'));
% CaSignal.ICA_components = run_ICA(CaSignal.ica_data.Data, {S, V, 30, ICnum});
% CaSignal.rois_by_IC = cell(1,ICnum);
% % CaSignal.ICnum_prev = ICnum;
% 
% guidata(handles.figure1, handles);
% disp_ICA(handles);

% 
% function IC_num_edit_Callback(hObject, eventdata, handles)
% runICA_button_Callback(hObject, eventdata, handles);
% 

% --- Executes during object creation, after setting all properties.
% function IC_num_edit_CreateFcn(hObject, eventdata, handles)
% 
% if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
%     set(hObject,'BackgroundColor','white');
% end
% 
% function disp_ICA(handles)
% global CaSignal % ROIinfo ICA_ROIs
% RowNum = CaSignal.imSize(1);
% ColNum = CaSignal.imSize(2);
% if ~ishandle(CaSignal.ICA_figs)
%     CaSignal.ICA_figs(1) = figure('Position', [123   460   512   512]);
%     CaSignal.ICA_figs(2) = figure('Position',[115    28   512   512]);
% end
% disp_ICAcomponent_and_blobs(CaSignal.ICA_components(CaSignal.currentIC,:),RowNum, ColNum, CaSignal.ICA_figs);
% for i = 1:length(CaSignal.ICA_figs)
%     figure(CaSignal.ICA_figs(i)),
%     plot_ROIs(handles);
%     title(sprintf('IC #%d',CaSignal.currentIC),'FontSize',15);
% end
% 
% function fig = disp_mean_IC_map(IC)
% for i=1:size(IC,1), 
%     IC_norm(i,:) = (IC(i,:)- nanmean(IC(i,:)))./ nanstd(IC(i,:)); 
% end
% IC_norm_mean = nanmax(abs(IC),[],1); % mean(abs(IC_norm),1);
% clim = [0  max(IC_norm_mean)*0.7];
% fig = figure('Position', [123   372   512   512]);
% imagesc(reshape(IC_norm_mean, 128, 512), clim); 
% axis square;

function [data_norm_max,fig] = disp_maxDelta_rawData(data)
% each image data has to be already transformed to 1D
% normalize
data_cell = mat2cell(data,ones(1,size(data,1)));
clear data
data_cell_norm = cellfun(@(x) (x-mean(x))./std(x), data_cell, 'UniformOutput',false);
clear data_cell
data_norm = cell2mat(data_cell_norm);
% for i = 1:size(data,1)
%     data_norm(i,:) = (data(i,:) - mean(data(i,:)))./std(data(i,:));
% end
data_norm_max = max(data_norm,[],1);
clim = [0  max(data_norm_max)*0.7];
fig = figure('Position', [100   100   512   512]);
imagesc(reshape(data_norm_max, 128, 512), clim);
axis square;
% --- Executes during object creation, after setting all properties.
function current_ICnum_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to current_ICnum_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes on button press in ROI_load_button.
function ROI_load_button_Callback(hObject, eventdata, handles)
global CaSignal


% --------------------------------------------------------------------
function Load_Ca_results_Callback(hObject, eventdata, handles)
global CaSignal
[fn pathstr] = uigetfile('*.mat', 'Load Previous CaTrials results', CaSignal.results_path);

if ischar(fn)
    CaSignal.results_path = pathstr;
    CaSignal.results_fname = fullfile(pathstr, fn);
    prev_results = load(CaSignal.results_fname);
    CaSignal.CaTrials = prev_results.CaTrials;
end
handles = update_image_axes(handles);
update_projection_images(handles);

% --------------------------------------------------------------------
function Load_Callback(hObject, eventdata, handles)
% hObject    handle to Load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function Load_ROIinfo_Callback(hObject, eventdata, handles)
global CaSignal
[fn pathstr] = uigetfile('*.mat', 'Load saved ROI info', CaSignal.results_path);

if ischar(fn)
    CaSignal.ROIinfo_fname = fullfile(pathstr, fn);
    load(CaSignal.ROIinfo_fname);
    load_ROIinfo(ROIinfo, handles);    
end

handles = update_image_axes(handles);
update_projection_images(handles);


% --------------------------------------------------------------------
function load_ROIinfo(ROIinfo, handles)
global CaSignal
if iscell(ROIinfo)
    f1 = fieldnames(ROIinfo{1}); f2 = fieldnames(CaSignal.ROIinfo);
    for i = 1:length(ROIinfo)
        for j = 1:length(f1)
            CaSignal.ROIinfo(i).(f2{strcmpi(f2,f1{j})}) = ROIinfo{i}.(f1{j});
        end
    end
else
    CaSignal.ROIinfo = ROIinfo;
end
nROIs_allTrials = arrayfun(@(x) length(x.ROIpos), ROIinfo);

set(handles.nROIsText, 'String', num2str(max(nROIs_allTrials)));


% --------------------------------------------------------------------
% function Load_ICA_results_Callback(hObject, eventdata, handles)
% global CaSignal
% [fn pathstr] = uigetfile('*.mat','Load saved ICA results');
% if ischar(fn)
%     load(fullfile(pathstr, fn)); % load ICA_results
%     fprintf('ICA_results of %s loaded!\n', ICA_results.FileBaseName);
%     CaSignal.ICA_components = ICA_results.ICA_components;
%     CaSignal.currentIC = 1;
%     disp_ICA(handles)
% end



function current_ICnum_text_Callback(hObject, eventdata, handles)
global CaSignal  
newIC_No = str2num(get(hObject, 'String'));
if newIC_No <= size(CaSignal.ICA_components,1)
    CaSignal.currentIC = newIC_No;
    guidata(hObject, handles);
    disp_ICA(handles);
end


% --- Executes on button press in maxDelta_only_button.
function maxDelta_only_button_Callback(hObject, eventdata, handles)
global CaSignal
% if get(hObject,'Value') == 1
%     [fn, pth] = uigetfile('*.mat','Load Max Delta Image Array');
%     
%     
% end


% --- Executes during object creation, after setting all properties.
function ROI_def_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROI_def (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over ROI_modify_button.
function ROI_modify_button_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to ROI_modify_button (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)



function roiNo_to_plot_Callback(hObject, eventdata, handles)
% hObject    handle to roiNo_to_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of roiNo_to_plot as text
%        str2double(get(hObject,'String')) returns contents of roiNo_to_plot as a double


% --- Executes during object creation, after setting all properties.
function roiNo_to_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to roiNo_to_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in check_plotAllROIs.
function check_plotAllROIs_Callback(hObject, eventdata, handles)
% hObject    handle to check_plotAllROIs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of check_plotAllROIs


% --- Executes when selected object is changed in uipanel1.
function uipanel1_SelectionChangeFcn(hObject, eventdata, handles)
% hObject    handle to the selected object in uipanel1 
% eventdata  structure with the following fields (see UIBUTTONGROUP)
%	EventName: string 'SelectionChanged' (read only)
%	OldValue: handle of the previously selected object or empty if none was selected
%	NewValue: handle of the currently selected object
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in import_ROI_from_Trial_checkbox.
function import_ROI_from_Trial_checkbox_Callback(hObject, eventdata, handles)
% hObject    handle to import_ROI_from_Trial_checkbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of import_ROI_from_Trial_checkbox


% --- Executes on button press in AnalysisModeDeltaFF.
function AnalysisModeDeltaFF_Callback(hObject, eventdata, handles)
% hObject    handle to AnalysisModeDeltaFF (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of AnalysisModeDeltaFF


% --- Executes on button press in ROI_move_all_check.
function ROI_move_all_check_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_move_all_check (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROI_move_all_check



function CurrentImageFilenameText_Callback(hObject, eventdata, handles)
% hObject    handle to CurrentImageFilenameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of CurrentImageFilenameText as text
%        str2double(get(hObject,'String')) returns contents of CurrentImageFilenameText as a double


% --- Executes during object creation, after setting all properties.
function CurrentImageFilenameText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentImageFilenameText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function CurrentTrialNo_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentTrialNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes during object creation, after setting all properties.
function ImageJPathET_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CurrentTrialNo (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
if exist('D:\Fiji.app\ImageJ-win64.exe','file')
    set(hObject,'String','D:\Fiji.app\ImageJ-win64.exe');
end

function ImageJPathB_Callback(hObject, eventdata, handles)
global CaSignal
[fn,fp,fi] = uigetfile('*.exe','Please select you iamge app position');
if fi
    ImagjPathFull = fullfile(fp,fn);
    set(handles.ImageJPathET,'String',ImagjPathFull);
    CaSignal.OpenWithImagJ = 1;
else
    CaSignal.OpenWithImagJ = 0;
    return;
end

function OpenInImageJ_Callback(hObject, eventdata, handles)
% button down function
global CaSignal
CurrentTrials = CaSignal.CurrentTrialNo;
CurrentFile = fullfile(CaSignal.data_path,CaSignal.data_file_names{CurrentTrials});
ImageJPath = get(handles.ImageJPathET,'String');
if exist(ImageJPath,'file') && strcmp(ImageJPath(end-3:end),'.exe')
    system([ImageJPath ' ' CurrentFile]);
else
    fprintf('ImageJ file doean''t exists, please select your app position.\n');
    ImageJPathB_Callback(hObject, eventdata, handles);
    if CaSignal.OpenWithImagJ
        OpenInImageJ_Callback(hObject, eventdata, handles);
    end
end



function ImageJPathET_Callback(hObject, eventdata, handles)
% hObject    handle to ImageJPathET (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of ImageJPathET as text
%        str2double(get(hObject,'String')) returns contents of ImageJPathET as a double


% --- Executes on button press in ExcludeCTr.
function ExcludeCTr_Callback(hObject, eventdata, handles)
% hObject    handle to ExcludeCTr (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global CaSignal
cTrNum = CaSignal.CurrentTrialNo;
CheckState = get(hObject,'Value');
if CheckState
    CaSignal.IsTrialExcluded(cTrNum) = true;
    fprintf('Trial number %d will be excluded from further analysis.\n',cTrNum);
else
    CaSignal.IsTrialExcluded(cTrNum) = false;
    fprintf('Trial number %d will be included for further analysis.\n',cTrNum);
end

% Hint: get(hObject,'Value') returns toggle state of ExcludeCTr


% --- Executes during object creation, after setting all properties.
function cTrFrameNum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cTrFrameNum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called


% --- Executes during object creation, after setting all properties.
function cTrFNumDisp_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cTrFNumDisp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'ForegroundColor','r','FontSize',10);

% --- Executes on key press with focus on figure1 or any of its controls.
function figure1_WindowKeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure1 (see GCBO)
% eventdata  structure with the following fields (see MATLAB.UI.FIGURE)
%	Key: name of the key that was pressed, in lower case
%	Character: character interpretation of the key(s) that was pressed
%	Modifier: name(s) of the modifier key(s) (i.e., control, shift) pressed
% handles    structure with handles and user data (see GUIDATA)
switch eventdata.Key   %'uparrow','downarrow','leftarrow','rightarrow'.
    case 'rightarrow'
        NextTrialButton_Callback(hObject, eventdata, handles);
    case 'leftarrow'
        PrevTrialButton_Callback(hObject, eventdata, handles);
    case 'downarrow'
        TwoStepNextTrial_Callback(hObject, eventdata, handles);
    case 'uparrow'
        TwoStepPreTrial_Callback(hObject, eventdata, handles);
    case 'a'
        % add new ROI
        ROI_add_Callback(hObject, eventdata, handles);
    case 's'
        % set ROI
        Set_ROI_button_Callback(hObject, eventdata, handles)
    otherwise
%         fprintf('Key pressed without response.\n');
end


% --- Executes on button press in NewROITag.
function NewROITag_Callback(hObject, eventdata, handles)
global CaSignal
% hObject    handle to NewROITag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
cTagValue = get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of NewROITag
if cTagValue
    set(handles.OldROITag,'Value',0);
    set(handles.MissROITag,'Value',0);
else
    if ~(get(handles.OldROITag,'Value') || get(handles.MissROITag,'Value'))
        warning('No Valide ROI state indicator, using default value');
        set(handles.NewROITag,'Value',1);
    end
end
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
CaSignal.ROIStateIndicate(CurrentROINo,:) = [get(handles.NewROITag,'Value'),...
    get(handles.OldROITag,'Value'),get(handles.MissROITag,'Value')];


% --- Executes on button press in OldROITag.
function OldROITag_Callback(hObject, eventdata, handles)
global CaSignal
% hObject    handle to OldROITag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
if get(hObject,'Value')
    set(handles.NewROITag,'Value',0);
    set(handles.MissROITag,'Value',0);
else
    if get(handles.NewROITag,'Value')
        set(handles.NewROITag,'Value',1);
    end
end
% Hint: get(hObject,'Value') returns toggle state of OldROITag
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
CaSignal.ROIStateIndicate(CurrentROINo,:) = [get(handles.NewROITag,'Value'),...
    get(handles.OldROITag,'Value'),get(handles.MissROITag,'Value')];



% --- Executes on button press in MissROITag.
function MissROITag_Callback(hObject, eventdata, handles)
global CaSignal
% hObject    handle to MissROITag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hint: get(hObject,'Value') returns toggle state of MissROITag
if get(hObject,'Value')
    set(handles.NewROITag,'Value',0);
    set(handles.OldROITag,'Value',0);
else
    if get(handles.NewROITag,'Value')
        set(handles.NewROITag,'Value',1);
    end
end
CurrentROINo = str2double(get(handles.CurrentROINoEdit, 'String'));
CaSignal.ROIStateIndicate(CurrentROINo,:) = [get(handles.NewROITag,'Value'),...
    get(handles.OldROITag,'Value'),get(handles.MissROITag,'Value')];


% --- Executes on button press in ROI_draw_freehand.
function ROI_draw_freehand_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_draw_freehand (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROI_draw_freehand


% --- Executes on button press in ROI_draw_poly.
function ROI_draw_poly_Callback(hObject, eventdata, handles)
% hObject    handle to ROI_draw_poly (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of ROI_draw_poly


% --- Executes on button press in IsConAcqCheck.
function IsConAcqCheck_Callback(hObject, eventdata, handles)
global CaSignal
% hObject    handle to IsConAcqCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IsContiAcq = get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of IsConAcqCheck
if IsContiAcq
    CaSignal.ContAcqCheck = 1;
else
    CaSignal.ContAcqCheck = 0;
end


% --- Executes on button press in AutoZoomCheck.
function AutoZoomCheck_Callback(hObject, eventdata, handles)
global CaSignal
% hObject    handle to AutoZoomCheck (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
IsAutoZoom = get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of AutoZoomCheck
if IsAutoZoom
     CaSignal.IsAutozoom = 1;
else
    CaSignal.IsAutozoom = 0;
end
