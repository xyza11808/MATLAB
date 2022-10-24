FolderPath = pwd;
load(fullfile(FolderPath,'NPClassHandleSaved.mat'));
%%
SpikeClus = readNPY(fullfile(FolderPath, 'spike_clusters.npy'));
SpikeTimeSample = readNPY(fullfile(FolderPath, 'spike_times.npy'));
SpikeStrc = loadParamsPy(fullfile(FolderPath, 'params.py'));
SpikeTimes = single(SpikeTimeSample)/SpikeStrc.sample_rate;
ClusMaxChnData = load(fullfile(FolderPath, 'ClusterTypeANDchn.mat'));
ClusTypesAll = ClusMaxChnData.ClusterTypes;
ClusMaxChnAll = ClusMaxChnData.ClusterBestChn;

ClusinfoCell = readcell(fullfile(FolderPath,'cluster_info.csv'));
ClusterLabels = ClusinfoCell(2:end,4);
GoodClusLabels = cellfun(@(x) strcmpi(x,'good'),ClusterLabels);
GoodClusIDs = ClusTypesAll(GoodClusLabels);
GoodClusMaxChn = ClusMaxChnAll(GoodClusLabels);
GoodClusNums = length(GoodClusIDs);

TotalSampleTime = single(ProbNPSess.Numsamp)/SpikeStrc.sample_rate;


ProbNPSess.CurrentSessInds = strcmpi('Task',ProbNPSess.SessTypeStrs);
TaskTrigOnTimes = ProbNPSess.UsedTrigOnTime{ProbNPSess.CurrentSessInds};
BlockSectionInfo = Bev2blockinfoFun(behavResults);

BlockEndsInds = BlockSectionInfo.BlockTrScales(:,2); % where block tr ends
if BlockEndsInds(end) ~= numel(TaskTrigOnTimes)
    AfterBlockSWTrOnTime = TaskTrigOnTimes(BlockEndsInds+1);
else
    AfterBlockSWTrOnTime = [TaskTrigOnTimes(BlockEndsInds(1:end-1) + 1); TaskTrigOnTimes(end)+10];
end
TaskStartTime = TaskTrigOnTimes(1);
TaskEndsTime = TaskTrigOnTimes(end)+10;


BlockSectionInfo = Bev2blockinfoFun(behavResults);
ClusNeedCheckInds = false(GoodClusNums,1);
GoodClusFRs = zeros(GoodClusNums,1);
AllFRs = cell(GoodClusNums,1);
for cClusIdInds = 1 : GoodClusNums
    cClusID = GoodClusIDs(cClusIdInds);
    cID_Inds = SpikeClus == cClusID;
    cClusSPTs = SpikeTimes(cID_Inds);
    CountEdges = [0:10:TotalSampleTime,TotalSampleTime];
    CountCents = CountEdges(1:end-1)+5;
    OverAllFR = numel(cClusSPTs)/TotalSampleTime;
    GoodClusFRs(cClusIdInds) = OverAllFR;
%     if OverAllFR < 0.01
%         continue;
%     end
    [Counts, ~, loc] = histcounts(cClusSPTs,CountEdges);
    
%     BlockFRs = zeros(BlockSectionInfo.NumBlocks, 1);
    BlockEdgeTimes = [TaskStartTime; AfterBlockSWTrOnTime+1];
    BlockCounts = histcounts(cClusSPTs, BlockEdgeTimes);
    BlockFRs = BlockCounts(:) ./ diff(BlockEdgeTimes(:));
%     for cB = 1 : BlockSectionInfo.NumBlocks
%         if cB == 1
%             cB_StartEnd = [TaskStartTime, AfterBlockSWTrOnTime(cB)];
%         else
%             cB_StartEnd = [AfterBlockSWTrOnTime(cB-1)+1,AfterBlockSWTrOnTime(cB)];
%         end
%         cBFR = cClusSPTs(cClusSPTs >= cB_StartEnd(1) & cClusSPTs < cB_StartEnd(2));
%         BlockFRs(cB) = numel(cBFR)/(diff(cB_StartEnd));
%     end
    AllFRs{cClusIdInds} = BlockFRs;
    if min(BlockFRs) < 0.1 && max(BlockFRs) > 1
        % check whether some cluster only have spikes in certain blocks but
        % no spike in others
        ClusNeedCheckInds(cClusIdInds) = true;
        continue;
    end
    if min(BlockFRs) < max(BlockFRs)/3
        ClusNeedCheckInds(cClusIdInds) = true;
        continue;
    end    
end

%%
NeedCheckClusIDs = GoodClusIDs(ClusNeedCheckInds);
NeedCheckClusMaxChn = GoodClusMaxChn(ClusNeedCheckInds);
NeedCheckClusNums = length(NeedCheckClusIDs);
% for cCheckClus = 1 : NeedCheckClusIDs
    cCheckClus = 3;
    cCheckClusID = NeedCheckClusIDs(cCheckClus);
    cCheckClusMaxChn = NeedCheckClusMaxChn(cCheckClus);
    
    % only same channel clusters will be checked
    SameMaxChn_clusGoodInds = (ismember(abs(GoodClusMaxChn - cCheckClusMaxChn),[0,2])  & ...
        GoodClusIDs ~= cCheckClusID & GoodClusFRs > 0.01);
    SameMaxChn_clusIDs = GoodClusIDs(SameMaxChn_clusGoodInds);
    
    NumSameChnClus = numel(SameMaxChn_clusIDs);
 %%   
    if NumSameChnClus > 0
        AllCheckClusters = [cCheckClusID;SameMaxChn_clusIDs(:)];
        CheckClusInds = ismember(SpikeClus, AllCheckClusters);
        AllCheckClusSP = SpikeTimes(CheckClusInds);
        AllCheckClusIDs = SpikeClus(CheckClusInds);
        Checkcorrelograms = Spikeccgfun(AllCheckClusSP,AllCheckClusIDs,...
            0.4,0.002,false,AllCheckClusters);
        
        
    end

% end
    
        
        
        
        

