% for calculate population prediction accuracy of trial choice
% this scripts is used for analysis of the trial by trial results by using
% error trials as real behavior choice for training
TimeScale = 1;
if length(TimeScale) == 1
    FrameScale = sort([(start_frame+1),(start_frame + round(TimeScale*frame_rate))]);
elseif length(TimeScale) == 2
    FrameScale = sort([(start_frame + round(TimeScale(1)*frame_rate)),(start_frame + round(TimeScale(2)*frame_rate))]);
end
if exist('ccUsedROIInds','var')
    RespData = mean(data_aligned(:,ccUsedROIInds,FrameScale(1):FrameScale(2)),3);
else
    RespData = mean(data_aligned(:,:,FrameScale(1):FrameScale(2)),3);
end
%%
% Trial outcomes correction
AnimalChoice = double(behavResults.Action_choice(:));
UsingTrInds = AnimalChoice ~= 2;
% UsingTrInds = trial_outcome == 1;
UsingAnmChoice = double(AnimalChoice(UsingTrInds));
UsingRespData = RespData(UsingTrInds,:);
Stimlulus = (double(behavResults.Stim_toneFreq(UsingTrInds)))';
TrialOutcomes = trial_outcome(UsingTrInds);
TrialTypes = (double(behavResults.Trial_Type(UsingTrInds)))';

StimTypes = unique(Stimlulus);
NumStims = numel(StimTypes);
% StimTypeDatas = cell(numel(StimTypes),size(UsingRespData,2));
StimRProb = zeros(NumStims,1);
StimTypeIndsAll = cell(NumStims,2);
for cs = 1 : NumStims
    csInds = Stimlulus == StimTypes(cs);
    StimTypeIndsAll{cs,1} = csInds;
    
    StimTypeIndsAll{cs,2} = UsingRespData(csInds,:);
    StimRProb(cs) = mean(UsingAnmChoice(csInds));
end
rescaleB = max(StimRProb);
rescaleA = min(StimRProb);

StimOctaves = log2(Stimlulus/min(Stimlulus)) - 1;
StimOctaveTypes = unique(StimOctaves);

%%
nRepeats = 50;
StimPerfAll = zeros(nRepeats,NumStims,NumStims);
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
    StimPerfAll(ccRe,:,:) = cRepeatPerf;
end


%%
% repeats of same partition fold, using 100 times of repeats
% if exist('UsedROIInds','var')
%     if ~isdir('./PopuChoice_Pred_PartROI/')
%         mkdir('./PopuChoice_Pred_PartROI/');
%     end
%     cd('./PopuChoice_Pred_PartROI/');
% else
%     if ~isdir('./Categ_PopuChoice_Pred/')
%         mkdir('./Categ_PopuChoice_Pred/');
%     end
%     cd('./Categ_PopuChoice_Pred/');
% end
%%
% nTrs = size(UsingRespData,1);
% nROI = size(UsingRespData,2);
% nRepeats = 50;
% foldsRange = 6*ones(nRepeats,1);
% foldLen = length(foldsRange);
% IterPredChoice = zeros(foldLen,nTrs);
% ModelPerf = zeros(foldLen,foldsRange(1));
% %%
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
% 
% end
% PredAccuMtx = repmat(UsingAnmChoice',foldLen,1) == IterPredChoice;
% if isRepeat
%     save PopuPredictionSave.mat IterPredChoice UsingAnmChoice PredAccuMtx -v7.3
% end


