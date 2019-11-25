function BincentANDdatas = DisANDCoefplot(AllCoefs,AllDiss,Pixel2umRatio)
% plot the correlation between coef values and distance
if isempty(Pixel2umRatio)
    Pixel2umRatio = 0.718;
end
DistanceValue = AllDiss * Pixel2umRatio;

BinNum = 25;
AllBinEdges = linspace(min(DistanceValue),max(DistanceValue),BinNum+1);

BinCenters = (AllBinEdges(1:end-1)+AllBinEdges(2:end))/2;

BinnedCoefDatas = cell(BinNum,1);
IsEmptyBin = zeros(BinNum,1);
for cBin = 1 : BinNum 
    cBinRangeInds = DistanceValue >= AllBinEdges(cBin) | DistanceValue < AllBinEdges(cBin+1);
    BinnedCoefDatas{cBin} = AllCoefs(cBinRangeInds);
    if isempty(BinnedCoefDatas{cBin})
        IsEmptyBin(cBin) = 1;
    end
end

if sum(IsEmptyBin)
    BinnedCoefDatas(logical(IsEmptyBin)) = [];
    BinCenters(logical(IsEmptyBin)) = [];
end

BincentANDdatas = {BinnedCoefDatas,BinCenters};
