
%this script will be used for summarizing all cortical ROC discrimination
%ability sessions together

Add_char = 'y';
m = 1;
ROCValueAll = [];
ROCshuffleAll = [];
ROCSigFrac = [];
ROCfpathAll = {};

while ~strcmpi(Add_char,'n')
    [fname,fpath,~] = uigetfile('ROC_score.mat','Please select ROC score distribution saving data for one session');
    cd(fpath);
    ROCfpathAll{m} = fullfile(fpath,fname);
    xx = load(fullfile(fpath,fname));
    RealROC = xx.ROCarea;
    RealROC(logical(xx.ROCRevert)) = 1 - RealROC(logical(xx.ROCRevert));
    ROCValueAll = [ROCValueAll,RealROC];
    ROCshuffleAll = [ROCshuffleAll,xx.ROCShufflearea];
    ROCSigFrac = [ROCSigFrac,xx.RespFraction];
    
    Add_char=input('Would you like to add more session''s data>\n','s');
    m = m + 1;
end
 m = m - 1;
saveDir = uigetdir(pwd,'Please select a path to save summarized ROC data');
cd(saveDir);
save ROCSummary.mat ROCValueAll ROCfpathAll ROCshuffleAll ROCSigFrac -v7.3
fileID = fopen('ROCsummary_datapath.txt','w+');
fprintf(fileID,'%s\n','ROC analysis data path used for summary:');
for nn = 1 : m
    fprintf(fileID,'%s\n',ROCfpathAll{m});
end
fclose(fileID);
