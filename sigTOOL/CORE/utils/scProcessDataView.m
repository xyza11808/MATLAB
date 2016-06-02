function scProcessDataView(fhandle, DataView)

if isempty(DataView) || isempty(fieldnames(DataView))
    return
end


if isfield(DataView, 'XLim')
    h=findobj(fhandle, 'Type', 'axes');
    set(h, 'XLim', DataView.XLim);
    scDataViewDrawData(fhandle);
end
    
if isfield(DataView, 'CursorPositions')
    for k=1:length(DataView.CursorPositions)
        if ~isempty(DataView.CursorPositions(k))
            CreateCursor(fhandle, k);
            SetCursorLocation(fhandle, k, DataView.CursorPositions{k})
        end
    end
end


return
