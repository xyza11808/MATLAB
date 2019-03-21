function RawData = Scale__1_1_2Raw(ScaleData,MinMaxData)
% used for recorve scaled to [0 1] range data into raw data range
RawData = 0.5*(ScaleData+1)*(MinMaxData(2) - MinMaxData(1)) + MinMaxData(1);
