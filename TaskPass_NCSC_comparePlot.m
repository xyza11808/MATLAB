% this scripts is used for summarize all signal correlation saving data
% together and compare the passive and task condition, loading noise
% correlation automatically and performing all kinds of comparsion
clear
clc

addchar = 'y';
m = 1;
TaskSigDataSum = {};
PassSigDataSum = {};
TaskNCDataSum = {};
PassNCDataSum = {};
TaskSigPath = {};
PassSigPath = {};
TaskSigCoefAll = [];
PassSigCoefAll = [];
TaskNCCoefAll = [];
PassNCCoefAll = [];

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('SignalCorrSave.mat','Please select task signal correlation data');
    if ~fi
        continue;
    else
        cPath = fullfile(fp,fn);
        TaskSigPath{m} = cPath;
        TaskSigDataStrc = load(cPath);
        TaskSigDataSum{m} = TaskSigDataStrc;
        cd(fp);
        
        TaskNCPath = strrep(cPath,'Popu_signalCorr_Plot\SignalCorrSave.mat',...
            'Popu_Corrcoef_save_NOS\TimeScale 0_1500ms noise correlation\ROIModified_coefSaveMean.mat');
        TaskNCDataStrc = load(TaskNCPath);
        TaskNCDataSum{m} = TaskNCDataStrc;
    end
    
    %loading passive data
     [fn,fp,fi] = uigetfile('SignalCorrSave.mat','Please select passive signal correlation data');
    if ~fi
        return;
    else
        cPassPath = fullfile(fp,fn);
        PassSigPath{m} = cPassPath;
        PassDataSigStrc = load(cPassPath);
        PassSigDataSum{m} = PassDataSigStrc;
        
        PassNCPath = strrep(cPassPath,'Popu_signalCorr_Plot\SignalCorrSave.mat',...
            'Popu_Corrcoef_save_NOS\TimeScale 0_1500ms noise correlation\ROIModified_coefSaveMean.mat');
        PassNCDataStrc = load(PassNCPath);
        PassNCDataSum{m} = PassNCDataStrc;
    end    
    
        if length(PassDataSigStrc.PairedROISigcorr) ~= length(TaskSigDataStrc.PairedROISigcorr)
            TaskSCmatrix = squareform(TaskSigDataStrc.PairedROISigcorr);
            PassSCmatrix = squareform(PassDataSigStrc.PairedROISigcorr);
            minROI = min([size(TaskSCmatrix,1),size(PassSCmatrix,1)]);
            TaskSCmatrixNew = TaskSCmatrix(1:minROI,1:minROI);
            PassSCmatrixNew = PassSCmatrix(1:minROI,1:minROI);
            RawMatrixData = ones(minROI);
            RawMatrixMask = logical(tril(RawMatrixData,-1));
            TaskSCVectorData = TaskSCmatrixNew(RawMatrixMask);
            PassSCVectorData = PassSCmatrixNew(RawMatrixMask);
        else
            TaskSCVectorData = TaskSigDataStrc.PairedROISigcorr;
            PassSCVectorData = PassDataSigStrc.PairedROISigcorr;
        end
        
        PassSigCoefAll = [PassSigCoefAll;PassSCVectorData];
        TaskSigCoefAll = [TaskSigCoefAll;TaskSCVectorData];
    
   
        if length(PassNCDataStrc.PairedROIcorr) ~= length(TaskNCDataStrc.PairedROIcorr)
            PassDataNC = squareform(PassNCDataStrc.PairedROIcorr);
            TaskDataNC = squareform(TaskNCDataStrc.PairedROIcorr);
            PassDataNCNew = PassDataNC(1:minROI,1:minROI);
            TaskDataNCNew = TaskDataNC(1:minROI,1:minROI);
            PassDataNCVect = PassDataNCNew(RawMatrixMask);
            TaskNCVectorData = TaskDataNCNew(RawMatrixMask);
        else
            PassDataNCVect = PassNCDataStrc.PairedROIcorr;
            TaskNCVectorData = TaskNCDataStrc.PairedROIcorr;
        end
        
        TaskNCCoefAll = [TaskNCCoefAll;TaskNCVectorData];
        PassNCCoefAll = [PassNCCoefAll;PassDataNCVect];
        
    m = m + 1;
    addchar = input('Would you like to add a new session data?\n','s');
