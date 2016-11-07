function MeanAlignedDataPlot(AlignedData,TimeOnset,TrialType,FrameRate,varargin)
%this function is used for plot the mean calcium trace for aligned data
%form, with SD value defined shadow area

if nargin>4
    TrialResult = varargin{1};
else
    TrialResult = [];
end

if nargin>5
    PopuStd = varargin{2};  %this should be an vector with each value represente the std value for each ROI
    InputStd = 1;
else
    InputStd = 0;
    PopuStd = zeros(1,size(AlignedData,2));
end

if isempty(PopuStd)
    PopuStd = zeros(1,size(AlignedData,2));
end

if isempty(TrialResult)
    DataSelect = AlignedData;
    TrialSelected = TrialType;
else
    CorrectInds = TrialResult == 1;
    DataSelect = AlignedData(CorrectInds,:,:);
    TrialSelected = TrialType(CorrectInds);
end

inds_left = TrialSelected == 0;
inds_right = TrialSelected == 1;

DataSize=size(DataSelect);
frames=1:DataSize(3);
StimLength=floor(0.3*FrameRate);
XTick=1:FrameRate:DataSize(3);
XTickLabel=floor(XTick/FrameRate);
PeakRange = [0.5*FrameRate FrameRate];

if ~isdir('./Aligned_Mean_Trace/')
    mkdir('./Aligned_Mean_Trace/');
end
cd('./Aligned_Mean_Trace/');
% ts = frames/FrameRate;
%the structure named MeanAlignData have following fields
%LeftData,RightData, LeftSig, RightSig, ROIIndsLeft, ROIIndsRight, ROISig

opt_plot=struct('t_eventOn',TimeOnset,'eventDur',StimLength);
MeanAlignData.DataAll=AlignedData;
MeanAlignData.TrialType=TrialSelected;
MeanAlignData.FrameOnset=opt_plot;
MeanAlignData.LeftData=zeros(DataSize(2),DataSize(3));
MeanAlignData.RightData=zeros(DataSize(2),DataSize(3));
MeanAlignData.LeftRawData=zeros(DataSize(2),DataSize(3));
MeanAlignData.RightRawData=zeros(DataSize(2),DataSize(3));
MeanAlignData.LeftMaxInds=zeros(1,DataSize(2));
MeanAlignData.RightMaxInds=zeros(1,DataSize(2));
MeanAlignData.AllDataMean=zeros(DataSize(2),DataSize(3));
MeanAlignData.AllDataMeanNor=zeros(DataSize(2),DataSize(3));
MeanAlignData.AllMaxInds=zeros(1,DataSize(2));

MaxValueLeftAll = zeros(1,DataSize(2));
MaxValueRightAll = zeros(1,DataSize(2));
if ~isdir('./Single_Mean_Trace/')
    mkdir('./Single_Mean_Trace/');
end
cd('./Single_Mean_Trace/');

