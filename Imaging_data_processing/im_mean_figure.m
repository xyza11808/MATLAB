function [mean_im, fig] = im_mean(im, clim)

fig = figure('Name','mean Projection Image','Position',[960   40   512   512]);
mean_im = mean(im,3);
imagesc(mean_im);
colormap(gray);
set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
if ~isempty(clim)
    set(gca,'CLim',clim);
end