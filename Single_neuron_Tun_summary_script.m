clear 
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the task session path');
filepath = fullfile(fp,fn);
fid = fopen(filepath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    DataStrcPath = fullfile(tline,'Spike_Tunfun_plot\TunningDataSave.mat');
    DataIndsPath = fullfile(tline,'Spike_Tunfun_plot\Curve fitting plots\CellCategorySave.mat');
    SavePath = fullfile(tline,'Spike_Tunfun_plot\Curve fitting plots');
    cd(SavePath);
    
    DataStrc = load(DataStrcPath);
    DataIndexStrc = load(DataIndsPath);
    DataTaskSessTun = DataStrc.CorrTunningFun;
    DataPassSessTun = DataStrc.PassTunningfun;
    DataTaskOctave = DataStrc.TaskFreqOctave;
    DataPassOctave = DataStrc.PassFreqOctave;
    
    DataCagIndex = DataIndexStrc.CategROiinds;
    DataTunIndex = DataIndexStrc.TunROIInds;
    nROIAll = size(DataTaskSessTun,2);
    nCagROINum = length(DataCagIndex);
    nTunROINum = length(DataTunIndex);
    ROInumArray = [nROIAll,nCagROINum,nTunROINum];
    
    % plot the categorical ROI mean tuning curve
    TaskGrNum = floor(numel(DataTaskOctave)/2);
    PassGrNum = floor(numel(DataPassOctave)/2);
    TaskCagROIData = DataTaskSessTun(:,DataCagIndex);
    PassCagROIData = DataPassSessTun(:,DataCagIndex);
      % reverse the response side
      TaskPreferCagROIdata = TaskCagROIData;
      RevROIInds = mean(TaskPreferCagROIdata(1:TaskGrNum,:)) > mean(TaskPreferCagROIdata(end-TaskGrNum+1:end,:));
      RevDataRaw = TaskPreferCagROIdata(:,RevROIInds);
      RevData = RevDataRaw;
      RevData(1:TaskGrNum,:) = RevDataRaw(end-TaskGrNum+1:end,:);
      RevData(end-TaskGrNum+1:end,:) = RevDataRaw(1:TaskGrNum,:);
      TaskPreferCagROIdata(:,RevROIInds) = RevData;
      
      PassPreferCagROIdata = PassCagROIData;
      PassRevDataRaw = PassPreferCagROIdata(:,RevROIInds);
      PassRevData = PassRevDataRaw;
      PassRevData(1:PassGrNum,:) = PassRevDataRaw((end-PassGrNum+1):end,:);
      PassRevData((end-PassGrNum+1):end,:) = PassRevDataRaw(1:PassGrNum,:);
      PassPreferCagROIdata(:,RevROIInds) = PassRevData;
      
      
    TaskCagMean = mean(TaskPreferCagROIdata,2);
    PassCagMean = mean(PassPreferCagROIdata,2);
    TaskCagSEM = std(TaskPreferCagROIdata,[],2)/sqrt(size(TaskPreferCagROIdata,2));
    PassCagSEM = std(PassPreferCagROIdata,[],2)/sqrt(size(PassPreferCagROIdata,2));
    hCagF = figure;
    hold on
    l1 = errorbar(DataTaskOctave,TaskCagMean,TaskCagSEM,'r-o','linewidth',1.8);
    l2 = errorbar(DataPassOctave,PassCagMean,PassCagSEM,'k-o','linewidth',1.8);
    xlabel('Frequency (Oct.)');
    ylabel('Spike Rate');
    set(gca,'FontSize',16);
    legend([l1,l2],{'Task','Passive'},'FontSize',14);
    saveas(hCagF,'Categprical ROIs tuning curve');
    saveas(hCagF,'Categprical ROIs tuning curve','png');
    saveas(hCagF,'Categprical ROIs tuning curve','pdf');
    close(hCagF);
    
    % plot the tuned ROI mean tuning curve
    TaskTunROIData = DataTaskSessTun(:,DataTunIndex);
    PassTunROIData = DataPassSessTun(:,DataTunIndex);
    TaskTunMean = mean(TaskTunROIData,2);
    PassTunMean = mean(PassTunROIData,2);
    TaskTunSEM = std(TaskTunROIData,[],2)/sqrt(size(TaskTunROIData,2));
    PassTunSEM = std(PassTunROIData,[],2)/sqrt(size(PassTunROIData,2));
    hTunF = figure;
    hold on
    l1 = errorbar(DataTaskOctave,TaskTunMean,TaskTunSEM,'r-o','linewidth',1.8);
    l2 = errorbar(DataPassOctave,PassTunMean,PassTunSEM,'k-o','linewidth',1.8);
    xlabel('Frequency (Oct.)');
    ylabel('Spike Rate');
    set(gca,'FontSize',16);
    legend([l1,l2],{'Task','Passive'},'FontSize',14);
    saveas(hTunF,'Tuning ROIs tuning curve');
    saveas(hTunF,'Tuning ROIs tuning curve','png');
    saveas(hTunF,'Tuning ROIs tuning curve','pdf');
    close(hTunF);
    
    save ROITypeData.mat TaskPreferCagROIdata PassPreferCagROIdata TaskTunROIData PassTunROIData DataTaskOctave DataPassOctave ROInumArray -v7.3
    
    tline = fgetl(fid);
end

%% summary of categorical ROI response
clear
clc
TaskCagNorDataAll = {};
PassCagNorDataAll = {};
TaskOctaveAll = {};
PsssOctaveAll = {};
m = 1;
[fn,fp,fi] = uigetfile('*.txt','Please select the task session path');
filepath = fullfile(fp,fn);
fid = fopen(filepath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    CagDataPath = fullfile(tline,'Spike_Tunfun_plot\Curve fitting plots\ROITypeData.mat');
    DataStrc = load(CagDataPath);
    TaskCagData = DataStrc.TaskPreferCagROIdata;
    TaskOctave = DataStrc.DataTaskOctave;
    PassCagData = DataStrc.PassPreferCagROIdata;
    PassOctave = DataStrc.DataPassOctave;
    
    MeanTaskResp = mean(TaskCagData,2);
    MeanPassResp = mean(PassCagData,2);
    
    disp(PassOctave');
    PassOctaveIndsRaw = input('Please select the used octave inds:\n','s');
    if isempty(PassOctaveIndsRaw)
        tline = fgetl(fid);
        continue;
    end
    PassOctaveInds = str2num(PassOctaveIndsRaw);
    PassOctused = PassOctave(PassOctaveInds);
    PassRespUsed = MeanPassResp(PassOctaveInds);
    
    if mod(numel(MeanTaskResp),2)
        MeanTaskResp(ceil(numel(MeanTaskResp)/2)) = [];
    end
    TaskCagNorDataAll{m} = MeanTaskResp/mean(MeanTaskResp);
    PassCagNorDataAll{m} = PassRespUsed/mean(PassRespUsed);
    TaskOctaveAll{m} = TaskOctave;
    PsssOctaveAll{m} = PassOctused;
    m = m + 1;
    tline = fgetl(fid);
end

%% plot of summarized-categorical ROI results
TaskNorAll = cell2mat(TaskCagNorDataAll);
PassNorAll = cell2mat(PassCagNorDataAll);
Octave = TaskOctaveAll{1};
TaskNorAllMean = mean(TaskNorAll,2);
PassNorAllMean = mean(PassNorAll,2);
TaskNorAllSEM = std(TaskNorAll,[],2)/sqrt(size(TaskNorAll,2));
PassNorAllSEM = std(PassNorAll,[],2)/sqrt(size(PassNorAll,2));
hf = figure;
hold on
ll1 = errorbar(Octave,TaskNorAllMean,TaskNorAllSEM,'r-o','linewidth',2);
ll2 = errorbar(Octave,PassNorAllMean,PassNorAllSEM,'k-o','linewidth',2);
xlabel('Frequency (Oct.)');
ylabel('Spike Rate');
set(gca,'FontSize',16);
legend([ll1,ll2],{'Task','Passive'},'FontSize',14,'location','northwest');
saveas(hf,'Averaged Session CagROI tuning curve');
saveas(hf,'Averaged Session CagROI tuning curve','png');
saveas(hf,'Averaged Session CagROI tuning curve','pdf');
% close(hf);
save TaskPassCagSave.mat TaskCagNorDataAll PassCagNorDataAll TaskOctaveAll PsssOctaveAll -v7.3
%% categorical ROI fraction calculation
clear 
clc
DataCellFrac = [];
m = 1;
[fn,fp,fi] = uigetfile('*.txt','Please select the task session path');
filepath = fullfile(fp,fn);
fid = fopen(filepath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    DataStrcPath = fullfile(tline,'Spike_Tunfun_plot\Curve fitting plots\CellCategorySave.mat');
    DataStrc = load(DataStrcPath);
    DataCellFrac(m,:) = [length(DataStrc.CategROiinds),length(DataStrc.TunROIInds),length(DataStrc.ROIisResponsive)];
    tline = fgetl(fid);
    m = m + 1;
end
CagROIFrac = DataCellFrac(:,1)./DataCellFrac(:,3);
save SessCagROIsave.mat CagROIFrac -v7.3

%% #################################################
%% summary of tuning ROI response
clear
clc
TaskTunNorDataAll = {};
PassTunNorDataAll = {};
TaskOctaveAll = {};
PsssOctaveAll = {};
AllROInumFrac = [];
TaskPeakAlignAll = {};
PassPeakAlignAll = {};
m = 1;
[fn,fp,fi] = uigetfile('*.txt','Please select the task session path');
filepath = fullfile(fp,fn);
fid = fopen(filepath);
tline = fgetl(fid);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    TunDataPath = fullfile(tline,'Spike_Tunfun_plot\Curve fitting plots\ROITypeData.mat');
    DataStrc = load(TunDataPath);
    TaskTunData = DataStrc.TaskTunROIData;
    TaskOctave = DataStrc.DataTaskOctave;
    PassTunData = DataStrc.PassTunROIData;
    PassOctave = DataStrc.DataPassOctave;
    
    MeanTaskResp = mean(TaskTunData,2);
    MeanPassResp = mean(PassTunData,2);
    AllROInumFrac(m,:) = DataStrc.ROInumArray;
    
    disp(PassOctave');
    PassOctaveIndsRaw = input('Please select the used octave inds:\n','s');
    if isempty(PassOctaveIndsRaw)
        tline = fgetl(fid);
        continue;
    end
    PassOctaveInds = str2num(PassOctaveIndsRaw);
    PassOctused = PassOctave(PassOctaveInds);
    PassRespUsed = MeanPassResp(PassOctaveInds);
    
    if mod(numel(MeanTaskResp),2)
        MeanTaskResp(ceil(numel(MeanTaskResp)/2)) = [];
        TaskTunData(ceil(numel(MeanTaskResp)/2),:) = [];
    end
    TaskTunNorDataAll{m} = MeanTaskResp/mean(MeanTaskResp);
    PassTunNorDataAll{m} = PassRespUsed/mean(PassRespUsed);
    TaskOctaveAll{m} = TaskOctave;
    PsssOctaveAll{m} = PassOctused;
    
    % aligned the response peak to the same position
    ROINum = size(TaskTunData,2);
    NumOctave = size(TaskTunData,1);
    TaskAlignDataSet = nan(NumOctave*2-1,ROINum);
    PassAlignDataSet = nan(NumOctave*2-1,ROINum);
    for nROI = 1 : ROINum
        TaskROIResp = TaskTunData(:,nROI);
        NorTaskROIResp = TaskROIResp/mean(TaskROIResp);
        [~,PeakInds] = max(NorTaskROIResp);
        TaskStartInds = (NumOctave - PeakInds) + 1;
        TaskAlignDataSet(TaskStartInds:(TaskStartInds+NumOctave-1),nROI) = NorTaskROIResp;
        
        PassROIResp = PassTunData(PassOctaveInds,nROI);
        NorPassResp = PassROIResp/mean(PassROIResp);
        [~,PeakInds] = max(NorPassResp);
        PassStartInds = (NumOctave - PeakInds) + 1;
        PassAlignDataSet(PassStartInds:(PassStartInds+NumOctave-1),nROI) = NorPassResp;
    end
    TaskPeakAlignAll{m} = TaskAlignDataSet;
    PassPeakAlignAll{m} = PassAlignDataSet;
    %
    m = m + 1;
    tline = fgetl(fid);
end
save TunDataSumSave.mat TaskTunNorDataAll PassTunNorDataAll TaskOctaveAll PsssOctaveAll AllROInumFrac TaskPeakAlignAll PassPeakAlignAll m -v7.3
%% plot of summarized-categorical ROI results
% m = m - 1;
TaskNorAll = cell2mat(TaskTunNorDataAll);
PassNorAll = cell2mat(PassTunNorDataAll);
Octave = TaskOctaveAll{1};
TaskNorAllMean = mean(TaskNorAll,2);
PassNorAllMean = mean(PassNorAll,2);
TaskNorAllSEM = std(TaskNorAll,[],2)/sqrt(size(TaskNorAll,2));
PassNorAllSEM = std(PassNorAll,[],2)/sqrt(size(PassNorAll,2));
hf = figure;
hold on
ll1 = errorbar(Octave,TaskNorAllMean,TaskNorAllSEM,'r-o','linewidth',2);
ll2 = errorbar(Octave,PassNorAllMean,PassNorAllSEM,'k-o','linewidth',2);
xlabel('Frequency (Oct.)');
ylabel('Spike Rate');
set(gca,'FontSize',16);
legend([ll1,ll2],{'Task','Passive'},'FontSize',14,'location','northwest');
saveas(hf,'Averaged Session Tuned ROI tuning curve');
saveas(hf,'Averaged Session Tuned ROI tuning curve','png');
saveas(hf,'Averaged Session Tuned ROI tuning curve','pdf');
% close(hf);

%% plot the aligned peak tuning curve for each session and then plot together
OctFromPeak = [-2,-1.6,-1.2,-0.8,-0.4,0,0.4,0.8,1.2,1.6,2];
nSession = m - 1;
SessTaskData = zeros(nSession,length(OctFromPeak));
SessPassData = zeros(nSession,length(OctFromPeak));
for nSess = 1 : nSession
    TaskData = TaskPeakAlignAll{nSess};
    PassData = PassPeakAlignAll{nSess};
    cSessROINum = AllROInumFrac(nSess,:);
    
    TaskDataNum = sum(double(~isnan(TaskData)),2);
    MeanTaskData = mean(TaskData,2,'omitnan');
    StdTaskData = (std(TaskData,[],2,'omitnan'))./sqrt(max(TaskDataNum,1));
    
    PassDataNum = sum(double(~isnan(PassData)),2);
    MeanPassData = mean(PassData,2,'omitnan');
    StdPassData = (std(PassData,[],2,'omitnan'))./sqrt(max(PassDataNum,1));
    
    SessTaskData(nSess,:) = MeanTaskData;
    SessPassData(nSess,:) = MeanPassData;
    
    %
    TaskNanInds = isnan(MeanTaskData);
    PassNanInds = isnan(MeanPassData);
    UsefulTaskDataMean = MeanTaskData(~TaskNanInds);
    UsefulTaskDataStd = StdTaskData(~TaskNanInds);
    UsefulTaskOct = OctFromPeak(~TaskNanInds);
    UsefulPassDataMean = MeanPassData(~PassNanInds);
    UsefulPassDataStd = StdPassData(~PassNanInds);
    UsefulPassOct = OctFromPeak(~PassNanInds);
    
    h_f = figure;
    hold on;
    hel1 = errorbar(UsefulTaskOct,UsefulTaskDataMean,UsefulTaskDataStd,'r-o','linewidth',1.6);
    hel2 = errorbar(UsefulPassOct,UsefulPassDataMean,UsefulPassDataStd,'k-o','linewidth',1.6);
    text(0,0.5,sprintf('%d/%d ROIs',cSessROINum(3),cSessROINum(1)),'FontSize',16,'HorizontalAlignment','center');
    legend([hel1,hel2],{'Task','Pass'},'FontSize',14);
    xlabel('Octave Dis From Peak');
    ylabel('Nor. Firing rate');
    title(sprintf('Session%d Aligned plot',nSess));
    set(gca,'FontSize',18);
    saveas(h_f,sprintf('Session%d Aligned tun plot',nSess));
    saveas(h_f,sprintf('Session%d Aligned tun plot',nSess),'png');
    saveas(h_f,sprintf('Session%d Aligned tun plot',nSess),'pdf');
    close(h_f);
end
save SessMeanSave.mat OctFromPeak nSession SessTaskData SessPassData -v7.3
%%
TaskDataNumAll = sum(double(~isnan(SessTaskData)));
MeanTaskDataAll = mean(SessTaskData,'omitnan');
StdTaskDataAll = (std(SessTaskData,'omitnan'))./sqrt(max(TaskDataNumAll,1));
TaskOctaveUsed = OctFromPeak(~isnan(MeanTaskDataAll));

PassDataNumAll = sum(double(~isnan(SessPassData)));
MeanPassDataAll = mean(SessPassData,'omitnan');
StdPassDataAll = (std(SessPassData,'omitnan'))./sqrt(max(PassDataNumAll,1));
PassOctaveused = OctFromPeak(~isnan(MeanPassDataAll));
%
hAllf = figure;
hold on
hll1 = errorbar(TaskOctaveUsed,MeanTaskDataAll,StdTaskDataAll,'r-o','LineWidth',1.7);
hll2 = errorbar(PassOctaveused,MeanPassDataAll,StdPassDataAll,'k-o','LineWidth',1.7);
text(0,0.5,sprintf('nSess = %d',nSession),'FontSize',16,'HorizontalAlignment','center');
legend([hll1,hll2],{'Task','Pass'},'FontSize',14);
xlabel('Octave Dis From Peak');
ylabel('Nor. Firing rate');
title('Across session Aligned plot');
set(gca,'FontSize',18);
saveas(hAllf,'MultiSession Aligned peak Tun plot');
saveas(hAllf,'MultiSession Aligned peak Tun plot','png');
saveas(hAllf,'MultiSession Aligned peak Tun plot','pdf');
% close(hAllf);