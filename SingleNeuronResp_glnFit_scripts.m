% proportion = failed ./ tested;
clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
%% [Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
fpath = fullfile(fp,fn);
% PassFid = fopen(fullfile(Passfp,Passfn));

ff = fopen(fpath);
tline = fgetl(ff);
% PassLine = fgetl(PassFid);
cSess = 1;
SessPartialCorrData = {};
TempporalDataAll = {};
%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ff);
        %        PassLine = fgetl(PassFid);
        continue;
    end
    %
    cd(tline);
    try
        SPData = load(fullfile(tline,'EstimateSPsaveNew.mat'),'SpikeAligned');
    catch
        SPData = load(fullfile(tline,'EstimateSPsave.mat'),'SpikeAligned');
    end
    load(fullfile(tline,'CSessionData.mat'));
    %
    RespWin = [0.1,0.5];
    RespFrame = round(RespWin*frame_rate)+start_frame;
    TemporalWin = [0.1,1];
    TemporalFrame = round(TemporalWin*frame_rate)+start_frame;
    TimeStep = 0.1;
    FrameStep = round(TemporalFrame(1):(TimeStep*frame_rate):TemporalFrame(2));
    FrameCenter = (FrameStep(1:end-1)+FrameStep(2:end))/2;
    
    
    % ROITempWinData = SpikeAligned(:,:,RespFrame(1):RespFrame(2));
    ChoiceAll = double(behavResults.Action_choice);
    NMInds = ChoiceAll ~= 2;
    NMChoice = ChoiceAll(NMInds);
%     NMChoice(NMChoice == 0) = -1;
    NMTrFreq = log2(double(behavResults.Stim_toneFreq(NMInds))/16000);
    NMRespData = sum(SPData.SpikeAligned(NMInds,:,RespFrame(1):RespFrame(2)),3);
    [nTrs, nROIs] = size(NMRespData);
    
    %
    ROIFitData = cell(nROIs,10);
    parfor cROI = 1 : nROIs
        cROIData = NMRespData(:,cROI);
        FreqTypes = unique(NMTrFreq);
        nFreqs = length(FreqTypes);
        FreqTypeMtrix = double(repmat(NMTrFreq(:),1,nFreqs) == repmat(FreqTypes,length(NMTrFreq),1));
        FreqTypeStr = cellstr(num2str((2.^FreqTypes(:))*16,'%.1f'));
        ChoiceTypeMtx = [1-NMChoice(:),NMChoice(:)];
        ChoiceTypeStr = {'Left','Right'};

        DataSetInds = cvpartition(nTrs,'kFold',10);
        for cPart = 1 : 10
            TrainIndex = DataSetInds.test(1);
            cROIfit = stepwiseglm([FreqTypeMtrix(TrainIndex,:),ChoiceTypeMtx(TrainIndex,:)],cROIData(TrainIndex),'linear','Distribution','poisson');
            ROIFitData{cROI,cPart} = cROIfit;
        end
    end
    save FitMdSummary.mat ROIFitData -v7.3
    %
    tline = fgetl(ff);
    cSess = cSess + 1;
end
% cd('E:\DataToGo\data_for_xu\SingleROIInfoSum');
% save FitDataSummary