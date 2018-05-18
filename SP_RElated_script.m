
UsedTimeWin = [0.1,0.5];
UsedFrameWin = round(UsedTimeWin*frame_rate)+start_frame;
RespData = sum(SpikeAligned(:,:,UsedFrameWin(1):UsedFrameWin(2)),3);
TrFreqs = log2(double(behavResults.Stim_toneFreq)/16000);
TrChoices = double(behavResults.Action_choice);
NMTrInds = TrChoices ~= 2;
NMRespData = RespData(NMTrInds,:);
NMChoice = TrChoices(NMTrInds);
NMTrFreq = TrFreqs(NMTrInds);
NMLRChoice = NMChoice;
NMLRChoice(NMLRChoice == 0) = -1;
%%
cROI = 101;
cROIData = NMRespData(:,cROI);
FreqTypes = unique(NMTrFreq);
nFreqs = length(FreqTypes);
FreqTypeMtrix = double(repmat(NMTrFreq(:),1,nFreqs) == repmat(FreqTypes,length(NMTrFreq),1));
FreqTypeStr = cellstr(num2str((2.^FreqTypes(:))*16,'%.1f'));
ChoiceTypeMtx = [1-NMChoice(:),NMChoice(:)];
ChoiceTypeStr = {'Left','Right'};
TrainInds = randsample(length(cROIData),round(length(cROIData)*0.8));
TrainIndex = false(length(cROIData),1);
TrainIndex(TrainInds) = true;
TestIndex = ~TrainIndex;

%%
% cROIfit = fitglm([NMTrFreq(:),NMLRChoice(:)],cROIData,'linear','Distribution','poisson');
cROIfit = stepwiseglm([FreqTypeMtrix(TrainIndex,:),ChoiceTypeMtx(TrainIndex,:)],cROIData(TrainIndex),'linear','Distribution','poisson');
FitPred = predict(cROIfit,[FreqTypeMtrix(TestIndex,:),ChoiceTypeMtx(TestIndex,:)]);

ConstantV = cROIfit.Coefficients.Estimate(1);
FreqCoef = cROIfit.Coefficients.Estimate(2);
ChoiceCoef = cROIfit.Coefficients.Estimate(3);

FreqValues = FreqCoef * NMTrFreq(:) + ConstantV;
ChoiceValue = ChoiceCoef * NMLRChoice(:) + ConstantV;
% OverAllValue = FreqCoef * NMTrFreq(:) + ChoiceCoef * NMLRChoice(:) + ConstantV;
%%

FreqAvgData = zeros(nFreqs,4);
for cFreq = 1 : nFreqs
    cFreqInds = NMTrFreq(:) == FreqTypes(cFreq);
    FreqAvgData(cFreq,:) = [mean(cROIData(cFreqInds)),mean(FreqValues(cFreqInds)),...
        mean(ChoiceValue(cFreqInds)),mean(FitData(cFreqInds))];
end

%%
hf = figure;
hold on 
hl1 = plot(FreqTypes,FreqAvgData(:,1),'k','linewidth',1.4);
hl2 = plot(FreqTypes,FreqAvgData(:,2),'r','linewidth',1.4);
hl3 = plot(FreqTypes,FreqAvgData(:,3),'c','linewidth',1.4);
hl4 = plot(FreqTypes,FreqAvgData(:,4),'b','linewidth',1.4);
legend([hl1,hl2,hl3,hl4],{'All','Sensory','Choice','Fit'},'Location','NorthEast','box','off');

