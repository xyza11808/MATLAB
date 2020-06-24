function ROIData = Fun_ROIDataExtract(ROImask,Datas)
if ndims(Datas) == 2
    ROIData = mean(Datas(ROImask));
else
    MaskInds = find(ROImask);
    nFrames = size(Datas,3);
    ROIData = zeros(1,nFrames);
    for cf = 1 : nFrames
        cfData = squeeze(Datas(:,:,cf));
        ROIData(1,cf) = mean(cfData(MaskInds)); %#ok<FNDSB>
    end
%     AllPixelData = reshape(Datas(repmat(ROImask,1,1,nFrames)),nPixels,nFrames);
%     ROIData = mean(AllPixelData);
end