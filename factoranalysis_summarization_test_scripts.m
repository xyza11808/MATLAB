
SavePath = uigetdir('Please select a data path for current data save');
cd(SavePath);
%%
addchar = 'y';
m = 1;
TaskDataPath = {};
PassDataPath = {};
TaskdataSum = {};
PassdataSum = {};

while ~strcmpi(addchar,'n')
    [fn,fp,~] = uigetfile('MeanPlotData.mat','Please select your task data save file');
    TaskDataPath{m} = fullfile(fp,fn);
    
    [fn,fp,~] = uigetfile('MeanPlotData.mat','Please select your passive data save file');
    PassDataPath{m} = fullfile(fp,fn);
    
    TaskdataAll = load(TaskDataPath{m});
    PassDataAll = load(PassDataPath{m});
    TaskdataSum{m} = TaskdataAll;
    PassdataSum{m} = PassDataAll;
    %
    CombinedMax = max([max(TaskdataAll.cLRIndexSum(:)),max(PassDataAll.cLRIndexSum(:))]);
    TaskIndexNor = TaskdataAll.cLRIndexSum./CombinedMax;
    PassIndexNor = PassDataAll.cLRIndexSum./CombinedMax;
    TaskxTimes = TaskdataAll.xTimes;
    PassxTimes = PassDataAll.xTimes;
    TaskBeforeSFrames = TaskdataAll.start_frame;
    PassBeforeSFrames = PassDataAll.start_frame;
    AlignFbeforeS = min([TaskBeforeSFrames,PassBeforeSFrames]);
    TaskmoveInds = TaskBeforeSFrames - AlignFbeforeS;
    PassmoveInds = PassBeforeSFrames - AlignFbeforeS;

    %
    TaskRealigndata = TaskIndexNor(:,(TaskmoveInds+1):end);
    PassRealigndata = PassIndexNor(:,(PassmoveInds+1):end);
    TaskAlignxtimes = TaskxTimes((TaskmoveInds+1):end);
    PassAlignxtimes = PassxTimes((TaskmoveInds+1):end);
    AlineTime = AlignFbeforeS/TaskdataAll.frame_rate;

    %
    % task mean trace
    TaskLCorrMean = mean(TaskRealigndata(TaskdataAll.LeftCorrInds,:));
    TaskRCorrMean = mean(TaskRealigndata(TaskdataAll.RightCorrInds,:));
    TaskLErroMean = mean(TaskRealigndata(TaskdataAll.LeftErrorInds,:));
    TaskRErroMean = mean(TaskRealigndata(TaskdataAll.RightErroInds,:));

    % pass mean
    PassLCorrMean = mean(PassRealigndata(PassDataAll.LeftCorrInds,:));
    PassRCorrMean = mean(PassRealigndata(PassDataAll.RightCorrInds,:));

    %
    h = figure('position',[200 200 1000 800]);
    hold on;
    h1 = plot(TaskAlignxtimes,TaskLCorrMean,'b','LineWidth',1.6);
    h2 = plot(TaskAlignxtimes,TaskRCorrMean,'r','LineWidth',1.6);
    h3 = plot(TaskAlignxtimes,TaskLErroMean,'Color',[.2 .2 .2],'LineWidth',1.6);
    h4 = plot(TaskAlignxtimes,TaskRErroMean,'Color',[.8 .8 .8],'LineWidth',1.6);
    h5 = plot(PassAlignxtimes,PassLCorrMean,'b','LineWidth',1.5,'LineStyle','--');
    h6 = plot(PassAlignxtimes,PassRCorrMean,'r','LineWidth',1.5,'LineStyle','--');
    yaxisrange = get(gca,'ylim');
    line([AlineTime AlineTime],yaxisrange,'COlor',[.6 .6 .6],'LineWidth',1.6,'LineStyle','--');
    ylim(yaxisrange);
    xlabel('Time(s)')
    ylabel('Mean index');
    set(gca,'FontSize',18);
    legend([h1,h2,h3,h4,h5,h6],{'TaskLCorr','TaskRCorr','TaskLErro','TaskRErro','PassLCorr','PassRCorr'},'FOntSize',10);
    saveas(h,sprintf('Session%d task and passive factor analysis compare plot',m));
    saveas(h,sprintf('Session%d task and passive factor analysis compare plot',m),'png');
    close(h);
    
    m = m + 1;
    addchar = input('Would you like to add another session data?\n','s');
end
m = m - 1;


%%

f = fopen('Task_pasive_factorAna_path.txt','w');
fprintf(f,'Data path for task data:\r\n');
fFormat = '%s;\r\n';
for nmnm = 1 : m
    fprintf(f,fFormat,TaskDataPath{nmnm});
end

fprintf(f,'\r\n \r\n \r\n');
fprintf(f,'Data path for passive data:\r\n');
for nmnm = 1 : m
    fprintf(f,fFormat,PassDataPath{nmnm});
end
fclose(f);
save dataSum.mat TaskdataSum PassdataSum TaskDataPath PassDataPath -v7.3