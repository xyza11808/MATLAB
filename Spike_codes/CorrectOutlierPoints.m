function LowHighThres = CorrectOutlierPoints(Data, stdRatio)

if ~exist('stdRatio','var') || isempty(stdRatio)
    stdRatio = 5;
end
Data(isnan(Data)) = [];

if length(Data) < 5
    warning('Too few datas, the calculation is in accurate.\n');
    LowHighThres = [nan,nan];
    return;
end
if std(Data) < 1e-6
    LowHighThres = [mean(Data),mean(Data)];
    return;
end


DataThres = prctile(Data, [1 99]);
WithinThresInds = Data >= DataThres(1) & Data <= DataThres(2);
WinThresDatas = Data(WithinThresInds);

DataAvg = mean(WinThresDatas);
DataStd = std(WinThresDatas);

LowHighThres = [DataAvg - DataStd*stdRatio, DataAvg + DataStd*stdRatio];


