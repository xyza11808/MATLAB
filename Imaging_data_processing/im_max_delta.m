function [im_out, fig] = im_max_delta(im, show_img, clim, hfig)

mean_im = mean(im,3);
im = im_mov_avg(im,5);
max_im = double(max(im,[],3));
im_out = max_im - mean_im;

if nargin > 2
    CL = clim;
else
    CL = [0 500];
end

if show_img ==1
    if nargin < 4
        fig = figure('Name','max Delta Image','Position',[960   40   512   512]);
    else
        fig = hfig;
    end
    imshow(im_out,CL,'Border','tight');
    colormap(gray);
%     set(gca, 'Position',[0.05 0.05 0.9 0.9], 'Visible','off');
    axis square
end