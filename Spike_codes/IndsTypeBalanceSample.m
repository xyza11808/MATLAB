function SampleInds = IndsTypeBalanceSample(TypeInds)
% function used to balance sampling group inds so that equal number of
% group types will be sampled

[UniTypes,~,SeqTypes] = unique(TypeInds);
TypeAccounts = accumarray(SeqTypes,1);

MinCountNum = min(TypeAccounts);
NumTypes = length(UniTypes);
SampleInds = false(numel(TypeInds),1);
for cTInds = 1 : NumTypes
    cType_RealInds = find(SeqTypes == cTInds);
    cTypeNum = numel(cType_RealInds);
    if cTypeNum == MinCountNum
        SampleInds(cType_RealInds) = true;
    else
        cTypeSampleIndex = randsample(cTypeNum,MinCountNum);
        SampleInds(cType_RealInds(cTypeSampleIndex)) = true;
    end
end
% fprintf('Sample fraction is %d/%d (%.2f).\n',sum(SampleInds),numel(SampleInds),mean(SampleInds)*100);



