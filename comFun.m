function Coordinate = comFun(Im, Mask)
% calculate the com for input image
UsedIm = Im;
if nargin > 1
    UsedIm(~Mask) = 0;
end

if length(unique(UsedIm(:))) == 2
    % used as binary image
    NormIm = UsedIm > 0;
else
    % normalized to [0 1]
    MaxValue = max(UsedIm(:));
    if MaxValue == 0
        error('The input image is empty.');
    else
        NormIm = UsedIm;
        NormIm = NormIm / MaxValue;
    end
end

[x, y] = meshgrid(1:size(NormIm, 2), 1:size(NormIm, 1));
weightedx = x .* NormIm;
weightedy = y .* NormIm;
xcentre = sum(weightedx(:)) / sum(NormIm(:));
ycentre = sum(weightedy(:)) / sum(NormIm(:));

Coordinate = [xcentre, ycentre];
