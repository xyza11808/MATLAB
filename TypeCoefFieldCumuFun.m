function DataSummary = TypeCoefFieldCumuFun(DatasStrc,DataType,BinSize)

UsedTypeStr = DatasStrc.CoefTypeStrs{DataType};
UsedTypeData = DatasStrc.plotfieldWiseDatas(DataType,:);
UsedWTCoefDatas = UsedTypeData{1};
UsedTgCoefDatas = UsedTypeData{3};

UsedWTFieldNum = length(UsedWTCoefDatas);
UsedTgFieldNum = length(UsedTgCoefDatas);
% BinSize = 0.05;
[WTFieldCumFracs,WTBinCents,~] = Coef2BinCumufrac(UsedWTCoefDatas, BinSize);
[TgFieldCumFracs,TgBinCents,~] = Coef2BinCumufrac(UsedTgCoefDatas, BinSize);

% WTFieldCumFracMtx = cell2mat(WTFieldCumFracs);
% WTFieldCumFracAvg = mean(WTFieldCumFracMtx);
% WTFieldCumFracSEM = std(WTFieldCumFracMtx)/sqrt(UsedWTFieldNum);
% 
% TgFieldCumFracMtx = cell2mat(TgFieldCumFracs);
% TgFieldCumFracAvg = mean(TgFieldCumFracMtx);
% TgFieldCumFracSEM = std(TgFieldCumFracMtx)/sqrt(UsedTgFieldNum);
% 
% WTFieldCoefMeans = cellfun(@mean,UsedWTCoefDatas);
% TgFieldCoefMeans = cellfun(@mean,UsedTgCoefDatas);

DataSummary = struct();
DataSummary.WTCoefs = UsedWTCoefDatas;
DataSummary.TgCoefs = UsedTgCoefDatas;
DataSummary.WTfieldFracs = WTFieldCumFracs;
DataSummary.TgfieldFracs = TgFieldCumFracs;
DataSummary.WTBinCent = WTBinCents;
DataSummary.TgBinCent = TgBinCents;
DataSummary.WTFieldNum = UsedWTFieldNum;
DataSummary.TgFieldNum = UsedTgFieldNum;
DataSummary.DataType = UsedTypeStr;


