% this scripts is used for compared plot of task and passive response for
% each stimulus, also a single session version for multisession summary
% plots
clear
clc
% load task analysis data first
[fn,fp,fi] = uigetfile('FreqWiseRespSave.mat','Please select your task data analysis result');
TaskPath = fullfile(fp,fn);
cd(fp);
TaskRespData = load(fn);
TaskSelectROIinds = TaskRespData.SelectROIinds;
TaskFreq = double(TaskRespData.FreqTypes);
TaskSigROIFreqResp = TaskRespData.SigROIFreqResp;

% load Passive analysis data 
[fn,fp,fi] = uigetfile('UnevenPassdata.mat','Please select your passive data analysis result');
PassPath = fullfile(fp,fn);
PassiveRespData = load(PassPath);
PassiveDB = PassiveRespData.DBtypes;
PassiveFreq = double(PassiveRespData.FreqTypes);
PassiveTypeData = cellfun(@(x) RFcellfunRespCal(x,PassiveRespData.FrameRate,PassiveRespData.TimeStimOn),PassiveRespData.typeData);

%%
PassSelectDBInds = PassiveDB == 70;
PassSelectDBData = squeeze(PassiveTypeData(TaskSelectROIinds,PassSelectDBInds,:));

CompDatamatrix = zeros(length(TaskSelectROIinds),length(TaskFreq),2); % for the third dimension, the first dimension is task
   % response data, and the sescond dimension is passive data
CompDatamatrix(:,:,1) = TaskSigROIFreqResp;
for nf = 1 : length(TaskFreq)
    cTaskFreq = TaskFreq(nf);
    cPassInds = abs(log2(PassiveFreq/cTaskFreq)) < 0.2;
    cPassData = mean(PassSelectDBData(:,cPassInds),2);
    CompDatamatrix(:,nf,2) = cPassData;
end

%%
if ~isdir('./Response_compare_plots/')
    mkdir('./Response_compare_plots/');
end
cd('./Response_compare_plots/');

