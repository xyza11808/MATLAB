% for task session analysis
TaskPathfileFullpath = 'E:\DataToGo\data_for_xu\Summarized_pairedAUC_analysis\Paired_AUCanalysis_path.txt';
fid = fopen(TaskPathfileFullpath);
kk = 1;
ErrorPath = {};
tline = fgetl(fid);
while ischar(tline)
    cline = tline;
    if ~isempty(strfind(cline,'DiffMeanAUC.mat'))
        PairedAUCpath = strrep(cline,'DisTance_based_AUC\DiffMeanAUC.mat;','StimPairedAUC.mat');
        cSessionPath = strrep(cline,'\DisTance_based_AUC\DiffMeanAUC.mat;','\');
        try
            xx = load(PairedAUCpath);
            cd(cSessionPath);
            GroupWiseAUCCal(xx.nROIpairedAUC,xx.nROIpairedAUCIsRev,xx.ROIwisedAUC,xx.StimulusTypes);
        catch
            ErrorPath{kk} = PairedAUCpath;
            kk = kk + 1;
        end
    end
    tline = fgetl(fid);
end
fclose(fid);
%%
% for task session analysis
ProcessedDataPath = {};
TaskPathfileFullpath = 'E:\DataToGo\data_for_xu\Task_NoiseCorrelation_summary\Noise_correlation_Multisession_path_new.txt';
fid = fopen(TaskPathfileFullpath);
cline = fgetl(fid);
kd = 1;
SumDataPathFull = {};
while ischar(cline)
    if ~isempty(strfind(cline,'ROIModified_coefSaveMean'))
        SumDataPathFull{kd} = strrep(cline,'Popu_Corrcoef_save\ROIModified_coefSaveMean.mat;','ROI_pairedWiseAUC_plot\DisTance_based_AUC\DiffMeanAUC.mat');
        kd = kd + 1;
    end
    cline = fgetl(fid);
end
kd = kd - 1;
savePath = uigetdir('Plese select a data path for file path save');
cd(savePath);
f = fopen('Paired_AUCanalysis_path.txt','w');
fprintf(f,'Paired AUC analysis path for Task response analysis:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : kd
    fprintf(f,FormatStr,SumDataPathFull{nbnb});
end
fclose(f);

%%
% for passive session analysis
PassPathfileFullpath = 'E:\DataToGo\data_for_xu\Summarized_pairedAUC_analysis_Pass\note2\Paired_AUCanalysis_path.txt';
fid = fopen(PassPathfileFullpath);
kk = 1;
ErrorPath = {};
tline = fgetl(fid);
while ischar(tline)
    cline = tline;
    if ~isempty(strfind(cline,'DiffMeanAUC.mat'))
        PairedAUCpath = strrep(cline,'DisTance_based_AUC\DiffMeanAUC.mat;','StimPairedAUC.mat');
        cSessionPath = strrep(cline,'\DisTance_based_AUC\DiffMeanAUC.mat;','\');
        try
            xx = load(PairedAUCpath);
            cd(cSessionPath);
            GroupWiseAUCCal(xx.nROIpairedAUC,xx.nROIpairedAUCIsRev,xx.ROIwisedAUC,xx.StimulusTypes);
        catch
            ErrorPath{kk} = PairedAUCpath;
            kk = kk + 1;
        end
    end
    tline = fgetl(fid);
end
fclose(fid);

%%
% for passive session analysis
ProcessedDataPath = {};
PassPathfileFullpath = 'E:\DataToGo\data_for_xu\passive_noiseCorf_summry\Noise_correlation_Multisession_path_new.txt';
fid = fopen(PassPathfileFullpath);
cline = fgetl(fid);
kd = 1;
SumDataPathFull = {};
while ischar(cline)
    if ~isempty(strfind(cline,'ROIModified_coefSaveMean'))
        SumDataPathFull{kd} = strrep(cline,'Popu_Corrcoef_save\ROIModified_coefSaveMean.mat;','ROI_pairedWiseAUC_plot\DisTance_based_AUC\DiffMeanAUC.mat');
        kd = kd + 1;
    end
    cline = fgetl(fid);
end
kd = kd - 1;
savePath = uigetdir('Plese select a data path for file path save');
cd(savePath);
f = fopen('Paired_AUCanalysis_path.txt','w');
fprintf(f,'Paired AUC analysis path for Task response analysis:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : kd
    fprintf(f,FormatStr,SumDataPathFull{nbnb});
end
fclose(f);

