function FileNameANDChannelAll = FileNameExtraction(InputStrc)
fIndex = find(arrayfun(@(x) strcmpi(x.Name,'File'),InputStrc));
nfs = length(fIndex);

FileNameANDChannelAll = cell(nfs,2);
for cf = 1 : nfs
    cfData = InputStrc(fIndex(cf)).Attributes;
    cfChannelNameIndex = arrayfun(@(x) strcmpi(x.Name,'channelName'),cfData);
    cfChannelName = cfData(cfChannelNameIndex).Value;
    
    cffilenameIndex = arrayfun(@(x) strcmpi(x.Name,'filename'),cfData);
    cffilename = cfData(cffilenameIndex).Value;
    
    FileNameANDChannelAll(cf,:) = {cfChannelName,cffilename};
end
