% scripts for summarized plots for multisession bootstrap way analysis of
% the classification accuracy

addchar = 'y';
DataPath = {};
DataSum = {};
optoMean = [];
contMean = [];
m = 1;

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('ContModuSessionSave.mat','Please select your modulated classification result');
    if fi
        DataPath{m} = fullfile(fp,fn);
        xx = load(DataPath{m});
        DataSum{m} = xx;
        cOptoMeans = cellfun(@mean,xx.optoBootResult);
        cContMean = cellfun(@mean,xx.ContBootResult);
        optoMean = [optoMean;(1-cOptoMeans(:))];
        contMean = [contMean;(1-cContMean(:))];
        
        m = m + 1;
    end
    
    addchar = input('Would you like to add another session data?\n','s');
end
m = m - 1;

%%
dataSaveDir = uigetdir('Please select a dir to save yout summarized data');
cd(dataSaveDir);
f = fopen('Uaed_session_data_path.txt','w');
fprintf(f,'Sessions path for current summarized plot:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,DataPath{nbnb});
end
fclose(f);
save SessionDataSum.mat DataSum optoMean contMean -v7.3

%%
h = figure('position',[200 200 1000 800]);
scatter(contMean,optoMean,40,'ro','LineWidth',1.6);
xlims = get(gca,'xlim');
ylims = get(gca,'ylim');
clims = [min([xlims,ylims]),max([xlims,ylims])];
line(clims,clims,'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
set(gca,'xlim',clims,'ylim',clims);
title('Multi session compare plot');
xlabel('Control Accuracy');
ylabel('Opto Accuracy');
set(gca,'FontSize',18);
saveas(h,'Summarized compare plot');
saveas(h,'Summarized compare plot','png');
close(h);
