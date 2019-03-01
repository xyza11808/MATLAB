clearvars -except NormSessPathTask NormSessPathPass

%
nSess = length(NormSessPathTask);
ErroSess = [];
TaskDataAll = cell(nSess,2);
PassDataAll = cell(nSess,2);
for css = 1 : nSess
    
    csPath = NormSessPathTask{css};
    cPassPath = NormSessPathPass{css};  
    cd(csPath);
    try
        cTaskDecFile = fullfile(csPath,'NewSpikeDec_temporal','mWin_perfPlot','MWinCLassData.mat');
        cTaskDecStrc = load(cTaskDecFile);
        cPassDecFile = fullfile(cPassPath,'NewSpikeDec_temporal','mWin_perfPlot','MWinCLassData.mat');
        cPassDecStrc = load(cPassDecFile);

        TaskDataAll(css,:) = {cTaskDecStrc.MultiTScale,cTaskDecStrc.TrWinClassPerfAll};
        PassDataAll(css,:) = {cPassDecStrc.MultiTScale,cPassDecStrc.TrWinClassPerfAll};
    catch
        fprintf('Empty data for session %d.\n',css);
    end
    
end

%%
EmptyInds = cellfun(@isempty,TaskDataAll(:,1));
UsedTaskData = TaskDataAll(~EmptyInds,:);
UsedPassData = PassDataAll(~EmptyInds,:);
TaskSessionFrame = cellfun(@numel,UsedTaskData(:,1));
PassSessionFrame = cellfun(@numel,UsedPassData(:,1));
TaskAvgPerf = cellfun(@(x) mean(x,2),UsedTaskData(:,2),'uniformOutput',false);
PassAvgPerf = cellfun(@(x) mean(x,2),UsedPassData(:,2),'uniformOutput',false);
MaxWinNum = max(TaskSessionFrame);
PassMAxNum = max(PassSessionFrame);

