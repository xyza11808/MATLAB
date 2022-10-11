ROIinfos = struct('ROIpos',[],'ROImask',[]);
ROINum = 1;
IsROIAdd = true;

while IsROIAdd
    h_roi = imfreehand;
    finish_drawing = 0;
    while finish_drawing == 0
        choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes', 'Re-draw', 'Cancel','Yes');
        switch choice
            case'Yes'
                hPos = h_roi.getPosition;
                line(hPos(:,1), hPos(:,2),'color','g','linewidth',1.5);
                Centers = mean(hPos);
                text(Centers(1),Centers(2),num2str(ROINum,'%d'),'Color','c');
%                 hMask = createMask(h_roi);
                ROIinfos(ROINum).ROIpos = hPos;
%                 ROIinfos(ROINum).ROImask = hMask;

                delete(h_roi);
                finish_drawing = 1;
    %             ROI_updated_flag = 1;
            case'Re-draw'
                delete(h_roi);
                h_roi = imfreehand; 
                finish_drawing = 0;
            case'Cancel'
                delete(h_roi); 
                finish_drawing = 1;
    %             ROI_updated_flag = 0;
%                 return
        end
    end
    
    Choice = questdlg('Add Another ROI?','Add ROI', 'Yes', 'No', 'Cancel','Yes');
    switch Choice
        case 'Yes'
            ROINum = ROINum + 1;
        case 'No'
            IsROIAdd = false;
        case 'Cancel'
            IsROIAdd = false;
    end
    
end

%%
AllDataPoints = AllYs{4,1}(UsedYInds,:);
NumROIs = length(ROIinfos);
UnitInterROI2 = nan(size(AllDataPoints,1),1);
for cROI = 1 : NumROIs
    cROIpos = ROIinfos(cROI).ROIpos;
    pgon = polyshape(cROIpos(:,1),cROIpos(:,2));
    ROIisInter = isinterior(pgon, AllDataPoints(:,1), AllDataPoints(:,2));
    
    UnitInterROI2(ROIisInter) = cROI;
end

UnitInterROI2(isnan(UnitInterROI2)) = NumROIs + 1;





