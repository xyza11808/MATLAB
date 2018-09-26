function binned = binSpatial(mov, factor)
% binned = bin_mov(mov, factor) spatially bins the Y-by-X-by-nFrames movie
% by an integer factor: Each new pixel is the average of factor-by-factor old
% pixels. If the dimensions of mov do not match, pixels are discarded at 
% the edges.

if factor == 1
    binned = mov;
    return
end

% Check if movie dimensions are evenly divisible by binfactor:
[h, w, z] = size(mov);
if mod(w, factor)
	warning('Pixels in X-dimension are not an integer multiple of the binning factor -- discarding %d Y-columns.', mod(w, factor));
	w = w - mod(w,factor);
    mov = mov(:,1:w,:);
end

if mod(h, factor)
	warning('Pixels in Y-dimension are not an integer multiple of the binning factor -- discarding %d Y-rows.', mod(h, factor));
	h = h - mod(h,factor);
    mov = mov(1:h,:,:);
end

% Bin along columns:
mov = mean(reshape(mov,factor,[]) ,1);

% Bin along rows:
mov = reshape(mov, h/factor, []).';       %Note transpose
mov = mean(reshape(mov, factor, []) ,1);

% Bring dimensions back in order:
mov = reshape(mov, w/factor, z, h/factor);
binned = permute(mov, [3, 1, 2]);