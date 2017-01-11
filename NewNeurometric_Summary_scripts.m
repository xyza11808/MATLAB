% new scripts for task neurometric curve analysis

add_char = 'y';
Datasum = {};
OctavesAll = [];
FitResultAll = [];
BehavResultAll = [];
DataPath = {};
WinFitPerf = [];
WinBehavPerf = [];
m = 1;

while ~strcmpi(add_char,'n')
    [fn,fp,fi] = uigetfile('NMDataSummry.mat','Please select your new neurometric data save file');
    if fi
        DataPath{m} = fullfile(fp,fn);
        xx = load(fullfile(fp,fn));
        Datasum{m} = xx;
        OctavesAll(m,:) = xx.Octavexfit;
        cFitData = xx.fityAll;
        cBehavData = xx.realy;
        GroupNum = length(cFitData)/2;
        cFitData(1:GroupNum) = 1 - cFitData(1:GroupNum);
        cBehavData(1:GroupNum) = 1 - cBehavData(1:GroupNum);
        
        FitResultAll(m,:) = cFitData;
        BehavResultAll(m,:) = cBehavData;
        
        WithinFreqPerfInds = xx.Octavexfit>0.00001 & xx.Octavexfit<1.9999;
        WinFitPerf(m) = mean(cFitData(WithinFreqPerfInds));
        WinBehavPerf(m) = mean(cBehavData(WithinFreqPerfInds));
        m = m + 1;
    end
    
    add_char = input('Would you like to add another session data?\n','s');
end

if fi
    m = m - 1;
end

%%
DataSvaePath = uigetdir('Please select a path to save current data');
cd(DataSvaePath);
save SummaryDataSave.mat Datasum OctavesAll FitResultAll BehavResultAll -v7.3
f = fopen('New_neurometric_save_path.txt','w+');
fprintf(f,'New neurometric analysis summary path:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,DataPath{nbnb});
end
fclose(f);

%%
% calculate the internal frequencies correct rate
fprintf('Totally %d session data being summarized for analysis.\n',m);
BehavSumMean = mean(WinBehavPerf);
RFNeuroSunMean = mean(WinFitPerf);
PairedPoints = [WinBehavPerf;WinFitPerf];
h_RFAll = figure('position',[200 200 1200 800]);
hold on;
bar(1,BehavSumMean,0.2,'k');
bar(2,RFNeuroSunMean,0.2,'b');
plot(PairedPoints,'color',[.5 .5 .5],'LineWidth',4);
xlim([0 3]);
set(gca,'xtick',[1 2],'xticklabel',{'Behav','Task Neuro'});
set(gca,'ytick',[0 0.5 1]);
ylim([0 1.1]);
title('Task Neuron compare with behavior');
set(gca,'FontSize',20);
[h,p] = ttest(WinBehavPerf,WinFitPerf);  % vartest2 for equal variance test
text(1.5,1,sprintf('p = %.4f',p),'HorizontalAlignment','center','FontSize',14);
saveas(h_RFAll,'Task and behavior compare plot2');
saveas(h_RFAll,'Task and behavior compare plot2','png');