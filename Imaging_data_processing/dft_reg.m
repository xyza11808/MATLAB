function [im_dft, shift] = dft_reg(im_s, im_tg, pix_range)

% im_s, source image data, can be multi-frame, m x n x p matrix.
% im_tg, target image for registration, a single frame image, m x n matrix.
%        If left empty, will generate default target image.
% 
% pix_range, specify the fraction of image used for registraiton.
%            If with 2 elements [startRow endRow], take as line_range,
%            If with 4 elements [startRow endRow startCol endCol], use a rectangle fraction of
%            the image.
% - NX
% Updated Aug, 2012, - NX

if nargin < 2 || isempty(im_tg)
    % By default, use mean of the last 10 frames as the target image.
    im_tg = mean(im_s(:,:,end-9:end),3);
end
if nargin < 3 || isempty(pix_range)
    row_nums = 1 : size(im_tg,1);
    col_nums = 1: size(im_tg, 2);
else
    if numel(pix_range) == 2
        row_nums = pix_range(1) : pix_range(2);
        col_nums = 1:size(im_tg, 2);
    end
    if numel(pix_range) == 4
        row_nums = pix_range(1):pix_range(2);
        col_nums = pix_range(3):pix_range(4);
    end
end

span = 3; % frame span for moving average, to set the targe image
t_fft=tic;
for i=1:size(im_s,3);
%     if i <= span
%         im_tg = mean(im_s(:,:,1:span),3);
%     else
%         im_tg = mean(im_s(:,:,i-span:i-1),3);
%     end

% If the image frame is blank due to shutter close duing
% photostimulation, skip this frame.
%     
%     if mean(reshape(im_s(:,:,i), 1,[])) < 2
%         output(:,i) = [0; 0; 0; 0];
% %         im_dft(:,:,i) = im_s(:,:,i);
%     else
%         imagesc(im_tg,[0 100]);   pause(0.2)
      [output(:,i), fft_frame_reg] = dftregistration(fft2(double(im_tg(row_nums,col_nums))),fft2(double(im_s(row_nums, col_nums,i))),1);
%         im_dft(:,:,i) = abs(ifft2(fft_frame_reg));
%     end
% The above no longer apply for SI4 data.
%     [output(:,i), fft_frame_reg] = dftregistration(fft2(double(im_tg(row_nums,col_nums))),fft2(double(im_s(row_nums, col_nums,i))),1);
end
t=toc(t_fft);
% disp(t);
shift = output(3:4,:);
padding = [0 0 0 0];
im_dft = ImageTranslation_nx(im_s,shift,padding,0);