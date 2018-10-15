load('ROIinfoBU_b55a02_test03_3x_2afc_150um_20180905_dftReg_.mat');
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

%%
% expand ROI masks
load('ROIinfoBU_b55a02_test03_3x_2afc_150um_20180905_dftReg_.mat');
nROIs = length(ROIinfoBU.ROImask);
FrameSize = size(ROIinfoBU.ROImask{1});
NewMasks = cell(nROIs,1);
NewPos = cell(nROIs,1);
for cROI = 1 : nROIs
    MaskInds = find(ROIinfoBU.ROImask{cROI});
    [Maxkx,Maxky] = ind2sub(FrameSize,MaskInds);

    DoubyMaskx = round(Maxkx*2);
    DoubMaskInds = sub2ind([FrameSize(1)*2,FrameSize(2)],DoubyMaskx,Maxky);
    NewDoubMask = false(FrameSize(1)*2,FrameSize(2));
    NewDoubMask(DoubMaskInds) = true;
    
    Bedges = bwboundaries(NewDoubMask);
    NewROIpos = Bedges{1};
    
    NewMasks{cROI} = NewDoubMask;
    NewPos{cROI} = NewROIpos(:,[2,1]);
    
end
 
NewROIinfo = ROIinfoBU;
NewROIinfo.ROImask = NewMasks;
NewROIinfo.ROIpos = NewPos;
NewROIinfo.Ringmask = {};
NewROIinfo.LabelNPmask = {};