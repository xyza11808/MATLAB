
%this script will be used for summarizing all cortical ROC discrimination
%ability sessions together

Add_char = 'y';
m = 1;
ROCValueAll = [];
ROCshuffleAll = [];
ROCSigFrac = [];
ROIRealIndex = [];
ROCfpathAll = {};

while ~strcmpi(Add_char,'n')
    [fname,fpath,~] = uigetfile('ROC_score.mat','Please select ROC score distribution saving data for one session');
    cd(fpath);
    try
        ROCfpathAll{m} = fullfile(fpath,fname);
        xx = load(fullfile(fpath,fname));
        RealROC = xx.ROCarea;
        RealROC(logical(xx.ROCRevert)) = 1 - RealROC(logical(xx.ROCRevert));
        ROCValueAll = [ROCValueAll,RealROC];
        ROCshuffleAll = [ROCshuffleAll,xx.ROCShufflearea];
        ROCSigFrac = [ROCSigFrac,xx.RespFraction];
        ROIRealIndex = [ROIRealIndex,xx.ROCarea];
    catch
        fprintf('Something wrong about current data storage, can''t add to summarized data.\n');
    end
    
    Add_char=input('Would you like to add more session''s data>\n','s');
    m = m + 1;
end
 m = m - 1;
saveDir = uigetdir(pwd,'Please select a path to save summarized ROC data');
cd(saveDir);
save ROCSummary.mat ROCValueAll ROCfpathAll ROCshuffleAll ROCSigFrac ROIRealIndex -v7.3
fileID = fopen('ROCsummary_datapath.txt','w+');
fprintf(fileID,'%s\n','ROC analysis data path used for summary:');
for nn = 1 : m
    fprintf(fileID,'%s\n',ROCfpathAll{nn});
end
fclose(fileID);

%%
h_SIgF = figure('position',[680 200 950 900],'PaperPositionMode','auto');
hold on;
bar(1,mean(ROCSigFrac),0.2,'c');
alpha(0.4);
errorbar(1,mean(ROCSigFrac),std(ROCSigFrac),'ro','LineWidth',1.5);
plot(ones(length(ROCSigFrac),1),ROCSigFrac,'o','color',[.8 .8 .8]);
xlabel('');
ylabel('Session above fraction')
title('fraction of cells above significant level');
set(gca,'fontSize',20);
text(1.05,mean(ROCSigFrac)+0.02,sprintf(['Sig.Frac. = %.2f',char(177),'%.2f'],mean(ROCSigFrac),std(ROCSigFrac)),'color',[.8 .8 .8],'FontSize',20);

saveas(h_SIgF,'Population SigAUC distribution','png');
saveas(h_SIgF,'Population SigAUC distribution','fig');
saveas(h_SIgF,'Population SigAUC distribution','epsc');
close(h_SIgF);

%%
ROIindexV = (ROIRealIndex - 0.5) * 2;
[Count,Center] = hist(ROIindexV,20);
SigAUCValue = ROCValueAll > ROCshuffleAll;
[CountSig,CenterSig] = hist(ROIindexV(SigAUCValue),20);

h_hist = figure('position',[430 300 1100 800],'PaperPositionMode','auto');
hold on
bar(Center,(Count/numel(ROIindexV)),'r');
alpha(0.3);
bar(CenterSig,(CountSig/numel(ROIindexV)),'r');
xlabel('Index value');
ylabel('Cell Fraction');
title('Population Selection index');
set(gca,'FontSize',20);
saveas(h_hist,'Population selection index plot','png');
saveas(h_hist,'Population selection index plot','fig');
saveas(h_hist,'Population selection index plot','epsc');
