
clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
% [Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');
cd('E:\DataToGo\data_for_xu\CategDataSummary');
%%
fpath = fullfile(fp,fn);
% PassFid = fopen(fullfile(Passfp,Passfn));

ff = fopen(fpath);
tline = fgetl(ff);
% PassLine = fgetl(PassFid);
cSess = 1;
TunROIWidthSum = {}; 
INormROIInds = {};
BoundTunWidthAll = {};
Tun2BoundDis = {};
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
       tline = fgetl(ff);
%        PassLine = fgetl(PassFid);
        continue;
    end
     cBehavDataP = fullfile(tline,'RandP_data_plots','boundary_result.mat');
     cBehavData = load(cBehavDataP);
     BehavBound = cBehavData.boundary_result.Boundary - 1;
     
     
     CellTypeDataStrc = load(fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewCurveFitsave.mat'));
     TunROIInds = logical(CellTypeDataStrc.IsTunedROI);
     TunROIGauFit = CellTypeDataStrc.GauCoefFit(TunROIInds);
     TunROIWidth = cellfun(@(x) x.c3,TunROIGauFit);
     TunROIPeak = cellfun(@(x) x.c2,TunROIGauFit);
     
     TunROIWidthSum{cSess} = TunROIWidth;
     
     ROIInds = find(TunROIInds);
     INormROIInds{cSess} = ROIInds(TunROIWidth >= 0.8);
     
     cBoundTunROIInds = BoundTunROIindex{cSess,2};
     BoundTunWidth = TunROIWidth(cBoundTunROIInds);
     BoundTunWidthAll{cSess} = BoundTunWidth;
     
     ROI2BoundDis = abs(TunROIPeak - BehavBound);
     Tun2BoundDis{cSess,1} = ROI2BoundDis;
     Tun2BoundDis{cSess,2} = ROI2BoundDis(cBoundTunROIInds);
     
     tline = fgetl(ff);
     cSess = cSess + 1;
end
fclose(ff);
%%
TunWidthAll = cell2mat(TunROIWidthSum');
BoundROIWidthAll = cell2mat(BoundTunWidthAll');
TunDisAll = cell2mat(Tun2BoundDis(:,1));
BoundTunDisAll = cell2mat(Tun2BoundDis(:,2));


%%
cChoice = double(behavResults.Action_choice(:));
NMInds = cChoice ~= 2;
NMChoice = cChoice(NMInds);
NMFreqs = double(behavResults.Stim_toneFreq(NMInds));
NMFreqOct = log2(NMFreqs(:)/16000);
NMFreqType = unique(NMFreqOct);
%%
tline = pwd;
try
    SPData = load(fullfile(tline,'EstimateSPsaveNew.mat'),'SpikeAligned');
catch
    SPData = load(fullfile(tline,'EstimateSPsave.mat'),'SpikeAligned');
end
load(fullfile(tline,'CSessionData.mat'));
%%
RespWin = [0.1,0.5];
RespFrame = round(RespWin*frame_rate)+start_frame;
TemporalWin = [0.1,1];
TemporalFrame = round(TemporalWin*frame_rate)+start_frame;
TimeStep = 0.1;
FrameStep = round(TemporalFrame(1):(TimeStep*frame_rate):TemporalFrame(2));
FrameCenter = (FrameStep(1:end-1)+FrameStep(2:end))/2;


%% ROITempWinData = SpikeAligned(:,:,RespFrame(1):RespFrame(2));
ChoiceAll = double(behavResults.Action_choice);
NMInds = ChoiceAll ~= 2;
NMChoice = ChoiceAll(NMInds);
% NMChoice(NMChoice == 0) = -1;
NMTrFreq = double(behavResults.Stim_toneFreq(NMInds))/16000;
NMRespData = sum(SPData.SpikeAligned(NMInds,:,RespFrame(1):RespFrame(2)),3);
[nTrs, nROIs] = size(NMRespData);

%%
ROIFitData = cell(nROIs,10);
for cROI = 1 : nROIs
    %%
    cROIData = NMRespData(:,cROI);
    FreqTypes = unique(NMTrFreq);
    nFreqs = length(FreqTypes);
    FreqTypeMtrix = double(repmat(NMTrFreq(:),1,nFreqs) == repmat(FreqTypes,length(NMTrFreq),1));
    FreqTypeStr = cellstr(num2str((2.^FreqTypes(:))*16,'%.1f'));
    ChoiceTypeMtx = [1-NMChoice(:),NMChoice(:)];
    ChoiceTypeStr = {'Left','Right'};
    %%
    DataSetInds = cvpartition(nTrs,'kFold',10);
    for cPart = 1 : 10
        TrainIndex = DataSetInds.test(1);
        cROIfit = stepwiseglm([FreqTypeMtrix(TrainIndex,:),ChoiceTypeMtx(TrainIndex,:)],cROIData(TrainIndex),'linear','Distribution','poisson');
        ROIFitData{cROI,cPart} = cROIfit;
    end
end