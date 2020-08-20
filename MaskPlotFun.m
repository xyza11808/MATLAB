function [hMask, hPos] = MaskPlotFun(fhandle)

figure(fhandle);

h_roi = imfreehand;
finish_drawing = 0;
while finish_drawing == 0
    choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes', 'Re-draw', 'Cancel','Yes');
    switch choice
        case'Yes'
            hPos = h_roi.getPosition;
            line(hPos(:,1), hPos(:,2),'color','g')
            hMask = createMask(h_roi);
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
            return
    end
end
