clear
clc
cd('E:\DataToGo\data_for_xu\Tuning_curve_plot');
[fn,fp,~] = uigetfile('*.txt','Please select the text file contains the path of all task sessions');
[Passfn,Passfp,~] = uigetfile('*.txt','Please select the text file contains the path of all passive sessions');
%%
clearvars -except fn fp Passfp Passfn 
m = 1;
nSession = 1;

fpath = fullfile(fp,fn);
ff = fopen(fpath);
tline = fgetl(ff);
PassFid = fopen(fullfile(Passfp,Passfn));
PassLine = fgetl(PassFid);
TaskSessDataAlls = {};
PassSessDataAlls = {};

while ischar(tline)
    if isempty(strfind(tline,'NO_Correction\mode_f_change')) %#ok<*STREMP>
        tline = fgetl(ff);
        PassLine = fgetl(PassFid);
        continue;
    end
    
    TaskDataP = fullfile(tline,'SVMAccuracy.mat');
    TaskDataStrc = load(TaskDataP);
    PassDataP = fullfile(PassLine,'NoBoundPassSVMSave.mat');
    PassDataStrc = load(PassDataP);
    
    TaskStimScore = TaskDataStrc.StimScoreAll{3};
    TaskChoiceScore = TaskDataStrc.ChoiceScoreAll{3};
    TaskCorrScore = TaskDataStrc.CorrScoreAll{3};
    TaskBehavData = TaskDataStrc.StimScoreAll{1};
    TaskStims = TaskDataStrc.StimTypes;
    TaskStimOcts = log2(TaskStims/16000);
    
    TaskSessDataAlls{m,1} = TaskStimOcts(:);
    TaskSessDataAlls{m,2} = TaskStimScore(:);
    TaskSessDataAlls{m,3} = TaskChoiceScore(:);
    TaskSessDataAlls{m,4} = TaskCorrScore(:);
    TaskSessDataAlls{m,5} = TaskBehavData(:);    
    
    PassStims = PassDataStrc.StimTypes;
    PassStimOcts = log2(PassStims/16000);
    
    disp(PassStimOcts');
    PassUsedInds = input('Please select passive stimulus used inds:\n','s');
    PassUsedIndex = str2num(PassUsedInds);
    if isempty(PassUsedIndex)
        tline = fgetl(ff);
        PassLine = fgetl(PassFid);
        m = m + 1;
        continue;
    end
    PassUsedOcts = PassStimOcts(PassUsedIndex);
    PassUsedData = PassDataStrc.StimNorScore(PassUsedIndex);
    PassSessDataAlls{m,1} = PassUsedOcts;
    PassSessDataAlls{m,2} = PassUsedData;
    
    tline = fgetl(ff);
    PassLine = fgetl(PassFid);
    m = m + 1;
end

%%

TaskOctavesAll = cell2mat(TaskSessDataAlls(:,1));
StimTaskDataAll = cell2mat(TaskSessDataAlls(:,2));
ChoiceTaskDataAll = cell2mat(TaskSessDataAlls(:,3));
CorrTaskDataAll = cell2mat(TaskSessDataAlls(:,4));
BehavRProbAll = cell2mat(TaskSessDataAlls(:,5));

PassOctavesAll = cell2mat(PassSessDataAlls(:,1));
PassDataAll = cell2mat(PassSessDataAlls(:,2));

TaskStimFitR = FitPsycheCurveWH_nx(TaskOctavesAll,StimTaskDataAll);
TaskChoiceFitR = FitPsycheCurveWH_nx(TaskOctavesAll,ChoiceTaskDataAll);
TaskCorrFitR = FitPsycheCurveWH_nx(TaskOctavesAll,CorrTaskDataAll);

PassStimFitR = FitPsycheCurveWH_nx(PassOctavesAll,PassDataAll);

BehavFitProb = FitPsycheCurveWH_nx(TaskOctavesAll,BehavRProbAll);

cd('E:\DataToGo\data_for_xu\SVMNeu_Summary\SVMAccuracy');
save SVMDataSummary.mat PassSessDataAlls TaskSessDataAlls -v7.3

%%
figure;
hold on
plot(PassStimFitR.curve(:,1),PassStimFitR.curve(:,2),'b')
plot(PassOctavesAll,PassDataAll,'co')
plot(PassStimFitR.curve(:,1),PassStimFitR.curve(:,2),'b')
plot(TaskCorrFitR.curve(:,1),TaskCorrFitR.curve(:,2),'k','linewidth',1.6)
plot(BehavFitProb.curve(:,1),BehavFitProb.curve(:,2),'r','linewidth',1.6)
