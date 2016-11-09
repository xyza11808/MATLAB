function RF2afcComparePlot(TaskData,TaskStim,RFdata,RFstim,FrameRate,AlignFrame,TimeScale,varargin)
% this function is tried to compare task and rf data response value and put
% in a scatter plot to show the final result
% also this function will tried to class ROIs as sound responsive ROI or an
% non-direct sound responsive ROI

[TaskTr,TaskROI,TaskFrame] = size(TaskData);
[rfTr.rfROI,rfFrame] = size(RFdata);
FinalROI = TaskROI;
if TaskROI ~= rfROI
    if rfROI > TaskROI
%         FinalROI = TaskROI;
%         TaskData = TaskData;
        RFdata = RFdata(:,1:FinalROI,:);
    else
        error('Task ROI number should less than rf data, please check your data set.');
    end
end
TaskStim = double(TaskStim);
RFstim = double(RFstim);

if length(FrameRate) > 1
    fprintf('Frame rate is different between task and rf data aqusition,\n Using %d as task framerate, and %d as rf framerate',FrameRate(1),FrameRate(2));
    fRate = FrameRate;
else
    fRate = [FrameRate,FrameRate];
end
if ~iscell(TimeScale)
    TaskFrameScale = sort([AlignFrame(1),AlignFrame(1) + round(TimeScale(1)*fRate(1))]);
    rfFrameScale = sort([AlignFrame(2),AlignFrame(2) + round(TimeScale(2)*fRate(2))]);
else
    TaskScale = TimeScale{1};
    rfScale = TimeScale{2};
    if length(TaskScale) > 1
        TaskFrameScale = sort([AlignFrame(1)+round(TaskScale(1)*fRate(1)),AlignFrame(1)+round(TaskScale(2)*fRate(1))]);
    else
        TaskFrameScale = sort([AlignFrame(1),AlignFrame(1)+round(TaskScale*fRate(1))]);
    end
    if length(rfScale) > 1
        rfFrameScale = sort([AlignFrame(2)+round(rfScale(1)*fRate(2)),AlignFrame(2)+round(rfScale(2)*fRate(2))]);
    else
        rfFrameScale = sort([AlignFrame(2),AlignFrame(2)+round(rfScale*fRate(2))]);
    end
end

TaskSelectData = max(TaskData(:,:,TaskFrameScale(1):TaskFrameScale(2)),[],3);
rfSelectData = max(RFdata(:,:,rfFrameScale(1):rfFrameScale(2)),[],3);
TaskStimType = unique(TaskStim);
rfStimType = unique(RFstim);
TaskMeanTrace = zeros(length(TaskStimType),FinalROI,TaskFrame);
RFMeanTrace = zeros(length(TaskStimType),FinalROI,rfFrame);

if length(TaskStimType) ~= length(rfStimType)
    fprintf('2afc stimlus is different from rf stimlus, using octave band mean response for comparation.\n');
    TasknROIResp = zeros(FinalROI,length(TaskStimType));
    RFnROIResp = zeros(FinalROI,length(TaskStimType));
    for nn = 1 : length(TaskStimType)
        cFreq = TaskStimType(nn);
        cFreqScale = cFreq * power(2,[-0.25,0.25]);
        RFTrWithinBand = (RFstim > cFreqScale(1)) & (RFstim < cFreqScale(2));
        TaskTsInds = TaskStim == cFreq;
        TasknROIResp(:,nn) = mean(TaskSelectData(TaskTsInds,:));
        RFnROIResp(:,nn) = mean(rfSelectData(RFTrWithinBand,:));
        TaskMeanTrace(nn,:,:) = squeeze(mean(TaskData(TaskTsInds,:,:)));
        RFMeanTrace(nn,:,:) = squeeze(mean(RFdata(RFTrWithinBand,:,:)));
    end
else
    fprintf('Task Stimulus are the same as rf stimulus, using mean response for each stimuli type.\n');
    TasknROIResp = zeros(FinalROI,length(TaskStimType));
    RFnROIResp = zeros(FinalROI,length(TaskStimType));
    for nn = 1 : length(TaskStimType)
        RFTrInds = RFstim == rfStimType(nn);
        TaskTrInds = TaskStim == TaskStimType(nn);
        TasknROIResp(:,nn) = mean(TaskSelectData(TaskTrInds,:));
        RFnROIResp(:,nn) = mean(rfSelectData(RFTrInds,:));
        TaskMeanTrace(nn,:,:) = squeeze(mean(TaskData(TaskTrInds,:,:)));
        RFMeanTrace(nn,:,:) = squeeze(mean(RFdata(RFTrInds,:,:)));
    end
end

if ~isdir('./Task_rf_compPlot/')
    mkdir('./Task_rf_compPlot/');
end
cd('./Task_rf_compPlot/');

[lmtb,~,Rsqur,hf] = lmFunCalPlot(reshape(TasknROIResp,[],1),reshape(RFnROIResp,[],1));
% scatter(reshape(TasknROIResp,[],1),reshape(RFnROIResp,[],1),40,'ro','LineWidth',1.5);
xlabel('Task \DeltaF/F_0(%)');
ylabel('RF \DeltaF/F_0(%)');
title({'Task and rf response comparation';sprintf('R = %.3f',Rsqur)});
saveas(hf,'Scatter plot for task and rf response comp');
saveas(hf,'Scatter plot for task and rf response comp','png');
close(hf);

save sumResult.mat lmtb Rsqur hf TasknROIResp RFnROIResp TaskMeanTrace RFMeanTrace -v7.3
RsqrAll = zeros(length(TaskStimType),1);
lmMdlAll = cell(length(TaskStimType),1);
for nnn = 1 : length(TaskStimType)
    [lmdl,~,Rsqr,h_sf] = lmFunCalPlot(TasknROIResp(:,nnn),RFnROIResp(:,nnn));
    RsqrAll(nnn) = Rsqr;
    lmMdlAll{nnn} = lmdl;
    xlabel('Task \DeltaF/F_0(%)');
    ylabel('RF \DeltaF/F_0(%)');
    title({'Task and rf response comparation';sprintf('R = %.3f',Rsqr)});
    saveas(h_sf,'Scatter plot for task and rf response comp');
    saveas(h_sf,'Scatter plot for task and rf response comp','png');
    close(h_sf);
end
save TypeSepResult.mat RsqrAll lmMdlAll -v7.3

for nnnn = 1 : length(TaskStimType)
    for nxr = 1 : FinalROI
        cTraceTask = squeeze(TaskMeanTrace(nnnn,nxr,:));
        cTracerf = squeeze(RFMeanTrace(nnnn,nxr,:));
        
cd ..;


function [] = OnsetTimeDec(TraceData,AligeF,TimeLim,ValueThres,FrameRate)
% within func onset time detection

Strace = smooth(TraceData,0.05,'rloess');
[MaxV,MaxInds] = max(Strace);
if max(Strace) <= ValueThres || MaxInds < TimeLim
    OnsetF = 0;
    return;
else
    HalfMaxWid = MaxV/2;
    BeforeHalfInds = find(fliplr(Strace(1:MaxInds)) < HalfMaxWid,1,'first');
    AfterHalfInds = find(Strace(MaxInds:end) < HalfMaxWid,1,'first');
    if (AfterHalfInds + BeforeHalfInds) < FrameRate
        fprintf('Current peak seems not to be a real calcium peak.\n');
        return;
    else
        RealHalfInds = [MaxInds - BeforeHalfInds, MaxInds + AfterHalfInds];
        HalfPeakWidth = diff(RealHalfInds);
    end
end