for n=1:DataSize(2)
    SingleROIData = squeeze(DataSelect(:,n,:)); %with m trials by n frames
    T_eventOn = opt_plot.t_eventOn;
    T_eventOff = T_eventOn + opt_plot.eventDur;
    %plot of all aligned data, the color map
    h_colorplot=figure;
    hold on;
    subplot(2,1,1)
    imagesc(SingleROIData(inds_left,:),[0 min(max(SingleROIData(:)),300)]);
    hlBar=colorbar;
    set(get(hlBar,'Title'),'string','\DeltaF/F_0');
    yaxis = axis();
    H.eventPatch = patch([T_eventOn, T_eventOn, T_eventOff, T_eventOff],...
        [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],...
        [.1 .8 .1],'Edgecolor','none', 'facealpha',0.3);
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    xlim([0 DataSize(3)]);
%     ylim([0 DataSize(1)]);
    xlabel('Time(s)');
    ylabel('Trials');
    title('Left trials');
    
    subplot(2,1,2)
    imagesc(SingleROIData(inds_right,:),[0 min(max(SingleROIData(:)),300)]);
    hlBar=colorbar;
    set(get(hlBar,'Title'),'string','\DeltaF/F_0');
    yaxis = axis();
    H.eventPatch = patch([T_eventOn, T_eventOn, T_eventOff, T_eventOff],...
        [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],...
        [.1 .8 .1],'Edgecolor','none', 'facealpha',0.3);
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    xlim([0 DataSize(3)]);
%     ylim([0 DataSize(1)]);
    xlabel('Time(s)');
    ylabel('Trials');
    title('Right trials');
    
    suptitle(['Single ROI color plot ROI' num2str(n)]);
    saveas(h_colorplot,['Aligned_All_colorplot_ROI' num2str(n)],'png');
    saveas(h_colorplot,['Aligned_All_colorplot_ROI' num2str(n)]);
    close(h_colorplot);
    
    MeanAllTrialsTrace = mean(SingleROIData);
    MeanSEMAllTrials = std(SingleROIData)./sqrt(size(SingleROIData,1));
    [~,IAll] = max(MeanAllTrialsTrace);
    MeanAlignData.AllDataMean(n,:) = MeanAllTrialsTrace;
    MeanAlignData.AllMaxInds(n) = IAll;
    MeanAlignData.AllDataMeanNor(n,:) = zscore(MeanAllTrialsTrace);
    hAll_fig=figure;
    hold on;
    H_ALL = plot_meanCaTrace(MeanAllTrialsTrace, MeanSEMAllTrials, frames, hAll_fig, opt_plot);
    hold off;
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    xlim([0 DataSize(3)]);
    xlabel('Time(s)');
    ylabel('\DeltaF/F_0');
    title('Mean Calcium Trace Sorted by Peak Time');
    saveas(hAll_fig,['Aligned_AllMean_plot_ROI' num2str(n)],'png');
    saveas(hAll_fig,['Aligned_AllMean_plot_ROI' num2str(n)]);
    close(hAll_fig);
    
    MeanTraceLeft = mean(SingleROIData(inds_left,:));
    MeanSEM_left = std(SingleROIData(inds_left,:))./sqrt(sum(inds_left));
    [MaxValueLeft,ILeft] = max(MeanTraceLeft);
    
    MeanTraceRight = mean(SingleROIData(inds_right,:));
    MeanSEM_Right = std(SingleROIData(inds_right,:))./sqrt(sum(inds_right));
    %     MeanAlignData.RightData(n,:) = MeanTraceRight;
    [MaxValueRight,IRight] = max(MeanTraceRight);
    
    %     MeanAlignData.LeftData(n,:) = MeanTraceLeft/max(MaxValueLeft,MaxValueRight);
    MeanAlignData.LeftData(n,:) = zscore(MeanTraceLeft);
    MeanAlignData.LeftRawData(n,:) = MeanTraceLeft;
    MeanAlignData.LeftMaxInds(n) = ILeft;
    MaxValueLeftAll(n) = MaxValueLeft;
    
    %     MeanAlignData.RightData(n,:) = MeanTraceRight/max(MaxValueLeft,MaxValueRight);
    MeanAlignData.RightData(n,:) = zscore(MeanTraceRight);
    MeanAlignData.RightRawData(n,:) = MeanTraceRight;
    MeanAlignData.RightMaxInds(n) = IRight;
    MaxValueRightAll(n) = MaxValueRight;
    
    h_fig = figure;
    hold on;
    H_L = plot_meanCaTrace(MeanTraceLeft, MeanSEM_left, frames, h_fig, opt_plot);
    
    H_R = plot_meanCaTrace(MeanTraceRight, MeanSEM_Right, frames, h_fig, opt_plot);
    hold off;
    %     title(sprintf('ROI--%d, align StimOn',roiNo),'fontsize',14)
    set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    xlim([0 DataSize(3)]);
    xlabel('Time(s)');
    ylabel('\DeltaF/F_0');
    
    set(H_L.meanPlot, 'color','b')
    set(H_R.meanPlot, 'color','r')
    title(['Aligned data mean trace for ROI' num2str(n)]);
%     saveas(h_fig,sprintf('Aligned_plot_ROI%d',n),'png');
    print(h_fig,sprintf('Aligned_plot_ROI%d',n),'-dpng');
    saveas(h_fig,sprintf('Aligned_plot_ROI%d',n),'fig');
