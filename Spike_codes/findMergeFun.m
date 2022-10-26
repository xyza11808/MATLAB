function [AM1CheckedID_targetIDs,goodClus_Ismerged2] = findMergeFun(AM1GoodClus, AM1GoodClusMaxChn, AM1NeedCheckInds,...
    AM1GoodClusWaveShape,AM1GoodClusFRs,...
    AfterMerge1SPtimes,AfterMergeSpikeClus)
AM1GoodClusNums = numel(AM1GoodClus);
AM1NeedCheckClusIDs = AM1GoodClus(AM1NeedCheckInds);
AM1NeedCheckClusMaxChn = AM1GoodClusMaxChn(AM1NeedCheckInds);
AM1NeedCheckClusNums = length(AM1NeedCheckClusIDs);
goodClus_Ismerged2 = zeros(AM1GoodClusNums,1);
AM1MergeOpInds = 1;
AM1CheckedID_targetIDs = zeros(AM1NeedCheckClusNums, 1);
for cCheckClus = 1 : AM1NeedCheckClusNums
%     cCheckClus = 3;
%
    cCheckClusID = AM1NeedCheckClusIDs(cCheckClus);
    cCheckClusMaxChn = AM1NeedCheckClusMaxChn(cCheckClus);
    if goodClus_Ismerged2(AM1GoodClus == cCheckClusID) > 0
        continue;
    end
    WaveLen = size(AM1GoodClusWaveShape,2);
    CheckClusWaveShape = squeeze(AM1GoodClusWaveShape(AM1GoodClus == cCheckClusID,:,cCheckClusMaxChn+1));
    if cCheckClusMaxChn < 1
        CheckClus_preWaveShap = rand(1,WaveLen);
        CheckClus_afterWaveShap = squeeze(AM1GoodClusWaveShape(AM1GoodClus == cCheckClusID,:,cCheckClusMaxChn+2));
    elseif cCheckClusMaxChn+2 > 383
        CheckClus_preWaveShap = squeeze(AM1GoodClusWaveShape(AM1GoodClus == cCheckClusID,:,cCheckClusMaxChn));
        CheckClus_afterWaveShap = rand(1,WaveLen);
    else
        CheckClus_preWaveShap = squeeze(AM1GoodClusWaveShape(AM1GoodClus == cCheckClusID,:,cCheckClusMaxChn));
        CheckClus_afterWaveShap = squeeze(AM1GoodClusWaveShape(AM1GoodClus == cCheckClusID,:,cCheckClusMaxChn+2));
    end
    % only same channel clusters will be checked
    SameMaxChn_clusGoodInds = (ismember(abs(AM1GoodClusMaxChn - cCheckClusMaxChn),[0,2])  & ...
        AM1GoodClus ~= cCheckClusID & AM1GoodClusFRs > 0.01 & goodClus_Ismerged2 == 0);
    clusGoodSearchInds = find(SameMaxChn_clusGoodInds);
    SameMaxChn_clusIDs = AM1GoodClus(SameMaxChn_clusGoodInds);
    SameMaxChn_WaveDatas = AM1GoodClusWaveShape(clusGoodSearchInds,:,:);
    NumSameChnClus = numel(clusGoodSearchInds);
    %
    if NumSameChnClus > 0
        SameMaxChn_Chns = [cCheckClusMaxChn;AM1GoodClusMaxChn(clusGoodSearchInds)];
        SameMaxChn_Mtx = abs(SameMaxChn_Chns - SameMaxChn_Chns');
        SameMaxChnClusWave = zeros(WaveLen,NumSameChnClus);
        PreMaxChnClusWave = zeros(WaveLen,NumSameChnClus);
        PostMaxChnClusWave = zeros(WaveLen,NumSameChnClus);
        for cID = 1 : NumSameChnClus
            SameMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn+1));
            if cCheckClusMaxChn < 1
                PreMaxChnClusWave(:,cID) = CheckClus_preWaveShap;
                PostMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn+2));
            elseif cCheckClusMaxChn+2 > 383
                PreMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn));
                PostMaxChnClusWave(:,cID) = CheckClus_afterWaveShap;
            else
                PreMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn));
                PostMaxChnClusWave(:,cID) = squeeze(SameMaxChn_WaveDatas(cID,:,cCheckClusMaxChn+2));
            end
        end
        corrs = corrcoef([CheckClusWaveShape',SameMaxChnClusWave]);
%         corrs = corrs - eye(size(corrs));
        preCorrs = corrcoef([CheckClus_preWaveShap',PreMaxChnClusWave]);
%         preCorrs = preCorrs - eye(size(preCorrs));
        postCorrs = corrcoef([CheckClus_afterWaveShap',PostMaxChnClusWave]);
%         postCorrs = postCorrs - eye(size(postCorrs));
        
        AllCheckClusters = [cCheckClusID;SameMaxChn_clusIDs(:)];
        CheckClusInds = ismember(AfterMergeSpikeClus, AllCheckClusters);
        AllCheckClusSP = AfterMerge1SPtimes(CheckClusInds);
        AllCheckClusIDs = AfterMergeSpikeClus(CheckClusInds);
        Checkcorrelograms = Spikeccgfun(AllCheckClusSP,AllCheckClusIDs,...
            0.4,0.002,false,AllCheckClusters);
        RefracBin = RefracTimeCal(Checkcorrelograms,20);
        % only the first col will be checked, only check whether current ID
        % needs merge
%         Cond1 = RefracBin(:,1) >= 5 & (RefracBin(1,:) >= 5)' & corrs(:,1) > 0.9;
%         Cond2 = corrs(:,1) > 0.9 & preCorrs(:,1) > 0.9 & postCorrs(:,1) > 0.9;
%         MergeInds = find( (Cond1 | Cond2)...
%             & SameMaxChn_Mtx(:,1) < 3); % in case of a single-direction inhibition effect
%         if ~isempty(MergeInds)
%             MtxInds = unique([MergeRow;MergeCol]);
%             CorrIndex = sub2ind(size(corrs),MergeRow,MergeCol);
%             AllMergeInds = AllCheckClusters(MtxInds);
%             goodClus_Ismerged(ismember(GoodClusIDs,AllMergeInds)) = MergeOpInds;
%             fprintf('Merge Cluster IDs:\n');
%             disp(AllMergeInds');
%             disp(corrs(CorrIndex)');
%             fprintf('In operation %d:\n',MergeOpInds);
%             MergeOpInds = MergeOpInds + 1;
%         end
%
        refracCond1 = tril(RefracBin,-1) >= 5 & (triu(RefracBin,1) >= 5)'...
            & tril(SameMaxChn_Mtx,-1) < 3;
        if RefracBin(1,1) > 4
            SameWaveShapeCond2 = tril(corrs,-1) > 0.95 & (tril(preCorrs,-1) > 0.90 & tril(postCorrs,-1) > 0.90) ...
                & RefracBin == -1;
        else
            SameWaveShapeCond2 = tril(corrs,-1) > 0.95 & (tril(preCorrs,-1) > 0.90 & tril(postCorrs,-1) > 0.90);
        end
        FinalCheckMtx = refracCond1 | SameWaveShapeCond2;
        FinalCheckMtx(2:end,2:end) = false; % only the check Cluster ID related IDs were merged
        [MergeRow,MergeCol] = find(FinalCheckMtx); % in case of a single-direction inhibition effect
        if ~isempty(MergeRow)
            MtxInds = unique([MergeRow;MergeCol]);
            CorrIndex = sub2ind(size(corrs),MergeRow,MergeCol);
            AllMergeInds = AllCheckClusters(MtxInds);
            AM1CheckedID_targetIDs(cCheckClus) = AM1MergeOpInds;
            goodClus_Ismerged2(ismember(AM1GoodClus,AllMergeInds)) = AM1MergeOpInds;
            fprintf('Merge Cluster IDs:\n');
            disp(AllMergeInds');
            disp(corrs(CorrIndex)');
            fprintf('In operation %d:\n',AM1MergeOpInds);
            AM1MergeOpInds = AM1MergeOpInds + 1;
        end
        
    end

end