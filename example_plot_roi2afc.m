%%
%load deltaf/f data save file
[fn,fpath,~] = uigetfile('*.mat','Select your normalized calcium trace saving file.');
x=load(fullfile(fpath,fn));
cd(fpath);

%%
RawData = x.FChangeData;
size_data = size(RawData);
TrialType = double(x.behavResults.Trial_Type);
FrameRate = 55;
FrameNum = size(RawData,3);
onset_time=x.behavResults.Time_stimOnset;
% stim_type_freq=behavResults.Stim_toneFreq;
align_time_point=min(onset_time);
alignment_frames=floor((double((onset_time-align_time_point))/1000)*FrameRate);
framelength=size_data(3)-max(alignment_frames);
alignment_frames(alignment_frames<1)=1;
start_frame=floor((double(align_time_point)/1000)*FrameRate);
data_aligned=zeros(size_data(1),size_data(2),framelength);
for i=1:size_data(1)
    data_aligned(i,:,1:framelength)=RawData(i,:,alignment_frames(i):(alignment_frames(i)+framelength-1));
end
MegOnFrame = start_frame;

%%
%example ROI plot for 2AFC task
%example ROI plot
ExampROIinds = [2,4,5,8,16,20,22,23,31,33,51,57,97,130];
ExampleTrials = 1:15;  %trial number choosed to plot
TrialNum = length(ExampleTrials);
DataToPlot = data_aligned(ExampleTrials,ExampROIinds,:);
TrialTypeP = TrialType(ExampleTrials);
save ROIinds.mat ExampROIinds ExampleTrials -v7.3
GapsBetTrace = 50;  %gaps between each trace
AfterMegT = 3;  % seconds after stimuli start
BeforeMegT = 1; %Time choossed for baseline
BeforeMegF = floor(BeforeMegT * FrameRate); 
SelectEndFrame = BeforeMegF + floor(AfterMegT * FrameRate);
h_example = figure('position',[200 50 1600 1000],'color','w');
hold on
yBase = 0;
for n = 1 : length(ExampROIinds)
%     cROINum = ExampROIinds(n);
%     cROIData = (squeeze(AllDataChange(:,cROINum,:)))';
    cROIData = (squeeze(DataToPlot(:,n,:)))';
    cPartData = cROIData;
    if (MegOnFrame - BeforeMegF) < 1
        warning('Before StimFrame is larger than real StimOn frame, set to frame start inds');
        BeforeMegF = MegOnFrame - 1;
    end
%     yBaseAdd = max(cROIData(:));
    if (FrameNum - SelectEndFrame - (MegOnFrame - BeforeMegF)) > floor(5 * FrameRate)
        cPartData(1:(MegOnFrame - BeforeMegF),:) = [];
        cPartData((SelectEndFrame + floor(5 * FrameRate) + 1):end,:) = [];
        FrameNumNew = size(cPartData,1);
    else
        cPartData(1:(MegOnFrame - BeforeMegF),:) = [];
        cPartData((SelectEndFrame + floor(5 * FrameRate) + 1):end,:) = [];
        FrameNumNew = size(cPartData,1);
%         BeforeMegF = MegOnFrame;
    end
    cPartData(SelectEndFrame:end,:) = nan;
    yBaseAdd = max(cPartData(:));
    cROITrace = cPartData(:);
    TrialLength = length(cROITrace);
    plot(cROITrace + yBase,'color','b','LineWidth',0.8);
    for k=1:TrialNum
        MegOnFrameTrial=BeforeMegF+(k-1)*FrameNumNew;
        line([MegOnFrameTrial MegOnFrameTrial],[min(cROITrace)+yBase max(cROITrace)+yBase],'color',[.8 .8 .8],'LineWidth',1);
    end
    % plot right trials in red color
    cPartData(:,logical(TrialTypeP)) = nan;
    cROITrace = cPartData(:);
    plot(cROITrace + yBase,'color','r','LineWidth',0.8);
    
    yBase = yBase + max(yBaseAdd) + GapsBetTrace;
end
TrialLength = TrialLength + FrameRate*2;
%%
xtickPartStart = 0:FrameNumNew:FrameNumNew*TrialNum;
xtickPartEnd = SelectEndFrame:FrameNumNew:FrameNumNew*TrialNum;
xtickLine = BeforeMegF+((1:TrialNum)-1)*FrameNumNew;
xtickAll = sort([xtickPartStart,xtickPartEnd,xtickLine]);
xticklabel = repmat({'0',num2str(BeforeMegT),num2str(BeforeMegT+AfterMegT)},1,TrialNum);
set(gca,'xtick',xtickAll,'xticklabel',xticklabel);
set(gca,'ytick',[],'ycolor','w')
xlabel('Time(s)');
% xscales = get(gca,'xlim');
line([TrialLength TrialLength],[100,200],'LineWidth',2,'color','k');
text((TrialLength),150,'100% \DeltaF/F_0');
ylim([-50 yBase]);
% ylabel('\DeltaF/f_0');
title('Example ROI plot---Sound Response');
saveas(h_example,'Example ROI plot.png');
saveas(h_example,'Example ROI plot.fig');
close(h_example);


