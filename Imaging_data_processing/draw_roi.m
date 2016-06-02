function draw_roi(im_array, draw_opt)

%
% draw_opt: 'freehand', 'polygon'

fig = figure;
haxis = gca;
% define the way of drawing, freehand or ploygon
switch draw_opt
    case 'freehand'
        draw = @imfreehand;
    case 'polygon'
        draw = @impoly;
end
trialNo = 0;
roiNo = 0;
draw_next_image = 'y';
while ~strcmpi(draw_next_image, 'n')
    trialNo = trialNo + 1;
    figure(fig);
    imagesc(im_array(:,:,trialNo)); colormap(gray);
    draw_more_roi = 'y';
    while ~strcmpi(draw_more_roi, 'n')
        roiNo = roiNo + 1;
        axes(haxis);
        h_roi = feval(draw);
        finish_drawing = 0;
        while finish_drawing == 0
            choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes', 'Re-draw', 'Cancel','Yes');
            switch choice
                case'Yes',
                    pos = h_roi.getPosition;
                    hROIplot(roiNo) = line(pos(:,1), pos(:,2),'color','g');
                    BW = createMask(h_roi);
                    delete(h_roi);
                    finish_drawing = 1;
                case'Re-draw'
                    delete(h_roi);
                    h_roi = feval(draw); finish_drawing = 0;
                case'Cancel',
                    delete(h_roi); finish_drawing = 1;
                    return
            end
        end
        ROIinfo(trialNo).ROIpos{roiNo} = pos;
        ROIinfo(trialNo).ROImask{roiNo} = BW;
        ROIinfo(trialNo).ROItype{roiNo} = 'tuft branch'; % ROIType;
        draw_more_roi = input('Draw more ROIs in this frame? ','s');
    end
    draw_next_image = input('Draw ROIs in more images? ', 's');
end
save(['ROIinfo_'], 'ROIinfo');