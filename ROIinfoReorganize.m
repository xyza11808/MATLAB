function GUIROIinfo = ROIinfoReorganize(ClickROIinfo,FrameSize)
% this function is used for transfering ROI info file saved from Hu
% Yachuang's code to ROI info format that can be read by ROI data
% extraction GUI

% cROI = 1;
% cROIinfodata = ROIInfo{1};
% 
% %%
% FrameSize = [512,512];
% 
% BlankInds = false(FrameSize);
% cROIglobalMask = BlankInds;
% cROIglobalMask(cROIinfodata{1}:cROIinfodata{2},cROIinfodata{3}:cROIinfodata{4}) = cROIinfodata{5};
% figure
% imagesc(cROIglobalMask)
% 
% %%
% 
% B=bwboundaries(cROIglobalMask); %generate boundary position, return a cell variabele
% % RealMask=L;
% RealPos=B;

%
nROIs = length(ClickROIinfo);

GUIROIinfo = struct('ROImask',{}, 'ROIpos',{}, 'ROItype',{},'BGpos',[],...
        'BGmask', [], 'ROI_def_trialNo',[], 'Method','');

ROImasksAll = cell(nROIs,1);
ROIposAll = cell(nROIs,1);
ROItypeAll = cell(nROIs,1);

for cR = 1 : nROIs
    cRblankMask = false(FrameSize);
    cROIinfodata = ClickROIinfo{cR};
    cRblankMask(cROIinfodata{1}:cROIinfodata{2},cROIinfodata{3}:cROIinfodata{4}) = cROIinfodata{5};
    
    B=bwboundaries(cRblankMask);
    
    ROImasksAll{cR} = cRblankMask;
    ROIposAll{cR} = B{1};
    ROItypeAll{cR} = 'Soma';
%     GUIROIinfo.ROI_def_trialNo(cR) = 1;
    
end
GUIROIinfo.ROImask = ROImasksAll;
GUIROIinfo.ROIpos = ROIposAll;
GUIROIinfo.ROItype = ROItypeAll;
GUIROIinfo.ROI_def_trialNo = ones(nROIs,1);

