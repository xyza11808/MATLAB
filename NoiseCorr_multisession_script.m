% this script is used for summarize all sesssion noise correlation result
% together and draw a population map
addChar = 'y';
DataPath = {};
DataSumAll = {};
Datasum = [];
DataSigSum = [];
SignalCorrDataSumAll = {};
SignalCorrDataSum = [];
SignalCorrDataSigSum = [];
m = 1;

while ~strcmpi(addChar,'n')
    [fn,fp,fi] = uigetfile('ROIModified_coefSaveMean.mat','Please select your noise correlation data');
    if fi
        xx = load(fullfile(fp,fn));
        DataSumAll{m} = xx;
        DataPath{m} = fullfile(fp,fn);
        Datasum = [Datasum;xx.PairedROIcorr];
        DataSigSum = [DataSigSum;xx.PairedNCpvalue];
        
        SignalCorrFPath = strrep(fullfile(fp,fn),'Popu_Corrcoef_save_NOS\ROIModified_coefSaveMean.mat','Popu_signalCorr_Plot\SignalCorrSave.mat');
        yy = load(SignalCorrFPath);
        SignalCorrDataSumAll{m} = yy;
        SignalCorrDataSum = [SignalCorrDataSum;yy.PairedROISigcorr];
        SignalCorrDataSigSum = [SignalCorrDataSigSum;yy.PairedSCpvalue];
    end
    
    addChar = input('Would you like to add another session data?\n','s');
    m = m + 1;
end

%%
m = m - 1;

