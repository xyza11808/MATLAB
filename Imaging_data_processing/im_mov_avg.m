function im_smth = im_mov_avg(im, span)

% Note, span has to be odd number

% - NX 3/11/2009

im = double(im);
mean_im = mean(im,3);

pad = zeros(size(im,1),size(im,2), (span-1)/2);
for i = 1: (span-1)/2
    pad(:,:,i) = mean_im;
end;
temp = cat(3,pad,im,pad);

im_smth = zeros(size(im),'uint16');

for i = 1:size(im,3) % (span-1)/2+1 : size(im,3)+(span-1)/2
    im_smth(:,:,i) = mean(temp(:,:,i:i+span-1), 3);
end;
