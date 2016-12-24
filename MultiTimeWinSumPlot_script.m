%script for summary plot of extimated spike across time plot

add_char = 'y';
inputChoice = input('would like to added new session data into last summary result?\n','s');
if strcmpi(inputChoice,'y')
    [fnx,fpx,fix] = uigetfile('SessionDataSum.mat','Please load your last summary plot result');
    if fix
        load(fullfile(fpx,fnx));
        isOldLoad = 1;
    else
        isOldLoad = 0;
    end
else
    isOldLoad = 0;
end
if ~isOldLoad
    m = 1;
    datapath = {};
    DataSum = {};
    TimeWinScale = {};
    TrWinPerf = {};
    TrWinPerfAll = {};
else
   m = length(DataSum) + 1;
end

while ~strcmpi(add_char,'n')
    [fn,fp,fi] = uigetfile('MWinCLassData.mat','Please select your ROI fraction based classification result save');
    if fi
        datapath{m} = fullfile(fp,fn);
        xx = load(fullfile(fp,fn));
        DataSum{m} = xx;
        TimeWinScale{m} = xx.MultiTScale;
        TrWinPerfAll{m} = xx.TrWinClassPerfAll;
        TrWinPerf{m} = mean(xx.TrWinClassPerfAll,2);
    end
    add_char = input('Do you want to add with more session data?\n','s');
    m = m + 1;
end
m = m - 1;

fp = uigetdir(pwd,'Please select a session to save your current data');
cd(fp);
f = fopen('Session_resp_path.txt','w');
fprintf(f,'Sessions path for response summary plot:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,datapath{nbnb});
end
fclose(f);
save SessionDataSum.mat DataSum TimeWinScale TrWinPerf TrWinPerfAll datapath -v7.3

%%
TrScaleLen = cellfun(@length,TimeWinScale);

if length(unique(TrScaleLen)) > 1
    fprintf('Multi length time scale exists, using the min time scale for plotting.\n');
    TargetLen = min(TrScaleLen);
    DataCellAll = cellfun(@(x,y) CellDataExtract(x,TargetLen),TrWinPerf,'UniformOutput',false);
    DataCellAll = (DataCellAll(:))';
    DataMatrixAll = (cell2mat(DataCellAll))';
else
    fprintf('Unique length of all time scales, convert into number matrix.\n');
    TargetLen = TrScaleLen(1);
    DataCellAll = (TrWinPerf(:))';
    DataMatrixAll = (cell2mat(DataCellAll))';
end
DataMatrixAll = 1 - DataMatrixAll;
xTickScaleLen = TimeWinScale{1}(1:TargetLen);
TimeWinStep = diff(xTickScaleLen(1:2));
xTickScaleLen(xTickScaleLen < 0) = xTickScaleLen(xTickScaleLen < 0) + TimeWinStep;
xTickScaleLen = xTickScaleLen(:);
TrWinPerfMean = mean(DataMatrixAll);
TrWinPerfSEM = std(DataMatrixAll)/sqrt(size(DataMatrixAll,1));
xTickP = [xTickScaleLen;flipud(xTickScaleLen)];
TrWinPerfPatch = [(TrWinPerfMean + TrWinPerfSEM),fliplr(TrWinPerfMean - TrWinPerfSEM)];

h = figure('position',[300 200 1000 800]);
patch(xTickP,TrWinPerfPatch,1,'facecolor',[.5 .5 .5],...
              'edgecolor','none',...
              'facealpha',0.7);
plot(xTickScaleLen,TrWinPerfMean,'k','LineWidth',1.6);
line([0 0],[0.4 1],'Color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
ylim([0.4 1]);
xlims = get(gca,'xlim');
line([xlims(1),xlims(2)],[0.5 0.5],'Color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
xlabel('Time (s)');
ylabel('Classification Accuracy');
title('Temporal profile of choice classification');
set(gca,'FontSize',20);
saveas(h,'Time Win classification of choice by extimated spike');
saveas(h,'Time Win classification of choice by extimated spike','png');
% close(h);

save MeanTimeWinData.mat xTickScaleLen DataMatrixAll -v7.3


%%
% scripts for compare plot of task and passive data summary set
[fn,fp,fi] = uigetfile('MeanTimeWinData.mat','Select Task across session choice classification result plot');
xxtask = load(fullfile(fp,fn));
TaskTicks = xxtask.xTickScaleLen;
TaskCLassidata = xxtask.DataMatrixAll;

[fn,fp,fi] = uigetfile('MeanTimeWinData.mat','Select passive across session choice classification result plot');
xxPass = load(fullfile(fp,fn));
PassTicks = xxPass.xTickScaleLen;
PassCLassidata = xxPass.DataMatrixAll;
%
[h,~,hLine1] = MeanSemPlot(TaskCLassidata,TaskTicks,[],'k','LineWidth',1.6);
[hPlotf,hp,hLine2] = MeanSemPlot(PassCLassidata,PassTicks,h,'r','LineWidth',1.6);
line([0 0],[0.4,1],'color',[.8 .8 .8],'LineWidth',1.6,'LineStyle','--');
set(hp,'facecolor','r','facealpha',0.4);
xlabel('Time (s)');
ylabel('Accuracy');
title('Task Passive comparation');
set(gca,'FontSize',20,'ytick',[0.4,0.6,0.8,1]);
ylim([0.4 1]);
legend([hLine1,hLine2],{'Task','Passive'},'FontSize',14);
saveas(hPlotf,'Task Passive comparation plot');
saveas(hPlotf,'Task Passive comparation plot','png');
close(hPlotf);
save CompSaveResult.mat TaskCLassidata TaskTicks PassCLassidata PassTicks -v7.3
%%
% single trace compare plot
for nTr = 1 : size(PassCLassidata,1)
    h = figure;
    hold on;
    plot(TaskTicks,TaskCLassidata(nTr,:),'k','LineWidth',1.6);
    plot(PassTicks,PassCLassidata(nTr,:),'r','LineWidth',1.6);
    xlabel('Time (s)');
    ylabel('Classification accuracy');
    title(sprintf('Session%d compare plot',nTr));
    set(gca,'FontSize',20)
    xlim([-1 max(TaskTicks)]);
    saveas(h,sprintf('Session%d task passive compare plot',nTr));
    saveas(h,sprintf('Session%d task passive compare plot',nTr),'png');
    close(h);
end