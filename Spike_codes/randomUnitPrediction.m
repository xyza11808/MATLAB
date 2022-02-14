function SampleScore2Prob = randomUnitPrediction(AllUnitResponse, TargetTypes, sampleNumber, RepeatNum)
% This function is used to randomly sample defined neumber of units to
% check the consistance of population decoding performance
TotalUnitNums = size(AllUnitResponse,2);
if sampleNumber > TotalUnitNums
    error('The sample number should be less than total numbers.');
end
if sampleNumber > (TotalUnitNums*0.8)
   warning('The sample number is higher than 80% of total unit numbers, the sample result might be quiet similar.\n');
end
NumofFolds = 10;
TrInds = (1:size(AllUnitResponse,1))';
GrWithinIndsSet = seqpartitionFun(TrInds, NumofFolds);
SampleScore2Prob = cell(RepeatNum, 4);

for cR = 1 : RepeatNum
    cReSampleInds = randsample(TotalUnitNums, sampleNumber);
    cReSampleResp = AllUnitResponse(:,cReSampleInds);
    
    TrPredBlockTypes = cell(NumofFolds,5); % PredInds, PredType, PredScore
    Trmdperfs = zeros(NumofFolds,2);
    for cfold = 1 : NumofFolds
        cFoldInds = (GrWithinIndsSet(cfold,:))';
        
        AllTrIndsBack = GrWithinIndsSet;
        AllTrIndsBack(cfold,:) = [];
        TrainInds = cell2mat(AllTrIndsBack(:,1)); % for model training
        MDPerfInds = cell2mat(AllTrIndsBack(:,2)); % for model performance evaluating
        PerdTrInds = cell2mat(cFoldInds(:)); % predicting the rest datas
        
        mdl = fitcsvm(cReSampleResp(TrainInds,:),TargetTypes(TrainInds));
        mdEvaluates = predict(mdl, cReSampleResp(MDPerfInds,:));
        MDPerfs = mean(mdEvaluates == TargetTypes(MDPerfInds));
        
        [mdTargetTypes, PredScores] = predict(mdl, cReSampleResp(PerdTrInds,:)); % predDatas
        PredPerfs = mean(mdTargetTypes == TargetTypes(PerdTrInds));
        
        Trmdperfs(cfold,:) = [MDPerfs, PredPerfs];
        
        TrPredBlockTypes(cfold,:) = {PerdTrInds,mdTargetTypes,PredScores(:,1),mdl.Beta,mdl.Bias};
    end
    
    AllUsedTrPredScores = cell2mat(TrPredBlockTypes(:,3));
    AllUsedTrInds = cell2mat(TrPredBlockTypes(:,1));
    PredScore2Prob = 1./(1+exp(-1.*AllUsedTrPredScores));
    
    SampleScore2Prob(cR,:) = {PredScore2Prob, AllUsedTrInds, TrPredBlockTypes, Trmdperfs};


end





