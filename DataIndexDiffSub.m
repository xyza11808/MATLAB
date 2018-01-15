function DisDataAvg = DataIndexDiffSub(Data)
% used for between and within data distance wise averaged value generation
nRows = size(Data,2);
DistanceNum = nRows - 1;
GrNum = nRows/2;

if ndims(Data) > 2
    DataMaskOne = ones(size(Data,2),size(Data,3));
    DataMaskZeros = zeros(size(Data,2),size(Data,3));
    nROI = size(Data,1);
else
    DataMaskOne = ones(size(Data));
    DataMaskZeros = zeros(size(Data));
    nROI = 1;
end

BetGrMask = DataMaskZeros;
BetGrMask(1:GrNum,GrNum+1:end) = 1;
BetGrMask = logical(BetGrMask);

BetDisData = zeros(nROI,DistanceNum,2);
WinDisData = zeros(nROI,GrNum-1,2);
for cROI = 1 : nROI
    if nROI == 1
        cData = Data;
    else
        cData = squeeze(Data(cROI,:,:));
    end
    for cDis = 1 : DistanceNum
        if cDis < DistanceNum
            cDisMask = logical(triu(DataMaskOne,cDis) - triu(DataMaskOne,cDis+1));
        else
            cDisMask = logical(triu(DataMaskOne,cDis));
        end

        cDisBetMask = cDisMask & BetGrMask;
        cDisBetData = cData(cDisBetMask);
        BetDisData(cROI,cDis,:) = [mean(cDisBetData),cDis];

        if cDis < GrNum
            cDisWinMask = cDisMask & ~BetGrMask;
            cDisWinData = cData(cDisWinMask);
            WinDisData(cROI,cDis,:) = [mean(cDisWinData),cDis];
        end  
    end 
end

DisDataAvg.BetGrData = squeeze(BetDisData);
DisDataAvg.WinGrData = squeeze(WinDisData);
