
TaskLine = 'K:\batch38\20151207\anm05\test02\im_data_reg_cpu\result_save\plot_save\Type2_f0_calculation\NO_Correction\mode_f_change';
PassLine = 'K:\batch38\20151207\anm05\test02rf\im_data_reg_cpu\result_save\plot_save\NO_Correction';
TaskDataf = fullfile(TaskLine,'CSessionData.mat');
PassDataf = fullfile(PassLine,'rfSelectDataSet.mat');
TaskDataStrc = load(TaskDataf);
PassDataStrc = load(PassDataf);
%%
TaskTrFreqs = double(TaskDataStrc.behavResults.Stim_toneFreq(:));
TaskTrTypes = double(TaskDataStrc.behavResults.Trial_Type(:));
TaskTrChoice = double(TaskDataStrc.behavResults.Action_choice(:));
NMTrInds = TaskTrChoice ~= 2;
TaskData = TaskDataStrc.smooth_data;
NMData = TaskData(NMTrInds,:,:);
NMFreqs = TaskTrFreqs(NMTrInds);
NMTypes = TaskTrTypes(NMTrInds);
NMChoice = TaskTrChoice(NMTrInds);
FrameWin = [TaskDataStrc.start_frame+1,TaskDataStrc.start_frame+TaskDataStrc.frame_rate];
TaskRespData = max(NMData(:,:,FrameWin(1):FrameWin(2)),[],3);
NorRespData = zscore(TaskRespData);
%% Stimulus information calculation
PartInds = cvpartition(NMFreqs,'KFold',10);
PredStims = zeros(size(NMFreqs));
for cv = 1 : 10
    cPartTrainInds = PartInds.training(1);
    cPartTrainData = TaskRespData(cPartTrainInds,:);
    
    
end

%%
nCorrect = mean(NMTypes(:) == NMChoice(:));
    
%%
nIters = 1000;
StimCorProb = zeros(nIters,1);
TypeCorProb = zeros(nIters,1);
parfor citer = 1 : nIters 
    TrainInds = false(length(NMFreqs),1);
    SampleInds = CusRandSample(NMFreqs,0.7);
    TrainInds(SampleInds) = true;
    TestInds = ~TrainInds;
    nbStimModel = fitcnb(NorRespData(TrainInds,:),NMFreqs(TrainInds));
    TestpredStim = predict(nbStimModel,NorRespData(TestInds,:));
    TestRealStims = NMFreqs(TestInds);
    ComData = [TestpredStim,TestRealStims(:)];
    TypeComData = [double(ComData)>16000,NMChoice(TestInds)];
    StimCorActCorProb = sum(ComData(:,1) == ComData(:,2) & TypeComData(:,1) == TypeComData(:,3)...
        )/sum(ComData(:,1) == ComData(:,2));
    TypeCorActCorProb = sum(TypeComData(:,1) == TypeComData(:,2) & TypeComData(:,1) == TypeComData(:,3)...
        )/sum(TypeComData(:,1) == TypeComData(:,2));
    StimCorProb(citer) = StimCorActCorProb;
    TypeCorProb(citer) = TypeCorActCorProb;
end

%%
FreqTypes = unique(NMFreqs);
FreqChoiceData = zeros(3,length(FreqTypes));
for cf = 1 : length(FreqTypes)
    cfreq = FreqTypes(cf);
    cFreqChoice = NMChoice(NMFreqs == cfreq);
    FreqChoiceData(:,cf) = [cfreq,sum(1-cFreqChoice),sum(cFreqChoice)];
end
