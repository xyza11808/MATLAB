function [AM1NeedCheckInds,AM1GoodClusWaveShape,AM1GoodClusMaxChn,AM1GoodClus,AM1GoodClusFRs,AM1AllFRs,AfterMerg1ClusTypes] = ...
    locateNeedCheckClus(AfterMergeSpikeClus,...
    AfterMergeSpikeTimeSample,SpikeStrc,...
    AfterMergetempsUnW,AfterMergeMaxChn,AfterMergeksLabels,BlockEdgeTimes,TotalSampleTime)

AfterMerg1ClusTypes = unique(AfterMergeSpikeClus);
% AfterMerg1ClusNum = length(AfterMerg1ClusTypes);
AfterMerge1SPtimes = double(AfterMergeSpikeTimeSample)/SpikeStrc.sample_rate;

AM1sedtempsUnW = AfterMergetempsUnW(AfterMerg1ClusTypes+1,:,:);
AM1sedMaxChn = AfterMergeMaxChn(AfterMerg1ClusTypes+1);
AM1GoodLabels = cellfun(@(x) strcmpi(x,'good'),AfterMergeksLabels.KSLabel(AfterMerg1ClusTypes+1));
AM1GoodClusWaveShape = AM1sedtempsUnW(AM1GoodLabels,:,:);
AM1GoodClus = AfterMerg1ClusTypes(AM1GoodLabels);
AM1GoodClusMaxChn = AM1sedMaxChn(AM1GoodLabels);
AM1GoodClusNums = length(AM1GoodClus);

% CountEdges = [0:10:TotalSampleTime,TotalSampleTime];
% BlockEdgeTimes = [TaskStartTime; AfterBlockSWTrOnTime+1];
AM1NeedCheckInds = false(AM1GoodClusNums,1);
AM1GoodClusFRs = zeros(AM1GoodClusNums,1);
AM1AllFRs = cell(AM1GoodClusNums,1);
for cClusIdInds = 1 : AM1GoodClusNums
    cClusID = AM1GoodClus(cClusIdInds);
    cID_Inds = AfterMergeSpikeClus == cClusID;
    cClusSPTs = AfterMerge1SPtimes(cID_Inds);
%     CountCents = CountEdges(1:end-1)+5;
    cAllFRs = numel(cClusSPTs)/TotalSampleTime;
    AM1GoodClusFRs(cClusIdInds) = cAllFRs;
    if cAllFRs < 0.01
        continue;
    end
%     [Counts, ~, loc] = histcounts(cClusSPTs,CountEdges);
    
    BlockCounts = histcounts(cClusSPTs, BlockEdgeTimes);
    BlockFRs = BlockCounts(:) ./ diff(BlockEdgeTimes(:));
    
    AM1AllFRs{cClusIdInds} = BlockFRs;
    if min(BlockFRs) < 0.1 && max(BlockFRs) > 1
        % check whether some cluster only have spikes in certain blocks but
        % no spike in others
        AM1NeedCheckInds(cClusIdInds) = true;
        continue;
    end
    if min(BlockFRs) < max(BlockFRs)/3
        AM1NeedCheckInds(cClusIdInds) = true;
        continue;
    end    
end