%%
%load deltaf/f data save file
% using "Example_ROI_Colorlabeling_script" for ROI position colormap plot
clear 
clc
[fn,fpath,~] = uigetfile('DiffFluoResult.mat','Select your normalized calcium trace saving file.');
x=load(fullfile(fpath,fn));
cd(fpath);

%%
if ~iscell(x.FChangeData)
    RawData = x.FChangeData;
else
    TrFrameAll = cellfun(@(x) size(x,2),x.FChangeData);
    MinFrame = min(TrFrameAll);
    RawData = zeros(length(TrFrameAll),size(x.FChangeData{1},1),MinFrame);
    for cTr = 1 : length(TrFrameAll)
        cTrData = x.FChangeData{cTr};
        RawData(cTr,:,:) = cTrData(:,1:MinFrame);
    end
end
size_data = size(RawData);
StimulusData = load('rfSelectDataSet.mat','sound_array');
TrialType = double(StimulusData.sound_array(:,1));
StimTypes = unique(TrialType);
nStims = length(StimTypes);
fRate = load('rfSelectDataSet.mat','frame_rate');
FrameRate = fRate.frame_rate;
load('rfSelectDataSet.mat');
ROIstimResp = zeros(nStims,size_data(2));
for cStim = 1 : nStims
    cStimInds = sound_array(:,1) == StimTypes(cStim);
    cStimData = squeeze(mean(f_percent_change(cStimInds,:,(FrameRate+1):(FrameRate*2))));
    ROIstimResp(cStim,:) = max(cStimData,[],2);
end
StimOcts = log2(StimTypes/16000);
[~,MaxInds] = max(ROIstimResp);
ROITunOcts = zeros(size_data(2),1);
for cROI = 1 : size_data(2)
    ROITunOcts(cROI) = StimOcts(MaxInds(cROI));
