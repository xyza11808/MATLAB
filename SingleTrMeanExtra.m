function MeanRespData = SingleTrMeanExtra(RawDataAll,FrameWin,AlignF)
% this function is used for extract mean response data for each trial and
% then used for significance test
RealWinScale = FrameWin + AlignF;
ExtraData = RawDataAll(:,RealWinScale(1):RealWinScale(2));
MeanRespData = mean(ExtraData,2);
