% this scription is used for summarized plot of multiple sessions data into
% one plot, summaried all sessions' ROI response into one plot

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
    TaskClassDataSum = [];
    PavClassDataSum = [];
    FracMaxAUC = [];
    SUFClfDataSum = [];
    SessionAUCAll = {};
else
   m = length(DataSum) + 1;
end

while ~strcmpi(add_char,'n')
    [fn,fp,fi] = uigetfile('RFtaskFracClass.mat','Please select your ROI fraction based classification result save');
    if fi
        datapath{m} = fullfile(fp,fn);
        xx = load(fullfile(fp,fn));
        DataSum{m} = xx;
        TaskClassDataSum(m,:) = 1 - mean(xx.ClassScore,2);
        PavClassDataSum(m,:) = 1 - mean(xx.RFFracClassPerfAll,2);
        SUFClfDataSum(m,:) = 1 - mean(xx.SUFVlassScore,2);
        FracMaxAUC(m,:) = xx.FracMaxAUCV;
        SessionAUCAll{m} = xx.ROIauc;
        if m == 1
            ROIfrac = xx.FracROIValue(:);
        end
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
save SessionDataSum.mat DataSum TaskClassDataSum PavClassDataSum SUFClfDataSum FracMaxAUC ROIfrac SessionAUCAll -v7.3
%%
TaskMeanPerf = mean(TaskClassDataSum);
TaskPerfSEM = std(TaskClassDataSum)/sqrt(size(TaskClassDataSum,1));
PasvMeanPerf = mean(PavClassDataSum);
PasvPerfSEM = std(PavClassDataSum)/sqrt(size(PavClassDataSum,1));
SUFTaskMeanPerf = mean(SUFClfDataSum);
SUFTaskPerfSEM = std(SUFClfDataSum)/sqrt(size(SUFClfDataSum,1));
MeanMaxAUC = mean(FracMaxAUC);

xtickP = [ROIfrac;flipud(ROIfrac)];
yPatchTask = [(TaskMeanPerf + TaskPerfSEM),fliplr(TaskMeanPerf - TaskPerfSEM)];
yPatchPasv = [(PasvMeanPerf + PasvPerfSEM),fliplr(PasvMeanPerf - PasvPerfSEM)];
yPatchSUF = [(SUFTaskMeanPerf + SUFTaskPerfSEM),fliplr(SUFTaskMeanPerf - SUFTaskPerfSEM)];
h = figure('position',[300 200 1000 800]);
hold on;
patch(xtickP,yPatchTask,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
patch(xtickP,yPatchPasv,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
patch(xtickP,yPatchSUF,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
h1 = plot(ROIfrac,TaskMeanPerf,'k','LineWidth',2);
h2 = plot(ROIfrac,PasvMeanPerf,'r','LineWidth',2);
h3 = plot(ROIfrac,SUFTaskMeanPerf,'color',[.5 .5 .5],'LineWidth',2);
set(gca,'xticklabel',[]);
ylims = get(gca,'ylim');
%
% ROCmean = zeros(5,1);
% k = 1;
for nxnx = 0.2:0.2:1
    cFrac = nxnx;
    FracMean = MeanMaxAUC(abs(ROIfrac - cFrac) < 0.01);
%     ROCmean(k) = FracMean;
    text('Units', 'Data', 'Position', [cFrac, ylims(1) - 0.025], 'HorizontalAlignment', 'center', 'String',num2str(FracMean,'%.2f'),'FontSize',14);
    text('Units', 'Data', 'Position', [cFrac, ylims(1) - 0.01], 'HorizontalAlignment', 'center', 'String',num2str(cFrac,'%.2f'),'FontSize',14);
%     k = k + 1;
end
text('Units', 'Data', 'Position', [0 ylims(1) - 0.025],'HorizontalAlignment', 'center','String','Mean MaxAUC','FontSize',8);
text('Units', 'Data', 'Position', [0 ylims(1) - 0.01],'HorizontalAlignment', 'center','String','Cell Frac.','FontSize',8);
%
ylim([ylims(1),1]);
set(gca,'ytick',0.5:0.25:1);
% xlabel('Cell Frac');
ylabel('Classfication accuracy');
title('Task vs passive compare plot');
% line(0.2:0.2:1,ROCmean,'color',[.8 .8 .8],'LineWidth',1.6,'LineStyle','--');
set(gca,'FontSize',20);
legend([h1,h2,h3],{'Task','Passive','Task Shuffle'},'Location','northwest','FontSize',14);
saveas(h,'Task vs passive FracClassification plot');
saveas(h,'Task vs passive FracClassification plot','png');
% close(h);
