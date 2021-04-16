function IsExcluded = IsCoefFieldExcluded(PairedCoefsCell,PairedDisCell)

Numfield = length(PairedCoefsCell);
IsExcluded = zeros(Numfield,1);
for cf = 1 : Numfield
% cf = 54;
%     close;
%     hf = figure;
    cfDis = PairedDisCell{cf};
    cfCoef = PairedCoefsCell{cf};
%     tb = fitlm(BinMeanSEMData(:,3)/100,BinMeanSEMData(:,1));
    tb = fitlm(cfDis/100,cfCoef);
    if tb.Coefficients.Estimate(1) > 0.6 && tb.Coefficients.Estimate(2) > -0.08
        IsExcluded(cf) = 1;
    end
end

IsExcluded = logical(IsExcluded);