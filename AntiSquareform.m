function pDistdata = AntiSquareform(MtxData)
% Reverse function of squareform function, change the matrix into vectors

pDistdata = MtxData(logical(tril(ones(size(MtxData)),-1)));