%     saveas(h_fig,sprintf('Aligned_plot_ROI%d',n),'png');
    %     hE = MeanTrace + MeanStd;
    %     lE = MeanTrace - MeanStd;
    %     yP = [lE fliplr(hE)];
    %     xP = [frames fliplr(frames)];
    %     patchColor = [.7 .7 .7];
    %     faceAlpha = 1;
    %
    %     h=figure;
    %     hold on;
    %     h_ep = patch(xP,yP,1,'facecolor',patchColor,...
    %               'edgecolor','none',...
    %               'facealpha',faceAlpha);
    %     haxis = axis;
    %     hpch = patch([TimeOnset, TimeOnset, TimeOnset+StimLength, TimeOnset+StimLength], [haxis(3), haxis(4), haxis(4),haxis(3)],  [.1 .8 .1],'Edgecolor','none');
    %     plot(MeanTrace,'color','g','linewidth',2);
    %     set(gca,'xtick',XTick,'xticklabel',XTickLabel);
    % %     h_ep = patch(xP,yP,1,'facecolor',patchColor,...
    % %               'edgecolor','none',...
    % %               'facealpha',faceAlpha);
    %
    close(h_fig);
end
cd ..;
% PopuMad = size(PopuStd);
% if ~InputStd || isempty(PopuStd)
%     for n=1:DataSize(2)
%         AllTrialMean = [ MeanAlignData.LeftData(n,:)  MeanAlignData.RightData(n,:)];
%         PopuStd(n) = std(AllTrialMean);
%         PopuMad(n) = mad(AllTrialMean);
%     end
% end

MeanAlignData.LeftSig=zeros(sum(inds_left),DataSize(2));
MeanAlignData.RightSig=zeros(sum(inds_right),DataSize(2));
MeanAlignData.LRMeanDiff = MeanAlignData.LeftRawData-MeanAlignData.RightRawData;

RangeInds = [];
MeanAlignData.ROIIndsLeft = zeros(1,DataSize(2));
MeanAlignData.ROIIndsRight = zeros(1,DataSize(2));
MeanAlignData.ROISig = zeros(1,DataSize(2));

%####################################################################
% this part should be modified, use the same maxium for sig detection
for m=1:DataSize(2)
    SingROILeft = squeeze(DataSelect(inds_left,m,:));
    SingROIRight = squeeze(DataSelect(inds_right,m,:));
    MaxIndsLeft = MeanAlignData.LeftMaxInds(m);
    MaxIndsRight = MeanAlignData.RightMaxInds(m);
    
    if (MaxIndsLeft - PeakRange(1)) < 1
        RangeInds(1) = 1;
    else
        RangeInds(1) = MaxIndsLeft - PeakRange(1);
    end
    
    if (MaxIndsLeft + PeakRange(2)) > DataSize(3)
        RangeInds(2) = DataSize(3);
    else
        RangeInds(2) = MaxIndsLeft + PeakRange(2);
    end
    
    for n = 1 : sum(inds_left)
        CurrentTrace = SingROILeft(n,:);
        TraceInds = 1:length(CurrentTrace);
        %         [~,MaxInds] = max(CurrentTrace);
        %         MeanAlignData.LeftMaxInds(n,m) = MaxInds;
        
        PeakInds = TraceInds >= RangeInds(1) & TraceInds <=  RangeInds(2);
        IdleInds = ~PeakInds;
        PeakMeanValue = mean(CurrentTrace(PeakInds));
        IdleMeanValue = mean(CurrentTrace(IdleInds));
        if PeakMeanValue > 3*IdleMeanValue
            MeanAlignData.LeftSig(n,m) = 1;
        else
            MeanAlignData.LeftSig(n,m) = 0;
        end
    end
    
    if (MaxIndsRight - PeakRange(1)) < 1
        RangeInds(1) = 1;
    else
        RangeInds(1) = MaxIndsRight - PeakRange(1);
    end
    
    if (MaxIndsRight + PeakRange(2)) > DataSize(3)
        RangeInds(2) = DataSize(3);
    else
        RangeInds(2) = MaxIndsRight + PeakRange(2);
    end
    
    for n = 1 : sum(inds_right)
        CurrentTrace = SingROIRight(n,:);
        TraceInds = 1:length(CurrentTrace);
        %         [~,MaxInds] = max(CurrentTrace);
        %         MeanAlignData.RightMaxInds(n,m) = MaxInds;
        
        PeakInds = TraceInds >= RangeInds(1) & TraceInds <=  RangeInds(2);
        IdleInds = ~PeakInds;
        PeakMeanValue = mean(CurrentTrace(PeakInds));
        IdleMeanValue = mean(CurrentTrace(IdleInds));
        if PeakMeanValue > 3*IdleMeanValue
            MeanAlignData.RightSig(n,m) = 1;
        else
            MeanAlignData.RightSig(n,m) = 0;
        end
    end
    
    if mean(MeanAlignData.LeftSig(:,m)) > 0.3
        MeanAlignData.ROIIndsLeft(m) = 1;
    end
    if mean(MeanAlignData.RightSig(:,m)) > 0.3
        MeanAlignData.ROIIndsRight(m) = 1;
    end
    MeanAlignData.ROISig(m) =  MeanAlignData.ROIIndsLeft(m) || MeanAlignData.ROIIndsRight(m);
