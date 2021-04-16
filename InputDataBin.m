function BinFracs = InputDataBin(Datas,Bins)
% for frequency, the used bin is 
% [0,1e-3:0.5:5.1,10];

BinCounts = histcounts(Datas,Bins);
BinFracs = BinCounts/numel(Datas);