for nf = 1 : length(TaskFreq)
    TaskData = squeeze(CompDatamatrix(:,nf,1));
    PassData = squeeze(CompDatamatrix(:,nf,2));
    [h,p] = ttest(TaskData,PassData);
    [~,Coef,Rsqr,~,hf] = lmFunCalPlot(TaskData,PassData);
    xscales = get(gca,'xlim');
    yscales = get(gca,'ylim');
    LargeScale = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
    line(LargeScale,LargeScale,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
    text(xscales(2)*0.7,yscales(2)*0.7,sprintf('p = %.3f',p));
    set(gca,'xlim',LargeScale,'ylim',LargeScale);
    xlabel('Task Response')
    ylabel('Passive Response');
    title(sprintf('Freq = %d',TaskFreq(nf)));
    saveas(hf,sprintf('Frequency %d response plot',TaskFreq(nf)));
    saveas(hf,sprintf('Frequency %d response plot',TaskFreq(nf)),'png');
    close(hf);
end

%%
TaskFreqResp = squeeze(CompDatamatrix(:,:,1));
PassFreqResp = squeeze(CompDatamatrix(:,:,2));
[TaskMaxRespValue,TaskMaxRespInds] = max(TaskFreqResp,[],2);
PassMaxRespV = zeros(length(TaskMaxRespValue),1);
for nnmm = 1 : length(TaskMaxRespValue)
    PassMaxRespV(nnmm) = PassFreqResp(nnmm,TaskMaxRespInds(nnmm));
end
% PassMaxRespV = PassFreqResp(:,TaskMaxRespInds);
% h_maxResp = figure;
[~,CoefMax,RsqrMax,~,h_maxResp] = lmFunCalPlot(TaskMaxRespValue,PassMaxRespV);
[~,pMax] = ttest(TaskMaxRespValue,PassMaxRespV);
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
LargeScale = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
line(LargeScale,LargeScale,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
text(xscales(2)*0.7,yscales(2)*0.7,sprintf('p = %.3f',pMax));
set(gca,'xlim',LargeScale,'ylim',LargeScale);
xlabel('Task max Response')
ylabel('Passive max Response');

saveas(h_maxResp,'Task MaxResp compare plot');
saveas(h_maxResp,'Task MaxResp compare plot','png');
close(h_maxResp);
save MaxRespCompData.mat TaskMaxRespValue PassMaxRespV -v7.3

%%
% the following section is used for summarized plots of differnt session
% data 
DataPath = {};
DataSum = {};
m = 1;
TaskDataSum = [];
PassDataSum = [];
addchar = 'y';

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('MaxRespCompData.mat','Please select one session analysis result');
    if ~fi
        continue;
    end
    TotalData = load(fullfile(fp,fn));
    DataPath{m} = fullfile(fp,fn);
    DataSum{m} = TotalData;
    TaskDataSum = [TaskDataSum;TotalData.TaskMaxRespValue];
    PassDataSum = [PassDataSum;TotalData.PassMaxRespV];
    
    addchar = input('Would you like to add another session data?\n','s');
    m = m + 1;
end

%%
SavePath = uigetdir('Please select current data save path');
cd(SavePath);
m = m - 1;
f = fopen('Compared_resp_DataPath.txt','w');
fprintf(f,'Sessions path for compared response summary plot:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,DataPath{nbnb});
end
fclose(f);
save SessionDataSum.mat DataSum TaskDataSum PassDataSum -v7.3

%%
ExcludeInds = TaskDataSum > 2000 | PassDataSum > 2000;
TaskDataSum(ExcludeInds) = [];
PassDataSum(ExcludeInds) = [];
[~,CoefSum,RsqrSum,~,h_SumResp] = lmFunCalPlot(TaskDataSum,PassDataSum);
[~,pSum] = ttest(TaskDataSum,PassDataSum);
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
LargeScale = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
line(LargeScale,LargeScale,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
text(xscales(2)*0.7,yscales(2)*0.7,sprintf('p = %.3f',pMax));
set(gca,'xlim',LargeScale,'ylim',LargeScale);
xlabel('Summarized Task max Response')
ylabel('Summarized Passive max Response');

%%
saveas(h_SumResp,'Summarized Task and passive response plot');
saveas(h_SumResp,'Summarized Task and passive response plot','png');
close(h_SumResp);
cd ..;
%%  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
% multi-timescale plots
clear
clc

[fn,fp,fi] = uigetfile('MultiWinSave.mat','Please select the data file that contains the task time scale data for all time scales');
TaskPath = fullfile(fp,fn);
cd(fp);
TaskDataAll = load(fn);
taskFreqAll = TaskDataAll.TrialStimFreq(TaskDataAll.TrialInds);
TaskTrialDataAll = TaskDataAll.dataligned(TaskDataAll.TrialInds,:,:);
TaskData = TaskDataAll.dataligned;
TimeScales = TaskDataAll.TimeScales;
Frate = TaskDataAll.FrameRate;
AlignedFrame = TaskDataAll.alignF;

% load Passive analysis data 
[fn,fp,fi] = uigetfile('UnevenPassdata.mat','Please select your passive data analysis result');
PassPath = fullfile(fp,fn);
PassiveRespData = load(PassPath);
PassiveDB = PassiveRespData.DBtypes;
PassiveFreq = double(PassiveRespData.FreqTypes);
% PassiveTypeData = cellfun(@(x) RFcellfunRespCal(x,PassiveRespData.FrameRate,PassiveRespData.TimeStimOn),PassiveRespData.typeData);
%%
PassSelectDBInds = PassiveDB == 70;
PassDBData = squeeze(PassiveRespData.typeData(:,PassSelectDBInds,:));  % nROI by nfreq cell data
%
nROIs = min([size(TaskData,2),size(PassDBData,1)]);

TaskFreqTypes = unique(taskFreqAll);
nTaskFreq = length(TaskFreqTypes);
% nROIs = size(PassDBData,1);
cPassDataFreqWise = cell(nROIs,nTaskFreq);
cTaskDataFreqWise = cell(nROIs,nTaskFreq);
EmptyPassFreq = zeros(nTaskFreq,1);
for nfs = 1 : nTaskFreq
    % passive data generation
    cFreq = TaskFreqTypes(nfs);
    cPassFreqInds = abs(log2(PassiveFreq/cFreq)) < 0.2;
    if ~sum(cPassFreqInds)
        EmptyPassFreq(nfs) = 1;
        continue;
    end
    cPassFreqDatacell = PassDBData(1:nROIs,cPassFreqInds);
    if size(cPassFreqDatacell,2) > 1
        cPFreqCell = cell(nROIs,1);
        for nROI = 1 : nROIs
            cROIdata = cPassFreqDatacell(nROI,:);
            TogetherFreqData = cell2mat(cROIdata(:));
            cPFreqCell{nROI} = TogetherFreqData;
        end
        cPassFreqDatacell = cPFreqCell;  % nROI-by-1 cell data
    end
    cPassDataFreqWise(:,nfs) = cPassFreqDatacell;
    
    % task data generation
    TaskTrFreqInds = taskFreqAll == cFreq;
    cFDataSet = TaskData(TaskTrFreqInds,:,:);
    for nROI = 1 : nROIs
        cTaskDataFreqWise{nROI,nfs} = squeeze(cFDataSet(:,nROI,:));
    end 
end
%
if sum(EmptyPassFreq)
    EmptyPassFreq = logical(EmptyPassFreq);
    cPassDataFreqWise(:,EmptyPassFreq) = [];
    cTaskDataFreqWise(:,EmptyPassFreq) = [];
    TaskFreqTypes(EmptyPassFreq) = [];
    nTaskFreq = length(TaskFreqTypes);
end

%%
if ~isdir('./All_ROI_comparePlot_PassMax/')
    mkdir('./All_ROI_comparePlot_PassMax/');
end
cd('./All_ROI_comparePlot_PassMax/');

nTimes = length(TimeScales);
PassRespDataAllT = cell(nTimes,1);
TaskRespDataAllT = cell(nTimes,1);
RankTestAllT = cell(nTimes,1);
for nmnm = 1 : nTimes
    cTimes = TimeScales{nmnm};
    cFrameScale = round(cTimes*Frate);
    PassRespData = cellfun(@(x) timeDataExtraction(x,cFrameScale,Frate),cPassDataFreqWise);
    TaskRespData = cellfun(@(x) timeDataExtraction(x,cFrameScale,AlignedFrame),cTaskDataFreqWise);
    PassRespDataAllT{nmnm} = PassRespData;
    TaskRespDataAllT{nmnm} = TaskRespData;
    
    PassRespSingleTrData = cellfun(@(x) SingleTrMeanExtra(x,cFrameScale,Frate),cPassDataFreqWise,'UniformOutput', false);
    TaskRespSingleTrData = cellfun(@(x) SingleTrMeanExtra(x,cFrameScale,AlignedFrame),cTaskDataFreqWise,'UniformOutput', false);
    RankTestP = cellfun(@(x,y) ranksum(x,y),PassRespSingleTrData,TaskRespSingleTrData);
    RankTestAllT{nmnm} = RankTestP;
    StaticticSigInds = RankTestP < 0.05;
    %
    cTimeFolder = sprintf('./Time_scale%d_AllFreq_plot/',nmnm);
    if ~isdir(cTimeFolder)
        mkdir(cTimeFolder);
    end
    cd(cTimeFolder);
    %
    nFreqs = size(PassRespData,2);
    for nxnx = 1 : nFreqs
        FreqPassRespData = PassRespData(:,nxnx);
        FreqTaskRespData = TaskRespData(:,nxnx);
        
%         hf = figure;
%         hold on;
%         cFreqIsSig = StaticticSigInds(:,nxnx);
%         scatter(FreqTaskRespData,FreqPassRespData,60,'ro','LineWidth',1);
%         scatter(FreqTaskRespData(cFreqIsSig),FreqPassRespData(cFreqIsSig),40,'bp','LineWidth',1);
%         xscales = get(gca,'xlim');
%         yscales = get(gca,'ylim');
%         SelectScales = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
%         line(SelectScales,SelectScales,'color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
%         set(gca,'xlim',SelectScales,'ylim',SelectScales);
%         [~,p] = ttest(FreqTaskRespData,FreqPassRespData);
%         title({sprintf('Freq = %d',TaskFreqTypes(nxnx)),sprintf('p = %.3f',p)});
%         xlabel('Task Response');
%         ylabel('Passive Response');
%         set(gca,'FontSize',18);
%         
%         saveas(hf,sprintf('Freq%d response compara plot',TaskFreqTypes(nxnx)));
%         saveas(hf,sprintf('Freq%d response compara plot',TaskFreqTypes(nxnx)),'png');
%         close(hf);
    end
    save AllFreqCompData.mat PassRespData TaskRespData TaskFreqTypes -v7.3
    
    [PassMaxValue,PassMaxInds] = max(PassRespData,[],2);  % using passive data maximum response value
    TaskMaxValue = zeros(length(PassMaxInds),1);
    IsValueSig = zeros(length(PassMaxInds),1);
    for nnnnn = 1 : length(PassMaxInds)
        TaskMaxValue(nnnnn) = TaskRespData(nnnnn,PassMaxInds(nnnnn));
        IsValueSig(nnnnn) = StaticticSigInds(nnnnn,PassMaxInds(nnnnn));
    end
    IsValueSig = logical(IsValueSig);
    
    hfMax = figure;
    hold on;
    scatter(TaskMaxValue,PassMaxValue,60,'ro','LineWidth',1);
    scatter(TaskMaxValue(IsValueSig),PassMaxValue(IsValueSig),40,'bp','LineWidth',1);
    xscales = get(gca,'xlim');
    yscales = get(gca,'ylim');
    SelectScales = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
    line(SelectScales,SelectScales,'color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
    set(gca,'xlim',SelectScales,'ylim',SelectScales);
    [~,p] = ttest(TaskMaxValue,PassMaxValue);
    title(sprintf('p = %.3f',p));
    xlabel('Task Response');
    ylabel('Passive Response');
    set(gca,'FontSize',18);
    saveas(hfMax,'Passive Max Resp Scatter plot');
    saveas(hfMax,'Passive Max Resp Scatter plot','png');
    close(hfMax);
    %
    cd ..;
end
save CompDataSave.mat PassRespDataAllT TaskRespDataAllT RankTestAllT TaskFreqTypes -v7.3
cd ..;

%%
if ~isdir('./All_ROI_comparePlot_TaskMax/')
    mkdir('./All_ROI_comparePlot_TaskMax/');
end
cd('./All_ROI_comparePlot_TaskMax/');

nTimes = length(TimeScales);
for nmnm = 1 : nTimes
    cTimes = TimeScales{nmnm};
    cFrameScale = round(cTimes*Frate);
    PassRespData = cellfun(@(x) timeDataExtraction(x,cFrameScale,Frate),cPassDataFreqWise);
    TaskRespData = cellfun(@(x) timeDataExtraction(x,cFrameScale,AlignedFrame),cTaskDataFreqWise);
    
     PassRespSingleTrData = cellfun(@(x) SingleTrMeanExtra(x,cFrameScale,Frate),cPassDataFreqWise,'UniformOutput', false);
    TaskRespSingleTrData = cellfun(@(x) SingleTrMeanExtra(x,cFrameScale,AlignedFrame),cTaskDataFreqWise,'UniformOutput', false);
    RankTestP = cellfun(@(x,y) ranksum(x,y),PassRespSingleTrData,TaskRespSingleTrData);
    StaticticSigInds = RankTestP < 0.05;
    %
    cTimeFolder = sprintf('./Time_scale%d_AllFreq_plot/',nmnm);
    if ~isdir(cTimeFolder)
        mkdir(cTimeFolder);
    end
    cd(cTimeFolder);
    %
    nFreqs = size(PassRespData,2);
    for nxnx = 1 : nFreqs
        FreqPassRespData = PassRespData(:,nxnx);
        FreqTaskRespData = TaskRespData(:,nxnx);
        
        hf = figure;
        hold on;
        cFreqIsSig = StaticticSigInds(:,nxnx);
        scatter(FreqTaskRespData,FreqPassRespData,60,'ro','LineWidth',1);
        scatter(FreqTaskRespData(cFreqIsSig),FreqPassRespData(cFreqIsSig),40,'bp','LineWidth',1);
        xscales = get(gca,'xlim');
        yscales = get(gca,'ylim');
        SelectScales = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
        line(SelectScales,SelectScales,'color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
        set(gca,'xlim',SelectScales,'ylim',SelectScales);
        [~,p] = ttest(FreqTaskRespData,FreqPassRespData);
        title({sprintf('Freq = %d',TaskFreqTypes(nxnx)),sprintf('p = %.3f',p)});
        xlabel('Task Response');
        ylabel('Passive Response');
        set(gca,'FontSize',18);
        
        saveas(hf,sprintf('Freq%d response compara plot',TaskFreqTypes(nxnx)));
        saveas(hf,sprintf('Freq%d response compara plot',TaskFreqTypes(nxnx)),'png');
        close(hf);
    end
    save AllFreqCompData.mat PassRespData TaskRespData TaskFreqTypes -v7.3
    
    [TaskMaxValue,TaskMaxInds] = max(TaskRespData,[],2);  % using passive data maximum response value
    PassMaxValue = zeros(length(TaskMaxInds),1);
     IsValueSig = zeros(length(PassMaxInds),1);
    for nnnnn = 1 : length(PassMaxInds)
        PassMaxValue(nnnnn) = PassRespData(nnnnn,TaskMaxInds(nnnnn));
        IsValueSig(nnnnn) = StaticticSigInds(nnnnn,PassMaxInds(nnnnn));
    end
    IsValueSig = logical(IsValueSig);
    
    hfMax = figure;
    hold on;
    scatter(TaskMaxValue,PassMaxValue,60,'ro','LineWidth',1);
    scatter(TaskMaxValue(IsValueSig),PassMaxValue(IsValueSig),40,'bp','LineWidth',1);
    xscales = get(gca,'xlim');
    yscales = get(gca,'ylim');
    SelectScales = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
    line(SelectScales,SelectScales,'color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
    set(gca,'xlim',SelectScales,'ylim',SelectScales);
    [~,p] = ttest(TaskMaxValue,PassMaxValue);
    title(sprintf('p = %.3f',p));
    xlabel('Task Response');
    ylabel('Passive Response');
    set(gca,'FontSize',18);
    saveas(hfMax,'Task Max Resp Scatter plot');
    saveas(hfMax,'Task Max Resp Scatter plot','png');
    close(hfMax);
    %
    cd ..;
end
% save CompDataSave.mat PassRespData TaskRespData RankTestP TaskFreqTypes -v7.3
cd ..;

