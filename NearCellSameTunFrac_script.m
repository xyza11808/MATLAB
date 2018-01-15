% plot the colormap plot according to different cell types
% three neuron types will be considered, 
% categorical neuron, tuning neurons, no significantly selective neurons
clear
clc

[fn,fp,fi] = uigetfile('*.txt','Please select the session pathsave file');
if ~fi
    return;
end

%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
nSess = 1;
SessNearSaveTunFrac = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %
    % passive tuning frequency colormap plot
    TunDataAllStrc = load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
    load('TunningDataSave.mat');
    [~,EndInds] = regexp(tline,'result_save');
    ROIposfilePath = tline(1:EndInds);
    ROIposfilePosi = dir(fullfile(ROIposfilePath,'ROIinfo*.mat'));
    ROIdataStrc = load(fullfile(ROIposfilePath,ROIposfilePosi(1).name));
    if isfield(ROIdataStrc,'ROIinfoBU')
        ROIinfoData = ROIdataStrc.ROIinfoBU;
    elseif isfield(ROIdataStrc,'ROIinfo')
        ROIinfoData = ROIdataStrc.ROIinfo(1);
    else
        error('No ROI information file detected, please check current session path.');
    end
    
    ROIcenters = ROI_insite_label(ROIinfoData,0);
    ROIdistance = pdist(ROIcenters);
    DisMatrix = squareform(ROIdistance);
    
    % passive tuning octaves
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    UsedOctave = UsedOctave(:);
    UsedOctaveData = PassTunningfun(UsedOctaveInds,:);
    [PassMaxAmp,PassMaxInds] = max(UsedOctaveData);
    PassMaxIndsOctave = zeros(length(PassMaxAmp),1);
    for cRoi = 1 : length(PassMaxAmp)
        PassMaxIndsOctave(cRoi) = UsedOctave(PassMaxInds(cRoi));
    end
    
    % task Tuning octaves
    TaskFreqOctave = TaskFreqOctave(:);
    TaskOctaveData = CorrTunningFun;
    nROIs = size(TaskOctaveData,2);
    [TaskMaxAmp,TaskMaxInds] = max(TaskOctaveData);
    TaskMaxIndssOctave = zeros(nROIs,1);
    for cR = 1 : nROIs
        TaskMaxIndssOctave(cR) = TaskFreqOctave(TaskMaxInds(cR));
    end
    
    TaskSameTunFrac = zeros(nROIs,1);
    PassSameTunFrac = zeros(nROIs,1);
    for cROI = 1 : nROIs
        cTasktunFreq = TaskMaxIndssOctave(cROI);
        cPasstunFreq = PassMaxIndsOctave(cROI);
        cROIdistance = DisMatrix(:,cROI);
        [cDisSort,cDisSortInds] = sort(cROIdistance);
        NerFiveNeuInds = cDisSortInds(2:6);
        TaskNerTunFreq = TaskMaxIndssOctave(NerFiveNeuInds);
        PassNerTunFreq = PassMaxIndsOctave(NerFiveNeuInds);
        TaskSameTunFrac(cROI) = mean(TaskNerTunFreq == cTasktunFreq);
        PassSameTunFrac(cROI) = mean(PassNerTunFreq == cPasstunFreq);
    end
    
    SessNearSaveTunFrac{nSess,1} = TaskSameTunFrac;
    SessNearSaveTunFrac{nSess,2} = PassSameTunFrac;
    
    tline = fgetl(fid);
    nSess = nSess + 1;
end

%%
TaskFracAll = cell2mat(SessNearSaveTunFrac(:,1));
PassFracAll = cell2mat(SessNearSaveTunFrac(:,2));
[PassCumy,PassCumx] = ecdf(PassFracAll);
[TaskCumy,TaskCumx] = ecdf(TaskFracAll);
hhhf = figure('position',[100 100 400 320]);
hold on
plot(PassCumx,PassCumy,'k','linewidth',2);
plot(TaskCumx,TaskCumy,'r','linewidth',2);

