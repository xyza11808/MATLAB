% PassChoicePred_script
% Passive prediction of choice
TimeScale = 1;
start_frame = frame_rate;

if length(TimeScale) == 1
    FrameScale = sort([(start_frame+1),(start_frame + round(TimeScale*frame_rate))]);
elseif length(TimeScale) == 2
    FrameScale = sort([(start_frame + round(TimeScale(1)*frame_rate)),(start_frame + round(TimeScale(2)*frame_rate))]);
end
if exist('ccUsedROIInds','var')
    RespDataAll = mean(SelectData(:,ccUsedROIInds,FrameScale(1):FrameScale(2)),3);
else
    RespDataAll = mean(SelectData(:,:,FrameScale(1):FrameScale(2)),3);
end
if exist('PassUsedTrInds','var')
    RespData = RespDataAll(PassUsedTrInds,:);
    Stimlulus = SelectSArray(PassUsedTrInds);
    Stimlulus = Stimlulus(:);
else
    RespData = RespDataAll;
    Stimlulus = SelectSArray(:);
end

%%
% Trial outcomes correction

StimTypes = unique(Stimlulus);

MannuBound = TaskBehavBound;  % calculated from task sessions

UsingAnmChoice = double(Stimlulus > MannuBound);

UsingRespData = RespData;
TrialOutcomes = ones(numel(Stimlulus),1);


%%
nTrs = size(UsingRespData,1);
nROI = size(UsingRespData,2);
nRepeats = 50;
foldsRange = 6*ones(nRepeats,1);
foldLen = length(foldsRange);
IterPredChoice = zeros(foldLen,nTrs);
ModelPerf = zeros(foldLen,foldsRange(1));

parfor nIters = 1 : foldLen
    kfolds = foldsRange(nIters);
    cp = cvpartition(nTrs,'k',kfolds);
    PredChoice = zeros(nTrs,1);
    mdPerfTemp = zeros(kfolds,1);
    for nn = 1 : kfolds
        TrIdx = cp.training(nn);
        TeIdx = cp.test(nn);

        TrainingDataset = UsingRespData(TrIdx,:);
        Trainclasslabel = UsingAnmChoice(TrIdx);
        mdl = fitcsvm(TrainingDataset,Trainclasslabel(:));
        
        mdPerfTemp(nn) = kfoldLoss(crossval(mdl));
        
        TestData = UsingRespData(TeIdx,:);
        PredC = predict(mdl,TestData);
        
        PredChoice(TeIdx) = PredC;
    end
    ModelPerf(nIters,:) = mdPerfTemp;
    IterPredChoice(nIters,:) = PredChoice;
end
PredAccuMtx = repmat(UsingAnmChoice',foldLen,1) == IterPredChoice;

save ModelPredictionSavePass.mat IterPredChoice UsingAnmChoice PredAccuMtx -v7.3

