load('ROIinfoBU_b53a05_test02_2x_2afc_135um_20180630_dftReg_.mat');
nROIs = length(ROIinfoBU.ROImask);
FrameSize = size(ROIinfoBU.ROImask{1});
NewMasks = cell(nROIs,1);
NewPos = cell(nROIs,1);
for cROI = 1 : nROIs
    MaskInds = find(ROIinfoBU.ROImask{cROI});
    [Maxkx,Maxky] = ind2sub(FrameSize,MaskInds);

    HalfyMaskx = round(Maxkx/2);
    HalfMaskInds = sub2ind([FrameSize(1)/2,FrameSize(2)],HalfyMaskx,Maxky);
    NewHalfMask = false(FrameSize(1)/2,FrameSize(2));
    NewHalfMask(HalfMaskInds) = true;
    
    Bedges = bwboundaries(NewHalfMask);
    NewROIpos = Bedges{1};
    
    NewMasks{cROI} = NewHalfMask;
    NewPos{cROI} = NewROIpos(:,[2,1]);
    
end
 
NewROIinfo = ROIinfoBU;
NewROIinfo.ROImask = NewMasks;
NewROIinfo.ROIpos = NewPos;
NewROIinfo.Ringmask = {};
NewROIinfo.LabelNPmask = {};
%%
ROIinfoBU = NewROIinfo;
save ShapedMaskAll.mat ROIinfoBU -v7.3