% this script is used for analysis of multisession comparation of task auc
% and passive auc result together and do a t-test for all session data
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
    AllSessionAUC = [];
else
   m = length(DataSum) + 1;
end

while ~strcmpi(add_char,'n')
    [fn,fp,fi] = uigetfile('ROIrocsave.mat','Please select your task and passive AUC compare data');
    if fi
        datapath{m} = fullfile(fp,fn);
        xx = load(fullfile(fp,fn));
        DataSum{m} = xx;
        TaskAUC = xx.ROCdata2afc;
        PassAUC = xx.ROCdataRF;
        DataTogether = [TaskAUC,PassAUC];
        AllSessionAUC = [AllSessionAUC;DataTogether];
    end
    add_char = input('Do you want to add with more session data?\n','s');
    m = m + 1;
end
m = m - 1;

%%
fp = uigetdir(pwd,'Please select a session to save your current data');
cd(fp);
f = fopen('Session_resp_path.txt','w');
fprintf(f,'Sessions path for response summary plot:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,datapath{nbnb});
end
fclose(f);
save SessionDataSum.mat DataSum AllSessionAUC -v7.3

%%
h = figure('position',[200 200 1000 800]);
scatter(AllSessionAUC(:,1),AllSessionAUC(:,2),40,'ko');
line([0 1],[0.5 0.5],'color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
line([0.5 0.5],[0 1],'color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
line([0 1],[0 1],'color',[.8 .8 .8],'LineWidth',1.8,'LineStyle','--');
xlim([0 1]);ylim([0 1]);
xlabel('Task data auc');
ylabel('Passive data auc');
[~,p] = ttest(AllSessionAUC(:,1),AllSessionAUC(:,2));
title({sprintf('P = %.2e',p),sprintf('n = %d',size(AllSessionAUC,1))});
set(gca,'FontSize',20);
saveas(h,'Task Passive AUC compare plot');
saveas(h,'Task Passive AUC compare plot','png');
close(h);
