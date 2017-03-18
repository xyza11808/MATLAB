function RespValue = timeDataExtraction(DataAll,TimeWin,AlignF)
% this function is specifically used for cellfun function to extract
% responsive value within given time window
WinData = DataAll(:,(TimeWin(1)+AlignF):(TimeWin(2)+AlignF));
MeanWinData = mean(WinData);
RespValue = max(MeanWinData);
