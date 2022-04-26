function correlograms = twoClusCCGCalFun(cClus1_SPtimes, cClus2_SPtimes)


% cluster 2 after cluster 1
MergedSPtimes = [cClus1_SPtimes;cClus2_SPtimes];
MergedSP_clusInds = [zeros(numel(cClus1_SPtimes),1);...
    ones(numel(cClus2_SPtimes),1)];
[SortSPtimes, SortInds] = sort(MergedSPtimes);
Sort_clusInds = MergedSP_clusInds(SortInds);
correlograms = Spikeccgfun(SortSPtimes,Sort_clusInds,2,1e-3,false);




