function dF = dFcalc(subTrace,rawTrace,mode, acqBlocks)

if ~exist('mode','var') || isempty(mode)
    mode = 'custom_wfun';
end

if ~exist('acqBlocks','var') || isempty(acqBlocks)
    acqBlocks = [1, size(subTrace,2)];
end

nBlocks = size(acqBlocks,1);
nSigs = size(subTrace,1);
dF = nan(size(subTrace));
for nSig = 1:nSigs
    
    if all(isnan(subTrace(nSig,:))) || all(isnan(rawTrace(nSig,:)))
        dF(nSig,:) = nan;
        continue
    end
    for nBlock = 1:nBlocks
        blockInd = acqBlocks(nBlock,1):acqBlocks(nBlock,2);
        dF(nSig,blockInd) = (subTrace(nSig,blockInd) - getF_(subTrace(nSig,blockInd), mode))...
            ./getF_(rawTrace(nSig,blockInd), mode);
    end
end