function MtxData = VecData2Mtx(Data, DataLen)
if isempty(Data)
    MtxData = zeros(DataLen,1);
    return;
end
if ndims(Data) > 2
    MtxData = Data;
    return;
end

if length(Data) == numel(Data)
   if size(Data,1) == 1 
        MtxData = Data';
   elseif size(Data,2) == 1 
       MtxData = Data;
   end
else
    MtxData = mean(Data,2);
end

