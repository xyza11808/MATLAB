function NBC_for2afc(RawData,TrialFreq,StartFrame,FrameRate,Timescale,varargin)
% this function is trying to build a naive bayes classifier to do
% population decoding

[TrialNum,ROINum,TimeTrace] = size(RawData);
if TrialNum ~= length(TrialFreq)
    error('Trial number isn''t consistent, please check the input data.');
end

freqTypes = unique(TrialFreq);
freqPrior = zeros(length(freqTypes),1);
Boundary = double(freqTypes(1))*power(2,log2(double(freqTypes(end))/double(freqTypes(1)))/2);
trialInds = TrialFreq > Boundary;
freq2trialType = freqTypes > Boundary;
for nfreq = 1 : length(freqTypes)
    freqPrior(nfreq) = sum(TrialFreq == freqTypes(nfreq)) / length(TrialFreq);
end
TrialTypePrior = [sum(freqPrior(1:3)),sum(freqPrior(4:6))];
FrameScale = round(FrameRate * Timescale);
if TimeTrace - FrameScale < StartFrame
    FrameScale = TimeTrace - StartFrame - 1;
end
SelectData = RawData(:,:,StartFrame:(StartFrame+FrameScale));
TrainingData = max(SelectData,[],3);
%the current will only used for natlab versions higher than 2014a
md1 = fitcnb(TrainingData,trialInds(:),'prior',TrialTypePrior);
defaultCVMdl = crossval(md1);
defaultLoss = kfoldLoss(defaultCVMdl);
fprintf('Naive bayes classifier error rate equals %0.4f',defaultLoss);
if ~isdir('./NBC_analysis_result/')
    mkdir('./NBC_analysis_result/');
end
cd('./NBC_analysis_result/');

save NBC_result.mat md1 defaultCVMdl defaultLoss -v7.3


%%
% trial by trial crossvalidation
TestingData = zeros(100*length(freqTypes),ROINum);
for nIter = 1 : 100
    randInds = randsample(TrialNum,round(TrialNum*0.8));
    SelectInds = false(TrialNum,1);
    SelectInds(randInds) = true;
    TrainingDataT = RawData(SelectInds,:,:);
%     TestData = RawData(~SelectInds,:,:);
    
    TrainingFreq = TrialFreq(SelectInds);
    BaseInds = (nIter - 1)*length(freqTypes);
    for nfreq = 1 : length(freqTypes)
        cfreqInds = TrainingFreq == freqTypes(nfreq);
        cData = TrainingDataT(cfreqInds,:,:);
        cDataAvg = squeeze(mean(cData));
        TestingData(BaseInds+nfreq,:) = max(cDataAvg,[],2);
    end
end

RealFreq = repmat(freq2trialType(:),100,1);
TestFreq = predict(md1,TestingData);
CorrectPred = RealFreq == TestFreq;
FalseRate = 1-mean(CorrectPred);

save TestDataSet.mat RealFreq TestingData CorrectPred FalseRate -v7.3
FreqPerformance = mean(reshape(CorrectPred,6,100),2);
FitPerf = FreqPerformance;
FitPerf(1:3) = 1 - FitPerf(1:3);
freqTypes = double(freqTypes);
FreqOct = log2(freqTypes/min(freqTypes));
h_fitplot = figure;
plot(FreqOct,FitPerf,'o','color','r','MarkerSize',6,'LineWidth',1.4);
xlabel('Octave Diff.');
ylabel('RightWard Corr. rate');
title('Naive bayes classification');
saveas(h_fitplot,'NBC fit scatterPlot.png');
saveas(h_fitplot,'NBC fit scatterPlot.fig');
close(h_fitplot);
%%

cd ..;
