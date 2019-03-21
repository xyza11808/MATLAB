function RawData = Scale0_1_2Raw(ScaleData,MinMaxData)
% used for recorve scaled to [0 1] range data into raw data range
RawData = ScaleData*(MinMaxData(2) - MinMaxData(1)) + MinMaxData(1);
