function CellSubData = ThresSubData(CellData)
% clear the cellData values below than the threshold value, which is the 
% one time std for each ROI calculated from non-zeros values
Cell2ROIData = cell2mat(CellData');

Cell2ROIDataTemp = Cell2ROIData;
Cell2ROIDataTemp(Cell2ROIDataTemp < 1e-6) = nan;
ROIDataThres = std(Cell2ROIDataTemp,[],2,'omitnan');
clearvars Cell2ROIDataTemp
CellSubData = cellfun(@(x) ClearSubThresData(x,ROIDataThres),CellData,'UniformOutput',false);



function SubData = ClearSubThresData(DataMtx,Thres)
SubData = DataMtx;
cF = size(DataMtx,2);
ThresMtx = repmat(Thres(:),1,cF);
SubData(SubData < ThresMtx) = 0;



