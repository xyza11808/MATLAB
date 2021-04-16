function [BinMeanSEMData,BinAllDatas] = All2BinDatas(AllCoefs,AllDis,BinSize)

BinEdges = 0:BinSize:ceil(max(AllDis)/BinSize)*BinSize;
BinCenters = (BinEdges(1:end-1)+BinEdges(2:end))/2;
BinMeanSEMData = zeros(length(BinCenters),3);
BinAllDatas = cell(length(BinCenters),1);
ExcludedInds = false(length(BinCenters),1);
for cBin = 1 : length(BinCenters)
    cBinInds = AllDis >= BinEdges(cBin) & AllDis < BinEdges(cBin+1);
    cBinCoefData = AllCoefs(cBinInds);
    BinAllDatas{cBin} = cBinCoefData;
%     if numel(cBinCoefData) < 30
%         ExcludedInds(cBin) = 1;
%     end
    
    BinMeanSEMData(cBin,1) = mean(cBinCoefData);
    BinMeanSEMData(cBin,2) = std(cBinCoefData)/sqrt(numel(cBinCoefData));
end

BinMeanSEMData(:,3) = BinCenters;

if sum(ExcludedInds)
    BinMeanSEMData(ExcludedInds,:) = [];
    BinAllDatas(ExcludedInds) = [];
end

