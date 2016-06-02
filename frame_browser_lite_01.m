function frame_browser_lite_01(im, clim, roiPos)

if nargin < 2
    cl = [0 500];
else
    cl = clim;
end
if nargin < 3
    roiPos = [];
end
hf = figure('Position', [4   237   474   445]);
imagesc(im(:,:,1), cl); colormap(gray);
n = 1;
while ishandle(hf) %n > 0 && n <= size(ims,3)
    ch = getkey2(hf);
    if ~ishandle(hf) || ch == 27
        break
    end
    if ch == 29 && n < size(im,3)
        n = n+1;
        show_image(im,n,cl,roiPos)
    elseif ch == 28 && n > 1
        n = n-1;
        show_image(im,n,cl,roiPos)
    end
end
    
function show_image(im,n,cl,roiPos)
    % roiPos, Should be a cell array with each element corresponding to one ROI position.
    imagesc(im(:,:,n),cl);
    text(5,5,sprintf('%d / %d', n, size(im,3)),'color','g','fontsize',15)
    if ~isempty(roiPos)
        for i = 1:length(roiPos)
            h_roi_plots(i) = line(roiPos{i}(:,1),roiPos{i}(:,2), 'Color', [0.8 0 0], 'LineWidth', 2);
            text(median(roiPos{i}(:,1)), median(roiPos{i}(:,2)), num2str(i),'Color',[0 .7 0],'FontSize',18);
%             set(h_roi_plots(i), 'LineWidth', 2);
        end
    end