function ROIType = ROITypeSelection
% used for ROI type selection
ROIType = questdlg('Select ROI types','ROI Types','Terrotory','soma','Branch','soma');
if isempty(ROIType)
    ROIType = 'soma';
end
