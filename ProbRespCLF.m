% this is a test script for wenquan's idea about stimulus classification
% basic equation is 
% % % ############################
% p(c|f) = sum(p(c|x) * p(x|f))
% p(c|x) = p(x|c) * p(c)/p(x)
% % % ############################
% this the basic response probability distribution for analysis
% using normcdf(x,mu,sigma) to calculate the probability while given x

% Time scale transfer to frame scale
% given time length can be a one or two elements vector
TrialStimlusAll = TrialStimlus(:);
TrialChoiceAll = TrialChoice(:);
[TrNum,ROInum,nFrame] = size(AlignedData);
alignedF = FrameAlign;
if length(TimeScale) == 1
    FrameScale = sort([alignedF,(alignedF + round(Frate * TimeScale))]);
elseif length(TimeScale) == 2
    FrameScale = sort([(alignedF + round(Frate * TimeScale(1))),(alignedF + round(Frate * TimeScale(2)))]);
else
    error('Error time length input, quit analysis.');
end
if FrameScale(1) < 1 || FrameScale(2) > nFrame
    error('Select time scale out of matrix index, quit function.');
end
DataUsing = max(AlignedData(:,:,FrameScale(1):FrameScale(2)),[],3);
nIters = 1000;
pSummaryResult = cell(nIters,1);

for njj = 1 : nIters
    TrainInds = false(TrNum,1);
    RandIndex = randsample(TrNum,round(0.8 * TrNum));
    TrainInds(RandIndex) = true;
    TestInds = ~TrainInds;
    TrainingData = DataUsing(TrainInds,:);
    TestingData= DataUsing(TestInds,:);
    TrainingC = [TrialChoiceAll(TrainInds),TrialStimlusAll(TrainInds)];
    pSummary = NBCGeneAndTest(TrainingData,TrainingC,TestingData);
    pSummaryResult{njj} = pSummary;
end

