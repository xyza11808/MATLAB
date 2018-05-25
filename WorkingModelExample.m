function varargout = WorkingModelExample(varargin)
% WORKINGMODELEXAMPLE MATLAB code for WorkingModelExample.fig
%      WORKINGMODELEXAMPLE, by itself, creates a new WORKINGMODELEXAMPLE or raises the existing
%      singleton*.
%
%      H = WORKINGMODELEXAMPLE returns the handle to a new WORKINGMODELEXAMPLE or the handle to
%      the existing singleton*.
%
%      WORKINGMODELEXAMPLE('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in WORKINGMODELEXAMPLE.M with the given input arguments.
%
%      WORKINGMODELEXAMPLE('Property','Value',...) creates a new WORKINGMODELEXAMPLE or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before WorkingModelExample_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to WorkingModelExample_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help WorkingModelExample

% Last Modified by GUIDE v2.5 18-May-2018 12:02:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @WorkingModelExample_OpeningFcn, ...
                   'gui_OutputFcn',  @WorkingModelExample_OutputFcn, ...
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


% --- Executes just before WorkingModelExample is made visible.
function WorkingModelExample_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to WorkingModelExample (see VARARGIN)
global WorkModelPara
WorkModelPara.CategROINum = 11; % 
WorkModelPara.BoundScale = [-0.5,0.5];
WorkModelPara.CategROIparas = [0,0,0.2];  % [g, l, v]
WorkModelPara.modelfunb = @(g,l,u,v,x) g+(1-g-l)*0.5*(1+erf((x-u)/sqrt(2*v^2)));
WorkModelPara.gausCategFun = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
WorkModelPara.gausCategParaDef = [1,0.2,0];
WorkModelPara.CategNeuType = 'Sigmoidal';  % 'Sigmoidal' or 'Gaussian'
WorkModelPara.LCategFun = {};
WorkModelPara.RCategFun = {};
WorkModelPara.xDataNumUsed = 500;
WorkModelPara.xRange = linspace(-1,1,WorkModelPara.xDataNumUsed);
WorkModelPara.PopuChoiceData = [];
WorkModelPara.UncertainFun = 'Tuning';
WorkModelPara.UncertainFunCurve = [];
WorkModelPara.ChoiceDerivetiveFun = [];
WorkModelPara.ChoiceFitLim = [];
WorkModelPara.DeriveFun = [];
WorkModelPara.LRPopuRawData = {[],[]};
WorkModelPara.LRPopuRawFig = [];
WorkModelPara.Weights = 1/WorkModelPara.CategROINum;
WorkModelPara.IsRandWid = 0;
WorkModelPara.WidTypes = [];
WorkModelPara.WidTypeFrac = [];
WorkModelPara.SlopeV = [];
WorkModelPara.BaseROITypes = [0.1,0.14,0.41,0.35];
WorkModelPara.BaseROITypeStrs = {'Categ','BoundTun','SensTun','NoiseTun'};
WorkModelPara.CategGauWeights = [0.5,0.5];

cROIparas = WorkModelPara.CategROIparas;
set(handles.CategROIsAxes,'Visible','off');
set(handles.RawCategROIOutput,'Visible','off');
set(handles.ROINum,'string',num2str(WorkModelPara.CategROINum));
set(handles.ROIparasTag,'String',sprintf('%.1f,%.1f,%.3f',cROIparas(1),cROIparas(2),cROIparas(3)));
set(handles.ROIboundLow,'String',num2str(WorkModelPara.BoundScale(1),'%.4f'));
set(handles.ROIboundHigh,'String',num2str(WorkModelPara.BoundScale(2),'%.4f'));
set(handles.xDataNums,'String',num2str(WorkModelPara.xDataNumUsed,'%d'));
set(handles.PoolSumDataPlot,'Value',0);

% #####################################################
% generate bound Tuning function
BoundTunFunParaDef = [0 0 0 0.15];
syms b o p s y  % symbols in sorted sequence, or the 'matlabFuntion' function will change the sequence of given cofficiences
cFun = WorkModelPara.modelfunb(b, o, p, s, y);
UncertainFunDerivt = diff(cFun,y);
BoundTunFunStrc.Paras = BoundTunFunParaDef;
BoundTunFunStrc.Fun = matlabFunction(UncertainFunDerivt);
WorkModelPara.BoundTunTuningFuns = BoundTunFunStrc;

% generate step tuning function
StepTunFunParaDef = [1,2];
StepTunFunScale = [-0.5,0.5];
StepTunFunStrc.ValueScale = StepTunFunParaDef;
StepTunFunStrc.xScales = StepTunFunScale;
StepTunFunStrc.Fun = @(StepTunFunParaDef,StepTunFunScale,x) StepFun(StepTunFunParaDef,StepTunFunScale,x);
WorkModelPara.StepTunFuns = StepTunFunStrc;

% generate scaled boundary tuning function
ScaleBoundTunDef = [0 0 0 0.15];
ScaleBoundTunScale = [-0.5 0.5];
ScaleBoundFunStrc.TunParas = ScaleBoundTunDef;
ScaleBoundFunStrc.TunxScales = ScaleBoundTunScale;
ScaleBoundFunStrc.Fun = @(ScaleBoundTunDef,ScaleBoundTunScale,x) ScaleBoundTunF(ScaleBoundTunDef,ScaleBoundTunScale,x);
WorkModelPara.ScaleBoundFuns = ScaleBoundFunStrc;

% Gaussian uncertainty function
GaussParasDef = [2 0 0.4 1];
GaussModuScale = [-0.5 0.5];
% GaussianFunc = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
ScaleBoundFunStrc.GauParas = GaussParasDef;
ScaleBoundFunStrc.GauModuScale = GaussModuScale;
ScaleBoundFunStrc.GauFun = @(GauParas,GauModuScale,x) GaussScaleFun(GauParas,GauModuScale,x);
WorkModelPara.GauTunFuns = ScaleBoundFunStrc;
% CurveAll = GaussScaleFun(GaussParaDEFs,ModuScale,x)

% update uncertainty function
UncertaintyFunUpdate(handles);
% #######################################################
% Choose default command line output for WorkingModelExample
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes WorkingModelExample wait for user response (see UIRESUME)
% uiwait(handles.figure1);

function ffAll = ScaleBoundTunF(BoundTunDef,ModuScale,t)
global WorkModelPara
ffAll = zeros(length(t),1);
ModuScale = sort(ModuScale);
syms y
cFun = WorkModelPara.modelfunb(BoundTunDef(1),BoundTunDef(2),BoundTunDef(3),BoundTunDef(4),y);
RealModuScale = ModuScale + BoundTunDef(3);
UncertainFunDerivt = diff(cFun);
for ctn = 1 : length(t)
    
    if t(ctn) < RealModuScale(1)
        ff = 1;
    elseif t(ctn) < RealModuScale(2)
        
        ff = double(subs(UncertainFunDerivt,t(ctn))) + 1;
    else
        ff = 1;
    end
    ffAll(ctn) = ff;
end

function fAll = StepFun(MaxMinV,Scale,t)
Scale = sort(Scale);
fAll = zeros(length(t),1);
for ctn = 1 : length(t)
    
    if t(ctn) < Scale(1)
        f = min(MaxMinV);
    elseif t(ctn) < Scale(2)
        f = max(MaxMinV);
    else
        f = min(MaxMinV);
    end
    fAll(ctn) = f;
end

function CurveAll = GaussScaleFun(GaussParaDEFs,ModuScale,x)
% function for scale-modulated gaussian function
% WorkModelPara.gausCategFun = @(c1,c2,c3,c4,x) c1*exp((-1)*((x - c2).^2)./(2*(c3^2)))+c4;
global WorkModelPara
Scale = sort(ModuScale);
RealScale = Scale + GaussParaDEFs(2);
% fAll = zeros(numel(x),1);
CurveAll = WorkModelPara.gausCategFun(GaussParaDEFs(1),GaussParaDEFs(2),GaussParaDEFs(3),GaussParaDEFs(4),x);
OutScaleInds = x < RealScale(1) | x > RealScale(2);
CurveAll(OutScaleInds) = 1;


function UncertaintyFunUpdate(handles)
% this function used for update the uncertainty function curve
global WorkModelPara
FunctionType = WorkModelPara.UncertainFun;
switch FunctionType
    case 'Tuning'
        % Normal Scale Bound tuning function
        set(handles.TuningParaGrs,'visible','on');
        set(handles.StepFunParas,'visible','off');
        set(handles.AmplifParas,'visible','off');
        set(handles.GaussParasGroup,'visible','off');
        
        cParas = WorkModelPara.BoundTunTuningFuns.Paras;
        
        Curve = WorkModelPara.BoundTunTuningFuns.Fun(cParas(1),cParas(2),cParas(3),cParas(4),WorkModelPara.xRange);
%         Curve = cfunc(WorkModelPara.xRange);
        axes(handles.UncertaintyCurve);
        cla;
        plot(WorkModelPara.xRange,Curve,'Color','m','linewidth',1.4);
        title('Modu curve');
        
        
        set(handles.TuningFun_Para,'String',sprintf('%.2f,%.2f,%.2f,%.2f',cParas(1),cParas(2),cParas(3),cParas(4)));
        
    case 'Step'
        % Step Tuning Fun
        set(handles.TuningParaGrs,'visible','off');
        set(handles.AmplifParas,'visible','off');
        set(handles.StepFunParas,'visible','on');
        set(handles.GaussParasGroup,'visible','off');
        
        cValueParas = WorkModelPara.StepTunFuns.ValueScale;
        cxScales = WorkModelPara.StepTunFuns.xScales;
        cfunc = WorkModelPara.StepTunFuns.Fun;
        
        Curve = cfunc(cValueParas,cxScales,WorkModelPara.xRange);
        axes(handles.UncertaintyCurve);
        cla;
        plot(WorkModelPara.xRange,Curve,'Color','m','linewidth',1.4);
        title('Modu curve');
        
        
        set(handles.StepScaleData,'String',sprintf('%.2f,%.2f',cxScales(1),cxScales(2)));
        set(handles.StepValues,'String',sprintf('%.2f,%.2f',cValueParas(1),cValueParas(2)));
    case 'Amplif'
        % scaled Bound Tuning fun
        set(handles.TuningParaGrs,'visible','off');
        set(handles.StepFunParas,'visible','off');
        set(handles.AmplifParas,'visible','on');
        set(handles.GaussParasGroup,'visible','off');
        
        cValueParas = WorkModelPara.ScaleBoundFuns.TunParas;
        cScales = WorkModelPara.ScaleBoundFuns.TunxScales;
        cfunc = WorkModelPara.ScaleBoundFuns.Fun;
        
        Curve = cfunc(cValueParas,cScales,WorkModelPara.xRange);
        axes(handles.UncertaintyCurve);
        cla;
        plot(WorkModelPara.xRange,Curve,'Color','m','linewidth',1.4);
        title('Modu curve');
        
        
        set(handles.AmplifTunPara,'String',sprintf('%.2f,%.2f,%.2f,%.2f',cValueParas(1),cValueParas(2),cValueParas(3),cValueParas(4)));
        set(handles.AmplifTunScale,'String',sprintf('%.2f,%.2f',cScales(1),cScales(2)));
        
    case 'Gaussian'
        % Guassian function uncertainty function
        set(handles.TuningParaGrs,'visible','off');
        set(handles.StepFunParas,'visible','off');
        set(handles.AmplifParas,'visible','off');
        set(handles.GaussParasGroup,'visible','on');
        
        cValueParas = WorkModelPara.GauTunFuns.GauParas;
        cScales = WorkModelPara.GauTunFuns.GauModuScale;
        cfunc = WorkModelPara.GauTunFuns.GauFun;
        
        Curve = cfunc(cValueParas,cScales,WorkModelPara.xRange);
        axes(handles.UncertaintyCurve);
        cla;
        plot(WorkModelPara.xRange,Curve,'Color','m','linewidth',1.4);
        title('Modu curve');
        
        set(handles.GaussFunPara,'String',sprintf('%.2f,%.2f,%.2f,%.2f',cValueParas(1),cValueParas(2),cValueParas(3),cValueParas(4)));
        set(handles.GauModuScale,'String',sprintf('%.2f,%.2f',cScales(1),cScales(2)));
        
    otherwise
        warning('Error uncertainty Function type.');
        Curve = [];
%         return;
end
WorkModelPara.UncertainFunCurve = Curve;

% --- Outputs from this function are returned to the command line.
function varargout = WorkingModelExample_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function ROINum_Callback(hObject, eventdata, handles)
% hObject    handle to ROINum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
ROINum = str2num(get(hObject,'String'));
if ~isnumeric(ROINum)
    warning('Inputt should be a numeric number.');
    return;
else
    if isempty(ROINum) || ROINum < 3
        warning('ROI number should not be less than 3.');
        return;
    else
        WorkModelPara.CategROINum = ROINum;
    end
end
% BoundFracData_Callback(hObject, eventdata, handles)
CategROICal_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of ROINum as text
%        str2double(get(hObject,'String')) returns contents of ROINum as a double


% --- Executes during object creation, after setting all properties.
function ROINum_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROINum (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROIparasTag_Callback(hObject, eventdata, handles)
% hObject    handle to ROIparasTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara

CategROIPara = str2num(get(hObject,'String'));
if ~isnumeric(CategROIPara)
    warning('Inputt should be a numeric number.');
    return;
else
    if length(CategROIPara) ~= 3
        warning('Error length of input parameters');
        return;
    else
        cCategROITYpe = WorkModelPara.CategNeuType;
        switch cCategROITYpe
            case 'Sigmoidal'
                WorkModelPara.CategROIparas = CategROIPara;
            case 'Gaussian'
                WorkModelPara.gausCategParaDef = CategROIPara;
            otherwise
                warning('Unknown categROI base function type');
        end
    end
end

CategROICal_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of ROIparasTag as text
%        str2double(get(hObject,'String')) returns contents of ROIparasTag as a double


% --- Executes during object creation, after setting all properties.
function ROIparasTag_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIparasTag (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROIboundLow_Callback(hObject, eventdata, handles)
% hObject    handle to ROIboundLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
BoundLow = str2num(get(hObject,'String'));
if ~isnumeric(BoundLow)
    warning('Input should be a numeric number.');
    return;
else
    if isempty(BoundLow) || abs(BoundLow) >= 1
        warning('The ABS bound Value should not be less than 1.');
        return;
    else
        WorkModelPara.BoundScale(1) = BoundLow;
    end
end
CategROICal_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of ROIboundLow as text
%        str2double(get(hObject,'String')) returns contents of ROIboundLow as a double


% --- Executes during object creation, after setting all properties.
function ROIboundLow_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIboundLow (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function ROIboundHigh_Callback(hObject, eventdata, handles)
% hObject    handle to ROIboundHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
BoundHigh = str2num(get(hObject,'String'));
if ~isnumeric(BoundHigh)
    warning('Input should be a numeric number.');
    return;
else
    if isempty(BoundHigh) || abs(BoundHigh) >= 1
        warning('The ABS bound Value should not be less than 1.');
        return;
    else
        WorkModelPara.BoundScale(2) = BoundHigh;
    end
end
CategROICal_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of ROIboundHigh as text
%        str2double(get(hObject,'String')) returns contents of ROIboundHigh as a double


% --- Executes during object creation, after setting all properties.
function ROIboundHigh_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIboundHigh (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in CategROICal.
function CategROICal_Callback(hObject, eventdata, handles)
% hObject    handle to CategROICal (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara

nROIs = WorkModelPara.CategROINum;
xDataNum = WorkModelPara.xDataNumUsed;
set(handles.CategROIsAxes,'Visible','on');
set(handles.RawCategROIOutput,'Visible','on');
CategModel = WorkModelPara.modelfunb;
switch WorkModelPara.CategNeuType
    case 'Sigmoidal'

        RPreferBound = linspace(WorkModelPara.BoundScale(1),WorkModelPara.BoundScale(2),nROIs);
        LPreferBound = linspace(WorkModelPara.BoundScale(1),WorkModelPara.BoundScale(2),nROIs);
        g = WorkModelPara.CategROIparas(1);
        l = WorkModelPara.CategROIparas(2);
        v = WorkModelPara.CategROIparas(3);
        cSlope = (-1)*sqrt(2)*0.5*(g+l-1)/(sqrt(pi)*v);
        nCategROI = length(RPreferBound);
        RPrefCategFun = cell(nCategROI,1);
        LPrefCategFun = cell(nCategROI,1);
        for cROI = 1 : nCategROI
            RPrefCategFun{cROI} = @(x) CategModel(g,l,RPreferBound(cROI),v,x);
            LPrefCategFun{cROI} = @(x) 1 - CategModel(g,l,LPreferBound(cROI),v,x);
        end
        WorkModelPara.LCategFun = LPrefCategFun;
        WorkModelPara.RCategFun = RPrefCategFun;
        xRange = linspace(-1,1,xDataNum);
        WorkModelPara.xRange = xRange;

        % Test categorical ROI function
        axes(handles.CategROIsAxes);
        hold on
        cla
        for cROI = 1 : nCategROI
            cRFun = RPrefCategFun{cROI};
            cLFun = LPrefCategFun{cROI};
            cRCurve = cRFun(xRange);
            cLCurve = cLFun(xRange);
            plot(xRange,cRCurve,'r','linewidth',1.6);
            plot(xRange,cLCurve,'b','linewidth',1.6);
        end
        text(0.7,0.5,sprintf('%.2f',cSlope),'FontSize',8);
        title(sprintf('nROI = %d',nROIs));

        xData = xRange;
        RDataCell = cell(nCategROI,1);
        LDataCell = cell(nCategROI,1);
        for cROI = 1 : nCategROI
            cRFun = RPrefCategFun{cROI};
            cLFun = LPrefCategFun{cROI};
            RDataCell{cROI} = cRFun(xData);
            LDataCell{cROI} = cLFun(xData);
        end
        RDataMtx = cell2mat(RDataCell);
        LDataMtx = cell2mat(LDataCell);

        ChoiceData = (sum(RDataMtx) - sum(LDataMtx))/nCategROI;
        
        WorkModelPara.LRPopuRawData{1} = sum(LDataMtx)/nCategROI;
        WorkModelPara.LRPopuRawData{2} = sum(RDataMtx)/nCategROI;
        
    case 'Gaussian'
        BoundFracData_Callback(hObject, eventdata, handles,0); % check if ROI fraction was biased
        cCategTunParas = WorkModelPara.gausCategParaDef;
        TuningPeakNum = nROIs;
        TunPeakData = linspace(-1,1,TuningPeakNum);
        if length(unique(WorkModelPara.Weights)) > 1
           WeightNum = TuningPeakNum * WorkModelPara.Weights;
           BiasFracTunNum = round(WeightNum(WeightNum > 1));
           BiasFracTun = find(WeightNum > 1);
           BiasROINum = sum(BiasFracTunNum);
           BiasTunPeak = zeros(1,BiasROINum); 
           k = 1;
           for cBias = 1 : length(BiasFracTunNum)
               BiasTunPeak(k:k + BiasFracTunNum(cBias)-1) = TunPeakData(BiasFracTun(cBias));
               k = k + BiasFracTunNum(cBias);
           end
           RestTunPeak = linspace(-1,1,TuningPeakNum - sum(BiasFracTunNum));
           UsedTunPeak = [BiasTunPeak,RestTunPeak];
           
        else
            UsedTunPeak = TunPeakData;
        end
        
        if ~WorkModelPara.IsRandWid
            %         TunPeakData = linspace(WorkModelPara.BoundScale(1),WorkModelPara.BoundScale(2),TuningPeakNum);
            TunROIFun = cell(TuningPeakNum,1);
            for cROI = 1 : TuningPeakNum
                TunROIFun{cROI} = @(x) WorkModelPara.gausCategFun(cCategTunParas(1),UsedTunPeak(cROI),cCategTunParas(2),cCategTunParas(3),x);
            end
        else
            if sum(WorkModelPara.WidTypeFrac) >= 1
                error('The rand ROI width fraction should not be more than 1');
            else
                nFracROIs = round(nROIs * WorkModelPara.WidTypeFrac);
                if sum(nFracROIs) > nROIs
                    error('ROINum exceed total ROI numbers');
                else
                    ROIWidTypes = [];
                    for cFrac = 1 : length(nFracROIs)
                        ROIWidTypes = [ROIWidTypes,repmat(WorkModelPara.WidTypes(cFrac),1,nFracROIs(cFrac))];
                    end
                    RestROINum = nROIs - sum(nFracROIs);
                    if RestROINum > 0
                        ExtraROIs = randsample(length(nFracROIs),RestROINum,true);
                        ROIWidTypes = [ROIWidTypes,WorkModelPara.WidTypes(ExtraROIs)];
                    end
                    UsedROIWidTypes = Vshuffle(ROIWidTypes);
                    
                    TunROIFun = cell(TuningPeakNum,1);
                    for cROI = 1 : TuningPeakNum
                        TunROIFun{cROI} = @(x) WorkModelPara.gausCategFun(cCategTunParas(1),UsedTunPeak(cROI),UsedROIWidTypes(cROI),cCategTunParas(3),x);
                    end
                end
            end
        end
        
        xscales = linspace(-1,1,xDataNum);
        BaseROIRespDataAll = cell(TuningPeakNum,1);
        UsedColor = jet(TuningPeakNum);
        axes(handles.CategROIsAxes)
        cla
        hold on
        for cROI = 1 : TuningPeakNum
            cROIFun = TunROIFun{cROI};
            cROIData = cROIFun(xscales);
            plot(xscales,cROIData,'Color',UsedColor(cROI,:),'linewidth',1.4);
            BaseROIRespDataAll{cROI} = cROIData * sign(UsedTunPeak(cROI));
        end
        % calculate the population output, left as negtive value
        popuOutData = sum(cell2mat(BaseROIRespDataAll));
        ChoiceData = (popuOutData - min(popuOutData))/(max(popuOutData) - min(popuOutData))*2-1; % norm to [-1 1]
        %%
        LROIInds = UsedTunPeak < 0;
        RROIInds = UsedTunPeak > 0;
        LPopuData = -sum(cell2mat(BaseROIRespDataAll(LROIInds)));
        RPopuData = sum(cell2mat(BaseROIRespDataAll(RROIInds)));
        WorkModelPara.LRPopuRawData{1} = LPopuData;
        WorkModelPara.LRPopuRawData{2} = RPopuData;
        
        %%
    case 'MixedPopu'
        % for mixed neuron types
        set(handles.MixedROIFrac,'Visible','on');
        set(handles.ROIFracStrs,'Visible','on');
        ROITypeFracStr = get(handles.MixedROIFrac,'String');
        ROITypeFrac = str2num(ROITypeFracStr);
         
        ROITypeNum = round(nROIs*ROITypeFrac);
        if sum(ROITypeNum) > nROIs
            ROITypeNum(4) = ROITypeNum(4) - sum(ROITypeNum) + nROIs;
        end
        if nROIs < 100
            warning('ROI number was low, Please increase the number of ROI used.\n');
        end
        
        %% calculate categprical ROI data
        cnCategROI = ROITypeNum(1);
        EachROINum = floor(cnCategROI/2);
        if EachROINum < 1
            warning('Not enough categprical ROI number');
            return;
        end
        RPreferBound = linspace(WorkModelPara.BoundScale(1),WorkModelPara.BoundScale(2),EachROINum);
        LPreferBound = linspace(WorkModelPara.BoundScale(1),WorkModelPara.BoundScale(2),EachROINum);
        g = WorkModelPara.CategROIparas(1);
        l = WorkModelPara.CategROIparas(2);
        v = WorkModelPara.CategROIparas(3);
        cSlope = (-1)*sqrt(2)*0.5*(g+l-1)/(sqrt(pi)*v);
        nCategROI = length(RPreferBound);
        RPrefCategFun = cell(nCategROI,1);
        LPrefCategFun = cell(nCategROI,1);
        for cROI = 1 : nCategROI
            RPrefCategFun{cROI} = @(x) CategModel(g,l,RPreferBound(cROI),v,x);
            LPrefCategFun{cROI} = @(x) 1 - CategModel(g,l,LPreferBound(cROI),v,x);
        end
        WorkModelPara.LCategFun = LPrefCategFun;
        WorkModelPara.RCategFun = RPrefCategFun;
        xRange = linspace(-1,1,xDataNum);
        WorkModelPara.xRange = xRange;
        
        axes(handles.CategROIsAxes)
        cla
        hold on
        RDataCell = cell(nCategROI,1);
        LDataCell = cell(nCategROI,1);
        for cROI = 1 : nCategROI
            cRFun = RPrefCategFun{cROI};
            cLFun = LPrefCategFun{cROI};
            RDataCell{cROI} = cRFun(xRange);
            LDataCell{cROI} = cLFun(xRange);
            plot(xRange,RDataCell{cROI},'r','Linewidth',1.2);
            plot(xRange,LDataCell{cROI},'b','Linewidth',1.2);
        end
        RDataMtx = cell2mat(RDataCell);
        LDataMtx = cell2mat(LDataCell);
        CategChoiceData = (sum(RDataMtx) - sum(LDataMtx))/nCategROI;
        
        %% processing Gaussian data
        cnGauNumber =  ROITypeNum(3);
         BoundFracData_Callback(hObject, eventdata, handles,0); % check if ROI fraction was biased
        cCategTunParas = WorkModelPara.gausCategParaDef;
        TuningPeakNum = cnGauNumber;
        TunPeakData = linspace(-1,1,TuningPeakNum);
        if length(unique(WorkModelPara.Weights)) > 1
           WeightNum = TuningPeakNum * WorkModelPara.Weights;
           BiasFracTunNum = round(WeightNum(WeightNum > 1));
           BiasFracTun = find(WeightNum > 1);
           BiasROINum = sum(BiasFracTunNum);
           BiasTunPeak = zeros(1,BiasROINum); 
           k = 1;
           for cBias = 1 : length(BiasFracTunNum)
               BiasTunPeak(k:k + BiasFracTunNum(cBias)-1) = TunPeakData(BiasFracTun(cBias));
               k = k + BiasFracTunNum(cBias);
           end
           RestTunPeak = linspace(-1,1,TuningPeakNum - sum(BiasFracTunNum));
           UsedTunPeak = [BiasTunPeak,RestTunPeak];
           
        else
            UsedTunPeak = TunPeakData;
        end
        
        if ~WorkModelPara.IsRandWid
            %         TunPeakData = linspace(WorkModelPara.BoundScale(1),WorkModelPara.BoundScale(2),TuningPeakNum);
            TunROIFun = cell(TuningPeakNum,1);
            for cROI = 1 : TuningPeakNum
                TunROIFun{cROI} = @(x) WorkModelPara.gausCategFun(cCategTunParas(1),UsedTunPeak(cROI),cCategTunParas(2),cCategTunParas(3),x);
            end
        else
            if sum(WorkModelPara.WidTypeFrac) >= 1
                error('The rand ROI width fraction should not be more than 1');
            else
                nFracROIs = round(cnGauNumber * WorkModelPara.WidTypeFrac);
                if sum(nFracROIs) > cnGauNumber
                    error('ROINum exceed total ROI numbers');
                else
                    ROIWidTypes = [];
                    for cFrac = 1 : length(nFracROIs)
                        ROIWidTypes = [ROIWidTypes,repmat(WorkModelPara.WidTypes(cFrac),1,nFracROIs(cFrac))];
                    end
                    RestROINum = cnGauNumber - sum(nFracROIs);
                    if RestROINum > 0
                        ExtraROIs = randsample(length(nFracROIs),RestROINum,true);
                        ROIWidTypes = [ROIWidTypes,WorkModelPara.WidTypes(ExtraROIs)];
                    end
                    UsedROIWidTypes = Vshuffle(ROIWidTypes);
                    
                    TunROIFun = cell(TuningPeakNum,1);
                    for cROI = 1 : TuningPeakNum
                        TunROIFun{cROI} = @(x) WorkModelPara.gausCategFun(cCategTunParas(1),UsedTunPeak(cROI),UsedROIWidTypes(cROI),cCategTunParas(3),x);
                    end
                end
            end
        end
        
        BaseROIRespDataAll = cell(TuningPeakNum,1);
        UsedColor = parula(TuningPeakNum);
%         axes(handles.CategROIsAxes)
%         cla
%         hold on
        for cROI = 1 : TuningPeakNum
            cROIFun = TunROIFun{cROI};
            cROIData = cROIFun(xRange);
            plot(xRange,cROIData,'Color',UsedColor(cROI,:),'linewidth',1.4);
            BaseROIRespDataAll{cROI} = cROIData * sign(UsedTunPeak(cROI));
        end
        % calculate the population output, left as negtive value
        PopuMtxData = cell2mat(BaseROIRespDataAll);
        popuOutData = sum(PopuMtxData);
        GauChoiceData = (popuOutData - min(popuOutData))/(max(popuOutData) - min(popuOutData))*2-1; % norm to [-1 1]
        %
        LROIInds = UsedTunPeak < 0;
        RROIInds = UsedTunPeak > 0;
        LPopuData = -sum(cell2mat(BaseROIRespDataAll(LROIInds)))/sum(LROIInds);
        RPopuData = sum(cell2mat(BaseROIRespDataAll(RROIInds)))/sum(RROIInds);
        
        LPopuDataNor = LPopuData / max(LPopuData);
        RPopuDataNor = RPopuData / max(RPopuData);
        
        LAvgData = mean(LDataMtx) * WorkModelPara.CategGauWeights(1) + LPopuDataNor * WorkModelPara.CategGauWeights(2);
        RAvgData = mean(RDataMtx) * WorkModelPara.CategGauWeights(1) + RPopuDataNor * WorkModelPara.CategGauWeights(2);
        
        WorkModelPara.LRPopuRawData{1} = LAvgData;
        WorkModelPara.LRPopuRawData{2} = RAvgData;
        
        %% adding noisy ROIs
%         NoisyROINum = ROITypeNum(4);
         WeightSums = CategChoiceData * WorkModelPara.CategGauWeights(1) + GauChoiceData * WorkModelPara.CategGauWeights(2);
         NorWeightsSum = (WeightSums - min(WeightSums))/(max(WeightSums) - min(WeightSums))*2 - 1;
         ChoiceData = NorWeightsSum;
        
        %%
    otherwise
        warning('Undefined baseROI type');
        return;
end

xData  = linspace(-1,1,xDataNum);
WorkModelPara.PopuChoiceData = ChoiceData;

SP = [min(ChoiceData),1-max(ChoiceData) - min(ChoiceData),0,1];
UL = [max(ChoiceData),max(ChoiceData),max(xData),100];
LM = [min(ChoiceData),min(ChoiceData),min(xData),1e-6];
WorkModelPara.ChoiceFitLim = [SP;UL;LM];

[ffit, gof] =fit(xData(:),ChoiceData(:),CategModel,'StartPoint',SP,'Upper',UL,'Lower',LM);
syms xValue
cChoiceFun = CategModel(ffit.g,ffit.l,ffit.u,ffit.v,xValue);
ChoiceFunDerivative = diff(cChoiceFun);
ChoiceSlopeData = double(subs(ChoiceFunDerivative,xData));
WorkModelPara.ChoiceDerivetiveFun = matlabFunction(ChoiceFunDerivative);
FitData = feval(ffit,xData(:));
[MaxSlope,MaxInds] = max(ChoiceSlopeData);

axes(handles.RawCategROIOutput);
yyaxis left
cla
yyaxis right
cla

yyaxis left
hold on
plot(xData,ChoiceData,'r','linewidth',1.5);
plot(xData,FitData,'c','linewidth',1.5);
ylabel('Raw');
set(gca,'ycolor','r')

yyaxis right
plot(xData,ChoiceSlopeData,'k','linewidth',1.6);
text(xData(MaxInds),MaxSlope+0.1,sprintf('BSlope = %.3f',MaxSlope),'Color',[0 0.7 0],'HorizontalAlignment','center');
ylabel('Slope')
set(gca,'ycolor','k')

set(handles.FinalPlot,'visible','on');
% calculate the derivetive function
syms Newg Newl Newu Newv Newx
NewFunc = WorkModelPara.modelfunb(ffit.g,ffit.l,Newu,Newv,Newx);  % upper and lower bound fixed
NewChoiceFunSlope = diff(NewFunc,Newx);
NewChoiceFunSlopehandle = matlabFunction(NewChoiceFunSlope);
WorkModelPara.DeriveFun = NewChoiceFunSlopehandle; % handles with five input request
WorkModelPara.ChoiceDataFitMD = ffit;

PoolSumDataPlot_Callback(hObject, eventdata, handles);

UncertaintyFunUpdate(handles);
if strcmpi(get(handles.SlopeChangeAxes,'visible'),'on')
    FinalPlot_Callback(hObject, eventdata, handles);
end

% --- Executes on selection change in BoundTunROIType.
function BoundTunROIType_Callback(hObject, eventdata, handles)
% hObject    handle to BoundTunROIType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
contents = cellstr(get(hObject,'String'));
cUncertainFunStr = contents{get(hObject,'Value')};
WorkModelPara.UncertainFun = cUncertainFunStr;

UncertaintyFunUpdate(handles);
if strcmpi(get(handles.SlopeChangeAxes,'visible'),'on')
    FinalPlot_Callback(hObject, eventdata, handles);
end
% Hints: contents = cellstr(get(hObject,'String')) returns BoundTunROIType contents as cell array
%        contents{get(hObject,'Value')} returns selected item from BoundTunROIType


% --- Executes during object creation, after setting all properties.
function BoundTunROIType_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoundTunROIType (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Tuning';'Step';'Amplif';'Gaussian'},'Value',1,'FontSize',12);



function xDataNums_Callback(hObject, eventdata, handles)
% hObject    handle to xDataNums (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
InputxDataNum = str2num(get(hObject,'String'));
if ~isnumeric(InputxDataNum)
    warning('Inputt should be a numeric number.');
    return;
else
    if isempty(InputxDataNum) || InputxDataNum < 3
        warning('ROI number should not be less than 3.');
        return;
    else
        WorkModelPara.xDataNumUsed = InputxDataNum;
    end
end

UncertaintyFunUpdate(handles);
WorkModelPara.xRange = linspace(-1,1,InputxDataNum);
CategROICal_Callback(hObject, eventdata, handles);

% Hints: get(hObject,'String') returns contents of xDataNums as text
%        str2double(get(hObject,'String')) returns contents of xDataNums as a double

% --- Executes during object creation, after setting all properties.
function xDataNums_CreateFcn(hObject, eventdata, handles)
% hObject    handle to xDataNums (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AmplifTunPara_Callback(hObject, eventdata, handles)
% hObject    handle to AmplifTunPara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
InputValues = str2num(get(hObject,'String'));
if isnumeric(InputValues)
    if length(InputValues) == 4
        WorkModelPara.ScaleBoundFuns.TunParas = InputValues;
    end
end
UncertaintyFunUpdate(handles);
if strcmpi(get(handles.SlopeChangeAxes,'visible'),'on')
    FinalPlot_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of AmplifTunPara as text
%        str2double(get(hObject,'String')) returns contents of AmplifTunPara as a double


% --- Executes during object creation, after setting all properties.
function AmplifTunPara_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AmplifTunPara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function AmplifTunScale_Callback(hObject, eventdata, handles)
% hObject    handle to AmplifTunScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
InputValues = str2num(get(hObject,'String'));
if isnumeric(InputValues)
    if length(InputValues) == 2 && max(abs(InputValues)) < 1
        WorkModelPara.ScaleBoundFuns.TunxScales = InputValues;
    end
end
UncertaintyFunUpdate(handles);
if strcmpi(get(handles.SlopeChangeAxes,'visible'),'on')
    FinalPlot_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of AmplifTunScale as text
%        str2double(get(hObject,'String')) returns contents of AmplifTunScale as a double


% --- Executes during object creation, after setting all properties.
function AmplifTunScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to AmplifTunScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StepScaleData_Callback(hObject, eventdata, handles)
% hObject    handle to StepScaleData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
InputValues = str2num(get(hObject,'String'));
if isnumeric(InputValues)
    if length(InputValues) == 2 && max(abs(InputValues)) < 1
        WorkModelPara.StepTunFuns.xScales = sort(InputValues);
    end
end
UncertaintyFunUpdate(handles);
if strcmpi(get(handles.SlopeChangeAxes,'visible'),'on')
    FinalPlot_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of StepScaleData as text
%        str2double(get(hObject,'String')) returns contents of StepScaleData as a double


% --- Executes during object creation, after setting all properties.
function StepScaleData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepScaleData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function StepValues_Callback(hObject, eventdata, handles)
% hObject    handle to StepValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
InputValues = str2num(get(hObject,'String'));
if isnumeric(InputValues)
    if length(InputValues) == 2
        WorkModelPara.StepTunFuns.ValueScale = sort(InputValues);
    end
end
UncertaintyFunUpdate(handles);
if strcmpi(get(handles.SlopeChangeAxes,'visible'),'on')
    FinalPlot_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of StepValues as text
%        str2double(get(hObject,'String')) returns contents of StepValues as a double


% --- Executes during object creation, after setting all properties.
function StepValues_CreateFcn(hObject, eventdata, handles)
% hObject    handle to StepValues (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TuningFun_Para_Callback(hObject, eventdata, handles)
% hObject    handle to TuningFun_Para (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
InputParas = str2num(get(hObject,'String'));
if isnumeric(InputParas)
    if length(InputParas) == 4
        WorkModelPara.BoundTunTuningFuns.Paras = InputParas;
    end
end
UncertaintyFunUpdate(handles);
if strcmpi(get(handles.SlopeChangeAxes,'visible'),'on')
    FinalPlot_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of TuningFun_Para as text
%        str2double(get(hObject,'String')) returns contents of TuningFun_Para as a double


% --- Executes during object creation, after setting all properties.
function TuningFun_Para_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TuningFun_Para (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function TunModuScales_Callback(hObject, eventdata, handles)
% hObject    handle to TunModuScales (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of TunModuScales as text
%        str2double(get(hObject,'String')) returns contents of TunModuScales as a double


% --- Executes during object creation, after setting all properties.
function TunModuScales_CreateFcn(hObject, eventdata, handles)
% hObject    handle to TunModuScales (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function SlopeChangeText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SlopeChangeText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'visible','off');


% --- Executes during object creation, after setting all properties.
function SlopeChangeAxes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to SlopeChangeAxes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'visible','off');
% Hint: place code in OpeningFcn to populate SlopeChangeAxes


% --- Executes during object creation, after setting all properties.
function FinalCurveText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FinalCurveText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'visible','off');


% --- Executes during object creation, after setting all properties.
function OnSlopeFactorCurve_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OnSlopeFactorCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'visible','off');
% Hint: place code in OpeningFcn to populate OnSlopeFactorCurve


% --- Executes during object creation, after setting all properties.
function FinalCurvetext2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FinalCurvetext2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'visible','off');


% --- Executes during object creation, after setting all properties.
function OnCurveFactorCurve_CreateFcn(hObject, eventdata, handles)
% hObject    handle to OnCurveFactorCurve (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'visible','off');
% Hint: place code in OpeningFcn to populate OnCurveFactorCurve


% --- Executes on button press in FinalPlot.
function FinalPlot_Callback(hObject, eventdata, handles)
% hObject    handle to FinalPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
ChoiceFitmd = WorkModelPara.ChoiceDataFitMD;
if isempty(WorkModelPara.ChoiceDerivetiveFun)
    error('Choice Data empty, Please calculate that first.');
end
set(handles.SlopeChangeText,'visible','on');
set(handles.FinalCurveText,'visible','on');
set(handles.FinalCurvetext2,'visible','on');

ChoiceSlopeData = WorkModelPara.ChoiceDerivetiveFun(WorkModelPara.xRange(:));
SlopeFactorData = WorkModelPara.UncertainFunCurve(:);
AmplifSlopeData = SlopeFactorData(:) .* ChoiceSlopeData(:);

set(handles.SlopeChangeAxes,'visible','on');
axes(handles.SlopeChangeAxes);
cla
hold on
hl1 = plot(WorkModelPara.xRange,AmplifSlopeData,'r','linewidth',1.4);
hl2 = plot(WorkModelPara.xRange,ChoiceSlopeData,'k','linewidth',1.4);
legend([hl1,hl2],{'ModuSlope','RawSlope'},'Box','off','FontSize',10);

ChoiceCLim = WorkModelPara.ChoiceFitLim;
cSlopeFunHandle = WorkModelPara.DeriveFun;
NewSP = ChoiceCLim(1,:).*[1 1 1 0]+[0 0 0 1/max(AmplifSlopeData)];

cFitTypes = fittype(WorkModelPara.DeriveFun,'coefficients',{'Newu','Newv'},'independent',{'Newx'},'dependent',{'ShapedSlope'});
[Newffit, Newgof] = fit(WorkModelPara.xRange(:),AmplifSlopeData(:),cFitTypes,'StartPoint',NewSP(3:4),'Upper',...
    ChoiceCLim(2,3:4),'Lower',ChoiceCLim(3,3:4));
NewSlopeData = feval(Newffit,WorkModelPara.xRange(:));

NewChoiceFun = @(x) WorkModelPara.modelfunb(ChoiceFitmd.g,ChoiceFitmd.l,Newffit.Newu,Newffit.Newv,x);
NewChoiceData = NewChoiceFun(WorkModelPara.xRange);
BoundData = NewChoiceFun(Newffit.Newu);
FactorSlopeData = (-1)*sqrt(2)*0.5*(ChoiceFitmd.g+ChoiceFitmd.l-1)/(sqrt(pi)*Newffit.Newv);
set(handles.OnSlopeFactorCurve,'visible','on');
axes(handles.OnSlopeFactorCurve);
cla;
%%
hold on
hl1 = plot(WorkModelPara.xRange,NewChoiceData,'r','linewidth',1.4);
hl2 = plot(WorkModelPara.xRange,WorkModelPara.PopuChoiceData,'k','linewidth',1.4);
text(Newffit.Newu,BoundData,{sprintf('Bound%.4f',Newffit.Newu),sprintf('Slope%.2f',FactorSlopeData)});
legend([hl1,hl2],{'Final curve','Raw curve'},'Box','off','FontSize',10,'Location','Northwest');
set(gca,'ylim',[-1.1 1.1]);
%%
FactorOnChoiceData = WorkModelPara.PopuChoiceData(:) .* SlopeFactorData(:);
FactorOnChoiceData(FactorOnChoiceData > 1) = 1;
FactorOnChoiceData(FactorOnChoiceData < -1) = -1;
UL = [max(FactorOnChoiceData)+abs(min(FactorOnChoiceData)), Inf, max(WorkModelPara.xRange), 100];
SP = [min(FactorOnChoiceData),max(FactorOnChoiceData) - min(FactorOnChoiceData), mean(WorkModelPara.xRange), 1];
LM = [-Inf,-Inf, min(WorkModelPara.xRange), -100];
% ParaBoundLim = ([UL;SP;LM]);
[Finalfit,Finalfitgof] = fit(WorkModelPara.xRange(:),FactorOnChoiceData(:),...
    WorkModelPara.modelfunb,'StartPoint',SP,'Upper',UL,'Lower',LM);
FactorOnCHoiceData = feval(Finalfit,WorkModelPara.xRange);
FactorBoundV = feval(Finalfit,Finalfit.u);
SlopeD = (-1)*sqrt(2)*0.5*(Finalfit.g+Finalfit.l-1)/(sqrt(pi)*Finalfit.v);
set(handles.OnCurveFactorCurve,'visible','on');
axes(handles.OnCurveFactorCurve);
cla;
%%
hold on
hl1 = plot(WorkModelPara.xRange,FactorOnCHoiceData,'r','linewidth',1.4);
hl2 = plot(WorkModelPara.xRange,FactorOnChoiceData,'k','linewidth',1.4,'linestyle','--');
hl3 = plot(WorkModelPara.xRange,WorkModelPara.PopuChoiceData,'b','linewidth',1.4);
text(Finalfit.u,FactorBoundV,{sprintf('Bound%.4f',Finalfit.u);sprintf('Slope%.2f',SlopeD)});
legend([hl1,hl2,hl3],{'Final curve','Raw final curve','RawChoiceCurve'},'Box','off','FontSize',10,'Location','Northwest');
set(gca,'ylim',[-1.1 1.1]);

WorkModelPara.SlopeV = [max(ChoiceSlopeData),abs(SlopeD)];
%%
% saveas(gcf,'OverAll figure plot savage');
% print(gcf,'-painters','OverAll figure plot savage','-dpdf');
% %%
% hf = figure;
% hold on
% hl1 = plot(WorkModelPara.xRange,FactorOnCHoiceData,'r','linewidth',1.4);
% hl2 = plot(WorkModelPara.xRange,FactorOnChoiceData,'k','linewidth',1.4);
% hl3 = plot(WorkModelPara.xRange,WorkModelPara.PopuChoiceData,'b','linewidth',1.4);
% text(Finalfit.u,FactorBoundV,{sprintf('Bound%.4f',Finalfit.u);sprintf('Slope%.2f',SlopeD)});
% legend([hl1,hl2,hl3],{'Final curve','Raw final curve','RawChoiceCurve'},'Box','off','FontSize',10,'Location','Northwest');
% set(gca,'ylim',[-1.1 1.1]);
% % save final curve
% saveas(hf,'Final curve plots save');
% saveas(hf,'Final curve plots save','pdf');
% close(hf);
% % final curve slope compare plot
% hhf = figure;
% hold on
% StepSize = WorkModelPara.xRange(2) - WorkModelPara.xRange(1);
% NewSlopeData = diff(FactorOnCHoiceData);
% NewSlopeData = [NewSlopeData(1);NewSlopeData]/(StepSize);
% plot(WorkModelPara.xRange,NewSlopeData,'r','linewidth',1.6);
% text(0,max(NewSlopeData),sprintf('%.2f',max(NewSlopeData)));
% 
% RawChoiceSlope = diff(WorkModelPara.PopuChoiceData);
% RawChoiceSlope = [RawChoiceSlope(1),RawChoiceSlope]/StepSize;
% plot(WorkModelPara.xRange,RawChoiceSlope,'k','linewidth',1.6);
% text(0,max(RawChoiceSlope),sprintf('%.2f',max(RawChoiceSlope)));
% %
% saveas(hhf,'Final data output Slope curve');
% saveas(hhf,'Final data output Slope curve','pdf');
% close(hhf);
% %
% h_f = figure;
% plot(WorkModelPara.xRange,SlopeFactorData,'m','linewidth',1.6)
% [MaxV,MaxInds] = max(SlopeFactorData);
% text(WorkModelPara.xRange(MaxInds),MaxV,sprintf('Max ModuValue %.2f',MaxV));
% set(gca,'ylim',[0.8 MaxV+0.2]);
% %
% saveas(h_f,'Final data output Modu curve');
% saveas(h_f,'Final data output Modu curve','pdf');
% close(h_f);

% --- Executes during object creation, after setting all properties.
function FinalPlot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to FinalPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'visible','off');


% --- Executes on selection change in CategNeuTypes.
function CategNeuTypes_Callback(hObject, eventdata, handles)
% hObject    handle to CategNeuTypes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
contents = cellstr(get(hObject,'String'));
cType = contents{get(hObject,'Value')};
WorkModelPara.CategNeuType = cType;
switch cType
    case 'Sigmoidal'
        cTypeParas = WorkModelPara.CategROIparas;
        set(handles.ROIparasTag,'string',sprintf('%.2f,%.2f,%.4f',cTypeParas(1),cTypeParas(2),cTypeParas(3)));
        
    case 'Gaussian'
        cTypeParas = WorkModelPara.gausCategParaDef;
        set(handles.ROIparasTag,'string',sprintf('%.2f,%.2f,%.4f',cTypeParas(1),cTypeParas(2),cTypeParas(3)));
end
        
CategROICal_Callback(hObject, eventdata, handles);
% Hints: contents = cellstr(get(hObject,'String')) returns CategNeuTypes contents as cell array
%        contents{get(hObject,'Value')} returns selected item from CategNeuTypes


% --- Executes during object creation, after setting all properties.
function CategNeuTypes_CreateFcn(hObject, eventdata, handles)
% hObject    handle to CategNeuTypes (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String',{'Sigmoidal';'Gaussian';'MixedPopu'},'Value',1,'FontSize',12);



function GaussFunPara_Callback(hObject, eventdata, handles)
% hObject    handle to GaussFunPara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
InputValues = str2num(get(hObject,'String'));
if isnumeric(InputValues)
    if length(InputValues) == 4
        WorkModelPara.GauTunFuns.GauParas = InputValues;
    end
end
UncertaintyFunUpdate(handles);
if strcmpi(get(handles.SlopeChangeAxes,'visible'),'on')
    FinalPlot_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of GaussFunPara as text
%        str2double(get(hObject,'String')) returns contents of GaussFunPara as a double


% --- Executes during object creation, after setting all properties.
function GaussFunPara_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GaussFunPara (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function GauModuScale_Callback(hObject, eventdata, handles)
% hObject    handle to GauModuScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
InputValues = str2num(get(hObject,'String'));
if isnumeric(InputValues)
    if length(InputValues) == 2
        WorkModelPara.GauTunFuns.GauModuScale = InputValues;
    end
end
UncertaintyFunUpdate(handles);
if strcmpi(get(handles.SlopeChangeAxes,'visible'),'on')
    FinalPlot_Callback(hObject, eventdata, handles);
end
% Hints: get(hObject,'String') returns contents of GauModuScale as text
%        str2double(get(hObject,'String')) returns contents of GauModuScale as a double


% --- Executes during object creation, after setting all properties.
function GauModuScale_CreateFcn(hObject, eventdata, handles)
% hObject    handle to GauModuScale (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in PoolSumDataPlot.
function PoolSumDataPlot_Callback(hObject, eventdata, handles)
% hObject    handle to PoolSumDataPlot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
% Hint: get(hObject,'Value') returns toggle state of PoolSumDataPlot
cState = get(handles.PoolSumDataPlot,'Value');
if cState
    if ~isempty(WorkModelPara.LRPopuRawData{1})
        if isempty(WorkModelPara.LRPopuRawFig)
            WorkModelPara.LRPopuRawFig = figure('position',[100 100 420 360]);
            hold on
        else
            figure(WorkModelPara.LRPopuRawFig);
            clf;
            hold on
        end
        hl1 = plot(WorkModelPara.xRange,WorkModelPara.LRPopuRawData{1},'b','linewidth',1.4);
        hl2 = plot(WorkModelPara.xRange,WorkModelPara.LRPopuRawData{2},'r','linewidth',1.4);
        set(gca,'xtick',-1:0.5:1);
        xlabel('Octave');
        ylabel('Activity');
        set(gca,'FontSize',14);
        legend([hl1,hl2],{'LPool','RPool'},'Location','east','box','off');
    else
        warning('Pooling sum data is empty');
    end
else
    if ishandle(WorkModelPara.LRPopuRawFig)
        close(WorkModelPara.LRPopuRawFig);
        WorkModelPara.LRPopuRawFig = [];
    end
end

function BoundFracData_Callback(hObject, eventdata, handles,varargin)
% hObject    handle to BoundFracData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
% Hints: get(hObject,'String') returns contents of BoundFracData as text
%        str2double(get(hObject,'String')) returns contents of BoundFracData as a double
IsCategCalUpdate = 1;
if nargin < 4
    IsCategCalUpdate = 1;
else
    IsCategCalUpdate = varargin{1};
end

cPeakFrac = str2num(get(handles.BoundFracData,'String'));
if isempty(cPeakFrac)
    WorkModelPara.Weights = zeros(WorkModelPara.CategROINum,0);
    WorkModelPara.Weights(:) = 1/WorkModelPara.CategROINum;
%     return;
else
    if min(cPeakFrac) < 0
        Strs = '';
        for cFrac = 1 : length(cPeakFrac)
            Strs = [Strs,num2str(cPeakFrac(cFrac),'%.1f')];
        end
        set(handles.BoundFracData,'String',Strs);
        error('FracValue should not less than 0.');
    end
    if length(cPeakFrac) == WorkModelPara.CategROINum
        if sum(cPeakFrac) ~= 1
            cPeakFrac = cPeakFrac / sum(cPeakFrac);
        end
        WorkModelPara.Weights = cPeakFrac;
    elseif length(cPeakFrac) == 2
        BiasFrac = cPeakFrac(2);
        CellFracs = zeros(WorkModelPara.CategROINum,1);
        if cPeakFrac(1) == 1
            % bias high fraction to the outer frequency    
            CellFracs(1) = BiasFrac/2;
            CellFracs(end) = BiasFrac/2;
            CellFracs(2:end-1) = (1-BiasFrac)/(WorkModelPara.CategROINum-2);
        elseif cPeakFrac(1) == 0
            % bias to the near boundary frequency
            if mod(WorkModelPara.CategROINum,2)
                CellFracs(:) = (1 - BiasFrac)/(WorkModelPara.CategROINum - 1);
                CellFracs(ceil(WorkModelPara.CategROINum/2)) = BiasFrac;
            else
                CellFracs(:) = (1 - BiasFrac)/(WorkModelPara.CategROINum - 2);
                CellFracs((WorkModelPara.CategROINum/2)+[0,1]) = BiasFrac/2;
            end
        end
        WorkModelPara.Weights = CellFracs;
    end
end
if IsCategCalUpdate
    CategROICal_Callback(hObject, eventdata, handles);
end
   
% --- Executes during object creation, after setting all properties.
function BoundFracData_CreateFcn(hObject, eventdata, handles)
% hObject    handle to BoundFracData (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in IsRandVarWid.
function IsRandVarWid_Callback(hObject, eventdata, handles)
% hObject    handle to IsRandVarWid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
cV = get(hObject,'Value');
% Hint: get(hObject,'Value') returns toggle state of IsRandVarWid
if cV
    set(handles.RandWidStrs,'visible','on');
    set(handles.RandWidFrac,'visible','on');
    set(handles.ROIWidStrs,'visible','on');
    cWidStrs = get(handles.RandWidStrs,'String');
    if isempty(cWidStrs)
        cWidStrs = '0.2,0.4,0.8';
        cWidFracs = '0.2,0.2,0.2';
    else
        cWidFracs = get(handles.RandWidFrac,'String');
    end
    
    WorkModelPara.IsRandWid = 1;
    WorkModelPara.WidTypes = str2num(cWidStrs);
    WorkModelPara.WidTypeFrac = str2num(cWidFracs);
    RandWinStrsAll = num2str(WorkModelPara.WidTypes,'%.2f,');
    RandWinStrsAll = RandWinStrsAll(1:end-1);
    set(handles.RandWidStrs,'String',RandWinStrsAll);
    RandWinFracStrs = num2str(WorkModelPara.WidTypeFrac,'%.2f,');
    RandWinFracStrs = RandWinFracStrs(1:end-1);
    set(handles.RandWidFrac,'String',RandWinFracStrs);
else
    WorkModelPara.IsRandWid = 0;
    set(handles.RandWidStrs,'visible','off');
    set(handles.RandWidFrac,'visible','off');
    set(handles.ROIWidStrs,'visible','off');
end
% callbacks for re-calculation
CategROICal_Callback(hObject, eventdata, handles);

% --- Executes during object creation, after setting all properties.
function IsRandVarWid_CreateFcn(hObject, eventdata, handles)
% hObject    handle to IsRandVarWid (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Value',0);


function RandWidStrs_Callback(hObject, eventdata, handles)
% hObject    handle to RandWidStrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
cString = get(hObject,'String');
IsRandVar = WorkModelPara.IsRandWid;
% Hints: get(hObject,'String') returns contents of RandWidStrs as text
%        str2double(get(hObject,'String')) returns contents of RandWidStrs as a double
if ~isempty(cString) && IsRandVar
    StrWids = str2num(cString);
    WorkModelPara.WidTypes = StrWids;
    cFracStrs = repmat(num2str(1/length(StrWids),'%.2f,'),1,length(StrWids));
    WorkModelPara.cWidFracs = repmat(1/length(StrWids),1,length(StrWids));
elseif isempty(cString) && IsRandVar
    cWidStrs = '0.2,0.4,0.8';
    cWidFracs = '0.2,0.2,0.2';
    WorkModelPara.WidTypes = str2num(cWidStrs);
    WorkModelPara.cWidFracs = str2num(cWidFracs);
end
RandWinStrsAll = num2str(WorkModelPara.WidTypes,'%.2f,');
RandWinStrsAll = RandWinStrsAll(1:end-1);
set(handles.RandWidStrs,'String',RandWinStrsAll);
RandWinFracStrs = num2str(WorkModelPara.WidTypeFrac,'%.2f,');
RandWinFracStrs = RandWinFracStrs(1:end-1);
set(handles.RandWidFrac,'String',RandWinFracStrs);

CategROICal_Callback(hObject, eventdata, handles);


% --- Executes during object creation, after setting all properties.
function RandWidStrs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RandWidStrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Visible','off');


function RandWidFrac_Callback(hObject, eventdata, handles)
% hObject    handle to RandWidFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
cWTypes = WorkModelPara.WidTypes;
cString = get(hObject,'String');
cStrFrac = str2num(cString);
if length(cStrFrac) ~= length(cWTypes)
    warndlg('Unequal number of width types and fraction number','Error Number warning');
    return;
else
    WorkModelPara.IsRandWid = 1;
    WorkModelPara.WidTypeFrac = cStrFrac;
end
CategROICal_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of RandWidFrac as text
%        str2double(get(hObject,'String')) returns contents of RandWidFrac as a double


% --- Executes during object creation, after setting all properties.
function RandWidFrac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RandWidFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'Visible','off');

% --- Executes during object creation, after setting all properties.
function ROIWidStrs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to RandWidFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Visible','off');


% --- Executes on button press in SaveResultBut.
function SaveResultBut_Callback(hObject, eventdata, handles)
% hObject    handle to SaveResultBut (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
cd('S:\WorkingMDDatas\TestData');
save(sprintf('%sSave.mat',datestr(now,30)),'WorkModelPara','-v7.3');
% fprintf('Data was saved in folder: S:\\WorkingMDDatas\TestData.\n');


function MixedROIFrac_Callback(hObject, eventdata, handles)
% hObject    handle to MixedROIFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global WorkModelPara
cFracStr = get(hObject,'String');
cFracsAll = str2num(cFracStr);
if sum(cFracsAll) > 1
    error('Fraction number should be less than 1');
else
    WorkModelPara.BaseROITypes = cFracsAll;
end
CategROICal_Callback(hObject, eventdata, handles);
% Hints: get(hObject,'String') returns contents of MixedROIFrac as text
%        str2double(get(hObject,'String')) returns contents of MixedROIFrac as a double


% --- Executes during object creation, after setting all properties.
function MixedROIFrac_CreateFcn(hObject, eventdata, handles)
% hObject    handle to MixedROIFrac (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
set(hObject,'String','0.1,0.13,0.41,0.35');
set(hObject,'Visible','off');


% --- Executes during object creation, after setting all properties.
function ROIFracStrs_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ROIFracStrs (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'Visible','off');