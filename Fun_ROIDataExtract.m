function ROIData = Fun_ROIDataExtract(ROImask,Datas)
if ndims(Datas) == 2
    ROIData = mean(Datas(ROImask));
else
    nPixels = sum(ROImask(:));
    nFrames = size(Datas,3);
    AllPixelData = reshape(Datas(repmat(ROImask,1,1,nFrames)),nPixels,nFrames);
    ROIData = mean(AllPixelData);
end