% this script is used for analysis of passive data noise correlation
% analysis

conti_char = 'y';
Datapath = {};
m = 1;
while ~strcmpi(conti_char,'n')
    [fn,fp,fi] = uigetfile('rfSelectDataSet.mat','Please select your passive analysis saved data for noise correlation analysis.');
    if fi
        cd(fp);
        Datapath{m} = fullfile(fp,fn);
        xx = load(fn);
        SmoothData = xx.SelectData;
        SoundVector = xx.SelectSArray;
        Frate = xx.frame_rate;
        DataObj = DataAnalysisSum(SmoothData,SoundVector,Frate,Frate);
        DataObj.PairedAUCCal(1.5);
        DataObj.popuZscoredCorr(1.5,'Mean');
    end
    conti_char = input('Do you want to analysis another sesssion data?\n','s');
    m = m + 1;
end

%%
m = m - 1;

dataSaveFolder = uigetdir('Please select your data save path');
cd(dataSaveFolder);
f = fopen('Passive_noisecorrelation_path.txt','w+');
fprintf(f,'Noise Correlation path for passive response analysis:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,Datapath{nbnb});
end
fclose(f);