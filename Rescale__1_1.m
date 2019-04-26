function [ScaleData,MinMaxData] = Rescale__1_1(RawData)
% used for scale the raw input data into the [0 1] range
RawDataVec = RawData(:);
MinMaxData = [min(RawDataVec),max(RawDataVec)];
ScaleData = (RawData - MinMaxData(1))/(MinMaxData(2) - MinMaxData(1))*2-1;