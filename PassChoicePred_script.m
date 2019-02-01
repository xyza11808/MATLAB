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

NumStims = numel(StimTypes);
StimTypeIndsAll = cell(NumStims,2);
for cStim = 1 : NumStims
    csInds = Stimlulus == StimTypes(cStim);
    StimTypeIndsAll{cStim,1} = csInds;
    StimTypeIndsAll{cStim,2} = UsingRespData(csInds,:);
end

%%
if isPairedStimPred
    nRepeats = 50;
    PassStimPerfAll = zeros(nRepeats,NumStims,NumStims);
    parfor ccRe = 1 : nRepeats
        cRepeatPerf = zeros(NumStims,NumStims);
        for cBaseStim = 1 : NumStims
            for cCompStim = (cBaseStim+1) : NumStims
                %
                cBaseStimData = StimTypeIndsAll{cBaseStim,2};
                cCompStimData = StimTypeIndsAll{cCompStim,2};
                cBaseStimTrNum = size(cBaseStimData,1);
                cCompStimTrNum = size(cCompStimData,1);
                if abs(cBaseStimTrNum - cCompStimTrNum) > 10
                    % unbiased stim trial number for current pairs
                    UsedTrNum = min(cBaseStimTrNum, cCompStimTrNum);
                    if cBaseStimTrNum > cCompStimTrNum
                        RepeatPerfAll = zeros(nRepeats,1);
                        for cRepeat = 1 : nRepeats
                            UsedBaseStimInds = randsample(cBaseStimTrNum, cCompStimTrNum);
                            UsedBaseData = cBaseStimData(UsedBaseStimInds,:);
                            UsedCompData = cCompStimData;
                            TypeLabels = [zeros(cCompStimTrNum,1);ones(cCompStimTrNum,1)];
                            ItMdl = fitcsvm([UsedBaseData;UsedCompData],TypeLabels);
                            MdPerf = kfoldLoss(crossval(ItMdl));
                            RepeatPerfAll(cRepeat) = MdPerf;
                        end
                    else
                        RepeatPerfAll = zeros(nRepeats,1);
                        for cRepeat = 1 : nRepeats
                            UsedBaseStimInds = randsample(cCompStimTrNum, cBaseStimTrNum);
                            UsedBaseData = cBaseStimData;
                            UsedCompData = cCompStimData(UsedBaseStimInds,:);
                            TypeLabels = [zeros(cBaseStimTrNum,1);ones(cBaseStimTrNum,1)];
                            ItMdl = fitcsvm([UsedBaseData;UsedCompData],TypeLabels);
                            MdPerf = kfoldLoss(crossval(ItMdl));
                            RepeatPerfAll(cRepeat) = MdPerf;
                        end
                    end
                else
                    TypeLabels = [zeros(cBaseStimTrNum,1);ones(cCompStimTrNum,1)];
                    ItMdl = fitcsvm([cBaseStimData;cCompStimData],TypeLabels);
                    RepeatPerfAll = kfoldLoss(crossval(ItMdl));
                end

                cRepeatPerf(cBaseStim,cCompStim) = mean(RepeatPerfAll);

                %
            end
        end
        PassStimPerfAll(ccRe,:,:) = cRepeatPerf;
    end
else
   % pesudo choice classification
   TrainTestRatio = 0.8;
    NumTrs = numel(UsingAnmChoice);
    if isRepeat
        nRepeats = 100;
    else
        nRepeats = 500;
    end
    PassRepeatPredAccu = zeros(nRepeats,2);
    TrBaseIndex = false(NumTrs,1);
    parfor cRepeat = 1 : nRepeats
        cTrainInds = randsample(NumTrs,round(NumTrs*TrainTestRatio));
        TrainIndex = TrBaseIndex;
        TrainIndex(cTrainInds) = true;
        
        TrainChoice = UsingAnmChoice(TrainIndex);
        TrainData = UsingRespData(TrainIndex,:);
        TestChoice = UsingAnmChoice(~TrainIndex);
        TestData = UsingRespData(~TrainIndex,:);
        
        mdl = fitcsvm(TrainData,TrainChoice);
        mdLoss = kfoldLoss(crossval(mdl));
        
        TestDataPrediction = predict(mdl,TestData);
        TestDataAccuracy = mean(TestDataPrediction == TestChoice);
        PassRepeatPredAccu(cRepeat,:) = [mdLoss,TestDataAccuracy];
    end
    
end

%%
% nTrs = size(UsingRespData,1);
% nROI = size(UsingRespData,2);
% nRepeats = 50;
% foldsRange = 6*ones(nRepeats,1);
% foldLen = length(foldsRange);
% IterPredChoice = zeros(foldLen,nTrs);
% ModelPerf = zeros(foldLen,foldsRange(1));
% 
% parfor nIters = 1 : foldLen
%     kfolds = foldsRange(nIters);
%     cp = cvpartition(nTrs,'k',kfolds);
%     PredChoice = zeros(nTrs,1);
%     mdPerfTemp = zeros(kfolds,1);
%     for nn = 1 : kfolds
%         TrIdx = cp.training(nn);
%         TeIdx = cp.test(nn);
% 
%         TrainingDataset = UsingRespData(TrIdx,:);
%         Trainclasslabel = UsingAnmChoice(TrIdx);
%         mdl = fitcsvm(TrainingDataset,Trainclasslabel(:));
%         
%         mdPerfTemp(nn) = kfoldLoss(crossval(mdl));
%         
%         TestData = UsingRespData(TeIdx,:);
%         PredC = predict(mdl,TestData);
%         
%         PredChoice(TeIdx) = PredC;
%     end
%     ModelPerf(nIters,:) = mdPerfTemp;
%     IterPredChoice(nIters,:) = PredChoice;
% end
% PredAccuMtx = repmat(UsingAnmChoice',foldLen,1) == IterPredChoice;
% 
% save ModelPredictionSavePass.mat IterPredChoice UsingAnmChoice PredAccuMtx -v7.3

