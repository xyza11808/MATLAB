function IndexedPlotVec = Cell2indexPlots(CellData)
% convert cell data into index data for quick plot
NumofRows = length(CellData);
IndexedPlotCell = cell(NumofRows,2);
for cRow = 1 : NumofRows
    cRData = CellData{cRow};
    if ~isempty(cRData)
        IndexedPlotCell{cRow,1} = cRData(:);
        IndexedPlotCell{cRow,2} = cRow*ones(numel(cRData),1);
    end
end

IndexedPlotVec = cell2mat(IndexedPlotCell);
