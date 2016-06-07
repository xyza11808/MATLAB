
%%
%logistic regression result
 [B,dev,stats] = mnrfit(T8TData,TrialType'+1);
 MatrixWeight = B(2:end);
 ROIbias = (stats.beta(2:end))';
 MatrixScore = T8TData * MatrixWeight + B(1);
 pValue = 1./(1+exp(-1.*MatrixScore));
 
 %%
%  TrialFreq = CorrTrialStim;
 UniqueFreqTypes = unique(TrialFreq);
 FreqScores = zeros(length(UniqueFreqTypes),2);
 for nfreq = 1 : length(UniqueFreqTypes)
     cFreq = UniqueFreqTypes(nfreq);
     cFreqTrials =  TrialFreq == TrialFreq;
     cFreqScore = pValue(cFreqTrials);
     FreqScores(nfreq,:) = [mean(cFreqScore) (std(cFreqScore)/sqrt(length(cFreqScore)))];
 end
 
 %%
 % plot regression result
 UniqueFreqTypes = double(UniqueFreqTypes);
 Octa = log2(UniqueFreqTypes/UniqueFreqTypes(1));

%%
pValueThres = pValue > 0.5;
ErroeRate = abs(double(pValueThres) - double(TrialType)');

%%
[pihat,dlow,dhi] = mnrval(B,T8TData,stats);
PredTrialType = pihat(:,2) > 0.5;
ErroeRate = abs(double(PredTrialType) - double(TrialType)');

 %%
%  TrialFreq = CorrTrialStim;
 UniqueFreqTypes = unique(TrialFreq);
 FreqScores = zeros(length(UniqueFreqTypes),2);
 FreqCI = zeros(length(UniqueFreqTypes),2);
 for nfreq = 1 : length(UniqueFreqTypes)
     cFreq = UniqueFreqTypes(nfreq);
     cFreqTrials =  TrialFreq == cFreq;
     cFreqScore = PredTrialType(cFreqTrials);
     FreqScores(nfreq,:) = [mean(cFreqScore) (std(cFreqScore)/sqrt(length(cFreqScore)))];
     FreqCI(nfreq,1) = mean(dlow(cFreqTrials,1));
     FreqCI(nfreq,2) = mean(dhi(cFreqTrials,1));
 end
 
 %%
figure;
errorbar(Octa,FreqScores(:,1),FreqCI(:,1),'r-o');

%% %%%%%%
% sampling training data and testing data
TrialType = double(TrialType);
TrialNum = size(T8TData,1);
TrainingNum = ceil(TrialNum*0.5);
TestingNum = TrialNum - TrainingNum;
SampleInds = randsample(TrialNum,TrainingNum);

AllTInds = false(TrialNum,1);
AllTInds(SampleInds) = true;

% TrialFreq = varargin{3}.Stim_toneFreq;
TrainingDataSet = T8TData(AllTInds,:);
TrainingTType = TrialType(AllTInds);
TrainingFreq = TrialFreq(AllTInds);

TestingDataSet = T8TData(~AllTInds,:);
TestingTType = TrialType(~AllTInds);
TestingFreq = TrialFreq(~AllTInds);

%%
% using training data set to train a logistic regression classifier
 [BTrain,devTrain,statsTrain] = mnrfit(TrainingDataSet,TrainingTType(:)+1);
 MatrixWeight = BTrain(2:end);
%  ROIbias = (statsTrain.beta(2:end))';
 MatrixScore = TrainingDataSet * MatrixWeight + BTrain(1);
 pValue = 1./(1+exp(-1.*MatrixScore));
 
 %testing test data set score
%  TestMatrixScore = TestingDataSet * MatrixWeight + BTrain(1);
 [pihat,dlow,dhi] = mnrval(BTrain,TestingDataSet,statsTrain);
 PredTrialType=double(pihat(:,2));
 ErroeNum = abs(double(pihat(:,2)) - double(TestingTType)');

 %%
 %  TrialFreq = CorrTrialStim;
 UniqueFreqTypes = unique(TestingFreq);
 FreqScores = zeros(length(UniqueFreqTypes),2);
 FreqCI = zeros(length(UniqueFreqTypes),2);
 for nfreq = 1 : length(UniqueFreqTypes)
     cFreq = UniqueFreqTypes(nfreq);
     cFreqTrials =  TestingFreq == cFreq;
     cFreqScore = PredTrialType(cFreqTrials);
     FreqScores(nfreq,:) = [mean(cFreqScore) (std(cFreqScore)/sqrt(length(cFreqScore)))];
     FreqCI(nfreq,1) = mean(dlow(cFreqTrials,1));
     FreqCI(nfreq,2) = mean(dhi(cFreqTrials,1));
 end
 figure;
errorbar(Octa,FreqScores(:,1),FreqScores(:,2),'r-o');