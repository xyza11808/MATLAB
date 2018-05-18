clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
% [Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
load('E:\DataToGo\data_for_xu\SingleCell_RespType_summary\NewMethod\SessROItypeData.mat');
% cd('E:\DataToGo\data_for_xu\CategDataSummary');
%%
fpath = fullfile(fp,fn);

ff = fopen(fpath);
tline = fgetl(ff);
nSess = 1;
SessTypeRespAll = {};
% SessBoundTunAll = {};
% SessSenSoryTunAll = {};
% SessNoSelectionAll = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(ff);
        continue;
    end
    %
    clearvars FitData;
    RespDataPath = fullfile(tline,'Tunning_fun_plot_New1s','Curve fitting plots','NewLog_fit_test_new');
    cd(RespDataPath);

    FitData = load(fullfile(RespDataPath,'NewCurveFitsave.mat'));

%     cSessROITunInds = BoundTunROIindex(nSess,1:2);
    CategROIInds = find(FitData.IsCategROI);
    TunROIInds = find(FitData.IsTunedROI);
    BoundTunROIs = BoundTunROIindex{nSess,1};
    SenTunROIs = TunROIInds(BoundTunROIindex{nSess,2});
    NoSelectInds = ~logical(FitData.IsCategROI + FitData.IsTunedROI);
    %
    ROIrespData = FitData.ROISlopeFit(:,end-2:end);
    CategROIResp = ROIrespData(CategROIInds,:);
    BoundTunResp = ROIrespData(BoundTunROIs,:);
    SensoryTunResp = ROIrespData(SenTunROIs,:);
    NoSelectResp = ROIrespData(NoSelectInds,:);
    
    SessTypeRespAll{nSess,1} = CategROIResp;
    SessTypeRespAll{nSess,2} = BoundTunResp;
    SessTypeRespAll{nSess,3} = SensoryTunResp;
    SessTypeRespAll{nSess,4} = NoSelectResp;
    
    %
    tline = fgetl(ff);
    nSess = nSess + 1;
    
end
cd('E:\DataToGo\data_for_xu\ROIRespAmpSum');
save TypeAmpDataAll.mat SessTypeRespAll -v7.3
%% RespAmp Plots
% categ ROI plots
CategDataAll = cell2mat(SessTypeRespAll(:,1));
MaxRespAmp = max(CategDataAll,[],2);
ExInds = MaxRespAmp > 1000;
UsedData = CategDataAll(~ExInds,:);
[~,Categp] = ttest(UsedData(:,1),UsedData(:,3));

hf = figure;
plot(UsedData(:,1),UsedData(:,3),'ro','MarkerSize',9,'linewidth',2);
FigAxes = figaxesScaleUni(gca);
AxesScales = get(FigAxes,'xlim');
line(AxesScales,AxesScales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
xlabel('TaskAmp \DeltaF/F_0 (%)');
ylabel('PassAmp \DeltaF/F_0 (%)');
title(sprintf('Task %.1f, Pass %.1f, p = %.3e',mean(UsedData(:,1)),mean(UsedData(:,3)),Categp));
set(gca,'FontSize',15)
saveas(hf,'CategROI Amp Compare plots');
saveas(hf,'CategROI Amp Compare plots','png');
saveas(hf,'CategROI Amp Compare plots','pdf');


%% BoundTun ROI plots
BoundTunAmp = cell2mat(SessTypeRespAll(:,2));
MaxRespAmp = max(BoundTunAmp,[],2);
ExInds = MaxRespAmp > 1000;
UsedData = BoundTunAmp(~ExInds,:);
[~,Categp] = ttest(UsedData(:,1),UsedData(:,3));

hf = figure;
plot(UsedData(:,1),UsedData(:,3),'bo','MarkerSize',9,'linewidth',2);
FigAxes = figaxesScaleUni(gca);
AxesScales = get(FigAxes,'xlim');
line(AxesScales,AxesScales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
xlabel('TaskAmp \DeltaF/F_0 (%)');
ylabel('PassAmp \DeltaF/F_0 (%)');
title(sprintf('Task %.1f, Pass %.1f, p = %.3e',mean(UsedData(:,1)),mean(UsedData(:,3)),Categp));
set(gca,'FontSize',15)
saveas(hf,'BoundTunROI Amp Compare plots');
saveas(hf,'BoundTunROI Amp Compare plots','png');
saveas(hf,'BoundTunROI Amp Compare plots','pdf');

%% Sensory Tun ROIs
SensoryTunAmp = cell2mat(SessTypeRespAll(:,3));
MaxRespAmp = max(SensoryTunAmp,[],2);
ExInds = MaxRespAmp > 1000;
UsedData = SensoryTunAmp(~ExInds,:);
[~,Categp] = ttest(UsedData(:,1),UsedData(:,3));

hf = figure;
plot(UsedData(:,1),UsedData(:,3),'co','MarkerSize',9,'linewidth',2);
FigAxes = figaxesScaleUni(gca);
AxesScales = get(FigAxes,'xlim');
line(AxesScales,AxesScales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
xlabel('TaskAmp \DeltaF/F_0 (%)');
ylabel('PassAmp \DeltaF/F_0 (%)');
title(sprintf('Task %.1f, Pass %.1f, p = %.3e',mean(UsedData(:,1)),mean(UsedData(:,3)),Categp));
set(gca,'FontSize',15)
saveas(hf,'SensTunROI Amp Compare plots');
saveas(hf,'SensTunROI Amp Compare plots','png');
saveas(hf,'SensTunROI Amp Compare plots','pdf');

%%
NoSelectAmp = cell2mat(SessTypeRespAll(:,4));
MaxRespAmp = max(NoSelectAmp,[],2);
ExInds = MaxRespAmp > 1000;
UsedData = NoSelectAmp(~ExInds,:);
[~,Categp] = ttest(UsedData(:,1),UsedData(:,3));

hf = figure;
plot(UsedData(:,1),UsedData(:,3),'ko','MarkerSize',9,'linewidth',2);
FigAxes = figaxesScaleUni(gca);
AxesScales = get(FigAxes,'xlim');
line(AxesScales,AxesScales,'Color',[.7 .7 .7],'linewidth',1.6,'Linestyle','--');
xlabel('TaskAmp \DeltaF/F_0 (%)');
ylabel('PassAmp \DeltaF/F_0 (%)');
title(sprintf('Task %.1f, Pass %.1f, p = %.3e',mean(UsedData(:,1)),mean(UsedData(:,3)),Categp));
set(gca,'FontSize',15);
saveas(hf,'NoSelectTunROI Amp Compare plots');
saveas(hf,'NoSelectTunROI Amp Compare plots','png');
saveas(hf,'NoSelectTunROI Amp Compare plots','pdf');

