function CallFunCompPlot(TaskData,TaskStim,TaskFrate,TaskAlignF,TaskTimescale)
% this function is a call function for task and rf data comparation, rf
% data will be loaded from outside save

[fn,fp,fi] = uigetfile('rfSelectDataSet.mat','Please select your rf saved data');
if fi
    xxx = load(fullfile(fp,fn));
    rfData = xxx.SelectData;
    rfStim = xxx.SelectSArray;
    rfFrate = xxx.frame_rate;
else
    fprintf('Error file selection, quit analysis.\n');
    return;
end
if rfFrate ~= TaskFrate
    FRate = [TaskFrate,rfFrate];
else
    FRate = TaskFrate;
end
AlignFAll = [TaskAlignF,rfFrate]; % default alignf for rf session is 1s after trial start, using rfFrate for alignment frame
rfTimeScale = 1;
if length(TaskTimescale) > 1
    TimeScaleAll = {TaskTimescale,rfTimeScale};
elseif length(TaskTimescale) == 1
    TimeScaleAll = [TaskTimescale,rfTimeScale];
end
RF2afcComparePlot(TaskData,TaskStim,rfData,rfStim,FRate,AlignFAll,TimeScaleAll);
