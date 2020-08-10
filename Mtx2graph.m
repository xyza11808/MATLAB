function Gnets = Mtx2graph(Mtx)
% function to convert a input matrix into graph object
if ~issymmetric(Mtx)
    error('The input Mtx must be a symmetric matrix');
end

RowSize = size(Mtx, 1);
HalfMtx = tril(Mtx,-1);

[EdgeRows, EdgeCols,] = find(HalfMtx > 0);
UsedDataMtxIndex = sub2ind([RowSize RowSize],EdgeRows,EdgeCols);
Gnets = graph(EdgeRows, EdgeCols, HalfMtx(UsedDataMtxIndex));


