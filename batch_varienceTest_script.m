% batch variance test compare with randomness
% input data path
clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot\');
[fn,fp,fi] = uigetfile('*.txt','Please select All session data path');
if ~fi
    return;
end
%%
fPath = fullfile(fp,fn);
fid = fopen(fPath);
tline = fgetl(fid);
m = 1;
PassVarienceAll = [];
TaskVarienceAll = [];

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    %
    TunDataPath = fullfile(tline,'Tunning_fun_plot_New1s',...
        'CellType CP plot mean','TuningTypeIndexSave.mat');
    load(TunDataPath);
    ROITypeDataPath = fullfile(tline,'Tunning_fun_plot_New1s',...
        'CellType CP plot mean','cellTypeDataSave.mat');
    ROITypeDataStrc = load(ROITypeDataPath);
    ROIsigRespInds = ROITypeDataStrc.IIsResponsiveROI;
    
    RealVars = var(TaskMaxOctaves);
    RealSigvars = var(TaskMaxOctaves(ROIsigRespInds));
    OctTypes = unique(TaskMaxOctaves);
    RandDataRepeat = floor(numel(TaskMaxOctaves)/length(OctTypes));
    RandTypeData = repmat(OctTypes(:),1,RandDataRepeat);
    RandVars = var(RandTypeData(:));
    [~,Taskp] = vartest2(TaskMaxOctaves(:),RandTypeData(:));
    
    TaskVarienceAll(m,:) = [RealVars,RandVars,RealSigvars,Taskp];
    
    PassRealVar = var(PassMaxOct);
    PassSigVar = var(PassMaxOct(ROIsigRespInds));
    PassOctTypes = unique(PassMaxOct);
    PassRepeats = floor(numel(PassMaxOct)/length(PassOctTypes));
    PassRandData = repmat(OctTypes(:),1,PassRepeats);
    PassRandVar = var(PassRandData(:));
    [~,Passp] = vartest2(PassMaxOct,PassRandData(:));
    
    PassVarienceAll(m,:) = [PassRealVar,PassRandVar,PassSigVar,Passp];
    %
    tline = fgetl(fid);
    m = m + 1;
end
cd('E:\DataToGo\data_for_xu\SessionVarstest');
save SessVarsSum.mat PassVarienceAll TaskVarienceAll -v7.3
%% Passive test result plot
[~,PassvarP] = ttest(PassVarienceAll(:,1),PassVarienceAll(:,2));
hf = figure('position',[100 100 420 360]);
scatter(PassVarienceAll(:,1),PassVarienceAll(:,2),60,'ro','linewidth',2);
figaxesScaleUni(gca);
xlabel('Real varience');
ylabel('Rand varience');
title(sprintf('Passive p = %.4f',PassvarP));
set(gca,'FontSize',16);
saveas(hf,'Passive Session variance compare plot');
saveas(hf,'Passive Session variance compare plot','pdf');
saveas(hf,'Passive Session variance compare plot','png');

%% Task test result plot
[~,TaskvarP] = ttest(TaskVarienceAll(:,1),TaskVarienceAll(:,2));
hf = figure('position',[500 100 420 360]);
scatter(TaskVarienceAll(:,1),TaskVarienceAll(:,2),60,'ro','linewidth',2);
figaxesScaleUni(gca);
xlabel('Real varience');
ylabel('Rand varience');
title(sprintf('Task p = %.4f',TaskvarP));
set(gca,'FontSize',16);
saveas(hf,'Task Session variance compare plot');
saveas(hf,'Task Session variance compare plot','pdf');
saveas(hf,'Task Session variance compare plot','png');

%% task vartest bar plot
[~,TaskvarP] = ttest(TaskVarienceAll(:,1),TaskVarienceAll(:,2));
TaskVarAvg = mean(TaskVarienceAll(:,1:2));
TaskVarSEM = std(TaskVarienceAll(:,1:2))/sqrt(size(PassVarienceAll,1));
hf = figure('position',[500 100 420 360]);
hold on
bar(1,TaskVarAvg(1),0.5,'edgecolor','none','facecolor',[1 0.7 0.2]);
bar(2,TaskVarAvg(2),0.5,'edgecolor','none','facecolor',[.8 .8 .8]);
errorbar([1,2],TaskVarAvg,TaskVarSEM,'mo','linewidth',1.4,'Marker','none');
set(gca,'xtick',[1,2],'xticklabel',{'Real','Rand'},'xlim',[0.5 2.5],'ytick',0:0.1:0.5);
ylabel('Varience');
title(sprintf('Task p = %.4f',TaskvarP));
set(gca,'FontSize',16);
saveas(hf,'Task Session variance barplot');
saveas(hf,'Task Session variance barplot','pdf');
saveas(hf,'Task Session variance barplot','png');