end
% if size_data(3) > 300
%     FrameRate = 55;
% else
%     FrameRate = 29;
% end
FrameNum = size(RawData,3);
onset_time = FrameRate;
% MegOnFrame = onset_time;
% cCusMaps = (blue2red_2(nStims/2,0.1))';
% cCusMaps = ([(linspace(0,1,nStims))',zeros(nStims,1),(linspace(1,0,nStims))'])';
%%
%example ROI plot for rf
%example ROI plot
% @######################using updated plot meothods below #####################
%%%
ExampROIinds = [4,9,17,18,19,31,43,50,76,84];
% cColorROIs = ceil(length(ExampROIinds)/2);
% cCusMaps = fliplr((blue2red_2(length(ExampROIinds),0.7))');
cCusMaps = fliplr((cool(length(ExampROIinds)))');
ExampleROIOct = ROITunOcts(ExampROIinds);
[~,ROIOctInds] = sort(ExampleROIOct,'descend');
ExampROIinds = ExampROIinds(ROIOctInds);
% cTrMap = (parula(length(ExampROIinds)))';
ExampleTrials = 1:40;  %trial number choosed to plot
ExampleTrStims = TrialType(ExampleTrials);
[SortStims,TrFreqInds] = sort(ExampleTrStims);
TrStimOcts = log2(SortStims/8000);
ExampleTrials = ExampleTrials(TrFreqInds);

TrialNum = length(ExampleTrials);
DataToPlot = RawData(ExampleTrials,ExampROIinds,:); 
% TrialTypeP = TrialType(ExampleTrials);
% save ROIinds.mat ExampROIinds ExampleTrials -v7.3
GapsBetTrace = 40;  %gaps between each trace
AfterMegT = 4;  % seconds after stimuli start
BeforeMegT = 1; %Time choossed for baseline
BeforeMegF = floor(BeforeMegT * FrameRate); 
SelectEndFrame = BeforeMegF + floor(AfterMegT * FrameRate);
h_example = figure('position',[100 50 600 500],'color','w');
hold on
yBase = 0;
for n = 1 : length(ExampROIinds)
%     cROINum = ExampROIinds(n);
%     cROIData = (squeeze(AllDataChange(:,cROINum,:)))';
    cROIData = (squeeze(DataToPlot(:,n,:)))';
    cPartData = cROIData;
    cPartData = dataSmoothHD(cPartData,1,1);
    if (onset_time - BeforeMegF) < 1
        warning('Before StimFrame is larger than real StimOn frame, set to frame start inds');
        BeforeMegF = onset_time - 1;
    end
%     yBaseAdd = max(cROIData(:));
    if (FrameNum - SelectEndFrame - (onset_time - BeforeMegF)) > floor(5 * FrameRate)
        cPartData(1:(onset_time - BeforeMegF),:) = [];
        cPartData((SelectEndFrame + floor(5 * FrameRate) + 1):end,:) = [];
        FrameNumNew = size(cPartData,1);
    else
        cPartData(1:(onset_time - BeforeMegF),:) = [];
        cPartData((SelectEndFrame + floor(5 * FrameRate) + 1):end,:) = [];
        FrameNumNew = size(cPartData,1);
%         BeforeMegF = onset_time;
    end
    cPartData(SelectEndFrame:end,:) = nan;
    yBaseAdd = max(cPartData(:));
    cROITrace = cPartData(:);
    TrialLength = length(cROITrace);
%     plot(cROITrace + yBase,'color','k','LineWidth',1.2);
    cROITunInds = ROITunOcts(ExampROIinds(n));
%     cColor = StimOcts == cROITunInds;
    
    for k=1:TrialNum
        onset_timeTrial=BeforeMegF+(k-1)*FrameNumNew;
%         cFreqInds = ROITunOcts(k);
%         cColor = StimOcts == cFreqInds;
        line([onset_timeTrial onset_timeTrial],[min(cROITrace)+yBase max(cROITrace)+yBase],'color',[.8 .8 .8],'LineWidth',0.4); % cCusMaps(:,cColor)
        if n == length(ExampROIinds)
            text(onset_timeTrial,max(cROITrace)+yBase,sprintf('%.1f',TrStimOcts(k)),'FontSize',4);
        end
    end
    plot(cROITrace + yBase,'color',cCusMaps(:,n),'LineWidth',1);
    text(length(cROITrace)+50,yBase,[num2str(ExampROIinds(n)),' - ',num2str(n)],'color',cCusMaps(:,n));
    % plot right trials in red color
%     cPartData(:,logical(TrialTypeP)) = nan;
%     cROITrace = cPartData(:);
%     plot(cROITrace + yBase,'color','r','LineWidth',0.8);
    
    yBase = yBase + max(yBaseAdd) + GapsBetTrace;
end
TrialLength = TrialLength + FrameRate*2;
%%
% xtickPartStart = 0:FrameNumNew:FrameNumNew*TrialNum;
% xtickPartEnd = SelectEndFrame:FrameNumNew:FrameNumNew*TrialNum;
% xtickLine = BeforeMegF+((1:TrialNum)-1)*FrameNumNew;
% xtickAll = sort([xtickPartStart,xtickPartEnd,xtickLine]);
% xticklabel = repmat({'0',num2str(BeforeMegT),num2str(BeforeMegT+AfterMegT)},1,TrialNum);
% set(gca,'xtick',xtickAll,'xticklabel',xticklabel);
set(gca,'ytick',[],'ycolor','w','xcolor','w')
xlabel('Time(s)');
set(gca,'xtick',[],'xticklabel','');
% xscales = get(gca,'xlim');
line([TrialLength TrialLength],[100,200],'LineWidth',2,'color','k');
text((TrialLength),150,'100% \DeltaF/F_0');
line([TrialLength TrialLength+FrameRate*5],[100,100],'LineWidth',2,'color','k');
text(TrialLength,50,'5 s');
ylim([-50 yBase]);
% ylabel('\DeltaF/f_0');
title('Example ROI plot---Sound Response');
set(gca,'fontSize',20)
saveas(h_example,'Example ROI plot.png');
saveas(h_example,'Example ROI plot.fig');
% close(h_example);


%%
%example ROI plot for 2AFC task
%example ROI plot, trial type indicated by stim on line
ExampROIinds = [30,33,43,56,85,98];
ExampleTrials = 1:40;  %trial number choosed to plot
TrialNum = length(ExampleTrials);
DataToPlot = RawData(ExampleTrials,ExampROIinds,:);
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
    if (onset_time - BeforeMegF) < 1
        warning('Before StimFrame is larger than real StimOn frame, set to frame start inds');
        BeforeMegF = onset_time - 1;
    end
%     yBaseAdd = max(cROIData(:));
    if (FrameNum - SelectEndFrame - (onset_time - BeforeMegF)) > floor(5 * FrameRate)
        cPartData(1:(onset_time - BeforeMegF),:) = [];
        cPartData((SelectEndFrame + floor(5 * FrameRate) + 1):end,:) = [];
        FrameNumNew = size(cPartData,1);
    else
        cPartData(1:(onset_time - BeforeMegF),:) = [];
        cPartData((SelectEndFrame + floor(5 * FrameRate) + 1):end,:) = [];
        FrameNumNew = size(cPartData,1);
%         BeforeMegF = onset_time;
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
        onset_timeTrial=BeforeMegF+(k-1)*FrameNumNew;
        if TrialTypeP(k) == 0
            line([onset_timeTrial onset_timeTrial],[-50 yBase],'color','b','LineWidth',1);   %left trial line plot
        else
            line([onset_timeTrial onset_timeTrial],[-50 yBase],'color','r','LineWidth',1);   %right trial line plot
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
line([TrialLength TrialLength],[100,300],'LineWidth',0.8,'color','k');
text((TrialLength),200,'200% \DeltaF/F_0');
line([TrialLength TrialLength+FrameRate*10],[100,100],'LineWidth',0.8,'color','k');
text(TrialLength,50,'10 s');
ylim([-50 yBase]);
% ylabel('\DeltaF/f_0');
title('Example ROI plot---Sound Response');
set(gca,'fontSize',20);
%%
saveas(h_example,'Example ROI plot sorted.png');
saveas(h_example,'Example ROI plot sorted.fig');
saveas(h_example,'Example ROI plot sorted','pdf');
% close(h_example);