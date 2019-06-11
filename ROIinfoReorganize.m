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

% GUIROIinfo = struct('ROImask',{}, 'ROIpos',{}, 'ROItype',{},'BGpos',[],...
%         'BGmask', [], 'ROI_def_trialNo',[], 'Method','');

ROImasksAll = cell(nROIs,1);
ROIposAll = cell(nROIs,1);
ROItypeAll = cell(nROIs,1);

for cR = 1 : nROIs
    cRblankMask = false(FrameSize);
    cROIinfodata = ClickROIinfo{cR};
    try
        cRblankMask(cROIinfodata{1}:cROIinfodata{2},cROIinfodata{3}:cROIinfodata{4}) = cROIinfodata{5};
    catch
        fprintf('Possible boundary ROI detected.\n');
        if cROIinfodata{2} == FrameSize(1)
            yEnd = cROIinfodata{2};
            yStart = cROIinfodata{2}-size(cROIinfodata{5},1)+1;
%         else
%             yEnd = cROIinfodata{2};
%             yStart = cROIinfodata{1};
%         end
        elseif cROIinfodata{1} == 1
            yStart = 1;
            yEnd = size(cROIinfodata{5},1);
        else
            yEnd = cROIinfodata{2};
            yStart = cROIinfodata{1};
        end
            
        if cROIinfodata{4} == FrameSize(2)
            xEnd = cROIinfodata{4};
            xStart = cROIinfodata{4}-size(cROIinfodata{5},2)+1;
%         else
%             xEnd = cROIinfodata{4};
%             xStart = cROIinfodata{3};
%         end
        elseif cROIinfodata{3} == 1
            xStart = 1;
            xEnd = size(cROIinfodata{5},2);
        else
            xEnd = cROIinfodata{4};
            xStart = cROIinfodata{3};
        end
        
        cRblankMask(yStart:yEnd,xStart:xEnd) = cROIinfodata{5};
    end
        
    B=bwboundaries(cRblankMask);
    
    ROImasksAll{cR} = cRblankMask;
    ROIposAll{cR} = B{1}(:,[2,1]);%
    ROItypeAll{cR} = 'Soma';
%     GUIROIinfo.ROI_def_trialNo(cR) = 1;
    
end
GUIROIinfo.ROImask = ROImasksAll;
GUIROIinfo.ROIpos = ROIposAll;
GUIROIinfo.ROItype = ROItypeAll;
GUIROIinfo.ROI_def_trialNo = ones(nROIs,1);
GUIROIinfo.BGpos = [];
GUIROIinfo.BGmask = {};
GUIROIinfo.Method = '';

