

TaskDataStrc = load(fullfile(Taskline,'CSessionData.mat'));
PassDataStrc = load(fullfile(Passline,'rfSelectDataSet.mat'));

%% preprocessing of task data
SessActions = TaskDataStrc.behavResults.Action_choice;
NMInds = SessActions ~= 2;
NMTrFreq = double(TaskDataStrc.behavResults.Stim_toneFreq(NMInds)); % used for classification
NMTrChoice = double(TaskDataStrc.behavResults.Action_choice(NMInds));
NMTrTypes = double(TaskDataStrc.behavResults.Trial_Type(NMInds));
cSessData = TaskDataStrc.smooth_data(NMInds,:,:);
RespWin = [0 1];
RespFrameScale = TaskDataStrc.start_frame + round(RespWin * TaskDataStrc.frame_rate);
RespDataMtx = max(cSessData(:,:,(RespFrameScale(1)+1):RespFrameScale(2)),[],3); % used for classification

%% preprocessing of passive data
PassRespMtx = max(PassDataStrc.SelectData(:,:,(RespFrameScale(1)+1):RespFrameScale(2)),[],3);
PassRespTones = PassDataStrc.SelectSArray;
FreqTypes = unique(PassRespTones);
ExcluInds = PassRespTones == FreqTypes(1) | PassRespTones == FreqTypes(end);
UsedTrInds = ~ExcluInds;
PassRespUsedData = PassRespMtx(UsedTrInds,:); % used for classification
PassUsedFreqs = PassRespTones(UsedTrInds); % used for classification

%%
TaskFullbaseInds = false(numel(NMTrFreq),1);
PassFullbaseInds = false(numel(PassUsedFreqs),1);
PassTrainInds = CusRandSample(PassUsedFreqs,round(0.7*length(PassUsedFreqs)));
TaskTrainInds = CusRandSample(NMTrFreq,round(0.7*length(NMTrFreq)));

TrainingDataSet = [RespDataMtx(TaskTrainInds,:);PassRespUsedData(PassTrainInds,:)];
TrainingTypes = [ones(numel(TaskTrainInds),1);zeros(numel(PassTrainInds),1)];
TestMd = fitcsvm(TrainingDataSet,TrainingTypes);
%%
TaskFullbaseInds(TaskTrainInds) = true;
PassFullbaseInds(PassTrainInds) = true;
TaskTestInds = ~TaskFullbaseInds;
PassTestInds = ~PassFullbaseInds;
TestDataSet = [RespDataMtx(TaskTestInds,:);PassRespUsedData(PassTestInds,:)];
TestTypes = [ones(sum(TaskTestInds),1);zeros(sum(PassTestInds),1)];
PredTypes = predict(TestMd,TestDataSet);

%%
nROIs = size(TrainingDataSet,2);
ROIErroAll = zeros(10,nROIs);
for cROI = 1 : nROIs
    SimMd = fitcsvm(TrainingDataSet(:,cROI),TrainingTypes);
    ROIErroAll(:,cROI) = kfoldLoss(crossval(SimMd),'mode','Individual');
end

