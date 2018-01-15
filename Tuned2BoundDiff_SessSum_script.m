clear
clc
[fn,fp,fi] = uigetfile('*.txt','Please select the session path savage file');
if ~fi
    return;
end
%%
clearvars -except fn fp
fpath = fullfile(fp,fn);
fid = fopen(fpath);
tline = fgetl(fid);
nSess = 1;
SessDiffMean = [];  % All ROIs Diff
SessModeDiff = []; % mode value diff
SessPopuAverageDiff = [];
SessOctaveMeanDiff = [];
SessNearBoundFrac = {};
SingleNeuDifAll = {};
NearThres = [0.2,0.4,0.6];

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fid);
        continue;
    end
    load(fullfile(tline,'Tunning_fun_plot_New1s','TunningDataSave.mat'));
    cd(fullfile(tline,'Tunning_fun_plot_New1s'));
    
    BehavBoundfile = load(fullfile(tline,'RandP_data_plots','boundary_result.mat'));
    BehavBoundData = BehavBoundfile.boundary_result.Boundary - 1;
%     BehavCorr = BehavBoundfile.boundary_result.StimCorr;
%     Uncertainty = 1 - BehavCorr;
    
    % passive tuning octaves
    UsedOctaveInds = ~(abs(PassFreqOctave) > 1);
    UsedOctave = PassFreqOctave(UsedOctaveInds);
    UsedOctave = UsedOctave(:);
    UsedOctaveData = PassTunningfun(UsedOctaveInds,:);
    [PassMaxAmp,PassMaxInds] = max(UsedOctaveData);
    PassMaxIndsOctave = zeros(length(PassMaxAmp),1);
    for cRoi = 1 : length(PassMaxAmp)
        PassMaxIndsOctave(cRoi) = UsedOctave(PassMaxInds(cRoi));
    end
    
    % task Tuning octaves
    TaskFreqOctave = TaskFreqOctave(:);
    TaskOctaveData = CorrTunningFun;
    nROIs = size(TaskOctaveData,2);
    [TaskMaxAmp,TaskMaxInds] = max(TaskOctaveData);
    TaskMaxIndssOctave = zeros(nROIs,1);
    for cR = 1 : nROIs
        TaskMaxIndssOctave(cR) = TaskFreqOctave(TaskMaxInds(cR));
    end
    
    % every single ROI diff
    Pass2BoundDiff = abs(PassMaxIndsOctave - BehavBoundData);
    Task2BoundDiff = abs(TaskMaxIndssOctave - BehavBoundData);
    SingleNeuDifAll{nSess,1} = Pass2BoundDiff;
    SingleNeuDifAll{nSess,2} = Task2BoundDiff;
    SessDiffMean(nSess,:) = mean([Pass2BoundDiff,Task2BoundDiff]);
    
    % Mode Diff Boundary
    SessModeDiff(nSess,:) = [abs(mode(PassMaxIndsOctave) - BehavBoundData),...
        abs(mode(TaskMaxIndssOctave) - BehavBoundData)];
    
    % Octave mean diff
    SessOctaveMeanDiff(nSess,:) = [abs(mean(PassMaxIndsOctave) - BehavBoundData),...
        abs(mean(TaskMaxIndssOctave) - BehavBoundData)];
    
    % population average mean peak diff
    PassTransData = mean(zscore(PassMaxIndsOctave'));
    TaskTransData = mean(zscore(TaskOctaveData'));
    [~,PassAvgMaxInds] = max(PassTransData);
    [~,TaskAvgMaxInds] = max(TaskTransData);
    SessPopuAverageDiff(nSess,:) = [abs(UsedOctave(PassAvgMaxInds) - BehavBoundData),...
        abs(TaskFreqOctave(TaskAvgMaxInds) - BehavBoundData)];
    
    % Tuned-near-Bound cell fraction
    nThresValue = length(NearThres);
    PassNearBTunedFrac = zeros(nThresValue,1);
    TaskNearBTunedFrac = zeros(nThresValue,1);
    for cThres = 1 : nThresValue
        cThresValue = NearThres(cThres);
        PassNearThresInds = find(abs(UsedOctave - BehavBoundData) <= cThresValue);
        NearInds = zeros(length(PassMaxIndsOctave),1);
        for cInds = 1 : length(PassNearThresInds)
            NearInds(PassMaxIndsOctave == UsedOctave(PassNearThresInds(cInds))) = 1;
        end
        PassNearBTunedFrac(cThres) = mean(NearInds);
        
        TaskNearThresInds = find(abs(TaskFreqOctave - BehavBoundData) <= cThresValue);
        TaskNearInds = zeros(length(TaskMaxIndssOctave),1);
        for cInds = 1 : length(TaskNearThresInds)
            TaskNearInds(TaskMaxIndssOctave == TaskFreqOctave(TaskNearThresInds(cInds))) = 1;
        end
        TaskNearBTunedFrac(cThres) = mean(TaskNearInds);
    end
    SessNearBoundFrac{nSess,1} = PassNearBTunedFrac;
    SessNearBoundFrac{nSess,2} = TaskNearBTunedFrac;
    
    save Tun2BoundDataSave.mat Pass2BoundDiff Task2BoundDiff -v7.3
    tline = fgetl(fid);
    nSess = nSess + 1;
end
%%
SavePath = uigetdir(pwd,'Please select current figure save path');
cd(SavePath);
%% every single ROI diff
[~,p] = ttest(SessDiffMean(:,1),SessDiffMean(:,2));
hf = figure('position',[100 100 350 300]);
hold on
bar([1,2],mean(SessDiffMean),0.4,'FaceColor',[.8 .8 .8],'EdgeColor',[.3 .3 .3])
plot(ones(size(SessDiffMean(:,1))),SessDiffMean(:,1),'o','Color',[.5 .5 .5],'MarkerSize',6);
plot(ones(size(SessDiffMean(:,2)))*2,SessDiffMean(:,2),'o','Color',[.5 .5 .5],'MarkerSize',6);
errorbar([1,2],mean(SessDiffMean),std(SessDiffMean)/sqrt(size(SessDiffMean,1)),'k.','linewidth',2,'MarkerSize',10);
set(gca,'xtick',[1,2],'xticklabel',{'Passive','Task'});
ylabel('Distance to Bound');
set(gca,'FontSize',16);
GroupSigIndication([1,2],max(SessDiffMean),p,hf);
title('AllROIs')
% set(gca,'ytick',[0 1]);
saveas(hf,'Sess2Bound diff compare AllROIs plot');
saveas(hf,'Sess2Bound diff compare AllROIs plot','png');

% scatter plot of all sessions
hf = figure('position',[100 100 350 300]);
scatter(SessDiffMean(:,1),SessDiffMean(:,2),40,[.1 .1 .1],'o','linewidth',1.5)
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
CommonScales = [min(xscales(1),yscales(1)),max(xscales(2),yscales(2))];
line(CommonScales,CommonScales,'Color',[.7 .7 .7],'linewidth',1.8,'linestyle','--');
set(gca,'xlim',CommonScales,'ylim',CommonScales);
xlabel('Passive');
ylabel('Task');
title('Tun2Bound distance')
set(gca,'FontSize',16);
text(CommonScales(1)+0.1*diff(CommonScales),CommonScales(1)+0.8*diff(CommonScales),{sprintf('N = %d',size(SessDiffMean,1)),...
    sprintf('p = %.3e',p)},'FontSize',12)
saveas(hf,'Sess2Bound diff compare AllROIs scatter plot');
saveas(hf,'Sess2Bound diff compare AllROIs scatter plot','png');

%% Mode Diff Boundary
UsedDiffData = SessModeDiff;
[~,p] = ttest(UsedDiffData(:,1),UsedDiffData(:,2));
hf = figure('position',[100 100 350 300]);
hold on
bar([1,2],mean(UsedDiffData),0.4,'FaceColor',[.8 .8 .8],'EdgeColor',[.3 .3 .3])
plot(ones(size(UsedDiffData(:,1))),UsedDiffData(:,1),'o','Color',[.5 .5 .5],'MarkerSize',6);
plot(ones(size(UsedDiffData(:,2)))*2,UsedDiffData(:,2),'o','Color',[.5 .5 .5],'MarkerSize',6);
errorbar([1,2],mean(UsedDiffData),std(UsedDiffData)/sqrt(size(UsedDiffData,1)),'k.','linewidth',2,'MarkerSize',10);
set(gca,'xtick',[1,2],'xticklabel',{'Passive','Task'});
ylabel('Distance to Bound');
set(gca,'FontSize',16);
GroupSigIndication([1,2],max(UsedDiffData),p,hf);
title('Prefer2Bound')
% set(gca,'ytick',[0 1]);
saveas(hf,'Sess2Bound mode diff compare plot');
saveas(hf,'Sess2Bound mode diff compare AllROIs plot','png');

% scatter plot of all sessions
hf = figure('position',[100 100 350 300]);
scatter(SessModeDiff(:,1),SessModeDiff(:,2),40,[.1 .1 .1],'o','linewidth',1.5)
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
CommonScales = [min(xscales(1),yscales(1)),max(xscales(2),yscales(2))];
line(CommonScales,CommonScales,'Color',[.7 .7 .7],'linewidth',1.8,'linestyle','--');
set(gca,'xlim',CommonScales,'ylim',CommonScales);
xlabel('Passive');
ylabel('Task');
title('Prefer2Bound distance')
set(gca,'FontSize',16);
text(CommonScales(1)+0.1*diff(CommonScales),CommonScales(1)+0.8*diff(CommonScales),{sprintf('N = %d',size(SessModeDiff,1)),...
    sprintf('p = %.3e',p)},'FontSize',12)
saveas(hf,'Sess2Bound diff compare mode scatter plot');
saveas(hf,'Sess2Bound diff compare mode scatter plot','png');
%% Octave mean diff
UsedDiffData = SessOctaveMeanDiff;
[~,p] = ttest(UsedDiffData(:,1),UsedDiffData(:,2));
hf = figure('position',[100 100 350 300]);
hold on
bar([1,2],mean(UsedDiffData),0.4,'FaceColor',[.8 .8 .8],'EdgeColor',[.3 .3 .3])
plot(ones(size(UsedDiffData(:,1))),UsedDiffData(:,1),'o','Color',[.5 .5 .5],'MarkerSize',6);
plot(ones(size(UsedDiffData(:,2)))*2,UsedDiffData(:,2),'o','Color',[.5 .5 .5],'MarkerSize',6);
errorbar([1,2],mean(UsedDiffData),std(UsedDiffData)/sqrt(size(UsedDiffData,1)),'k.','linewidth',2,'MarkerSize',10);
set(gca,'xtick',[1,2],'xticklabel',{'Passive','Task'});
ylabel('Distance to Bound');
set(gca,'FontSize',16);
GroupSigIndication([1,2],max(UsedDiffData),p,hf);
title('OctMean2Bound')
% set(gca,'ytick',[0 1]);
saveas(hf,'Sess2Bound OctMean diff compare plot');
saveas(hf,'Sess2Bound OctMean diff compare AllROIs plot','png');

%% population average mean peak diff
UsedDiffData = SessPopuAverageDiff;
[~,p] = ttest(UsedDiffData(:,1),UsedDiffData(:,2));
hf = figure('position',[100 100 350 300]);
hold on
bar([1,2],mean(UsedDiffData),0.4,'FaceColor',[.8 .8 .8],'EdgeColor',[.3 .3 .3])
plot(ones(size(UsedDiffData(:,1))),UsedDiffData(:,1),'o','Color',[.5 .5 .5],'MarkerSize',6);
plot(ones(size(UsedDiffData(:,2)))*2,UsedDiffData(:,2),'o','Color',[.5 .5 .5],'MarkerSize',6);
errorbar([1,2],mean(UsedDiffData),std(UsedDiffData)/sqrt(size(UsedDiffData,1)),'k.','linewidth',2,'MarkerSize',10);
set(gca,'xtick',[1,2],'xticklabel',{'Passive','Task'});
ylabel('Distance to Bound');
set(gca,'FontSize',16);
GroupSigIndication([1,2],max(UsedDiffData),p,hf);
title('PopuMean2Bound')
% set(gca,'ytick',[0 1]);
saveas(hf,'Sess2Bound PopuMean diff compare plot');
saveas(hf,'Sess2Bound PopuMean diff compare AllROIs plot','png');

%% NearBound Fraction
nThres = length(NearThres);
ThresStrs = cellstr(num2str(NearThres(:),'%.1f'));
UsedStr = cell(nThres+1,1);
UsedStr{1} = 'Range=';
UsedStr(2:end) = ThresStrs(:);
Upperratio = [1.3,1.2,1.1];
pValues = zeros(nThres,1);
PassRealToRandP = zeros(nThres,1);
TaskRealToRandP = zeros(nThres,1);
hf = figure('position',[3000 200 450 380]);
hold on;
for cThres = 1 : nThres
    cThresPassFrac = cellfun(@(x) x(cThres),SessNearBoundFrac(:,1));
    cThresTaskFrac = cellfun(@(x) x(cThres),SessNearBoundFrac(:,2));
    cThresSEM = [std(cThresPassFrac)/sqrt(numel(cThresPassFrac)),std(cThresTaskFrac)/sqrt(numel(cThresTaskFrac))];
    b1 = bar(cThres-0.2,mean(cThresPassFrac),0.2,'FaceColor',[.8 .8 .8],'EdgeColor','none');
    b2 = bar(cThres+0.2,mean(cThresTaskFrac),0.2,'FaceColor',[0.9 0.2 0.2],'EdgeColor','none');
    line([cThres-0.2 cThres-0.2],mean(cThresPassFrac)+cThresSEM(1)*[-1,1],'Color','k','linewidth',2);
    line([cThres+0.2 cThres+0.2],mean(cThresTaskFrac)+cThresSEM(2)*[-1,1],'Color','k','linewidth',2);
%     errorbar([-0.2 0.2]+cThres,[mean(cThresPassFrac),mean(cThresTaskFrac)],...
%         [std(cThresPassFrac)/sqrt(numel(cThresPassFrac)),std(cThresTaskFrac)/sqrt(numel(cThresTaskFrac))],...
%         'k.','linewidth',2,'MarkerSize',10);
    [~,cp] = ttest(cThresPassFrac,cThresTaskFrac);
    pValues(cThres) = cp;
    hf = GroupSigIndication([-0.2 0.2]+cThres,[mean(cThresPassFrac),mean(cThresTaskFrac)],cp,hf,Upperratio(cThres));
    [~,PassRandCP] = ttest(cThresPassFrac,1/6);
    PassRealToRandP(cThres) = PassRandCP;
    [~,TaskRandCP] = ttest(cThresTaskFrac,1/6);
    TaskRealToRandP(cThres) = TaskRandCP;
end
set(gca,'xtick',[],'xticklabel','','xlim',[0.5 nThres+0.5]);
yscales = get(gca,'ylim');
set(gca,'ytick',0:0.2:yscales(2));
text([0.5,1:nThres],(-0.03*ones(nThres+1,1)),UsedStr,'HorizontalAlignment','center','FontSize',16)
ylabel('Cell fraction');
set(gca,'FontSize',18);
legend([b1,b2],{'Passive','Task'},'Location','NorthWest','FontSize',14);
legend('boxoff');
saveas(hf,'Different awayFromBound thres Value tuned cell fraction');
saveas(hf,'Different awayFromBound thres Value tuned cell fraction','png');

%% lowest thres value Tuned cell fraction
PassLowThresFrac = cellfun(@(x) x(1),SessNearBoundFrac(:,1));
TaskLowThresFrac = cellfun(@(x) x(1),SessNearBoundFrac(:,2));
ForLinePlotData = [PassLowThresFrac,TaskLowThresFrac];
RandProb = 1/6;
[~,PassP] = ttest(PassLowThresFrac,RandProb);
[~,TaskP] = ttest(TaskLowThresFrac,RandProb);
if PassP > 0.05
    PassSigStr = 'N.S.';
elseif PassP > 0.01
    PassSigStr = '*';
elseif PassP > 0.001
    PassSigStr = '**';
else
    PassSigStr = '***';
end
if TaskP > 0.05
    TaskSigStr = 'N.S.';
elseif TaskP > 0.01
    TaskSigStr = '*';
elseif TaskP > 0.001
    TaskSigStr = '**';
else
    TaskSigStr = '***';
end


hf = figure('position',[200 100 380 320]);
hold on
plot(ones(length(PassLowThresFrac),1),PassLowThresFrac,'*','Color',[.7 .7 .7],'MarkerSize',8);
plot(ones(length(TaskLowThresFrac),1)*2,TaskLowThresFrac,'*','Color',[.7 .7 .7],'MarkerSize',8);
errorbar([1,2],[mean(PassLowThresFrac),mean(TaskLowThresFrac)],[std(PassLowThresFrac)/sqrt(numel(PassLowThresFrac)),...
    std(TaskLowThresFrac)/sqrt(numel(TaskLowThresFrac))],...
    'ko','linewidth',2);
plot([1,2],ForLinePlotData','Color',[.7 .7 .7],'linewidth',1.6);
set(gca,'xtick',[1 2],'xticklabel',{'Pass','Task'},'xlim',[0.5 2.5]);
line([0.5,2.5],[RandProb RandProb],'Color','m','linewidth',1.4,'linestyle','--');
ylabel('Cell Fraction');
set(gca,'FontSize',18)
text(0.55,RandProb-0.04,'Rand Frac','FontSize',9,'Color','g');
if isempty(strfind(PassSigStr,'*'))
    FontSizeV = 10;
    AddValue = 0.04;
else
    FontSizeV = 24;
    AddValue = 0.02;
end
text(0.8,RandProb+AddValue,PassSigStr,'FontSize',FontSizeV,'Color','b','HorizontalAlignment','center');
if isempty(strfind(TaskSigStr,'*'))
    FontSizeV = 10;
     AddValue = 0.04;
else
    FontSizeV = 24;
     AddValue = 0.02;
end
text(2.2,RandProb+AddValue,TaskSigStr,'FontSize',FontSizeV,'Color','b','HorizontalAlignment','center');
yscales = get(gca,'ylim');
set(gca,'ytick',0:0.2:yscales(2));
saveas(hf,'Cloest Stimulus tuning ROI fraction');
saveas(hf,'Cloest Stimulus tuning ROI fraction','png');
%% single neuron paired scatter plot and cumulative plot
PassDiffDataAll = cell2mat(SingleNeuDifAll(:,1));
TaskDiffDataAll = cell2mat(SingleNeuDifAll(:,2));
[Passy,Passx] = ecdf(PassDiffDataAll);
[Tasky,Taskx] = ecdf(TaskDiffDataAll);
MeanValue = [mean(PassDiffDataAll),mean(TaskDiffDataAll)];
MeanStr = cellstr(num2str(MeanValue(:),'%.2f'));
pAll = ranksum(PassDiffDataAll,TaskDiffDataAll);
hhf = figure('position',[100 100 450 380]);
ha = axes;
hold on
plot(Passx,Passy,'k','linewidth',1.8);
plot(Taskx,Tasky,'r','linewidth',1.8);
set(ha,'ytick',[0 0.5 1]);
xlabel(ha,'Distance (Octave)');
ylabel(ha,'Fraction');
title(ha,'SingleNeu2Bound distance');
set(ha,'FontSize',16);
text(ha,caxesPos(1)+(0.02*caxesPos(3)),0.8,{sprintf('n = %d',length(PassDiffDataAll));sprintf('p = %.3e',pAll)},'FontSize',12);
caxesPos = get(ha,'position');
h_axes = axes('position',[caxesPos(1)+(2/3*caxesPos(3)),caxesPos(2)+0.02*caxesPos(4),caxesPos(3)/3,caxesPos(4)*0.5], 'color', 'none', 'visible','off');
hold(h_axes,'on');
bar(h_axes,1,mean(PassDiffDataAll),0.4,'EdgeColor','none','FaceColor','k','facealpha',0.8);
bar(h_axes,2,mean(TaskDiffDataAll),0.4,'EdgeColor','none','FaceColor','r','facealpha',0.8);
set(h_axes,'xlim',[0.5 2.5],'xcolor','w');
text(h_axes,[1,2],MeanValue*1.05,MeanStr,'HorizontalAlignment','center');

saveas(hhf,'Paired neuon distance cumulative plot');
saveas(hhf,'Paired neuon distance cumulative plot','png');

%%
save SessSummaryData.mat SessDiffMean SessModeDiff SessPopuAverageDiff SessOctaveMeanDiff SessNearBoundFrac NearThres SingleNeuDifAll -v7.3

%%
PassSelectThresFrac = cellfun(@(x) x(2),SessNearBoundFrac(:,1));
TaskSelectThresFrac = cellfun(@(x) x(2),SessNearBoundFrac(:,2));
UsedInds = 1:19;
PassSelectThresFrac = PassSelectThresFrac(UsedInds);
TaskSelectThresFrac = TaskSelectThresFrac(UsedInds);
ForLinePlotData = [PassSelectThresFrac,TaskSelectThresFrac];
[~,TestP] = ttest(PassSelectThresFrac,TaskSelectThresFrac);

hf = figure('position',[200 100 380 320]);
hold on
% plot(ones(length(PassLowThresFrac),1),PassLowThresFrac,'*','Color',[.7 .7 .7],'MarkerSize',8);
% plot(ones(length(TaskLowThresFrac),1)*2,TaskLowThresFrac,'*','Color',[.7 .7 .7],'MarkerSize',8);
plot([1,2],ForLinePlotData','Color',[.7 .7 .7],'linewidth',2);
errorbar([1,2],[mean(PassSelectThresFrac),mean(TaskSelectThresFrac)],[std(PassSelectThresFrac)/sqrt(numel(PassSelectThresFrac)),...
    std(TaskSelectThresFrac)/sqrt(numel(TaskSelectThresFrac))],...
    'ko','linewidth',3,'MarkerSize',11);
set(gca,'xtick',[1 2],'xticklabel',{'Pass','Task'},'xlim',[0.5 2.5]);
ylabel('Cell Fraction');
set(gca,'FontSize',18)
yscales = get(gca,'ylim');
set(gca,'ytick',0:0.2:yscales(2));
hf = GroupSigIndication([1,2],max(ForLinePlotData),TestP,hf,1.1,[],12);
% saveas(hf,'Near two tones cell fraction plots');
% saveas(hf,'Near two tones cell fraction plots','png');