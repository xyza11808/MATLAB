function DisAccuStrc = Mtx2DisAccuFun(Mtx,UsedInds)
% this function is used to convert mtx data into
% distance based accuracy
UsedMtxData = Mtx(UsedInds,UsedInds);
OneSideGrNum = size(UsedMtxData,1)/2;
PosCommonDis = OneSideGrNum - 1;

WinDisData = zeros(PosCommonDis,1);
BetDisData = zeros(PosCommonDis,1);
for cDis = 1 : PosCommonDis
    cDisData = diag(UsedMtxData,-cDis);
    BaseInds = false(numel(cDisData),1);
    
    BaseInds(OneSideGrNum-cDis+1:end-OneSideGrNum+cDis) = true;
    cBetData = cDisData(BaseInds);
    cWinData = cDisData(~BaseInds);
    
    WinDisData(cDis) = mean(cWinData);
    BetDisData(cDis) = mean(cBetData);
end

DisAccuStrc.WinAccu = WinDisData;
DisAccuStrc.BetAccu = BetDisData;
DisAccuStrc.Dis = PosCommonDis;
