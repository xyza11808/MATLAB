clear
clc
cd('D:\data\xinyu\Data');
[TaskPathfn,TaskPathfp,TaskPathfi] = uigetfile('*.txt','Please select the Task session path save file');
[PassPathfn,PassPathfp,PassPathfi] = uigetfile('*.txt','Please select the corresponded passive session path save file');
if ~TaskPathfi || ~PassPathfi
    return;
end
%%
TaskPathf = fullfile(TaskPathfp,TaskPathfn);
PassPathf = fullfile(PassPathfp,PassPathfn);
Taskfid =  fopen(TaskPathf);
Passfid = fopen(PassPathf);
TaskLine = fgetl(Taskfid);
PassLine = fgetl(Passfid);
SessionNum = 1;
TaskClfDataAll = {};
PassClfDataAll = {};
%%
while ischar(TaskLine) && ischar(PassLine)
    if isempty(strfind(TaskLine,'NO_Correction\mode_f_change'))  
        TaskLine = fgetl(Taskfid);
        PassLine = fgetl(Passfid);
        continue;
    end
    %
    clearvars SpikeAligned behavResults frame_rate
    NewTaskLine = ['D:\data\xinyu\Data\',TaskLine(4:end)];
    
    load(fullfile(NewTaskLine,'EstimateSPsaveNew.mat'));
    cd(NewTaskLine);
    CSPData = SpikeAligned;
    TestData = squeeze(CSPData(1:3,1,:));
    if sum(isnan(TestData(:)))
        warning('Nan data exists, using minimum valuable data.\n');
        FrameNum = cellfun(@(x) size(x,2),nnspike);
        UsedF = min(FrameNum);
        CSPData = SpikeAligned(:,:,1:UsedF);
    end
    if ~isdir('./EM_spike_analysis/')
          mkdir('./EM_spike_analysis/');
      end
      cd('./EM_spike_analysis/');
      TrTones = double(behavResults.Stim_toneFreq(:));
      trial_outcome = double(behavResults.Trial_Type(:) == behavResults.Action_choice(:));
     SessClfData = MultiTimeWinClass(CSPData,TrTones,trial_outcome,start_frame,frame_rate,1,0.1);
    %
      TaskClfDataAll{SessionNum} = SessClfData;
      
    clearvars PassSpike frame_rate SelectSArray
    NewPassLine = ['D:\data\xinyu\Data\',PassLine(4:end)];
    load(fullfile(NewPassLine,'EsSpikeSaveNew.mat'));
    cd(NewPassLine);
    TrOutcomes = ones(numel(SelectSArray),1);
    if exist('PassSpike','var')
        PassClfData = MultiTimeWinClass(PassSpike,SelectSArray,TrOutcomes,frame_rate,frame_rate,1,0.1);
    else
        PassClfData = MultiTimeWinClass(nnspike,SelectSArray,TrOutcomes,frame_rate,frame_rate,1,0.1);
    end
    
    PassClfDataAll{SessionNum} = PassClfData;
    %
    TaskLine = fgetl(Taskfid);
    PassLine = fgetl(Passfid);
    SessionNum = SessionNum + 1;
end

cd('D:\data\xinyu\Data\Summary\SpikePopuClf');
save SessClfDataSavenew.mat TaskClfDataAll PassClfDataAll -v7.3

%%
TaskSessTimeScales = (cellfun(@(x) x.TimeScale,TaskClfDataAll,'Uniformoutput',false))';
TaskSessDatas = (cellfun(@(x) x.TimeAccu,TaskClfDataAll,'Uniformoutput',false))';
TaskSessInfo = (cellfun(@(x) x.TimeInfo,TaskClfDataAll,'Uniformoutput',false))';

PassSessTimeScales = (cellfun(@(x) x.TimeScale,PassClfDataAll,'Uniformoutput',false))';
PassSessDatas = (cellfun(@(x) x.TimeAccu,PassClfDataAll,'Uniformoutput',false))';
PassSessInfo = (cellfun(@(x) x.TimeInfo,PassClfDataAll,'Uniformoutput',false))';

TaskSessTimeIndex = cellfun(@length,TaskSessTimeScales);
PassSessTimeIndex = cellfun(@length,PassSessTimeScales);
TaskMinF = min(TaskSessTimeIndex);
PassMinF = min(PassSessTimeIndex);

%%
TaskSessUsedTScales = (cellfun(@(x) x.TimeScale(1:TaskMinF),TaskClfDataAll,'Uniformoutput',false))';
PassSessUsedTScales = (cellfun(@(x) x.TimeScale(1:PassMinF),PassClfDataAll,'Uniformoutput',false))';
TaskSessUsedDatas = (cellfun(@(x) mean(x.TimeAccu(1:TaskMinF,:),2),TaskClfDataAll,'Uniformoutput',false));
PassSessUsedDatas = (cellfun(@(x) mean(x.TimeAccu(1:PassMinF,:),2),PassClfDataAll,'Uniformoutput',false));

TaskUsedDatasMtx = 1 - (cell2mat(TaskSessUsedDatas))';
TaskTimes = TaskSessUsedTScales{1};
PassUsedDatasMtx = 1 - (cell2mat(PassSessUsedDatas))';
PassTimes = PassSessUsedTScales{1};
[~,TaskMaxInds] = max(TaskUsedDatasMtx,[],2);
TaskPeakTime = TaskTimes(TaskMaxInds);

[~,PassMaxInds] = max(PassUsedDatasMtx,[],2);
PassPeakTime = PassTimes(PassMaxInds);

TaskDataAvg = mean(TaskUsedDatasMtx);
TaskDataSEM = std(TaskUsedDatasMtx)/sqrt(size(TaskUsedDatasMtx,1));
PassDataAvg = mean(PassUsedDatasMtx);
PassDataSEM = std(PassUsedDatasMtx)/sqrt(size(PassUsedDatasMtx,1));
nSess = size(TaskUsedDatasMtx,1);

hhf = figure('position',[100 100 340 260]);
hold on
TaskyP = [TaskDataAvg - TaskDataSEM,fliplr(TaskDataAvg + TaskDataSEM)];
TaskxP = [TaskTimes,fliplr(TaskTimes)];
PassyP = [PassDataAvg - PassDataSEM,fliplr(PassDataAvg + PassDataSEM)];
PassxP = [PassTimes,fliplr(PassTimes)];

patch(TaskxP,TaskyP,1,'FaceColor',[1 0.7 0.2],'EdgeColor','none','FaceAlpha',0.4);
patch(PassxP,PassyP,1,'FaceColor',[0.7 0.7 0.7],'EdgeColor','none','FaceAlpha',0.4);
plot(TaskTimes,TaskDataAvg,'Color',[1 0.6 0.2],'Linewidth',2);
plot(PassTimes,PassDataAvg,'Color',[.7 .7 .7],'Linewidth',2);
line([0 0],[0.4 1],'Color',[.7 .7 .7],'Linewidth',1.6,'Linestyle','--');
set(gca,'ytick',[0.5 1],'xlim',[-0.6 ceil(max(TaskTimes(end),PassTimes(end)))]);
xlabel('Time(s)');
ylabel('Accuracy');
title(sprintf('N = %d',nSess));
set(gca,'FontSize',14);
% saveas(hhf,'Spike Data popultion decoding analysis');
% saveas(hhf,'Spike Data popultion decoding analysis','pdf');
%%
[Count,Center] = hist(TaskPeakTime,10);
[PCount,PCenter] = hist(PassPeakTime,10);
hf = figure('position',[100 100 320 240]);
hold on
plot(Center,Count,'Color',[1 0.7 0.2],'Linewidth',1.6);
plot(PCenter,PCount,'Color',[0.7 0.7 0.7],'Linewidth',1.6);
cyScales = get(gca,'ylim');
line([mean(TaskPeakTime) mean(TaskPeakTime)],cyScales,'Color',[1 .7 .2],'linewidth',1.4,'Linestyle','--');
line([mean(PassPeakTime) mean(PassPeakTime)],cyScales,'Color',[.7 .7 .7],'linewidth',1.4,'Linestyle','--');
set(gca,'ylim',cyScales);
title('Peak Time distribution');
set(gca,'FontSize',14);

%%
ExampleSess = 1;
ExampleSessData = TaskSessDatas{ExampleSess};
% PrcData = prctile(1 - ExampleSessData',[2.5,97.5]);
SEMs = std(1 - ExampleSessData')/sqrt(1000);
ts = tinv([0.025 0.975],999);

CI = repmat(mean(1 - ExampleSessData'),2,1) + ts' * SEMs * 5;
AvgDatas = 1 - mean(ExampleSessData,2);

PassSessData = PassSessDatas{ExampleSess};
PassSessTime = PassSessTimeScales{ExampleSess};
PassSEMs = std(1 - PassSessData')/sqrt(1000);
PassCI = repmat(mean(1 - PassSessData'),2,1) + ts' * PassSEMs * 5;
PassAvgData = 1 - mean(PassSessData,2);

ExampleSessTime = TaskSessTimeScales{ExampleSess};
BaseLineData = reshape(ExampleSessData(1:5,:),[],1);
BaseSigThres = prctile(BaseLineData,[95,99]);
Prc95Patchx = [ExampleSessTime,fliplr(ExampleSessTime)];
% Prc95Patchy = [PrcData(1,:),fliplr(PrcData(2,:))];
Prc95Patchy = [CI(1,:),fliplr(CI(2,:))];
[~,MaxInds] = max(AvgDatas);
PassCIPatch = [PassCI(1,:),fliplr(PassCI(2,:))];
PassPatchx = [PassSessTime,fliplr(PassSessTime)];

hhhf = figure('position',[100 100 320 250]);
hold on
patch(Prc95Patchx,Prc95Patchy,1,'FaceColor',[1 0.7 0.2],'EdgeColor','none','FaceAlpha',0.4);
plot(ExampleSessTime,AvgDatas,'Color',[1 0.7 0.2],'Linewidth',1.6);
patch(PassPatchx,PassCIPatch,1,'FaceColor',[.6 .6 .6],'EdgeColor','none','FaceAlpha',0.4);
plot(PassSessTime,PassAvgData,'k','Linewidth',1.6);
yscales = get(gca,'ylim');
xscales = [-0.6 ceil(ExampleSessTime(end))];
line(xscales,[BaseSigThres(1) BaseSigThres(1)],'Color','m','linewidth',1.2,'linestyle','--');
line(ExampleSessTime([MaxInds MaxInds]),yscales,'Color','c','linewidth',1.2,'linestyle','--')
set(gca,'xlim',xscales,'ylim',yscales);

AboveThresInds = find(AvgDatas > BaseSigThres(1),1,'first');
cSessInds = [AboveThresInds,MaxInds];
cSessTimes = ExampleSessTime(cSessInds);
xlabel('Time (s)');
ylabel('Accuracy');
set(gca,'FontSize',12);
%%
saveas(hhhf,'Example session Plot save');
saveas(hhhf,'Example session Plot save','png');
saveas(hhhf,'Example session Plot save','pdf');


%% extract every session data 
SessIndsAll = zeros(length(TaskSessDatas),4);
PassSessIndsAll = zeros(length(TaskSessDatas),4);
for cSess = 1 : length(TaskSessDatas)
    ExampleSessData = TaskSessDatas{cSess};
%     PrcData = prctile(1 - ExampleSessData',[2.5,97.5]);
    AvgDatas = 1 - mean(ExampleSessData,2);
    ExampleSessTime = TaskSessTimeScales{cSess};
    BaseLineData = reshape(ExampleSessData(1:5,:),[],1);
    BaseSigThres = prctile(BaseLineData,[95,99]);
    [MaxValue,MaxInds] = max(AvgDatas);

%     hhhf = figure;
%     hold on
%     patch(Prc95Patchx,Prc95Patchy,1,'FaceColor',[.6 .6 .6],'EdgeColor','none','FaceAlpha',0.4);
%     plot(ExampleSessTime,AvgDatas,'k','Linewidth',1.6);
%     yscales = get(gca,'ylim');
%     xscales = [-0.6 ceil(ExampleSessTime(end))];
%     line(xscales,[BaseSigThres(1) BaseSigThres(1)],'Color','m','linewidth',1.2,'linestyle','--');
%     line(ExampleSessTime([MaxInds MaxInds]),yscales,'Color','c','linewidth',1.2,'linestyle','--')
%     set(gca,'xlim',xscales,'ylim',yscales);

    AboveThresInds = find(AvgDatas(6:end) > BaseSigThres(1),1,'first');
    cSessInds = [AboveThresInds+5,MaxInds];
    cSessTimes = ExampleSessTime(cSessInds);
    SessIndsAll(cSess,1:2) = cSessInds;
    SessIndsAll(cSess,3:4) = cSessTimes;
    SessIndsAll(cSess,5) = MaxValue;
    
    % passive session data extraction
    PassSessData = PassSessDatas{cSess};
    PassSessTime = PassSessUsedTScales{cSess};
    PassSessAvgAccu = 1 - mean(PassSessData,2);
    BaseData = reshape(PassSessData(1:5,:),[],1);
    BaseSigThres = prctile(BaseData,[95,99]);
    [PassMaxValue,PassMaxInds] = max(PassSessAvgAccu);
    PassAboveThresInd = find(PassSessAvgAccu(6:end) > BaseSigThres(1),1,'first');
    if ~isempty(PassAboveThresInd)
        cSessInds = [PassAboveThresInd+5,PassMaxInds];
        cSessTimes = ExampleSessTime(cSessInds);
    else
        cSessInds = [0,PassMaxInds];
        cSessTimes = [0,PassSessTime(PassMaxInds)];
    end
    PassSessIndsAll(cSess,1:2) = cSessInds;
    PassSessIndsAll(cSess,3:4) = cSessTimes;
    PassSessIndsAll(cSess,5) = PassMaxValue;
end
save SessIndsAllSave.mat PassSessIndsAll SessIndsAll -v7.3

%%  plot data save
PassNonExistInds = PassSessIndsAll(:,1) == 0;
TaskThresInds = SessIndsAll(:,3);
TaskMaxInds = SessIndsAll(:,4);
PassThresInds = PassSessIndsAll(~PassNonExistInds,3);
PassMaxInds = PassSessIndsAll(~PassNonExistInds,4);
[TaskThresCount,TaskThresCent] = ecdf(TaskThresInds);
[TaskMaxCount,TaskMaxCent] = ecdf(TaskMaxInds);
[PassThresCount,PassThresCent] = ecdf(PassThresInds);
[PassMaxCount,PassMaxCent] = ecdf(PassMaxInds);

hfThres = figure('position',[100 100 320 250]);
hold on
plot(TaskThresCent,TaskThresCount,'Color',[1 0.7 0.2],'linewidth',1.6);
plot(PassThresCent,PassThresCount,'Color',[.7 .7 .7],'linewidth',1.6);
set(gca,'xlim',[0 0.5])
xlabel('Time (s)');
ylabel('Count');
title('Above threshold time');
set(gca,'FontSize',12);
saveas(hfThres,'ThresTime Distribution plot');
saveas(hfThres,'ThresTime Distribution plot','pdf');

hfMax = figure('position',[100 500 320 250]);
hold on
plot(TaskMaxCent,TaskMaxCount,'Color',[1 0.7 0.2],'linewidth',1.6);
plot(PassMaxCent,PassMaxCount,'Color',[.7 .7 .7],'linewidth',1.6);
xlabel('Time (s)');
ylabel('Count');
title('Above threshold time');
set(gca,'FontSize',12);
saveas(hfMax,'MaxTime Distribution plot');
saveas(hfMax,'MaxTime Distribution plot','pdf');
%%
MaxVData = ([PassSessIndsAll(:,5),SessIndsAll(:,5)])';
[~,pps] = ttest(PassSessIndsAll(:,5),SessIndsAll(:,5));
hfMaxV = figure('position',[100 600 320 250]);
hold on
plot(MaxVData,'Color',[.7 .7 .7],'linewidth',1.2);
% plot(PassMaxCent,PassMaxCount,'Color',[.7 .7 .7],'linewidth',1.6);
hfMaxV = GroupSigIndication([1,2], max(MaxVData,[],2), pps, hfMaxV);
set(gca,'xtick',[1,2],'xticklabel',{'Pass','Task'},'xlim',[0.5 2.5]);
ylabel('Count');
title('MaxValue');
set(gca,'FontSize',12);
%
% saveas(hfMaxV,'MaxAccuracy compare plot');
% saveas(hfMaxV,'MaxAccuracy compare plot','pdf');

%%
TaskSessUsedTScales = (cellfun(@(x) x.TimeScale(1:TaskMinF),TaskClfDataAll,'Uniformoutput',false))';
PassSessUsedTScales = (cellfun(@(x) x.TimeScale(1:PassMinF),PassClfDataAll,'Uniformoutput',false))';
TaskSessUsedInfo = (cellfun(@(x) mean(x.TimeInfo(1:TaskMinF,:),2,'omitnan'),TaskClfDataAll,'Uniformoutput',false));
PassSessUsedInfo = (cellfun(@(x) mean(x.TimeInfo(1:PassMinF,:),2,'omitnan'),PassClfDataAll,'Uniformoutput',false));
TaskSessInfoMtx = (cell2mat(TaskSessUsedInfo))';
PassSessInfoMtx = (cell2mat(PassSessUsedInfo))';

TaskSessInfoAvg = mean(TaskSessInfoMtx);
TaskSessInfoSem = std(TaskSessInfoMtx)/sqrt(size(TaskSessInfoMtx,1));
PassSessInfoAvg = mean(PassSessInfoMtx);
PassSessInfoSem = std(PassSessInfoMtx)/sqrt(size(PassSessInfoMtx,1));

TaskTime = TaskSessUsedTScales{1};
PassTime = PassSessUsedTScales{1};
TaskPatchx = [TaskTime,fliplr(TaskTime)];
TaskPatchy = [TaskSessInfoAvg+TaskSessInfoSem,fliplr(TaskSessInfoAvg-TaskSessInfoSem)];
PassPatchx = [PassTime,fliplr(PassTime)];
PassPatchy = [PassSessInfoAvg+PassSessInfoSem,fliplr(PassSessInfoAvg-PassSessInfoSem)];

hf = figure;
hold on
patch(TaskPatchx,TaskPatchy,1,...
    'FaceColor',[1 0.7 0.3],'EdgeColor','none','facealpha',0.4);
patch(PassPatchx,PassPatchy,1,...
    'FaceColor',[.7 .7 .7],'EdgeColor','none','facealpha',0.4);
plot(TaskTime,TaskSessInfoAvg,'Color',[1 0.7 0.2],'linewidth',1.5);
plot(PassTime,PassSessInfoAvg,'Color',[0 0 0],'linewidth',1.5);
yscales = get(gca,'ylim');
line([0 0],yscales,'Color',[.7 .7 .7],'linewidth',1.2,'linestyle','--');
xlabel('Time(s)');
ylabel('Info (bits)');

saveas(hf,'Session information amount plots');
saveas(hf,'Session information amount plots','pdf');
saveas(hf,'Session information amount plots','png');