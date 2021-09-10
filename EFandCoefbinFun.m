function [BinCenters,BincoefValues, MaxBinValues] = EFandCoefbinFun(EventFreq, CoefValues, Distance)
% this function is used to bin the coef values according to the
% corresponded event frequency values
IsDistanceExists = 0;
if exist('Distance','var')
    IsDistanceExists = 1;
    DisValues = Distance{1};
    DisCutoffThres = Distance{2};
end
EventBinEdges = 0:1:ceil(max(EventFreq));
NumBins = length(EventBinEdges) - 1;
BinCenters = EventBinEdges(1:NumBins)+0.5;
MaxBinValues = NumBins;
BincoefValues = cell(NumBins,4);
for cBin = 1 : NumBins
    cBinCoefs = CoefValues(EventFreq >= EventBinEdges(cBin) & EventFreq < EventBinEdges(cBin+1));
    if IsDistanceExists
       cBinDis = DisValues(EventFreq >= EventBinEdges(cBin) & EventFreq < EventBinEdges(cBin+1));
       cBinCoefs(cBinDis > DisCutoffThres) = [];
    end
    Numbincoefs = numel(cBinCoefs);
    if Numbincoefs < 3
        BincoefValues(cBin,:) = {NaN,NaN,NaN,NaN};
    else
        BincoefValues(cBin,:) = {mean(cBinCoefs),std(cBinCoefs)/sqrt(Numbincoefs),Numbincoefs,cBinCoefs};
    end
end