end

MinusMaxLeft = MaxValueLeftAll < 0;
MinusMaxRight = MaxValueRightAll < 0;
if sum(MinusMaxLeft)>0
    MeanAlignData.LeftData(MinusMaxLeft,:) = 0;
end
if sum(MinusMaxRight)>0
    MeanAlignData.RightData(MinusMaxRight,:) = 0;
end


SigROIIndsSelect = logical(MeanAlignData.ROISig);
SigROIMaxIndsLeft = MeanAlignData.LeftMaxInds(SigROIIndsSelect);
SigROIMaxIndsRight = MeanAlignData.RightMaxInds(SigROIIndsSelect);
SigROINorDataLeft = MeanAlignData.LeftData(SigROIIndsSelect,:);
SigROINorDataRight = MeanAlignData.RightData(SigROIIndsSelect,:);
SigROIRawDataLeft = MeanAlignData.LeftRawData(SigROIIndsSelect,:);
SigROIRawDataRight = MeanAlignData.RightRawData(SigROIIndsSelect,:);

[~,ILeft] = sort(SigROIMaxIndsLeft);
[~,IRight] = sort(SigROIMaxIndsRight);
t_eventOn = TimeOnset;
t_eventOff = StimLength+TimeOnset;
XTick=(1:FrameRate:DataSize(3));
XTickLabel=floor((1:FrameRate:DataSize(3))/FrameRate);
save MeanTraceSum.mat MeanAlignData TimeOnset FrameRate -v7.3

if ~isdir('./Popu_Mean_Trace/')
    mkdir('./Popu_Mean_Trace/');
end
cd('./Popu_Mean_Trace/');

%%
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% plot the left and right response diff plot
DiffLRRaw = SigROIRawDataRight-SigROIRawDataLeft;
NorDiffLRdata = zscore(DiffLRRaw,0,2);
AfterRespData = NorDiffLRdata(:,TimeOnset:TimeOnset+FrameRate);  %1s after sound onset
ROIsResponse = mean(AfterRespData,2);
[~,ROISeq] = sort(ROIsResponse);

h_diff = figure('position',[400 150 1200 900],'Paperpositionmode','auto');
subplot(1,2,1);
imagesc(NorDiffLRdata(ROISeq,:),[-2 2]);
colorbar;

subplot(1,2,2)
imagesc(DiffLRRaw(ROISeq,:),[-300 300]);
colorbar;
line([TimeOnset TimeOnset],[0 size(DiffLRRaw,1)+1],'LineWidth',2,'color',[.8 .8 .8]);
saveas(h_diff,'ROI response diff plot');
saveas(h_diff,'ROI response diff plot','png');
close(h_diff);
%%
%plot the population mean trace color map with left and right distinguished

h_max=figure;
subplot(2,2,1)
imagesc(SigROINorDataLeft(ILeft,:),[0 1]);
title('Left trials sorted by left max inds');
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
yaxis = axis();
H.eventPatch = patch([t_eventOn, t_eventOn, t_eventOff, t_eventOff],...
    [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],...
    [.1 .8 .1],'Edgecolor','none', 'facealpha',0.8);