TaskNanFillTimeWin = cellfun(@(x) [x,nan(1,MaxWinNum-numel(x))],UsedTaskData(:,1),'uniformOutput',false);
TaskNanFillWinData = cellfun(@(x) [x',nan(1,MaxWinNum-numel(x))],TaskAvgPerf,'uniformOutput',false);
PassNanFillTimeWin = cellfun(@(x) [x,nan(1,PassMAxNum-numel(x))],UsedPassData(:,1),'uniformOutput',false);
PassNanFillWinData = cellfun(@(x) [x',nan(1,PassMAxNum-numel(x))],PassAvgPerf,'uniformOutput',false);

%%
TaskNanFillTimeWinMtx = cell2mat(TaskNanFillTimeWin);
TaskNanFillWinDataMtx = cell2mat(TaskNanFillWinData);
PassNanFillTimeWinMtx = cell2mat(PassNanFillTimeWin);
PassNanFillWinDataMtx = cell2mat(PassNanFillWinData);

TaskNanFillTimeWinTrace = mean(TaskNanFillTimeWinMtx(:,1:end-10),'omitnan');
TaskNanFillWinDataTrace = 1 - mean(TaskNanFillWinDataMtx(:,1:end-10),'omitnan');
TaskNanFillWinDataSEM = std(TaskNanFillWinDataMtx(:,1:end-10),'omitnan')/sqrt(size(TaskNanFillWinDataMtx,1));

PassNanFillTimeWinTrace = mean(PassNanFillTimeWinMtx(:,1:end-10),'omitnan');
PassNanFillWinDataTrace = 1 - mean(PassNanFillWinDataMtx(:,1:end-10),'omitnan');
PassNanFillWinDataSEM = std(PassNanFillWinDataMtx(:,1:end-10),'omitnan')/sqrt(size(PassNanFillWinDataMtx,1));
%%
% E:\DataToGo\data_for_xu\Spike_timeWinClass\Spike_timeWin_dec
TaskxPatchs = [TaskNanFillTimeWinTrace,fliplr(TaskNanFillTimeWinTrace)];
TaskyPatchs = [TaskNanFillWinDataTrace - TaskNanFillWinDataSEM,fliplr(TaskNanFillWinDataTrace + TaskNanFillWinDataSEM)];

PassxPatchs = [PassNanFillTimeWinTrace,fliplr(PassNanFillTimeWinTrace)];
PassyPatchs = [PassNanFillWinDataTrace - PassNanFillWinDataSEM,fliplr(PassNanFillWinDataTrace + PassNanFillWinDataSEM)];

hf = figure('position',[100 100 380 320]);
hold on
patch(TaskxPatchs,TaskyPatchs,1,'FaceColor',[1 0.7 0.2],'EdgeColor','none','Facealpha',0.4);
patch(PassxPatchs,PassyPatchs,1,'FaceColor',[0.2 0.2 0.2],'EdgeColor','none','Facealpha',0.4);
plot(TaskNanFillTimeWinTrace,TaskNanFillWinDataTrace,'Color',[1 0.8 0.4],'linewidth',1.6);
plot(PassNanFillTimeWinTrace,PassNanFillWinDataTrace,'k','linewidth',1.6);

set(gca,'ylim',[0.4 1.1]);
line([0 0],[0.4 1.1],'Color',[.7 .7 .7],'linewidth',1.2,'linestyle','--');
set(gca,'xlim',[-1 max(TaskNanFillTimeWinTrace)+0.5],'xtick',0:max(TaskNanFillTimeWinTrace),'ytick',[0.5 0.75 1]);
line([-1 max(TaskNanFillTimeWinTrace)+0.5],[0.5 0.5],'Color',[.7 .7 .7],'linewidth',1.2,'linestyle','--');
xlabel('Time (s)');
ylabel('Accuracy');
set(gca,'FontSize',12);

% saveas(hf,'MultiSession spike timeWin decoding accuracy');
% saveas(hf,'MultiSession spike timeWin decoding accuracy','png');
% saveas(hf,'MultiSession spike timeWin decoding accuracy','pdf');
%%
save SpikeTWinDataSum.mat TaskDataAll PassDataAll NormSessPathTask NormSessPathPass -v7.3

%%
% TaskNanFillTimeWinMtx = cell2mat(TaskNanFillTimeWin);
% TaskNanFillWinDataMtx = cell2mat(TaskNanFillWinData);
% PassNanFillTimeWinMtx = cell2mat(PassNanFillTimeWin);
% PassNanFillWinDataMtx = cell2mat(PassNanFillWinData);

[TaskPeakValue,TaskPeakInds] = max(1 - TaskNanFillWinDataMtx(:,1:35),[],2);
[PassPeakValue,PassPeakInds] = max(1 - PassNanFillWinDataMtx(:,1:25),[],2);
[~,pp] = ttest(TaskPeakValue,PassPeakValue);
hPeakf = figure('position',[100 100 340 260]);
hold on
plot([1 2],[TaskPeakValue,PassPeakValue],'k','linewidth',1.2);
GroupSigIndication([1,2],max([TaskPeakValue,PassPeakValue]),pp,hPeakf);
set(gca,'xlim',[0.7 2.3],'xtick',[1 2],'ylim',[0.5 1.2],'xticklabel',{'Task','Passive'});
text([1,2],[0.6 0.6],{num2str(mean(TaskPeakValue),'%.4f'),num2str(mean(PassPeakValue),'%.4f')});
text([1,2],[0.55 0.55],{num2str(std(TaskPeakValue),'%.4f'),num2str(std(PassPeakValue),'%.4f')});
ylabel('Decoding accuracy');
set(gca,'ytick',[0.6:0.2:1],'FontSize',10);

saveas(hPeakf,'Peak decoding accuracy compare plot');
saveas(hPeakf,'Peak decoding accuracy compare plot','png');
saveas(hPeakf,'Peak decoding accuracy compare plot','pdf');


%%
close
cSess = 6;
figure;
imagesc(PassDataAll{cSess,2})
colorbar

%%
cROI = 37;
[cTrFreqs,cTrInds] = sort(behavResults.Stim_toneFreq(:));
cROIData = squeeze(SpikeAligned(cTrInds,cROI,:));
close
figure;
imagesc(cROIData)
colorbar

%% calculate the half peak width
nSess = size(TaskNanFillWinDataMtx,1);
HalfStartEndInds = zeros(nSess,4);
for cSess = 1 : nSess
    %%
    cSess = 18;
    cSessTaskTrace = TaskNanFillWinDataMtx(cSess,:);
    cSessPassTrace = PassNanFillWinDataMtx(cSess,:);
    
    cSessTaskTraceReal = 1 - cSessTaskTrace(~isnan(cSessTaskTrace));
    cSessPassTraceReal = 1 - cSessPassTrace(~isnan(cSessPassTrace));
    
    [TaskPeakValue, TaskPeakInds] = max(cSessTaskTraceReal);
    [PassPeakValue, PassPeakInds] = max(cSessPassTraceReal);
    
    TaskAboveHalfPeakWidth = cSessTaskTraceReal >= (TaskPeakValue/2+0.25);
    PassAboveHalfPeakWidth = cSessPassTraceReal >= (PassPeakValue/2+0.25);
    % Calculate task width
    TaskHalfStartInds = find(TaskAboveHalfPeakWidth(6:end) > 0,1,'first') + 5; % exclude first five data points
    TaskHalfendInds = find(TaskAboveHalfPeakWidth(TaskHalfStartInds+1:end) <= 0,1,'first') + TaskHalfStartInds;
    if isempty(TaskHalfendInds)
        TaskHalfendInds = numel(TaskAboveHalfPeakWidth);
    end
    
    % Calculate Passive width
    PassHalfStartInds = find(PassAboveHalfPeakWidth(6:end) > 0,1,'first') + 5; % exclude first five data points
    PassHalfendInds = find(PassAboveHalfPeakWidth(PassHalfStartInds+1:end) <= 0,1,'first') + PassHalfStartInds;
    if isempty(PassHalfendInds)
        PassHalfendInds = numel(PassAboveHalfPeakWidth);
    end
    
    HalfStartEndInds(cSess,:) = [TaskHalfStartInds,TaskHalfendInds,PassHalfStartInds,PassHalfendInds];
    close;
    hf = figure;
    hold on
    plot(cSessTaskTraceReal,'r');
    plot(cSessPassTraceReal,'k')
    line([TaskHalfStartInds,TaskHalfendInds],cSessTaskTraceReal([TaskHalfStartInds,TaskHalfendInds]),'Color','r','linestyle','--');
    line([PassHalfStartInds,PassHalfendInds],cSessPassTraceReal([PassHalfStartInds,PassHalfendInds]),'Color','k','linestyle','--');
    
    %%
end


%% plot the comparison
PassWidT = 0.1*(HalfStartEndInds(:,4) - HalfStartEndInds(:,3));
TaskWidT = 0.1*(HalfStartEndInds(:,2) - HalfStartEndInds(:,1));
[~,pps] = ttest(TaskWidT,PassWidT);

hf = figure('position',[2000 100 320 280]);
hold on
plot([1,2],([TaskWidT,PassWidT])','Color',[.7 .7 .7],'linewidth',1.2);
GroupSigIndication([1,2],max([TaskWidT,PassWidT]),pps,hf);
set(gca,'xlim',[0.7 2.3],'xtick',[1 2],'xticklabel',{'Task','Passive'});
ylabel('Half-Peak width');
yscales = get(gca,'ylim');
set(gca,'ytick',0:yscales(2));
text([0.9 1.5],[3 2.5],{sprintf('%.4f,%.4f',mean(TaskWidT),std(TaskWidT)),sprintf('%.4f,%.4f',mean(PassWidT),std(PassWidT))});
saveas(hf,'HalfPeakWidth compare plots');
saveas(hf,'HalfPeakWidth compare plots','png');
saveas(hf,'HalfPeakWidth compare plots','pdf');
