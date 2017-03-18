
clear;
clc;

addchar = 'y';
dataPath = {};
DataSum = {};
TimeScalesDataAllTask = {};
TimeScalesDataAllPass = {};
% AllFreqSigPass = [];
% AllFreqSigTask = [];
m = 1;

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('CompDataSave.mat','Please select the task and passive compare plot');
    if ~fi
        continue;
    else
        cPath = fullfile(fp,fn);
        dataPath{m} = cPath;
        xx = load(cPath);
        DataSum{m} = xx;
        FreqNum = xx.TaskFreqTypes;
        cPassData = xx.PassRespDataAllT;
        cTaskData = xx.TaskRespDataAllT;
        cRankSumP = xx.RankTestAllT;
        nTimeScales = length(cPassData);
        [TaskSigData,PassSigData] = cellfun(@(x,y,z) SigROIdataExtraction(x,y,z),cTaskData,cPassData,cRankSumP,'UniformOutput',false);
        TaskDataMatrix = cellfun(@cell2mat,TaskSigData,'UniformOutput',false);
        PassDataMatrix = cellfun(@cell2mat,PassSigData,'UniformOutput',false);
        if m == 1
            TimeScalesDataAllTask = cell(nTimeScales,1);
            TimeScalesDataAllPass = cell(nTimeScales,1);
        end
        for nTs = 1 : nTimeScales  % sorted sigROIs data according to their time scales
            TimeScalesDataAllTask{nTs} = [TimeScalesDataAllTask{nTs};TaskDataMatrix{nTs}];
            TimeScalesDataAllPass{nTs} = [TimeScalesDataAllPass{nTs};PassDataMatrix{nTs}];
        end
        
        addchar = input('Would you like to add another sesssion data?\n','s');
        m = m + 1;
    end
end

%%
DataSaveDir = uigetdir(pwd,'Please select the data save path');
cd(DataSaveDir);
save SigDataSave.mat dataPath DataSum TimeScalesDataAllTask TimeScalesDataAllPass -v7.3
fid = fopen('Compare_session_path.txt','w');
fprintf(fid,'Session path used for current summary plot:\r\n');
format = '%s;\r\n';
m = m - 1;
for nsession = 1 : m
    fprintf(fid,format,dataPath{nsession});
end
fclose(fid);
%%
% plot the significant ROIs for each time scales
nTimes = length(TimeScalesDataAllPass);
for nnhh = 1 : nTimes
    %
    cTsPassDataAll = TimeScalesDataAllPass{nnhh};
    cTsTaskDataAll = TimeScalesDataAllTask{nnhh};
    PassAboveTaskFrac = mean(cTsPassDataAll > cTsTaskDataAll);
    hf = figure('Position',[450 320 940 700]);
    scatter(cTsTaskDataAll,cTsPassDataAll,50,'ro','LineWidth',1.5);
    xscales = get(gca,'xlim');
    yscales = get(gca,'ylim');
    SelectScales = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
    line(SelectScales,SelectScales,'color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
    set(gca,'xlim',SelectScales,'ylim',SelectScales);
    [~,p] = ttest(cTsTaskDataAll,cTsPassDataAll);
    title({sprintf('Summary plots TimeScale %d',nnhh),sprintf('p = %.3e',p)});
    set(gca,'FontSize',18);
    text(SelectScales(2)*0.5,SelectScales(2)*0.8,sprintf('PassAboveTaskFrac = %.3f',PassAboveTaskFrac),'FontSize',14,'Color','b');
    xlabel('Task response');
    ylabel('Passive response');
    %
    saveas(hf,sprintf('Task and passive Tscale%d compare plot',nnhh));
    saveas(hf,sprintf('Task and passive Tscale%d compare plot',nnhh),'png');
    saveas(hf,sprintf('Task and passive Tscale%d compare plot',nnhh),'epsc');
    close(hf);
end

%%
% old methods
excludedInds = (AllFreqSigTask > 2000) | (AllFreqSigPass > 2000);
AllFreqSigTask(excludedInds) = [];
AllFreqSigPass(excludedInds) = [];
hf = figure('Position',[450 320 940 700]);
scatter(AllFreqSigTask,AllFreqSigPass,50,'ro','LineWidth',1.8);
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
SelectScales = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
line(SelectScales,SelectScales,'color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
set(gca,'xlim',SelectScales,'ylim',SelectScales);
[~,p] = ttest(AllFreqSigTask,AllFreqSigPass);
title({'Summary plots',sprintf('p = %.3e',p)});
set(gca,'FontSize',18);
xlabel('Task response');
ylabel('Passive response');
saveas(hf,'Task and passive response compare plot');
saveas(hf,'Task and passive response compare plot','png');
close(hf);
