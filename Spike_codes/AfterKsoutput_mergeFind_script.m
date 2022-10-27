FolderPath = pwd;
load(fullfile(FolderPath,'NPClassHandleSaved.mat'));
%%
SpikeClus = readNPY(fullfile(FolderPath, 'spike_clusters.npy'));
SpikeTimeSample = readNPY(fullfile(FolderPath, 'spike_times.npy'));
SpikeAmplitude = single(readNPY(fullfile(FolderPath, 'amplitudes.npy')));
SpikeStrc = loadParamsPy(fullfile(FolderPath, 'params.py'));
SpikeTimes = single(SpikeTimeSample)/SpikeStrc.sample_rate;
ClusMaxChnData = load(fullfile(FolderPath, 'ClusterTypeANDchn.mat'));
ClusTypesAll = ClusMaxChnData.ClusterTypes;
ClusMaxChnAll = ClusMaxChnData.ClusterBestChn;
ksLabels = readtable(fullfile(FolderPath,'cluster_group.tsv'),'FileType','text',...
    'ReadVariableNames',true,'Format','%d%s');
% ClusinfoCell = readcell(fullfile(FolderPath,'cluster_info.csv'));
% ClusterLabels = ClusinfoCell(2:end,4);
% GoodClusLabels = cellfun(@(x) strcmpi(x,'good'),ClusterLabels);
% GoodClusIDs = ClusTypesAll(GoodClusLabels);
% GoodClusMaxChn = ClusMaxChnAll(GoodClusLabels);
% GoodClusNums = length(GoodClusIDs);

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
BlockEdgeTimes = [TaskStartTime; AfterBlockSWTrOnTime+1];
%%
ClusTemplate = readNPY(fullfile(FolderPath,'templates.npy'));
WhiteningMtxInv = readNPY(fullfile(FolderPath,'whitening_mat_inv.npy'));
TempMaxChn = readNPY(fullfile(FolderPath,'templates_maxChn.npy'));
% unwhiten all the templates
tempsUnW = zeros(size(ClusTemplate));
for t = 1:size(ClusTemplate,1)
    tempsUnW(t,:,:) = squeeze(ClusTemplate(t,:,:))*WhiteningMtxInv;
end
% UsedtempsUnW = tempsUnW(ClusTypesAll+1,:,:);
% GoodClusWaveShape = UsedtempsUnW(GoodClusLabels,:,:);

%%

[ClusNeedCheckInds,GoodClusWaveShape,GoodClusMaxChn,GoodClusIDs,GoodClusFRs,AllFRs,ClusTypesAll] = locateNeedCheckClus(SpikeClus,...
    SpikeTimeSample,SpikeStrc,...
    tempsUnW,TempMaxChn-1,ksLabels,BlockEdgeTimes,TotalSampleTime);

% ClusNeedCheckInds = false(GoodClusNums,1);
% GoodClusFRs = zeros(GoodClusNums,1);
% AllFRs = cell(GoodClusNums,1);
% for cClusIdInds = 1 : GoodClusNums
%     cClusID = GoodClusIDs(cClusIdInds);
%     cID_Inds = SpikeClus == cClusID;
%     cClusSPTs = SpikeTimes(cID_Inds);
% %     CountEdges = [0:10:TotalSampleTime,TotalSampleTime];
% %     CountCents = CountEdges(1:end-1)+5;
%     OverAllFR = numel(cClusSPTs)/TotalSampleTime;
%     GoodClusFRs(cClusIdInds) = OverAllFR;
%     if OverAllFR < 0.01
%         continue;
%     end
% 
%     BlockCounts = histcounts(cClusSPTs, BlockEdgeTimes);
%     BlockFRs = BlockCounts(:) ./ diff(BlockEdgeTimes(:));
% %     for cB = 1 : BlockSectionInfo.NumBlocks
% %         if cB == 1
% %             cB_StartEnd = [TaskStartTime, AfterBlockSWTrOnTime(cB)];
% %         else
% %             cB_StartEnd = [AfterBlockSWTrOnTime(cB-1)+1,AfterBlockSWTrOnTime(cB)];
% %         end
% %         cBFR = cClusSPTs(cClusSPTs >= cB_StartEnd(1) & cClusSPTs < cB_StartEnd(2));
% %         BlockFRs(cB) = numel(cBFR)/(diff(cB_StartEnd));
% %     end
%     AllFRs{cClusIdInds} = BlockFRs;
%     if min(BlockFRs) < 0.1 && max(BlockFRs) > 1
%         % check whether some cluster only have spikes in certain blocks but
%         % no spike in others
%         ClusNeedCheckInds(cClusIdInds) = true;
%         continue;
%     end
%     if min(BlockFRs) < max(BlockFRs)/3
%         ClusNeedCheckInds(cClusIdInds) = true;
%         continue;
%     end    
% end