subplot(2,2,2)
imagesc(SigROINorDataRight(ILeft,:),[0 1]);
title('Right trials sorted by left max inds');
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
yaxis = axis();
H.eventPatch = patch([t_eventOn, t_eventOn, t_eventOff, t_eventOff],...
    [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],...
    [.1 .8 .1],'Edgecolor','none', 'facealpha',0.8);

subplot(2,2,3)
imagesc(SigROINorDataLeft(IRight,:),[0 1]);
title('Left trials sorted by right max inds');
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
yaxis = axis();
H.eventPatch = patch([t_eventOn, t_eventOn, t_eventOff, t_eventOff],...
    [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],...
    [.1 .8 .1],'Edgecolor','none', 'facealpha',0.8);

subplot(2,2,4)
imagesc(SigROINorDataRight(IRight,:),[0 1]);
title('Right trials sorted by right max inds');
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
yaxis = axis();
H.eventPatch = patch([t_eventOn, t_eventOn, t_eventOff, t_eventOff],...
    [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],...
    [.1 .8 .1],'Edgecolor','none', 'facealpha',0.8);

suptitle('All sig trials sorted by max inds');
saveas(h_max,'Max_Inds_sorted_sigtrials_plot','png');
saveas(h_max,'Max_Inds_sorted_sigtrials_plot');
close;

h_left_ALL=figure;
plot(mean(SigROINorDataLeft),'color','b','LineWidth',2.5);
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
yaxis = axis;
H.eventPatch = patch([t_eventOn, t_eventOn, t_eventOff, t_eventOff],...
    [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],...
    'c','Edgecolor','none', 'facealpha',0.8);
title('All Left Trials for All ROIs Mean Trace');
saveas(h_left_ALL,'All_Left_Trials_Mean_Trace','png');
saveas(h_left_ALL,'All_Left_Trials_Mean_Trace');
close(h_left_ALL);

h_right_ALL=figure;
plot(mean(SigROINorDataRight),'color','r','LineWidth',2.5);
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
yaxis = axis;
H.eventPatch = patch([t_eventOn, t_eventOn, t_eventOff, t_eventOff],...
    [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],...
    'c','Edgecolor','none', 'facealpha',0.8);
title('All Right Trials for All ROIs Mean Trace');
saveas(h_right_ALL,'All_Right_Trials_Mean_Trace','png');
saveas(h_right_ALL,'All_Right_Trials_Mean_Trace');
close(h_right_ALL);

%%
%plot the distribution of left right maxium inds
%this may give some clues for further classification
h_hist=figure;
subplot(1,2,1)
hist(SigROIMaxIndsLeft,30);
xlim([1 DataSize(3)]);
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
title('Left maxium inds distribution');

subplot(1,2,2)
hist(SigROIMaxIndsRight,30);
xlim([1 DataSize(3)]);
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
title('Right maxium inds distribution');
saveas(h_hist,'Maxium inds distribution plot','png');
close(h_hist);

%
%plot the distribution of maxium inds by mean maxium/idle ratio
LeftPeakIdleRatio=zeros(1,sum(SigROIIndsSelect));
RightPeakIdleRatio=zeros(1,sum(SigROIIndsSelect));
for n=1:sum(SigROIIndsSelect)
    LeftRawData = SigROIRawDataLeft(n,:);
    RightRawData = SigROIRawDataRight(n,:);
    LeftMaxRangeInds=[SigROIMaxIndsLeft(n)-PeakRange(1) SigROIMaxIndsLeft(n)+PeakRange(2)];
    if LeftMaxRangeInds(1)<1
        LeftMaxRangeInds(1)=1;
    end
    if LeftMaxRangeInds(2)>length(frames)
        LeftMaxRangeInds(2)=length(frames);
    end
    LeftPeakinds = frames>=LeftMaxRangeInds(1) & frames<=LeftMaxRangeInds(2);
    LeftIdleinds = ~LeftPeakinds;
    LeftPeakIdleRatio(n) = mean(LeftRawData(LeftPeakinds))/mean(LeftRawData(LeftIdleinds));
    
    RightMaxRangeInds = [SigROIMaxIndsRight(n)-PeakRange(1) SigROIMaxIndsRight(n)+PeakRange(2)];
    if RightMaxRangeInds(1) < 1
        RightMaxRangeInds(1) = 1;
    end
    if RightMaxRangeInds(2) > length(frames)
        RightMaxRangeInds(2) = length(frames);
    end
    RightPeakinds = frames>=RightMaxRangeInds(1) & frames<=RightMaxRangeInds(2);
    RightIdleinds = ~RightPeakinds;
    RightPeakIdleRatio(n) = mean(RightRawData(RightPeakinds))/mean(RightRawData(RightIdleinds));
    
