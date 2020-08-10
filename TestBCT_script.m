
% Test02_corrs(abs(Test02_corrs) < 0.2) = 0;
UnUsedInds = abs(Test02_corrs) < 0.2;
NormTest02_corr = ((Test02_corrs + 1) - 2*diag(ones(size(Test02_corrs ,1),1)))/2;
NormTest02_corr(UnUsedInds) = 0;
figure;
imagesc(NormTest02_corr);

%%
[M,Q]=modularity_und(NormTest02_corr);
%%
[SortM, Inds] = sort(M);
NumROIs = length(M);
Gr_types = unique(M);
Gr_typeNum = length(Gr_types);
GrROINums = zeros(Gr_typeNum, 1);
for cGr = 1 : Gr_typeNum
    GrROINums(cGr) = sum(SortM == Gr_types(cGr));
end
GrNumCumSum = cumsum(GrROINums);

figure;
imagesc(NormTest02_corr(Inds,Inds))
title(sprintf('GrNum %d', Gr_typeNum));
for ccGr = 1 : Gr_typeNum
    line([0.5 NumROIs+0.5], [GrNumCumSum(ccGr) GrNumCumSum(ccGr)]+0.5, 'linewidth',1.5,'Color','r');
    line([GrNumCumSum(ccGr)+0.5 GrNumCumSum(ccGr)+0.5], [0.5 NumROIs+0.5], 'linewidth',1.5,'Color','r');
end
    
