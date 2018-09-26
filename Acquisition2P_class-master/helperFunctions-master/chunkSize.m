function sizes = chunkSize(nTotal, nChunks)
% sizes = chunkSize(nElement, nChunk) determines the sizes of individual
% chunks when a vector of length nTotal is partitioned into nChunks chunks.
% All chunks except the last one will be of size round(nTotal/nChunks). The
% last one will differ by at most one. The output of this function can be
% used with mat2cell to chunk arrays, e.g. for parallel processing.

if nTotal < 1 || nChunks < 1
    error('Inputs must be positive integers');
end

% Special case:
if nTotal < nChunks
    sizes = ones(1, nTotal);
    return
end

nInChunk = round(nTotal/nChunks);
sizes = histcounts(ceil((1:nTotal)/nInChunk), ([0:nChunks-1, inf])+0.5);