%%
%example ROI plot for 2AFC task
%example ROI plot, trial type indicated by stim on line
ExampROIinds = [4,5,20,23,31,33,51,57,97];
ExampleTrials = [1,2,3,5,7,11,12,13,15,16,17];  %trial number choosed to plot
TrialNum = length(ExampleTrials);
DataToPlot = data_aligned(ExampleTrials,ExampROIinds,:);
TrialTypeP = TrialType(ExampleTrials);
save ROIinds.mat ExampROIinds ExampleTrials -v7.3
GapsBetTrace = 50;  %gaps between each trace
AfterMegT = 5;  % seconds after stimuli start
BeforeMegT = 1; %Time choossed for baseline
BeforeMegF = floor(BeforeMegT * FrameRate); 
SelectEndFrame = BeforeMegF + floor(AfterMegT * FrameRate);
h_example = figure('position',[200 50 1600 1000],'color','w');
hold on
yBase = 0;
for n = 1 : length(ExampROIinds)
%     cROINum = ExampROIinds(n);
%     cROIData = (squeeze(AllDataChange(:,cROINum,:)))';
    cROIData = (squeeze(DataToPlot(:,n,:)))';
    cPartData = cROIData;
    if (MegOnFrame - BeforeMegF) < 1
        warning('Before StimFrame is larger than real StimOn frame, set to frame start inds');
        BeforeMegF = MegOnFrame - 1;
    end
%     yBaseAdd = max(cROIData(:));
    if (FrameNum - SelectEndFrame - (MegOnFrame - BeforeMegF)) > floor(5 * FrameRate)
        cPartData(1:(MegOnFrame - BeforeMegF),:) = [];
        cPartData((SelectEndFrame + floor(5 * FrameRate) + 1):end,:) = [];
        FrameNumNew = size(cPartData,1);
    else
        cPartData(1:(MegOnFrame - BeforeMegF),:) = [];
        cPartData((SelectEndFrame + floor(5 * FrameRate) + 1):end,:) = [];
        FrameNumNew = size(cPartData,1);
%         BeforeMegF = MegOnFrame;
    end
    cPartData(SelectEndFrame:end,:) = nan;
    yBaseAdd = max(cPartData(:));
    cROITrace = cPartData(:);
    TrialLength = length(cROITrace);
    plot(cROITrace + yBase,'color','k','LineWidth',1);
    
%     % plot right trials in red color
%     cPartData(:,logical(TrialTypeP)) = nan;
%     cROITrace = cPartData(:);
%     plot(cROITrace + yBase,'color','r','LineWidth',0.8);

    yBase = yBase + max(yBaseAdd) + GapsBetTrace;
end
TrialLength = TrialLength + FrameRate*2;
for k=1:TrialNum
        MegOnFrameTrial=BeforeMegF+(k-1)*FrameNumNew;
        if TrialTypeP(k) == 0
            line([MegOnFrameTrial MegOnFrameTrial],[-50 yBase],'color','b','LineWidth',1);   %left trial line plot
        else
            line([MegOnFrameTrial MegOnFrameTrial],[-50 yBase],'color','r','LineWidth',1);   %right trial line plot
        end
%         alpha(0.4)
end
%%
xtickPartStart = 0:FrameNumNew:FrameNumNew*TrialNum;
xtickPartEnd = SelectEndFrame:FrameNumNew:FrameNumNew*TrialNum;
xtickLine = BeforeMegF+((1:TrialNum)-1)*FrameNumNew;
xtickAll = sort([xtickPartStart,xtickPartEnd,xtickLine]);
xticklabel = repmat({'0',num2str(BeforeMegT),num2str(BeforeMegT+AfterMegT)},1,TrialNum);
% set(gca,'xtick',xtickAll,'xticklabel',xticklabel);
set(gca,'ytick',[],'ycolor','w')
set(gca,'xtick',[],'xcolor','w')
xlabel('Time(s)');
% xscales = get(gca,'xlim');
line([TrialLength TrialLength],[100,200],'LineWidth',2,'color','k');
text((TrialLength),150,'100% \DeltaF/F_0');
line([TrialLength TrialLength+FrameRate*5],[100,100],'LineWidth',2,'color','k');
text(TrialLength,50,'5 s');
ylim([-50 yBase]);
% ylabel('\DeltaF/f_0');
title('Example ROI plot---Sound Response');
saveas(h_example,'Example ROI plot.png');
saveas(h_example,'Example ROI plot.fig');
