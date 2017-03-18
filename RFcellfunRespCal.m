function ROIResp = RFcellfunRespCal(SingleStimData,FrameRate,TimeOn)
% this function is just used for cellfun processing of function
% "UnevenRFrespPlot" generated result variable "typeData", to extract the
% response value for each cell data
% mean trace peak is used as response value

StimOnFrame = FrameRate * TimeOn;
WinFrame = round(([0.2,1.5])*FrameRate) + StimOnFrame;
MeanTrace = mean(SingleStimData);
ROIResp = max(MeanTrace(WinFrame(1):WinFrame(2)));