%% first time merge check ###################################################
[CheckedID_targetIDs,goodClus_Ismerged] = findMergeFun(GoodClusIDs, GoodClusMaxChn, ClusNeedCheckInds,...
    GoodClusWaveShape,GoodClusFRs,...
    SpikeTimes,SpikeClus);

% goodClus_Ismerged = zeros(GoodClusNums,1);
% MergeOpInds = 1;
% CheckedID_targetIDs = zeros(NeedCheckClusNums, 1);
% for cCheckClus = 1 : NeedCheckClusNums
% %     cCheckClus = 3;
% %
%     cCheckClusID = NeedCheckClusIDs(cCheckClus);
%     cCheckClusMaxChn = NeedCheckClusMaxChn(cCheckClus);
%     if goodClus_Ismerged(GoodClusIDs == cCheckClusID) > 0
% %         continue;
%     end
%     WaveLen = size(GoodClusWaveShape,2);
%     CheckClusWaveShape = squeeze(GoodClusWaveShape(GoodClusIDs == cCheckClusID,:,cCheckClusMaxChn+1));
%     if cCheckClusMaxChn < 1
%         CheckClus_preWaveShap = rand(1,WaveLen);
%         CheckClus_afterWaveShap = squeeze(GoodClusWaveShape(GoodClusIDs == cCheckClusID,:,cCheckClusMaxChn+2));
%     elseif cCheckClusMaxChn+2 > 383
%         CheckClus_preWaveShap = squeeze(GoodClusWaveShape(GoodClusIDs == cCheckClusID,:,cCheckClusMaxChn));
%         CheckClus_afterWaveShap = rand(1,WaveLen);
%     else
%         CheckClus_preWaveShap = squeeze(GoodClusWaveShape(GoodClusIDs == cCheckClusID,:,cCheckClusMaxChn));
%         CheckClus_afterWaveShap = squeeze(GoodClusWaveShape(GoodClusIDs == cCheckClusID,:,cCheckClusMaxChn+2));
%     end
%     % only same channel clusters will be checked
%     SameMaxChn_clusGoodInds = (ismember(abs(GoodClusMaxChn - cCheckClusMaxChn),[0,2])  & ...
%         GoodClusIDs ~= cCheckClusID & GoodClusFRs > 0.01 & goodClus_Ismerged == 0);
%     clusGoodSearchInds = find(SameMaxChn_clusGoodInds);
%     SameMaxChn_clusIDs = GoodClusIDs(SameMaxChn_clusGoodInds);
%     SameMaxChn_WaveDatas = GoodClusWaveShape(clusGoodSearchInds,:,:);
%     NumSameChnClus = numel(clusGoodSearchInds);
%     %
%     if NumSameChnClus > 0
%         SameMaxChn_Chns = [cCheckClusMaxChn;GoodClusMaxChn(clusGoodSearchInds)];
%         SameMaxChn_Mtx = abs(SameMaxChn_Chns - SameMaxChn_Chns');
%         SameMaxChnClusWave = zeros(WaveLen,NumSameChnClus);
%         PreMaxChnClusWave = zeros(WaveLen,NumSameChnClus);
%         PostMaxChnClusWave = zeros(WaveLen,NumSameChnClus);
%         for cID = 1 : NumSameChnClus
%             SameMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn+1));
%             if cCheckClusMaxChn < 1
%                 PreMaxChnClusWave(:,cID) = CheckClus_preWaveShap;
%                 PostMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn+2));
%             elseif cCheckClusMaxChn+2 > 383
%                 PreMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn));
%                 PostMaxChnClusWave(:,cID) = CheckClus_afterWaveShap;
%             else
%                 PreMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn));
%                 PostMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn+2));
%             end
%         end
%         corrs = corrcoef([CheckClusWaveShape',SameMaxChnClusWave]);
% %         corrs = corrs - eye(size(corrs));
%         preCorrs = corrcoef([CheckClus_preWaveShap',PreMaxChnClusWave]);
% %         preCorrs = preCorrs - eye(size(preCorrs));
%         postCorrs = corrcoef([CheckClus_afterWaveShap',PostMaxChnClusWave]);
% %         postCorrs = postCorrs - eye(size(postCorrs));
%         
%         AllCheckClusters = [cCheckClusID;SameMaxChn_clusIDs(:)];
%         CheckClusInds = ismember(SpikeClus, AllCheckClusters);
%         AllCheckClusSP = SpikeTimes(CheckClusInds);
%         AllCheckClusIDs = SpikeClus(CheckClusInds);
%         Checkcorrelograms = Spikeccgfun(AllCheckClusSP,AllCheckClusIDs,...
%             0.4,0.002,false,AllCheckClusters);
%         RefracBin = RefracTimeCal(Checkcorrelograms,20);
%         % only the first col will be checked, only check whether current ID
%         % needs merge
% %         Cond1 = RefracBin(:,1) >= 5 & (RefracBin(1,:) >= 5)' & corrs(:,1) > 0.9;
% %         Cond2 = corrs(:,1) > 0.9 & preCorrs(:,1) > 0.9 & postCorrs(:,1) > 0.9;
% %         MergeInds = find( (Cond1 | Cond2)...
% %             & SameMaxChn_Mtx(:,1) < 3); % in case of a single-direction inhibition effect
% %         if ~isempty(MergeInds)
% %             MtxInds = unique([MergeRow;MergeCol]);
% %             CorrIndex = sub2ind(size(corrs),MergeRow,MergeCol);
% %             AllMergeInds = AllCheckClusters(MtxInds);
% %             goodClus_Ismerged(ismember(GoodClusIDs,AllMergeInds)) = MergeOpInds;
% %             fprintf('Merge Cluster IDs:\n');
% %             disp(AllMergeInds');
% %             disp(corrs(CorrIndex)');
% %             fprintf('In operation %d:\n',MergeOpInds);
% %             MergeOpInds = MergeOpInds + 1;
% %         end
% %
%         refracCond1 = tril(RefracBin,-1) >= 5 & (triu(RefracBin,1) >= 5)'...
%             & tril(SameMaxChn_Mtx,-1) < 3;
%         if RefracBin(1,1) > 4
%             SameWaveShapeCond2 = tril(corrs,-1) > 0.95 & (tril(preCorrs,-1) > 0.90 & tril(postCorrs,-1) > 0.90) ...
%                 & RefracBin == -1;
%         else
%             SameWaveShapeCond2 = tril(corrs,-1) > 0.95 & (tril(preCorrs,-1) > 0.90 & tril(postCorrs,-1) > 0.90);
%         end
%         FinalCheckMtx = refracCond1 | SameWaveShapeCond2;
%         FinalCheckMtx(2:end,2:end) = false; % only the check Cluster ID related IDs were merged
%         [MergeRow,MergeCol] = find(FinalCheckMtx); % in case of a single-direction inhibition effect
%         if ~isempty(MergeRow)
%             MtxInds = unique([MergeRow;MergeCol]);
%             CorrIndex = sub2ind(size(corrs),MergeRow,MergeCol);
%             AllMergeInds = AllCheckClusters(MtxInds);
%             CheckedID_targetIDs(cCheckClus) = MergeOpInds;
%             goodClus_Ismerged(ismember(GoodClusIDs,AllMergeInds)) = MergeOpInds;
%             fprintf('Merge Cluster IDs:\n');
%             disp(AllMergeInds');
%             disp(corrs(CorrIndex)');
%             fprintf('In operation %d:\n',MergeOpInds);
%             MergeOpInds = MergeOpInds + 1;
%         end
%         
%     end
% %
% end
%%
if MergeOpInds == 1
    fprintf('No merge operation is needed in current session.\n');
end

%% merge the found clusters that need further processing
NeedCheckClusIDs = GoodClusIDs(ClusNeedCheckInds);
NeedCheckClusMaxChn = GoodClusMaxChn(ClusNeedCheckInds);
NeedCheckClusNums = length(NeedCheckClusIDs);

CurrentMergeTimes = max(goodClus_Ismerged);
BeforeMergeMaxClusID = max(ClusTypesAll);
% cMer = 1;
AfterMergeSpikeClus = SpikeClus;
AfterMergeSpikeTimeSample = SpikeTimeSample;
AfterMergeksLabels = ksLabels;
% AfterMergeSpikeAmps = SpikeAmplitude;
AfterMergetempsUnW = [tempsUnW;zeros(CurrentMergeTimes,size(tempsUnW,2),size(tempsUnW,3))];
AfterMergeMaxChn = [TempMaxChn-1;zeros(CurrentMergeTimes,1)];
for cMer = 1 : CurrentMergeTimes
    cMerClus_inds = goodClus_Ismerged == cMer;
    cMerClus_IDs = GoodClusIDs(cMerClus_inds);
    
    cMerTargetID = NeedCheckClusIDs(CheckedID_targetIDs == cMer);
    cMerClus_MaxChn = NeedCheckClusMaxChn(CheckedID_targetIDs == cMer);
    TargetID_waveform = squeeze(tempsUnW(cMerTargetID+1,:,cMerClus_MaxChn+1));
    % assign a new clusterID to all merged IDs
    NewClusIDs = BeforeMergeMaxClusID + cMer;
    Targettemplate = squeeze(tempsUnW(cMerTargetID+1,:,:));
    NumMergeClus = length(cMerClus_IDs);
    
    fprintf('Merge %d of clusters:\n',NumMergeClus);
    disp(cMerClus_IDs');
    fprintf('Into new cluster %d',NewClusIDs);
    
    for cMergClus = 1 : NumMergeClus
        AfterMergeSpikeClus(SpikeClus == cMerClus_IDs(cMergClus)) = NewClusIDs;
        AfterMergetempsUnW(cMerClus_IDs(cMergClus)+1,:,:) = 0;
        cMerClus_waveform = squeeze(tempsUnW(cMerClus_IDs(cMergClus)+1,:,cMerClus_MaxChn+1));
        [xcf,lags,~] = crosscorr(TargetID_waveform,cMerClus_waveform);
        [~,maxinds] = max(xcf);
        AfterMergeSpikeTimeSample(SpikeClus == cMerClus_IDs(cMergClus)) = SpikeTimeSample(SpikeClus == cMerClus_IDs(cMergClus))...
            - lags(maxinds);
%         cIDExcludeInds = AfterMergeksLabels.cluster_id == cMerClus_IDs(cMergClus);
%         AfterMergeksLabels(cIDExcludeInds,:) = [];
%         AfterMergeSpikeAmps(SpikeClus == cMerClus_IDs(cMergClus)) = SpikeAmplitude(SpikeClus == cMerClus_IDs(cMergClus))/ChangeRatio;
    end
    AfterMergeksLabels = [AfterMergeksLabels;{NewClusIDs,'good'}]; %#ok<*AGROW>
    AfterMergetempsUnW(NewClusIDs+1,:,:) = Targettemplate;
    AfterMergeMaxChn(NewClusIDs+1) = cMerClus_MaxChn;
    
end

%% calculate the cluster types after first time merge
[AM1NeedCheckInds,AM1GoodClusWaveShape,AM1GoodClusMaxChn,AM1GoodClus,AM1GoodClusFRs,AM1AllFRs,AM1ClusTypes] = ...
    locateNeedCheckClus(AfterMergeSpikeClus,...
    AfterMergeSpikeTimeSample,SpikeStrc,...
    AfterMergetempsUnW,AfterMergeMaxChn,AfterMergeksLabels,BlockEdgeTimes,TotalSampleTime);

% AfterMerg1ClusTypes = unique(AfterMergeSpikeClus);
% AfterMerg1ClusNum = length(AfterMerg1ClusTypes);

% 
% AM1sedtempsUnW = AfterMergetempsUnW(AfterMerg1ClusTypes+1,:,:);
% AM1sedMaxChn = AfterMergeMaxChn(AfterMerg1ClusTypes+1);
% AM1GoodLabels = cellfun(@(x) strcmpi(x,'good'),AfterMergeksLabels.KSLabel(AfterMerg1ClusTypes+1));
% AM1GoodClusWaveShape = AM1sedtempsUnW(AM1GoodLabels,:,:);
% AM1GoodClus = AfterMerg1ClusTypes(AM1GoodLabels);
% AM1GoodClusMaxChn = AM1sedMaxChn(AM1GoodLabels);
% AM1GoodClusNums = length(AM1GoodClus);
% 
% AM1NeedCheckInds = false(AM1GoodClusNums,1);
% AM1GoodClusFRs = zeros(AM1GoodClusNums,1);
% AM1AllFRs = cell(AM1GoodClusNums,1);
% for cClusIdInds = 1 : AM1GoodClusNums
%     cClusID = AM1GoodClus(cClusIdInds);
%     cID_Inds = AfterMergeSpikeClus == cClusID;
%     cClusSPTs = AfterMerge1SPtimes(cID_Inds);
%     CountCents = CountEdges(1:end-1)+5;
%     cAllFRs = numel(cClusSPTs)/TotalSampleTime;
%     AM1GoodClusFRs(cClusIdInds) = cAllFRs;
%     
%     [Counts, ~, loc] = histcounts(cClusSPTs,CountEdges);
%     
%     BlockCounts = histcounts(cClusSPTs, BlockEdgeTimes);
%     BlockFRs = BlockCounts(:) ./ diff(BlockEdgeTimes(:));
%     
%     AM1AllFRs{cClusIdInds} = BlockFRs;
%     if min(BlockFRs) < 0.1 && max(BlockFRs) > 1
%         % check whether some cluster only have spikes in certain blocks but
%         % no spike in others
%         AM1NeedCheckInds(cClusIdInds) = true;
%         continue;
%     end
%     if min(BlockFRs) < max(BlockFRs)/3
%         AM1NeedCheckInds(cClusIdInds) = true;
%         continue;
%     end    
% end

%% second time merge check  ####################################################################
AfterMerge1SPtimes = double(AfterMergeSpikeTimeSample)/SpikeStrc.sample_rate;
[AM1CheckedID_targetIDs,goodClus_Ismerged2] = findMergeFun(AM1GoodClus, AM1GoodClusMaxChn, AM1NeedCheckInds,...
    AM1GoodClusWaveShape,AM1GoodClusFRs,...
    AfterMerge1SPtimes,AfterMergeSpikeClus);

% AM1NeedCheckClusIDs = AM1GoodClus(AM1NeedCheckInds);
% AM1NeedCheckClusMaxChn = AM1GoodClusMaxChn(AM1NeedCheckInds);
% AM1NeedCheckClusNums = length(AM1NeedCheckClusIDs);
% goodClus_Ismerged2 = zeros(AM1GoodClusNums,1);
% AM1MergeOpInds = 1;
% AM1CheckedID_targetIDs = zeros(AM1NeedCheckClusNums, 1);
% for cCheckClus = 1 : AM1NeedCheckClusNums
% %     cCheckClus = 3;
% %
%     cCheckClusID = AM1NeedCheckClusIDs(cCheckClus);
%     cCheckClusMaxChn = AM1NeedCheckClusMaxChn(cCheckClus);
%     if goodClus_Ismerged2(AM1GoodClus == cCheckClusID) > 0
%         continue;
%     end
%     WaveLen = size(AM1GoodClusWaveShape,2);
%     CheckClusWaveShape = squeeze(AM1GoodClusWaveShape(AM1GoodClus == cCheckClusID,:,cCheckClusMaxChn+1));
%     if cCheckClusMaxChn < 1
%         CheckClus_preWaveShap = rand(1,WaveLen);
%         CheckClus_afterWaveShap = squeeze(AM1GoodClusWaveShape(AM1GoodClus == cCheckClusID,:,cCheckClusMaxChn+2));
%     elseif cCheckClusMaxChn+2 > 383
%         CheckClus_preWaveShap = squeeze(AM1GoodClusWaveShape(AM1GoodClus == cCheckClusID,:,cCheckClusMaxChn));
%         CheckClus_afterWaveShap = rand(1,WaveLen);
%     else
%         CheckClus_preWaveShap = squeeze(AM1GoodClusWaveShape(AM1GoodClus == cCheckClusID,:,cCheckClusMaxChn));
%         CheckClus_afterWaveShap = squeeze(AM1GoodClusWaveShape(AM1GoodClus == cCheckClusID,:,cCheckClusMaxChn+2));
%     end
%     % only same channel clusters will be checked
%     SameMaxChn_clusGoodInds = (ismember(abs(AM1GoodClusMaxChn - cCheckClusMaxChn),[0,2])  & ...
%         AM1GoodClus ~= cCheckClusID & AM1GoodClusFRs > 0.01 & goodClus_Ismerged2 == 0);
%     clusGoodSearchInds = find(SameMaxChn_clusGoodInds);
%     SameMaxChn_clusIDs = AM1GoodClus(SameMaxChn_clusGoodInds);
%     SameMaxChn_WaveDatas = AM1GoodClusWaveShape(clusGoodSearchInds,:,:);
%     NumSameChnClus = numel(clusGoodSearchInds);
%     %
%     if NumSameChnClus > 0
%         SameMaxChn_Chns = [cCheckClusMaxChn;AM1GoodClusMaxChn(clusGoodSearchInds)];
%         SameMaxChn_Mtx = abs(SameMaxChn_Chns - SameMaxChn_Chns');
%         SameMaxChnClusWave = zeros(WaveLen,NumSameChnClus);
%         PreMaxChnClusWave = zeros(WaveLen,NumSameChnClus);
%         PostMaxChnClusWave = zeros(WaveLen,NumSameChnClus);
%         for cID = 1 : NumSameChnClus
%             SameMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn+1));
%             if cCheckClusMaxChn < 1
%                 PreMaxChnClusWave(:,cID) = CheckClus_preWaveShap;
%                 PostMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn+2));
%             elseif cCheckClusMaxChn+2 > 383
%                 PreMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn));
%                 PostMaxChnClusWave(:,cID) = CheckClus_afterWaveShap;
%             else
%                 PreMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn));
%                 PostMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn+2));
%             end
%         end
%         corrs = corrcoef([CheckClusWaveShape',SameMaxChnClusWave]);
% %         corrs = corrs - eye(size(corrs));
%         preCorrs = corrcoef([CheckClus_preWaveShap',PreMaxChnClusWave]);
% %         preCorrs = preCorrs - eye(size(preCorrs));
%         postCorrs = corrcoef([CheckClus_afterWaveShap',PostMaxChnClusWave]);
% %         postCorrs = postCorrs - eye(size(postCorrs));
%         
%         AllCheckClusters = [cCheckClusID;SameMaxChn_clusIDs(:)];
%         CheckClusInds = ismember(AfterMergeSpikeClus, AllCheckClusters);
%         AllCheckClusSP = AfterMerge1SPtimes(CheckClusInds);
%         AllCheckClusIDs = AfterMergeSpikeClus(CheckClusInds);
%         Checkcorrelograms = Spikeccgfun(AllCheckClusSP,AllCheckClusIDs,...
%             0.4,0.002,false,AllCheckClusters);
%         RefracBin = RefracTimeCal(Checkcorrelograms,20);
%         % only the first col will be checked, only check whether current ID
%         % needs merge
% %         Cond1 = RefracBin(:,1) >= 5 & (RefracBin(1,:) >= 5)' & corrs(:,1) > 0.9;
% %         Cond2 = corrs(:,1) > 0.9 & preCorrs(:,1) > 0.9 & postCorrs(:,1) > 0.9;
% %         MergeInds = find( (Cond1 | Cond2)...
% %             & SameMaxChn_Mtx(:,1) < 3); % in case of a single-direction inhibition effect
% %         if ~isempty(MergeInds)
% %             MtxInds = unique([MergeRow;MergeCol]);
% %             CorrIndex = sub2ind(size(corrs),MergeRow,MergeCol);
% %             AllMergeInds = AllCheckClusters(MtxInds);
% %             goodClus_Ismerged(ismember(GoodClusIDs,AllMergeInds)) = MergeOpInds;
% %             fprintf('Merge Cluster IDs:\n');
% %             disp(AllMergeInds');
% %             disp(corrs(CorrIndex)');
% %             fprintf('In operation %d:\n',MergeOpInds);
% %             MergeOpInds = MergeOpInds + 1;
% %         end
% %
%         refracCond1 = tril(RefracBin,-1) >= 5 & (triu(RefracBin,1) >= 5)'...
%             & tril(SameMaxChn_Mtx,-1) < 3;
%         if RefracBin(1,1) > 4
%             SameWaveShapeCond2 = tril(corrs,-1) > 0.95 & (tril(preCorrs,-1) > 0.90 & tril(postCorrs,-1) > 0.90) ...
%                 & RefracBin == -1;
%         else
%             SameWaveShapeCond2 = tril(corrs,-1) > 0.95 & (tril(preCorrs,-1) > 0.90 & tril(postCorrs,-1) > 0.90);
%         end
%         FinalCheckMtx = refracCond1 | SameWaveShapeCond2;
%         FinalCheckMtx(2:end,2:end) = false; % only the check Cluster ID related IDs were merged
%         [MergeRow,MergeCol] = find(FinalCheckMtx); % in case of a single-direction inhibition effect
%         if ~isempty(MergeRow)
%             MtxInds = unique([MergeRow;MergeCol]);
%             CorrIndex = sub2ind(size(corrs),MergeRow,MergeCol);
%             AllMergeInds = AllCheckClusters(MtxInds);
%             AM1CheckedID_targetIDs(cCheckClus) = AM1MergeOpInds;
%             goodClus_Ismerged2(ismember(AM1GoodClus,AllMergeInds)) = AM1MergeOpInds;
%             fprintf('Merge Cluster IDs:\n');
%             disp(AllMergeInds');
%             disp(corrs(CorrIndex)');
%             fprintf('In operation %d:\n',AM1MergeOpInds);
%             AM1MergeOpInds = AM1MergeOpInds + 1;
%         end
%         
%     end
% 
% end
%% performing second time merge
AM1NeedCheckClusIDs = AM1GoodClus(AM1NeedCheckInds);
AM1NeedCheckClusMaxChn = AM1GoodClusMaxChn(AM1NeedCheckInds);
AM1NeedCheckClusNums = length(AM1NeedCheckClusIDs);

CurrentMergeTimes = max(goodClus_Ismerged2);
BeforeMergeMaxClusID = max(AM1ClusTypes);
% cMer = 1;
AM2SpikeClus = AfterMergeSpikeClus;
AM2SpikeTimeSample = AfterMergeSpikeTimeSample;
AM2ksLabels = AfterMergeksLabels;
% AfterMergeSpikeAmps = SpikeAmplitude;
AM2tempsUnW = [AfterMergetempsUnW;zeros(CurrentMergeTimes,size(AfterMergetempsUnW,2),size(AfterMergetempsUnW,3))];
AM2MaxChn = [AfterMergeMaxChn;zeros(CurrentMergeTimes,1)];
for cMer = 1 : CurrentMergeTimes
    cMerClus_inds = goodClus_Ismerged2 == cMer;
    cMerClus_IDs = AM1GoodClus(cMerClus_inds);
    
    cMerTargetID = AM1NeedCheckClusIDs(AM1CheckedID_targetIDs == cMer);
    cMerClus_MaxChn = AM1NeedCheckClusMaxChn(AM1CheckedID_targetIDs == cMer);
    TargetID_waveform = squeeze(AfterMergetempsUnW(cMerTargetID+1,:,cMerClus_MaxChn+1));
    % assign a new clusterID to all merged IDs
    NewClusIDs = BeforeMergeMaxClusID + cMer;
    Targettemplate = squeeze(AfterMergetempsUnW(cMerTargetID+1,:,:));
    NumMergeClus = length(cMerClus_IDs);
    fprintf('Merge %d of clusters:\n',NumMergeClus);
    disp(cMerClus_IDs');
    fprintf('Into new cluster %d.\n',NewClusIDs);
    for cMergClus = 1 : NumMergeClus
        OldClusInds = AfterMergeSpikeClus == cMerClus_IDs(cMergClus);
        AfterMergeSpikeClus(OldClusInds) = NewClusIDs;
        AfterMergetempsUnW(cMerClus_IDs(cMergClus)+1,:,:) = 0;
        cMerClus_waveform = squeeze(AfterMergetempsUnW(cMerClus_IDs(cMergClus)+1,:,cMerClus_MaxChn+1));
        [xcf,lags,~] = crosscorr(TargetID_waveform,cMerClus_waveform);
        [~,maxinds] = max(xcf);
        
        AM2SpikeTimeSample(OldClusInds) = AfterMergeSpikeTimeSample(OldClusInds)...
            - lags(maxinds);
%         cIDExcludeInds = AfterMergeksLabels.cluster_id == cMerClus_IDs(cMergClus);
%         AfterMergeksLabels(cIDExcludeInds,:) = [];
%         AfterMergeSpikeAmps(SpikeClus == cMerClus_IDs(cMergClus)) = SpikeAmplitude(SpikeClus == cMerClus_IDs(cMergClus))/ChangeRatio;
    end
    AM2ksLabels = [AM2ksLabels;{NewClusIDs,'good'}]; %#ok<*AGROW>
    AM2tempsUnW(NewClusIDs+1,:,:) = Targettemplate;
    AM2MaxChn(NewClusIDs+1) = cMerClus_MaxChn;
    
end




