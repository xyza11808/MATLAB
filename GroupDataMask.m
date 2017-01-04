function [BetGrMask,WithinGrMask,pixelDisMatrix] = GroupDataMask(RowLen,varargin)
% this function if used for generating between group mask and within group
% mask for calculation
%%
SingleGroupSize = RowLen/2;
BetGrMask = zeros(RowLen);
BetGrMask(1:SingleGroupSize,(SingleGroupSize+1):end) = 1;
BetGrMask = logical(BetGrMask);

WithinGrMask = ones(RowLen);
WithinGrMask = triu(WithinGrMask,1);
WithinGrMask(1:SingleGroupSize,(SingleGroupSize+1):end) = 0;
WithinGrMask = logical(WithinGrMask);

%%
k = 1;
for nnn = 1 : RowLen
    for mmm = (nnn+1):RowLen
        PexelDis(k) = mmm - nnn; %#ok<AGROW>
        k = k + 1;
    end
end
pixelDisMatrix = squareform(PexelDis);  % distance matrix
% figure;
% imagesc(pixelMatrix);
% colorbar

