function [BinnedData,BinLen]=DataBinnedFunc(DataInput,BinLen,Dimension,varargin)
%this function will be used to binned data points together and return the
%binned data set, which is usually less than input data length in at least
%one dimension

if BinLen < 1
    disp('Input Bin length as time, convert to frame bin.\n');
    FrameRate = varargin{1};
    BinLen = round(BinLen * FrameRate);
end

if Dimension > ndims(DataInput)
    warning('Input demension is large than maxium dimension, quit function');
    return;
else
    DimLength = size(DataInput,Dimension);
    BinnedDataLen = ceil(DimLength/BinLen);
    RawInputSize = size(DataInput);
    BinnedSize = RawInputSize;
    BinnedSize(Dimension) = BinnedDataLen;
    BinnedData = zeros(BinnedSize);
end

if Dimension == 3
    for nBIN = 1 : BinnedDataLen
        nBINscale = (nBIN - 1)*BinLen+1:nBIN * BinLen;
        nBINscale(nBINscale>DimLength) = []; 
        BinnedData(:,:,nBIN) = mean(DataInput(:,:,nBINscale),Dimension);
    end
end