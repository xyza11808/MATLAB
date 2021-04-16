function [FieldCumFracs,BinCents,BinEdges] = Coef2BinCumufrac(FieldCoefData, BinSize)
% function used to calculate the coef datas

NumFields = length(FieldCoefData);
BinEdges = -1:BinSize:1;
BinCents = ((BinSize/2)-1):BinSize:1;

FieldCumFracs = cell(NumFields,1);
for cf = 1 : NumFields
    cfData = FieldCoefData{cf};
    Bincount = histcounts(cfData,BinEdges)/numel(cfData); % convert into fraction
    FieldCumFracs{cf} = cumsum(Bincount);
end


    


