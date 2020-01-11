function ROIDatas = ExtractROIDatas(RawData,ROIinfos)
NumROIs = length(ROIinfos);
NumFrames = size(RawData,3);
ROIDatas = zeros(NumROIs,NumFrames);
for cR = 1 : NumROIs
    cRMask = ROIinfos(cR).ROImask;
    cRMask_pixel = sum(sum(cRMask));
    
    ThreeD_mask = repmat(cRMask,1,1,NumFrames);
    cRData = mean(reshape(RawData(ThreeD_mask),cRMask_pixel,[]));
    
    ROIDatas(cR,:) = cRData;
end