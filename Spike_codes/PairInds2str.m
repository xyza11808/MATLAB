function PairStr = PairInds2str(PairInds, MaxTypesNum)
NumPairs = size(PairInds,2);
PairStr = cell(1,NumPairs);
for cP = 1 : NumPairs
    cP_Inds = PairInds(:,cP);
    PairStr{cP} = sprintf('%d-%d',cP_Inds(1),cP_Inds(2));
end

if NumPairs < MaxTypesNum
    PairStr = [PairStr,repmat({''},1,MaxTypesNum-NumPairs)];
end