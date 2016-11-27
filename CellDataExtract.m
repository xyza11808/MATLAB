function DataOut = CellDataExtract(CellData,TarLen)
% this function is specifically used for extract fixed length of columns
% from cell data, and return selected result
DataAll = CellData;
if length(DataAll) ~= numel(DataAll)
    DataOut = DataAll(:,1:TarLen);
else
    DataOut = DataAll(1:TarLen);
end