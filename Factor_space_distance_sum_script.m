DataSavePath = uigetdir('Please select your current data save path');
cd(DataSavePath);

%%
addchar = 'y';
TaskFactorData = {};
PassFactorData = {};
TaskTime = {};
PassTime = {};
PLotsTLRDis = {};
PlotsPLRDis = {};
m = 1;
while ~strcmpi(addchar,'n')
    [fn,fp,~] = uigetfile('FactorAnaData.mat','Please select your task factor analysis saved data');
    TaskPath = fullfile(fp,fn);
%     TaskPath = 'M:\batch\batch32\20160815\anm03\test02\im_data_reg_cpu\result_save\plot_save\Type2_f0_calculation\NO_Correction\mode_f_change\DimRed_Resplot\FactorAnaData.mat';
    TaskData = load(TaskPath);
    TaskTimeDataStrs = strrep(TaskPath,'FactorAnaData.mat','MeanPlotData.mat');
    TaskStartF = load(TaskTimeDataStrs,'start_frame');
    TimeStrings = {'xTimes','frame_rate'};
    TaskxTimes = load(TaskTimeDataStrs,TimeStrings{:});
    TaskxTimes.AlignedF = TaskStartF.start_frame;
    DataAll = TaskData.FSDataNorm;
    TLeftCorrData = DataAll(TaskData.LeftCorrInds,:,:);
    TRightCorrData = DataAll(TaskData.RightCorrInds,:,:);
    TLeftCorrMean = squeeze(mean(TLeftCorrData));
    TRightCorrMean = squeeze(mean(TRightCorrData));
    TaskFactorData{m} = TaskData;
    TaskTime{m} = TaskxTimes;
    %
    [fn,fp,~] = uigetfile('FactorAnaData.mat','Please select your passive factro analysis saved data');
    PassPath = fullfile(fp,fn);
%     PassPath = 'M:\batch\batch32\20160815\anm03\test02rf\im_data_reg_cpu\result_save\plot_save\NO_Correction\DimRed_Resplot\FactorAnaData.mat';
    PassData = load(PassPath);
    PassTimeStrs = strrep(PassPath,'FactorAnaData.mat','MeanPlotData.mat');
    PassStartF = load(PassTimeStrs,'start_frame');
    PassxTimes = load(PassTimeStrs,TimeStrings{:});
    PassxTimes.AlignedF = PassStartF.start_frame;
    DataAll = PassData.FSDataNorm;
    PLeftCorrData = DataAll(PassData.LeftCorrInds,:,:);
    PRightCorrData = DataAll(PassData.RightCorrInds,:,:);
    PLeftCorrMean = squeeze(mean(PLeftCorrData));
    PRightCorrMean = squeeze(mean(PRightCorrData));
    PassFactorData{m} = PassData;
    PassTime{m} = PassxTimes;
    %
    AlignFbeforeS = min([TaskStartF.start_frame,PassStartF.start_frame]);
    TaskmoveInds = TaskStartF.start_frame - AlignFbeforeS;
    PassmoveInds = PassStartF.start_frame - AlignFbeforeS;
    TaskAlignxtimes = TaskxTimes.xTimes((TaskmoveInds+1):end);
    PassAlignxtimes = PassxTimes.xTimes((TaskmoveInds+1):end);
    AlineTime = AlignFbeforeS/TaskxTimes.frame_rate;
    TLRDis = sqrt(sum((TLeftCorrMean - TRightCorrMean).^2));
    PLRDis = sqrt(sum((PLeftCorrMean - PRightCorrMean).^2));
    PlotTLRDis = TLRDis((TaskmoveInds+1):end);
    PlotPLRDis = PLRDis((TaskmoveInds+1):end);
    PLotsTLRDis{m} = PlotTLRDis;
    PlotsPLRDis{m} = PlotPLRDis;
    
    %
    h = figure;
    hold on;
    l1 = plot(TaskAlignxtimes,PlotTLRDis,'k','LineWidth',1.6);
    l2 = plot(PassAlignxtimes,PlotPLRDis,'r','LineWidth',1.6);
    yscales = get(gca,'ylim');
    line([AlineTime,AlineTime],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
    set(gca,'ylim',yscales);
    xlabel('Time(s)');
    ylabel('Mean trace difference')
    set(gca,'FontSize',18);
    legend([l1,l2],{'Task Mean Distance','Pass Mean Distance'},'FontSize',12);
    saveas(h,sprintf('Session%d factor space distance compare plot',m));
    saveas(h,sprintf('Session%d factor space distance compare plot',m),'png');
    close(h);
    
    addchar = input('Would you like to add another session data?\n','s');
    m = m + 1;
end

save FactorAnaDataSave.mat TaskFactorData TaskTime PassFactorData PassTime PLotsTLRDis PlotsPLRDis -v7.3

%%
m = m - 1;
TaskDataLen = cellfun(@length,PLotsTLRDis);
SelectLen = min(TaskDataLen);
TaskDataSum = zeros(m,SelectLen);
for nxnx = 1 : m
    TaskDataSum(nxnx,:) = PLotsTLRDis{nxnx}(1:SelectLen);
end
% TaskPlots = cell2mat(PLotsTLRDis');
PassPlots = cell2mat(PlotsPLRDis');
h_sumPlot = figure('position',[200 200 1000 800]);
hold on;
[hf,hp1,hl1] = MeanSemPlot(TaskDataSum,[],h_sumPlot,'k','LineWidth',1.6);
[hfsave,hp2,hl2] = MeanSemPlot(PassPlots,[],hf,'r','LineWidth',1.6);
yscales = get(gca,'ylim');
line([AlignFbeforeS AlignFbeforeS],yscales,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
set(gca,'FontSize',16,'xtick',0:55:SelectLen,'xTicklabel',0:(SelectLen/55));
set(hp1,'facecolor','k','facealpha',0.4);
set(hp2,'facecolor','r','facealpha',0.4);
xlabel('Time(s)');
ylabel('Mean Trace Distance');
title('Factor space distance');
legend([hl1,hl2],{'Task','Passive'},'FontSize',16);
saveas(hfsave,'Summarized compared plot of factor space distance');
saveas(hfsave,'Summarized compared plot of factor space distance','png');
close(hfsave);
save sumPlotDataSave.mat TaskDataSum PassPlots AlignFbeforeS frame_rate -v7.3