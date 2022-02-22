function [MaxCoefANDlag, RepeatUnitIndsANDbeta] = logisticFitUnitSampleFun(TrainData, ...
    TestData, BTANDChoices, SampleNum, NMRevFreqIndedx)
% repeated sampling of decoding units
MaxLag = 40;
DefaultRepeatNum = 100;
TotalUnits = size(TrainData,2);

RepeatUnitIndsANDbeta = cell(DefaultRepeatNum,5);
MaxCoefANDlag = zeros(DefaultRepeatNum,2);
parfor cR = 1 : DefaultRepeatNum
    cR_usedUnit = randsample(TotalUnits, SampleNum);
    UsedTrainData = TrainData(:,cR_usedUnit);
    UsedTestData = TestData(:,cR_usedUnit);
    
    [BTrain,~,statsTrain] = mnrfit(UsedTrainData,categorical(BTANDChoices(:,1)));
    [pihatNew,~,~] = mnrval(BTrain,UsedTestData,statsTrain);
    PredProbNew = pihatNew(:,1);
    
    NMRevFreqChoice = BTANDChoices(NMRevFreqIndedx,2);
    predProb4Revfreqs = PredProbNew(NMRevFreqIndedx);
    [xcf,lags,bounds] = crosscorr(predProb4Revfreqs,NMRevFreqChoice,'NumLags',MaxLag,'NumSTD',3);
    
    [MaxCoef,maxInds] = max(smooth(xcf, 5));
    MaxLags = lags(maxInds);
    RepeatUnitIndsANDbeta(cR,:) = {xcf,bounds,cR_usedUnit,BTrain,PredProbNew};
    MaxCoefANDlag(cR,:) = [MaxCoef, MaxLags];
    
end