end

h_maxDis=figure;
subplot(1,2,1);
scatter(SigROIMaxIndsLeft,LeftPeakIdleRatio,20,'+');
xlim([1 DataSize(3)]);
OldYlim=get(gca,'ylim');
ylim([0 OldYlim(2)]);
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
xlabel('Time(s)');
ylabel('MaxIdleRatio');
title('Left data');
hold on;
line([1 DataSize(3)],[3 3],'color','r','LineWidth',2);
line([1 DataSize(3)],[1 1],'color','g','LineWidth',2);

subplot(1,2,2);
scatter(SigROIMaxIndsRight,RightPeakIdleRatio,20,'*');
xlim([1 DataSize(3)]);
OldYlim=get(gca,'ylim');
ylim([0 OldYlim(2)]);
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
xlabel('Time(s)');
ylabel('MaxIdleRatio');
title('Right data');
hold on;
line([1 DataSize(3)],[3 3],'color','r','LineWidth',2);
line([1 DataSize(3)],[1 1],'color','g','LineWidth',2);

saveas(h_maxDis,'Maxium inds by MaxiumIdle ratio','png');
close(h_maxDis);

%%
%plot all trials mean trace for population response
RoiDataSeletedAll = MeanAlignData.AllDataMeanNor(SigROIIndsSelect,:);  %zscored data
[SortedMaxInds,IAllMean] = sort(MeanAlignData.AllMaxInds(SigROIIndsSelect));
h_AllMean=figure('position',[400 240 1050 800],'PaperPositionMode','auto');
imagesc(RoiDataSeletedAll(IAllMean,:),[-2,2]);
hbar=colorbar;
set(get(hbar,'title'),'string','zscore');
title('All ROIs sorted by Maxium Time');
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
xlabel('Time (s)');
ylabel('# ROIs');
yaxis = axis;
H.eventPatch = patch([t_eventOn, t_eventOn, t_eventOff, t_eventOff],...
    [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],...
    [.1 .8 .1],'Edgecolor','none', 'facealpha',0.8);
set(gca,'FontSize',20);
saveas(h_AllMean,'All_Trials_Mean_sorted_by_Peak_time','png');
saveas(h_AllMean,'All_Trials_Mean_sorted_by_Peak_time');
close(h_AllMean);

h_AllMeanTrace=figure;
plot(mean(RoiDataSeletedAll),'color','c','LineWidth',2.5);
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
yaxis = axis;
H.eventPatch = patch([t_eventOn, t_eventOn, t_eventOff, t_eventOff],...
    [yaxis(3), yaxis(4), yaxis(4),yaxis(3)],...
    [.1 .8 .1],'Edgecolor','none', 'facealpha',0.8);
title('All ROIs Mean Trace');
saveas(h_AllMeanTrace,'All_Trials_Mean_Trace','png');
saveas(h_AllMeanTrace,'All_Trials_Mean_Trace');
close(h_AllMeanTrace);

h_maxDist=figure;
hist(SortedMaxInds,30);
xlim([1 DataSize(3)]);
set(gca,'xtick',XTick,'xticklabel',XTickLabel);
title('All Data Mean Maxium Inds Distribution');
saveas(h_maxDist,'All_Data_MaxInds_Distri','png');
saveas(h_maxDist,'All_Data_MaxInds_Distri');
close(h_maxDist);

[nnumbers,ncenters]=hist(SortedMaxInds,30);
save MaxIndsDistridata.mat nnumbers ncenters;

cd ..;
cd ..;