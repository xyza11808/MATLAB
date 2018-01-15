% calculate paired neuron tuning peak difference and distance relationship
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
%
nSess = 1;
SessDataDisTunAll = {};

%
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %
    % passive tuning frequency colormap plot
    TunDataAllStrc = load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
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
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
    BehavCorr = BehavBoundfile.boundary_result.StimCorr;
    
    GrNum = floor(length(BehavCorr)/2);
    BehavPsycho = BehavCorr;
    BehavPsycho(1:GrNum) = 1 - BehavPsycho(1:GrNum);
    BehavStims = log2(double(BehavBoundfile.boundary_result.StimType)/16000);
    ROIcenters = ROI_insite_label(ROIinfoData,0);
    ROIdistance = pdist(ROIcenters);
    DisMatrix = squareform(ROIdistance);

    ROITypeDatafile = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewCurveFitsave.mat');
    ROITypeDataStrc = load(ROITypeDatafile);
    CategROIInds = logical(ROITypeDataStrc.IsCategROI);
    TunedROIInds = logical(ROITypeDataStrc.IsTunedROI);
    IIsResponsiveROI = logical(ROITypeDataStrc.ROIisResponsive);
    
    % passive data tuning peak
    PassUsedOctavesInds = ~(abs(TunDataAllStrc.PassFreqOctave) > 1);
    PassUsedOctaves = TunDataAllStrc.PassFreqOctave(PassUsedOctavesInds);
    PassUsedOctaves = PassUsedOctaves(:);
    PassUsedOctData = TunDataAllStrc.PassTunningfun(PassUsedOctavesInds,:);
    nTotalROIs = size(PassUsedOctData,2);
    [MaxAmp,MaxInds] = max(PassUsedOctData);
    PassMaxIndsOctave = zeros(nTotalROIs,1);
    for n = 1 : nTotalROIs
        PassMaxIndsOctave(n) = PassUsedOctaves(MaxInds(n));
    end
    PassTunOctDiff = pdist(PassMaxIndsOctave(:));
    
    % task data tuning peak
    TaskUsedOctaves = TunDataAllStrc.TaskFreqOctave(:);
    TaskUsedData = TunDataAllStrc.CorrTunningFun;
    TotalROIs = size(TaskUsedData,2);
    [MaxAmp,MaxInds] = max(TaskUsedData);
    TaskMaxOctaves = zeros(TotalROIs,1);
    for n = 1 : TotalROIs
        TaskMaxOctaves(n) = TaskUsedOctaves(MaxInds(n));
    end
    TaskTunOctDiff = pdist(TaskMaxOctaves(:));
    %
    SessDataDisTunAll{nSess,1} = ROIdistance(:);
    SessDataDisTunAll{nSess,2} = PassTunOctDiff(:);
    SessDataDisTunAll{nSess,3} = TaskTunOctDiff(:);
    
    nSess = nSess + 1;
    tline = fgetl(fid);
end
%%
cd('E:\DataToGo\data_for_xu\Local_Neural_Cluster');
save PairedDisTunDifSum.mat SessDataDisTunAll -v7.3
%%
ROIdisAll = cell2mat(SessDataDisTunAll(1:end-2,1));
PassTunDis = cell2mat(SessDataDisTunAll(1:end-2,2));
TaskTunDis = cell2mat(SessDataDisTunAll(1:end-2,3));
lmFunCalPlot(TaskTunDis,ROIdisAll)
lmFunCalPlot(PassTunDis,ROIdisAll)

%% Task Bin Data
Step = 0.1;
DisRange = -2.5:Step:2.5;
BinCenter = DisRange(1:end-1) + Step/2;
BinLeng = length(DisRange) - 1;
TaskBinDisData = zeros(BinLeng,1);
TaskBinDisSEM = zeros(BinLeng,1);
PassBinDisData = zeros(BinLeng,1);
PassBinDisSEM = zeros(BinLeng,1);
IsDataEmpty = zeros(BinLeng,1);
IsPassDataEmpty = zeros(BinLeng,1);
for cBin = 1 : BinLeng
    BinRangeInds = TaskTunDis >= DisRange(cBin) & TaskTunDis < DisRange(cBin+1);
    PassBinRages = PassTunDis >= DisRange(cBin) & PassTunDis < DisRange(cBin+1);
    if sum(BinRangeInds)
        TaskBinDisData(cBin) = mean(ROIdisAll(BinRangeInds));
        TaskBinDisSEM(cBin) = std(ROIdisAll(BinRangeInds))/sqrt(sum(BinRangeInds));
        if TaskBinDisSEM(cBin) > 1000
            return;
        end
        IsDataEmpty(cBin) = 1;
    end
    if sum(PassBinRages)
        PassBinDisData(cBin) = mean(ROIdisAll(PassBinRages));
        PassBinDisSEM(cBin) = std(ROIdisAll(PassBinRages))/sqrt(sum(PassBinRages));
        if PassBinDisSEM(cBin) > 1000
            return;
        end
        IsPassDataEmpty(cBin) = 1;
    end
end

TaskOctBinCen = BinCenter(logical(IsDataEmpty));
TaskBinDisAvg = TaskBinDisData(logical(IsDataEmpty));
TaskBinDisSEM = TaskBinDisSEM(logical(IsDataEmpty));

PassOctBinCen = BinCenter(logical(IsPassDataEmpty));
PassBinDisAvg = PassBinDisData(logical(IsPassDataEmpty));
PassBinDisSEM = PassBinDisSEM(logical(IsPassDataEmpty));

[TaskMdl,TaskFitData] = lmFunCalPlot(TaskTunDis,ROIdisAll,0);
[PassMdl,PassFitData] = lmFunCalPlot(PassTunDis,ROIdisAll,0);

hhf = figure('position',[100 100 380 300]);
hold on
el1 = errorbar(PassOctBinCen,PassBinDisAvg,PassBinDisSEM,'k-o','linewidth',1.4);
el2 = errorbar(TaskOctBinCen,TaskBinDisAvg,TaskBinDisSEM,'-o','linewidth',1.4,'Color',[1 0.7 0.4]);
ll1 = plot(TaskFitData(:,1),TaskFitData(:,2),'Color',[1 0.5 0.1],'linewidth',1.8);
ll2 = plot(PassFitData(:,1),PassFitData(:,2),'Color',[.3 .3 .3],'linewidth',1.8);
plot(TaskFitData(:,1),TaskFitData(:,[3,4]),'Color',[1 0.6 0.2],'linewidth',1.5,'linestyle','--');
plot(PassFitData(:,1),PassFitData(:,[3,4]),'Color',[.6 .6 .6],'linewidth',1.5,'linestyle','--');
set(gca,'xtick',[0 1 2],'xlim',[-0.1 2.1]);
xlabel('\DeltaBF');
ylabel(' Paired Distance');
title(sprintf('TaskSlope = %.3f, Pass = %.3f',TaskMdl.Coefficients.Estimate(2),...
    PassMdl.Coefficients.Estimate(2)));
set(gca,'FontSize',12);
legend([ll1,ll2],{sprintf('Taskp=%.3e',TaskMdl.Coefficients.pValue(2)),...
    sprintf('Passp=%.3e',PassMdl.Coefficients.pValue(2))},'FontSize',8,'Box','off');
saveas(hhf,'TunDiff vs PairedDis correlation plot');
saveas(hhf,'TunDiff vs PairedDis correlation plot','png');
saveas(hhf,'TunDiff vs PairedDis correlation plot','pdf');