dataSaveFolder = uigetdir('Please select your data save path');
cd(dataSaveFolder);
f = fopen('Noise_correlation_Multisession_path_new.txt','w+');
fprintf(f,'Noise Correlation path for multisession response summrization:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,DataPath{nbnb});
end
fclose(f);
save DataSum.mat Datasum DataSumAll DataSigSum SignalCorrDataSumAll SignalCorrDataSum SignalCorrDataSigSum -v7.3

%%
h = figure('position',[300 100 1000 800]);
hHist = histogram(Datasum,50);
hHist.FaceColor = [.5 .5 .5];
hHist.EdgeColor = 'k';
title(sprintf('Mean value = %.4f, Median = %.4f',mean(Datasum),median(Datasum)));
xlabel('Paired Noise Correlation');
ylabel('Pair Counts');
set(gca,'FontSize',18);
saveas(h,'Summrized population noise correlation distribution')
saveas(h,'Summrized population noise correlation distribution','png');
close(h);

%%
h = figure('position',[300 100 1000 800]);
hHist = histogram(SignalCorrDataSum,50);
hHist.FaceColor = [.5 .5 .5];
hHist.EdgeColor = 'k';
title(sprintf('Mean value = %.4f, Median = %.4f',mean(SignalCorrDataSum),median(SignalCorrDataSum)));
xlabel('Paired Noise Correlation');
ylabel('Pair Counts');
set(gca,'FontSize',18);
saveas(h,'Summrized population signal correlation distribution')
saveas(h,'Summrized population signal correlation distribution','png');
close(h);

%%


%%
[fn,fp,~] = uigetfile('DataSum.mat','Please select your task noise correlation dataset');
TaskNCpath = fullfile(fp,fn);
Taskdata = load(TaskNCpath);

[fn,fp,~] = uigetfile('DataSum.mat','Please select your Passive noise correlation dataset');
PassNCpath = fullfile(fp,fn);
Passdata = load(TaskNCpath);

%%
PassDataAll = Passdata.Datasum;
PassSCDataAll = Passdata.SignalCorrDataSum;
TaskDataAll = Taskdata.Datasum;
TaskSCDataAll = Taskdata.SignalCorrDataSum;

signalCorrPositiveInds = PassSCDataAll > 0 & TaskSCDataAll > 0;
signalCorrNegtiveInds = PassSCDataAll < 0 & TaskSCDataAll < 0;

% h_compPlot = figure('position',[100 100 1000 700]);
% subplot(121);
[~,CoefValue,Rsqur,~,hf,~] = lmFunCalPlot(TaskDataAll(signalCorrPositiveInds),PassDataAll(signalCorrPositiveInds));
[Coef,p_value] = corrcoef(TaskDataAll(signalCorrPositiveInds),PassDataAll(signalCorrPositiveInds));
title({sprintf('Positive signal correlation R-Squr = %.3f, Slope = %.3f',Rsqur,CoefValue(2)),sprintf('Corrcoef = %.3f, p = %.3f',Coef(1,2),p_value(1,2))});
xlabel('Task noise correlation');
ylabel('Passive noise correlation');
saveas(hf,'Positive signal correlation noise correlation compare plot');
saveas(hf,'Positive signal correlation noise correlation compare plot','png');
close(hf);

% subplot(122);
[~,CoefValue,Rsqur,~,h_compPlot,~] = lmFunCalPlot(TaskDataAll(signalCorrNegtiveInds),PassDataAll(signalCorrNegtiveInds));
[Coef,p_value] = corrcoef(TaskDataAll(signalCorrNegtiveInds),PassDataAll(signalCorrNegtiveInds));
title({sprintf('Negtive signal correlation R-Squr = %.3f, Slope = %.3f',Rsqur,CoefValue(2)),sprintf('Corrcoef = %.3f, p = %.3f',Coef(1,2),p_value(1,2))});
xlabel('Task noise correlation');
ylabel('Passive noise correlation');
saveas(h_compPlot,'Negtive Signal Correlation noise correlation compare plot');
saveas(h_compPlot,'Negtive Signal Correlation noise correlation compare plot','png');
close(h_compPlot);


%%
% ##########################################################
% section for compare plots of passive and task noise correlation 
TaskSigCorrCellData = SignalCorrDataSumAll;
TaskSigCorrDataAll = DataSumAll;

%%
PassSigCorrCellData = SignalCorrDataSumAll;
PassSigCorrDataAll = DataSumAll;

%%
TaskNCvalue = cellfun(@(x) mean(x.PairedROIcorr),TaskSigCorrDataAll);
PassNCvalue = cellfun(@(x) mean(x.PairedROIcorr),PassSigCorrDataAll);

%%
h_comp = figure;
scatter(TaskNCvalue,PassNCvalue,50,'ro');
xvalues = get(gca,'xlim');
line(xvalues,xvalues,'color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
xlim(xvalues);
ylim(xvalues);
xlabel('Task Noise correlation');
ylabel('Passive Noise correlation');
[h,p] = ttest(TaskNCvalue,PassNCvalue);
title(sprintf('pvalue = %.2e',p));
set(gca,'FontSize',18);
saveas(h_comp,'Compared Plot for task and passive noise correlation');
saveas(h_comp,'Compared Plot for task and passive noise correlation','png');
close(h_comp);
save PassTaskCompSave.mat TaskNCvalue PassNCvalue TaskSigCorrDataAll PassSigCorrDataAll -v7.3

%%
% example session noise correlation coefficient value compared with paired
% distance, for session b27a03_2016042602
hf = figure;
hold on
scatter(ROIRealDis',NCDataAll,10,'MarkerEdgeColor','none','MarkerFaceColor',[.7 .7 .7]);
errorbar(BinCenter(1:7),NewNCBinMeanSem(:,1),NewNCBinMeanSem(:,2),'k','linewidth',1.4);
[tbl,fitdata] = lmFunCalPlot(ROIRealDis',NCDataAll,0);
plot(fitdata{1},fitdata{2},'r','linewidth',1.4,'LineStyle','--');
xlabel('Distance (um)');
ylabel('Correlation coefficient');
set(gca,'FontSize',16);
saveas(hf,'NC coefficient vs paired distance correlation plot');
saveas(hf,'NC coefficient vs paired distance correlation plot','png');
saveas(hf,'NC coefficient vs paired distance correlation plot','pdf');