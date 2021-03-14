function FieldAvgDatas = fieldWiseAmpCal(CellAmps,EventDatas)
AnmNums = length(CellAmps);
FieldAmps = zeros(AnmNums,2);
for cAnm = 1 : AnmNums
    cAnmAmps = cellfun(@mean,CellAmps{cAnm});
    cAnmCellType = EventDatas{cAnm,2};
    
    NeuInds = cellfun(@(x) strcmpi(x,'Neu'),cAnmCellType);
    
    NeuAvgDatas = cAnmAmps(~isnan(cAnmAmps) & NeuInds);
    AstAvgDatas = cAnmAmps(~isnan(cAnmAmps) & ~NeuInds);
    
    FieldAmps(cAnm,:) = [mean(NeuAvgDatas),mean(AstAvgDatas)];

end

FieldAvgDatas = cell(2,1);
FieldAvgDatas{1} = FieldAmps(~isnan(FieldAmps(:,1)),1);
FieldAvgDatas{2} = FieldAmps(~isnan(FieldAmps(:,2)),2);