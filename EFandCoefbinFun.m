function [BinCenters,BincoefValues, MaxBinValues] = EFandCoefbinFun(EventFreq, CoefValues)
% this function is used to bin the coef values according to the
% corresponded event frequency values

EventBinEdges = 0:ceil(max(EventFreq));
NumBins = length(EventBinEdges) - 1;
BinCenters = EventBinEdges(1:NumBins)+0.5;
MaxBinValues = EventBinEdges(end);
BincoefValues = cell(NumBins,4);
for cBin = 1 : NumBins
    cBinCoefs = CoefValues(EventFreq >= EventBinEdges(cBin) & EventFreq < EventBinEdges(cBin+1));
    Numbincoefs = numel(cBinCoefs);
    if Numbincoefs < 3
        BincoefValues(cBin,:) = {NaN,NaN,NaN,NaN};
    else
        BincoefValues(cBin,:) = {mean(cBinCoefs),std(cBinCoefs)/sqrt(Numbincoefs),Numbincoefs,cBinCoefs};
    end
end






