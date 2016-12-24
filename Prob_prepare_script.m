
CorrectTrInds = trial_outcome == 1;
TrStimFreq = double(behavResults.Stim_toneFreq(CorrectTrInds));
TrChoice = double(behavResults.Action_choice(CorrectTrInds));
CorrDataAll = smooth_data(CorrectTrInds,:,:);
UsingData = smooth_data(CorrectTrInds,:,(start_frame+1):(start_frame+round(1.5*frame_rate)));
SumDataSet = max(UsingData,[],3);
%%
[~,scoreT,~,~,explainedT,~]=pca(SumDataSet);
ExplainSum = cumsum(explainedT);
SelectInds = find(ExplainSum > 90,1,'first');
if SelectInds > 20
    fprintf('%d dimension is need for explaination ratio to above 90%%.\n',SelectInds);
    fprintf('Using only the first 20 dimensions for calculation,which explains %.2f percent of total variance.\n',ExplainSum(20));
    SelectInds = 20;
else
    fprintf('The first %d dimensions explains above 90%% of total variance.\n',SelectInds);
end
% pcaData = scoreT(:,1:SelectInds);
pcaData = scoreT(:,1);
%%
nIters = 20;
RightWradFracSum = zeros(nIters,length(unique(TrStimFreq)));
for npp = 1 : nIters
% setting training and testing set
TrainingInds = false(length(TrStimFreq),1);
TrainIndex = randsample(length(TrStimFreq),round(0.7*length(TrStimFreq)));
TrainingInds(TrainIndex) = true;
TestingInds =  ~TrainingInds;
TrainingSet = pcaData(TrainingInds,:);
TrainingStim = ([TrStimFreq(TrainingInds);TrChoice(TrainingInds)])';
TestingSet = pcaData(TestingInds,:);
TestStim = (TrChoice(TestingInds))';
TestFreq = (TrStimFreq(TestingInds))';

%
% [coeffT,scoreT,~,~,explainedT,~]=pca(TrainingSet);
% ExplainSum = cumsum(explainedT);
% SelectInds = find(ExplainSum > 90,1,'first');
 p_cgivenf = NBCGeneAndTest(TrainingSet,TrainingStim,TestingSet);
 RightWardChoice = double(squeeze(p_cgivenf(:,1,:)) < squeeze(p_cgivenf(:,2,:)));
 CorrInds = RightWardChoice(:,1) == TestStim;
 fprintf('Mean correct rate is %.4f.\n',mean(CorrInds));
 
 %
 TestFreqType = unique(TestFreq);
 FreqRightwardChoice = zeros(length(TestFreqType),1);
 HalfNumber = length(TestFreqType)/2;
 for nnxx = 1 : length(TestFreqType)
     cFreq = TestFreqType(nnxx);
     cFreqRightward = CorrInds(TestFreq == cFreq);
     FreqRightwardChoice(nnxx) = mean(cFreqRightward);
 end
 FreqRightwardChoice(1:HalfNumber) = 1 - FreqRightwardChoice(1:HalfNumber);
%  figure;
%  plot(FreqRightwardChoice,'ro');
 RightWradFracSum(npp,:) = FreqRightwardChoice;
end
%
FreqRightward = mean(RightWradFracSum);
figure;
plot(FreqRightward)


%%
nIters = 20;
RightWradFracSum = zeros(nIters,length(unique(TrStimFreq)));
for npp = 1 : nIters
% setting training and testing set
TrainingInds = false(length(TrStimFreq),1);
TrainIndex = randsample(length(TrStimFreq),round(0.8*length(TrStimFreq)));
TrainingInds(TrainIndex) = true;
TestingInds =  ~TrainingInds;
TrainingSet = pcaData(TrainingInds,:);
TrainingStim = ([TrStimFreq(TrainingInds);TrChoice(TrainingInds)])';
TestingSet = pcaData(TestingInds,:);
TestChoice = (TrChoice(TestingInds))';
TestFreq = (TrStimFreq(TestingInds))';

%
% [coeffT,scoreT,~,~,explainedT,~]=pca(TrainingSet);
% ExplainSum = cumsum(explainedT);
% SelectInds = find(ExplainSum > 90,1,'first');
 p_cgivenf = NBCGeneAndTest2(TrainingSet,TrainingStim,TestingSet,TestFreq);
 p_RightChoice = p_cgivenf(:,1) < p_cgivenf(:,2);
 
 %
 TestFreqType = unique(TestFreq);
 FreqRightwardChoice = zeros(length(TestFreqType),1);
%  HalfNumber = length(TestFreqType)/2;
 for nnxx = 1 : length(TestFreqType)
     cFreq = TestFreqType(nnxx);
     cFreqRightward = p_RightChoice(TestFreq == cFreq);
     FreqRightwardChoice(nnxx) = mean(cFreqRightward);
 end
%  FreqRightwardChoice(1:HalfNumber) = 1 - FreqRightwardChoice(1:HalfNumber);
%  figure;
%  plot(FreqRightwardChoice,'ro');
 RightWradFracSum(npp,:) = FreqRightwardChoice;
end
meanRC = mean(RightWradFracSum);
h = figure;
plot(meanRC)
save Probresult.mat RightWradFracSum -v7.3
saveas(h,'Prob Mean Plot');
saveas(h,'Prob Mean Plot','png');
