function ClusSelfccg = refractoryPeriodCal_sg(spdataStrc,spclus,winsize,binsize)
% function to calculate the refractory period for given cluster
% inds, if empty cluster inds is given, try to calculate the
% ccg values for all valid clusters
if isempty(spclus)
    PlotclusInds = spdataStrc.UsedClus_IDs;
    AllClusCal = 1;
else
    PlotclusInds = sort(spclus); %
    AllClusCal = 0;
end
if binsize < 1 % in case of input as real time in seconds
    winsize = round(winsize * spdataStrc.sample_rate);
    binsize = round(binsize * spdataStrc.sample_rate);
end

MaxclusbatchSize = 5;
if length(PlotclusInds) > MaxclusbatchSize
    BatchNums = ceil(length(PlotclusInds) / MaxclusbatchSize);
    ClusSelfccg = cell(length(PlotclusInds),1);
    %%
    for cBatch = 1 : BatchNums
        cBatchedScale = [(cBatch-1)*MaxclusbatchSize+1,min(cBatch*MaxclusbatchSize,length(PlotclusInds))];
        cBatchedInds = cBatchedScale(1):cBatchedScale(2);
        cBatch_clus_inds = PlotclusInds(cBatchedInds);
        BatchClus2fullInds = ismember(spdataStrc.SpikeClus,cBatch_clus_inds);
        Batch_sptimesAll = spdataStrc.SpikeTimeSample(BatchClus2fullInds); % using sample value to increase the bin accuracy
        Batch_spclusAll = spdataStrc.SpikeClus(BatchClus2fullInds);
        Batchccg = Spikeccgfun(Batch_sptimesAll,Batch_spclusAll,winsize,binsize,false);
        for cb = 1 : length(cBatch_clus_inds)
            ClusSelfccg(cBatchedInds(cb)) = {squeeze(Batchccg(cb,cb,:))};
        end
    end
    %%
else
    ClusSelfccg = cell(length(PlotclusInds),1);
    clus2fullInds = ismember(spdataStrc.SpikeClus,PlotclusInds);
    sptimeAlls = spdataStrc.SpikeTimeSample(clus2fullInds);
    spclusAlls = spdataStrc.SpikeClus(clus2fullInds);
    ccgs = Spikeccgfun(sptimeAlls,spclusAlls,winsize,binsize,false);
    for cb = 1 : length(PlotclusInds)
        ClusSelfccg(cb) = {squeeze(ccgs(cb,cb,:))};
    end
end
if AllClusCal
    save(fullfile(spdataStrc.ksfolder,'AllClusccgData.mat'),'ClusSelfccg','PlotclusInds','-v7.3');
end