end

%%
m = m - 1;
DataSavepath = uigetdir(pwd,'Please select your data saving path');
cd(DataSavepath);
%%
fid = fopen('NC_SC_summary_path.txt','w');
fprintf(fid,'Data path for task signal correlation path:\r\n');
fformat = '%s;\r\n';
for nbnb = 1 : m
    fprintf(fid,fformat,TaskSigPath{nbnb});
end
fprintf(fid,' \r\n \r\n \r\n');
fprintf(fid,'Data path for pass signal correlation path:\r\n');
for nvnv = 1 : m
    fprintf(fid,fformat,PassSigPath{nvnv});
end
fclose(fid);
save SumDataSave.mat TaskSigDataSum PassSigDataSum TaskNCDataSum PassNCDataSum TaskSigCoefAll PassSigCoefAll TaskNCCoefAll PassNCCoefAll -v7.3

%%
% plot the signal correlation for task and passive correlation value
[TaskSCCum,TaskSCx] = ecdf(TaskSigCoefAll);
[PassSCCum,PassSCx] = ecdf(PassSigCoefAll);
p = ranksum(TaskSigCoefAll,PassSigCoefAll);
h_nc = figure;
hold on;
h1 = plot(TaskSCx,TaskSCCum,'k','lineWidth',1.6);
h2 = plot(PassSCx,PassSCCum,'r','lineWidth',1.6);
title(sprintf('SC Task mean = %.3f, Pass mean = %.3f',mean(TaskSigCoefAll),mean(PassSigCoefAll)));
text(-0.7,0.6,sprintf('p = %.3e',p),'FontSize',14);
xlabel('Signal correlation value');
ylabel('Cumulative Fraction');
set(gca,'FontSize',18);
legend([h1,h2],{'Task','Passive'},'location','northwest','FontSize',14);
saveas(h_nc,'Task and passive signal correlation compared plot');
saveas(h_nc,'Task and passive signal correlation compared plot','png');
saveas(h_nc,'Task and passive signal correlation compared plot','epsc');

%%
% plot the noise correlation for task and passive correlation value
[TaskNCCum,TaskNCx] = ecdf(TaskNCCoefAll);
[PassNCCum,PassNCx] = ecdf(PassNCCoefAll);
p = ranksum(TaskNCCoefAll,PassNCCoefAll);
h_nc = figure;
hold on;
h1 = plot(TaskNCx,TaskNCCum,'k','lineWidth',1.6);
h2 = plot(PassNCx,PassNCCum,'r','lineWidth',1.6);
title(sprintf('NC Task mean = %.3f, Pass mean = %.3f',mean(TaskNCCoefAll),mean(PassNCCoefAll)));
text(-0.7,0.6,sprintf('p = %.3e',p),'FontSize',14);
xlabel('Noise correlation value');
ylabel('Cumulative Fraction');
set(gca,'FontSize',18);
legend([h1,h2],{'Task','Passive'},'location','northwest','FontSize',14);
saveas(h_nc,'Task and passive noise correlation compared plot');
saveas(h_nc,'Task and passive noise correlation compared plot','png');
saveas(h_nc,'Task and passive noise correlation compared plot','epsc');

%%
STrongSCPairInds = abs(TaskSigCoefAll) > 0.3 | abs(PassSigCoefAll) > 0.3;
TaskStrongSC = TaskSigCoefAll(STrongSCPairInds);
PassStrongSC = PassSigCoefAll(STrongSCPairInds);
p = ranksum(abs(TaskStrongSC),abs(PassStrongSC));
h_strong = figure;
hold on
h1 = cdfplot(abs(TaskStrongSC));
h2 = cdfplot(abs(PassStrongSC));
xlabel('ABS. signal correlation');
ylabel('Cumulative fraction');
title(sprintf('pvalue = %.3e',p));
set(gca,'FontSize',18);
legend([h1,h2],{'Task Strong SC','Pass Strong SC'},'FontSize',14,'Location','northwest');
grid off
saveas(h_strong,'Strong SC cumulative plots compare');
saveas(h_strong,'Strong SC cumulative plots compare','png');
saveas(h_strong,'Strong SC cumulative plots compare','epsc');
close(h_strong);