%% passive vartest bar plot
[~,PassvarP] = ttest(PassVarienceAll(:,1),PassVarienceAll(:,2));
PassVarAvg = mean(PassVarienceAll(:,1:2));
PassVarSEM = std(PassVarienceAll(:,1:2))/sqrt(size(PassVarienceAll,1));
hf = figure('position',[100 100 420 360]);
hold on
bar(1,PassVarAvg(1),0.5,'edgecolor','none','facecolor','k');
bar(2,PassVarAvg(2),0.5,'edgecolor','none','facecolor',[.8 .8 .8]);
errorbar([1,2],PassVarAvg,PassVarSEM,'mo','linewidth',1.4,'Marker','none');
set(gca,'xtick',[1,2],'xticklabel',{'Real','Rand'},'xlim',[0.5 2.5],'ytick',0:0.1:0.5);
ylabel('Varience');
title(sprintf('Passive p = %.4f',PassvarP));
set(gca,'FontSize',16);
saveas(hf,'Pass Session variance barplot');
saveas(hf,'Pass Session variance barplot','pdf');
saveas(hf,'Pass Session variance barplot','png');

%% ###########################################################################################
%% task SigResponse vartest bar plot
[~,TaskvarP] = ttest(TaskVarienceAll(:,3),TaskVarienceAll(:,2));
TaskVarAvg = mean(TaskVarienceAll(:,[3,2]));
TaskVarSEM = std(TaskVarienceAll(:,[3,2]))/sqrt(size(PassVarienceAll,1));
hf = figure('position',[500 100 420 360]);
hold on
bar(1,TaskVarAvg(1),0.5,'edgecolor','none','facecolor',[1 0.7 0.2]);
bar(2,TaskVarAvg(2),0.5,'edgecolor','none','facecolor',[.8 .8 .8]);
errorbar([1,2],TaskVarAvg,TaskVarSEM,'mo','linewidth',1.4,'Marker','none');
set(gca,'xtick',[1,2],'xticklabel',{'Real','Rand'},'xlim',[0.5 2.5],'ytick',0:0.1:0.5);
ylabel('Varience');
title(sprintf('TaskSig p = %.4f',TaskvarP));
set(gca,'FontSize',16);
saveas(hf,'Task SigResp Session variance barplot');
saveas(hf,'Task SigResp Session variance barplot','pdf');
saveas(hf,'Task SigResp Session variance barplot','png');

%% passive SigResponse vartest bar plot
[~,PassvarP] = ttest(PassVarienceAll(:,3),PassVarienceAll(:,2));
PassVarAvg = mean(PassVarienceAll(:,[3,2]));
PassVarSEM = std(PassVarienceAll(:,[3,2]))/sqrt(size(PassVarienceAll,1));
hf = figure('position',[100 100 420 360]);
hold on
bar(1,PassVarAvg(1),0.5,'edgecolor','none','facecolor','k');
bar(2,PassVarAvg(2),0.5,'edgecolor','none','facecolor',[.8 .8 .8]);
errorbar([1,2],PassVarAvg,PassVarSEM,'mo','linewidth',1.4,'Marker','none');
set(gca,'xtick',[1,2],'xticklabel',{'Real','Rand'},'xlim',[0.5 2.5],'ytick',0:0.1:0.5);
ylabel('Varience');
title(sprintf('PassSig p = %.4f',PassvarP));
set(gca,'FontSize',16);
saveas(hf,'Pass SigResp Session variance barplot');
saveas(hf,'Pass SigResp Session variance barplot','pdf');
saveas(hf,'Pass SigResp Session variance barplot','png');

%%
%% task passive merged vartest bar plot
[~,TaskvarP] = ttest(TaskVarienceAll(:,1),TaskVarienceAll(:,2));
TaskVarAvg = mean(TaskVarienceAll(:,1:2));
TaskVarSEM = std(TaskVarienceAll(:,1:2))/sqrt(size(PassVarienceAll,1));
hf = figure('position',[500 100 520 360]);
hold on
bar(1,TaskVarAvg(1),0.5,'edgecolor','none','facecolor',[1 0.7 0.2]);
bar(3,TaskVarAvg(2),0.5,'edgecolor','none','facecolor',[.8 .8 .8]);
errorbar([1,3],TaskVarAvg,TaskVarSEM,'mo','linewidth',1.4,'Marker','none');

% passive vartest bar plot
[~,PassvarP] = ttest(PassVarienceAll(:,1),PassVarienceAll(:,2));
PassVarAvg = mean(PassVarienceAll(:,1:2));
PassVarSEM = std(PassVarienceAll(:,1:2))/sqrt(size(PassVarienceAll,1));
bar(2,PassVarAvg(1),0.5,'edgecolor','none','facecolor','k');
% bar(4,PassVarAvg(2),0.5,'edgecolor','none','facecolor',[.8 .8 .8]);
errorbar([2,4],PassVarAvg,PassVarSEM,'mo','linewidth',1.4,'Marker','none');
set(gca,'xtick',1:3,'xticklabel',{'Real','Real','Rand'},'xlim',[0.5 4.5],'ytick',0:0.1:0.5);
ylabel('Varience');
title(sprintf('Pass p = %.4f, Task p = %.4f',PassvarP,TaskvarP));
set(gca,'FontSize',16);
%%
saveas(hf,'Task and passive Session variance barplot');
saveas(hf,'Task and passive Session variance barplot','pdf');
saveas(hf,'Task and passive Session variance barplot','png');
