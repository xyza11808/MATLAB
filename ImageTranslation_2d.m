function new_img = ImageTranslation_2d(src_img, shift, padding)
% Take the output from dftregistration.m and translate the image
% acoordingly. Creating a larger image accomadating the translation, no
% pixel cut off.

% shift, a 2-by-nFrame array of net_row_shift and net_col_shift 
% padding, [top bottom left right] rows or columns to be padded to the src_img
%          if [], the 4 values would be taken from "shift".
%          If padding = [0 0 0 0], then the new_image is of the same size
%          of the original image, and the pixels shifted outside the image
%          are cut off.
% varargin: save_flag, save_path, save_name,ImageDescription

% The info for row and column index of the original image frames is saved
% in the header as 4-by-nframe array, with the 4 entries in each column to
% be [first_row_index; last_row_index; first_col_index; last_col_index], when save_flag is 1 

% - NX 7/2009

% % register every frame with dft reg algorithm, and get the shift value
% for i=1:size(src_img,3);
%     output(:,:,i) = dftregistration(fft2(double(target_img)),fft2(double(src_img(:,:,i))),1);
% end
% shift = squeeze(output(1,3:4,:));

% create a larger image according to the range of shift to be done
if isempty(padding)
    padding = get_im_padding(min(shift(1,:)),max(shift(1,:)),min(shift(2,:)),max(shift(2,:)));
end

class_str = class(src_img);
% new_img = zeros(size(src_img) + [padding(1)+padding(2), padding(3)+padding(4), 0], class_str);
new_img = ones(size(src_img) + [padding(1)+padding(2), padding(3)+padding(4)], class_str);

ind_row = padding(1)+1 : padding(1)+size(src_img,1);
ind_col = padding(3)+1 : padding(3)+size(src_img,2);


% If the shifts exceed the size if padded image, then cut off the exceeded
% pixels of the image.
% for i = 1:size(src_img,3)
    new_row = ind_row+shift(1);
    new_col = ind_col+shift(2);
    if new_row(1)<=0
        top_cut = 1-new_row(1);
        new_row = 1:new_row(end);
    else
        top_cut = 0;
    end
    if new_row(end)>size(new_img,1)
        bottom_cut = new_row(end)-size(new_img,1);
        new_row = new_row(1):size(new_img,1);
    else
        bottom_cut =0;
    end
    if new_col(1)<=0
        left_cut = 1-new_col(1);
        new_col=1:new_col(end);
    else
        left_cut = 0;
    end
    if new_col(end)>size(new_img,2)
        right_cut = new_col(end)-size(new_img,2);
        new_col = new_col(1):size(new_img,2);
    else
        right_cut = 0;
    end
    new_img(:,:) = new_img(:,:).*mean(mean(src_img(:,:)));
    new_img(new_row, new_col) = src_img((1+top_cut:end-bottom_cut),(1+left_cut:end-right_cut));
    
% end
