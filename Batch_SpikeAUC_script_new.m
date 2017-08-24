% scripts for batch processing of task session data, calculate the spike
% AUC
clear
clc
ErrorPath = {};
ErrorNum = 0;
[fn,fp,fi] = uigetfile('*.txt','Please select the task session data path');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fids = fopen(fpath);
tline = fgetl(fids);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fids);
        continue;
    end
    SessPath = strrep(tline,'\NeuroM_test\AfterTimeLength-1500ms\NMDataSummry.mat;','');
    SpikeDataPath = fullfile(SessPath,'EstimateSPsave.mat');
    SavePath = fullfile(SessPath,'SpikeDataSave');
    
    try
        SpikeData = load(SpikeDataPath);
    catch ME
        ErrorNum = ErrorNum + 1;
        ErrorPath{ErrorNum} = SessPath;
        tline = fgetl(fids);
        continue;
    end
    
    Spike = SpikeData.nnspike;
    TrType = SpikeData.behavResults.Trial_Type;
    if ~isdir(SavePath)
        mkdir(SavePath);
    end
    cd(SavePath);
    try
        TimeCorseROC(Spike,TrType,SpikeData.start_frame,SpikeData.frame_rate,[],2);
        ROC_check(Spike,TrType,SpikeData.start_frame,SpikeData.frame_rate,0.5,'Stim_time_AlignSP');
    catch ME
        ErrorNum = ErrorNum + 1;
        ErrorPath{ErrorNum} = SessPath;
        fprintf('Error Message:\n%s\n',ME.message);
        tline = fgetl(fids);
        continue;
    end
    tline = fgetl(fids);
    continue;
end

%%
% scripts for batch processing of task session data, calculate the spike
% AUC
clear
clc

%parameter struc
V.Ncells = 1;
% V.T = size_data(3);
V.Npixels = 1;
P.lam = 10;

ErrorPath = {};
ErrorNum = 0;
[fn,fp,fi] = uigetfile('*.txt','Please select the task session data path');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fids = fopen(fpath);
tline = fgetl(fids);
while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change'))
        tline = fgetl(fids);
        continue;
    end
    SessPath = strrep(tline,'\NeuroM_test\AfterTimeLength-1500ms\NMDataSummry.mat;','');
    SpikeDataPath = fullfile(SessPath,'CSessionData.mat');
    SavePath = fullfile(SessPath,'SpikeDataSave');
    if ~isdir(SavePath)
        mkdir(SavePath);
    end
    cd(SavePath);
    SpikeData = load(SpikeDataPath);
    V.dt = 1/SpikeData.frame_rate;
    nnspike = DataFluo2Spike(SpikeData.data_aligned,V,P); % estimated spike
    data_aligned = SpikeData.data_aligned;
    behavResults = SpikeData.behavResults;
    start_frame = SpikeData.start_frame;
    trial_outcome = SpikeData.trial_outcome;
    frame_rate = SpikeData.frame_rate;
    save EstimateSPsave.mat data_aligned nnspike trial_outcome behavResults start_frame frame_rate -v7.3
    
     TrType = double(behavResults.Trial_Type);
    try
        TimeCorseROC(nnspike,TrType,start_frame,frame_rate,[],2);
        ROC_check(nnspike,TrType,start_frame,frame_rate,0.5,'Stim_time_AlignSP');
    catch ME
        ErrorNum = ErrorNum + 1;
        ErrorPath{ErrorNum} = SessPath;
        fprintf('Error Message:\n%s\n',ME.message);
        tline = fgetl(fids);
        continue;
    end
    tline = fgetl(fids);
    continue;
end
fclose(fids);

%% passive session spike train convertion
clear
clc

%parameter struc
V.Ncells = 1;
% V.T = size_data(3);
V.Npixels = 1;
P.lam = 10;

ErrorPath = {};
ErrorNum = 0;
[fn,fp,fi] = uigetfile('*.txt','Please select the task session data path');
if ~fi
    return;
end
fpath = fullfile(fp,fn);
fids = fopen(fpath);
tline = fgetl(fids);
while ischar(tline)
    if isempty(strfind(tline,'plot_save\NO_Correction'))
        tline = fgetl(fids);
        continue;
    end
%     SessPath = strrep(tline,'\NeuroM_test\AfterTimeLength-1500ms\NMDataSummry.mat;','');
    SpikeDataPath = fullfile(tline,'rfSelectDataSet.mat');
    SavePath = fullfile(tline,'SpikeDataSave');
    if ~isdir(SavePath)
        mkdir(SavePath);
    end
    cd(SavePath);
    SpikeData = load(SpikeDataPath);
%     V.dt = 1/SpikeData.frame_rate;
%     nnspike = DataFluo2Spike(SpikeData.SelectData,V,P); % estimated spike
    ProcessedSPData = load(fullfile(tline,'SpikeDataSave\PassEstimateSPsave.mat'));
    nnspike = ProcessedSPData.nnspike;
    data_aligned = SpikeData.SelectData;
    SelectSArray = SpikeData.SelectSArray;
%     behavResults = SpikeData.behavResults;
    start_frame = SpikeData.frame_rate;
%     trial_outcome = SpikeData.trial_outcome;
    frame_rate = SpikeData.frame_rate;
    save PassEstimateSPsave.mat data_aligned nnspike SelectSArray start_frame frame_rate -v7.3
    
%      TrType = double(behavResults.Trial_Type);
%     try
%         TimeCorseROC(nnspike,TrType,start_frame,frame_rate,[],2);
%         ROC_check(nnspike,TrType,start_frame,frame_rate,0.5,'Stim_time_AlignSP');
%     catch ME
%         ErrorNum = ErrorNum + 1;
%         ErrorPath{ErrorNum} = SessPath;
%         fprintf('Error Message:\n%s\n',ME.message);
%         tline = fgetl(fids);
%         continue;
%     end
    tline = fgetl(fids);
    continue;
end
fclose(fids);