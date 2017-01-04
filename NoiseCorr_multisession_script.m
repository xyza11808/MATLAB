% this script is used for summarize all sesssion noise correlation result
% together and draw a population map
addChar = 'y';
DataPath = {};
DataSumAll = {};
Datasum = [];
m = 1;

while ~strcmpi(addChar,'n')
    [fn,fp,fi] = uigetfile('ROIModified_coefSaveMean.mat','Please select your noise correlation data');
    if fi
        xx = load(fullfile(fp,fn));
        DataSumAll{m} = xx;
        DataPath{m} = fullfile(fp,fn);
        Datasum = [Datasum;xx.PairedROIcorr];
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
save DataSum.mat Datasum DataSumAll -v7.3

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
PassDataAll = DataSumAll;
TaskDataAll = DataSumAll;
PassPairLen = cellfun(@(x) length(x.PairedROIcorr),PassDataAll);
TaskPairLen = cellfun(@(x) length(x.PairedROIcorr),TaskDataAll);