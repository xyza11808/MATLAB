function ActiveCellGene(SmoothRawData,TrialType,TrialOut,FrameRate,TimeWin,varargin)
% the input variable SmoothRawData is the output result from gaussian
% process regression analysis result, the curve should be very smooth
% across time

[TrialNum,ROINum,FrameNum] = size(SmoothRawData);  % matrix dimension
TrialResult = 