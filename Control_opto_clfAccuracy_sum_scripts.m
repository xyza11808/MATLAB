% scripts for multi-session data summarization of opto and control
% classification accuracy compare plots

addchar = 'y';
DataPath = {};
DataPathOpto = {};
dataSumControl = {};
dataSumOpto = {};
AccuracyDataControl = [];
AccuracyDataOpto = [];
m = 1;

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('TbyTClassNoSUF.mat','Please select control trials decoding accuracy save file');
    if fi
        DataPath{m} = fullfile(fp,fn);
        xx = load(DataPath{m});
        dataSumControl{m} = xx;
        AccuracyDataControl = [AccuracyDataControl,mean(xx.TestLoss)];
        
        OptoPath = strrep(DataPath{m},'Control_trials','Opto_trials');
        yy = load(OptoPath);
        DataPathOpto{m} = OptoPath;
        dataSumOpto{m} = yy;
        AccuracyDataOpto = [AccuracyDataOpto,mean(yy.TestLoss)];
        
        m = m + 1;
    end
    
    addchar = input('Would you like to add another session data?\n','s');
end

%%
m = m - 1;
SavePath = uigetdir('Please select a data path for current data save');
f = fopen('Opto_control_clfaccuracy_path.txt','w');
fprintf(f,'Data path for control trials data:\r\n');
fFormat = '%s;\r\n';
for nmnm = 1 : m
    fprintf(f,fFormat,DataPath{nmnm});
end

fprintf(f,'\r\n \r\n \r\n');
fprintf(f,'Data path for opto trials data:\r\n');
for nmnm = 1 : m
    fprintf(f,fFormat,DataPathOpto{nmnm});
end
fclose(f);
save DataSummary.mat dataSumControl AccuracyDataControl dataSumOpto AccuracyDataOpto -v7.3

%%

hplot = figure;
scatter(AccuracyDataControl,AccuracyDataOpto,40,'ro','LineWidth',1.8);
xlims = get(gca,'xlim');
ylims = get(gca,'ylim');
clims = [min([xlims(1),ylims(1)]),max([xlims(2),ylims(2)])];
line(clims,clims,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
set(gca,'xlim',clims,'ylim',clims);
[~,p] = ttest(AccuracyDataControl,AccuracyDataOpto);
title(sprintf('ttest pvalue = %.4e',p));
xlabel('Control trials decoding accuracy');
ylabel('Opto trials decoding accuracy');
saveas(hplot,'Summarized control and opto trials compare plot');
saveas(hplot,'Summarized control and opto trials compare plot','png');
close(hplot);