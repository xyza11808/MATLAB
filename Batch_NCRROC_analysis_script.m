clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[TaskPathfn,TaskPathfp,TaskPathfi] = uigetfile('*.txt','Please select the Task session path save file');
[PassPathfn,PassPathfp,PassPathfi] = uigetfile('*.txt','Please select the corresponded passive session path save file');
if ~TaskPathfi || ~PassPathfi
    return;
end
%%
TaskPathf = fullfile(TaskPathfp,TaskPathfn);
PassPathf = fullfile(PassPathfp,PassPathfn);
Taskfid =  fopen(TaskPathf);
Passfid = fopen(PassPathf);
TaskLine = fgetl(Taskfid);
PassLine = fgetl(Passfid);
SessionNum = 1;
TaskNCRData = {};
PassNCRData = {};

while ischar(TaskLine) && ischar(PassLine)
    if isempty(strfind(TaskLine,'NO_Correction\mode_f_change'))  
        TaskLine = fgetl(Taskfid);
        PassLine = fgetl(Passfid);
        continue;
    end
    
%     load(fullfile(TaskLine,'CSessionData.mat'));
%     cd(TaskLine);
%     DataAnaObj = DataAnalysisSum(data_aligned,behavResults.Stim_toneFreq,start_frame,frame_rate,1); 
%     DataAnaObj.popuZscoredCorr(1,'Mean');
%     try
%         TaskROCData = load(fullfile(TaskLine,'Stim_time_Align','ROC_Left2Right_result','ROC_score.mat'));
%     catch
%         ROC_check(smooth_data(NormalTrialInds,:,:),TrialTypes(NormalTrialInds),start_frame,frame_rate,1,'Stim_time_Align');
        TaskROCData = load(fullfile(TaskLine,'Stim_time_Align','ROC_Left2Right_result','ROC_score.mat'));
%     end
%     try
    TaskNoiseCRData = load(fullfile(TaskLine,'Popu_Corrcoef_save_NOS','TimeScale 0_1000ms noise correlation','ROIModified_coefSaveMean.mat'));
%     catch
%         load(fullfile(TaskLine,'CSessionData.mat'));
%         DataAnaObj = DataAnalysisSum(data_aligned,behavResults.Stim_toneFreq,start_frame,frame_rate,1);  
%         DataAnaObj.popuZscoredCorr(1.5,'Mean');
%         TaskNoiseCRData = load(fullfile(TaskLine,'Popu_Corrcoef_save_NOS','TimeScale 0_1500ms noise correlation','ROIModified_coefSaveMean.mat'));
%     end
%     load(fullfile(PassLine,'rfSelectDataSet.mat'));
%     cd(PassLine);
%     DataAnaObj = DataAnalysisSum(SelectData,SelectSArray,frame_rate,frame_rate,1);
%     DataAnaObj.popuZscoredCorr(1,'Mean'); 
    
    PassNoiseCRData = load(fullfile(PassLine,'Popu_Corrcoef_save_NOS','TimeScale 0_1000ms noise correlation','ROIModified_coefSaveMean.mat'));

    TaskNCRMtx = squareform(TaskNoiseCRData.PairedROIcorr);
    PassNCRMtx = squareform(PassNoiseCRData.PairedROIcorr);

    ROCABS = TaskROCData.ROCarea;
    ROCABS(TaskROCData.ROCRevert > 0) = 1 - ROCABS(TaskROCData.ROCRevert > 0);
    ROCSigInds = find(ROCABS > TaskROCData.ROCShufflearea);
    ROCSigArea = TaskROCData.ROCarea(ROCSigInds);
    LeftInds = ROCSigInds(ROCSigArea < 0.5);
    RightInds = ROCSigInds(ROCSigArea > 0.5);
    %
    TaskLeftNCRMtx = TaskNCRMtx(LeftInds,LeftInds);
    TaskLeftNCRVec = TaskLeftNCRMtx(logical(tril(ones(size(TaskLeftNCRMtx)),-1)));
    TaskRNCRMtx = TaskNCRMtx(RightInds,RightInds);
    TaskRNCRVec = TaskRNCRMtx(logical(tril(ones(size(TaskRNCRMtx)),-1)));
    TaskLRNCRMtx = TaskNCRMtx(RightInds,LeftInds);
    TaskLRNCRVec = TaskLRNCRMtx(:);

    PassLeftNCRMtx = PassNCRMtx(LeftInds,LeftInds);
    PassLeftNCRVec = PassLeftNCRMtx(logical(tril(ones(size(PassLeftNCRMtx)),-1)));
    PassRNCRMtx = PassNCRMtx(RightInds,RightInds);
    PassRNCRVec = PassRNCRMtx(logical(tril(ones(size(PassRNCRMtx)),-1)));
    PassLRNCRMtx = PassNCRMtx(RightInds,LeftInds);
    PassLRNCRVec = PassLRNCRMtx(:);
    
    TaskNCRData{SessionNum,1} = TaskLeftNCRVec;
    TaskNCRData{SessionNum,2} = TaskRNCRVec;
    TaskNCRData{SessionNum,3} = TaskLRNCRVec;
    TaskNCRData{SessionNum,4} = TaskROCData;
    
    PassNCRData{SessionNum,1} = PassLeftNCRVec;
    PassNCRData{SessionNum,2} = PassRNCRVec;
    PassNCRData{SessionNum,3} = PassLRNCRVec;
    
    TaskLine = fgetl(Taskfid);
    PassLine = fgetl(Passfid);
    SessionNum = SessionNum + 1;
end