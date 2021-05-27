function correlograms = Spikeccgfun(SpikeTimes,SpikeClus,winsize,binsize,isSymmetrize)
% function used to calculate the auto- and cross-correlation histograms
% based on the discription in the book "theoritical neuroscience" page 28

% binsize should be in ms format, as well as the winsize variable
% the spikeTimes is in seconds format
if ~exist('isSymmetrize','var') || isempty(isSymmetrize)
    IsSymOuts = false;
else
    IsSymOuts = isSymmetrize;
end
if ~islogical(IsSymOuts)
   error('The input symmetrize should be a logical values'); 
end
if numel(SpikeTimes) ~= numel(SpikeClus)
   error('The number of spike times and spikeclusters should be the same.'); 
end
SpikeClus = SpikeClus(:);
SpikeClus_inds = zeros(numel(SpikeClus),1);
ClusterType = unique(SpikeClus);
NumClus = length(ClusterType);
for cClus = 1 : NumClus
    SpikeClus_inds(SpikeClus == ClusterType(cClus)) = cClus; % find the cluster Inds for each cluster
end
win_length = floor(0.5*winsize/binsize)*2+1;
correlograms = zeros(NumClus,NumClus,floor(win_length/2)+1); % only half of the symmetrize window
ccgdims = size(correlograms);
% Shift between the two copies of the spike trains.
spshifts = 1;
TotalSPNums = numel(SpikeTimes);
spmasks = true(TotalSPNums,1);
while any(spmasks(1:TotalSPNums-spshifts))
%     disp(sum(spmasks(1:TotalSPNums-spshifts)));
    spike_time_diff = SpikeTimes((spshifts+1):TotalSPNums) - SpikeTimes(1:(TotalSPNums-spshifts));
    
    % convert spike time to bins
    spike_diff_bin = floor(spike_time_diff/binsize); 
   
    % create current shift inds
    cmask_shiftInds = 1:(TotalSPNums-spshifts);
    
    % spikes with no matching spikes are masked
    spmasks(cmask_shiftInds(spike_diff_bin > floor(win_length/2))) = false;
    
    % cache the masked spike delays
    shift_mask_backup = spmasks(1:TotalSPNums-spshifts);
    
    % fetch valid spike bins corresponded cluster inds
    sptimebins = spike_diff_bin(shift_mask_backup);
    
    % found current bin corresponded indices
    former_clusterInds = SpikeClus_inds(1:(TotalSPNums-spshifts));
    
    latter_clusterInds = SpikeClus_inds((1+spshifts):end);
    if max(sptimebins) > (ccgdims(3)-1)
        disp(max(sptimebins));
        error('Somewhere is wrong!');
    end
    AddIndices = sub2ind(ccgdims,former_clusterInds(shift_mask_backup),...
        latter_clusterInds(shift_mask_backup),sptimebins+1);
    
    [Types,Counts] = uniAndcount(AddIndices);
    
    correlograms(Types) = correlograms(Types) + Counts;
    
    spshifts = spshifts + 1;
end
if IsSymOuts
   Fullsizeccg =  zeros(NumClus,NumClus,win_length);
   RevccgInds = (ccgdims(3)):-1:2;
   Fullsizeccg(:,:,1:(ccgdims(3)-1)) = correlograms(:,:,RevccgInds);
   Fullsizeccg(:,:,ccgdims(3):end) = correlograms;
   HalfccgBack = correlograms;
   correlograms = Fullsizeccg;
end
figure;stem(1:size(correlograms,3),squeeze(correlograms(2,2,:)))

% % ccgWinLen = floor(winsize/binsize);
% % % FullccgWinLen = ccgWinLen*2+1;
% % 
% % k = 1;
% % NumclusCounts = cell(NumClus*NumClus,1);
% % ClusInds = zeros(NumClus*NumClus,2);
% % for ccClus = 1 : NumClus
% %     for cccClus = 1 : NumClus
% %         if ccClus == cccClus
% %             % auto-correlation histogram
% %             BinEdges = (0:(ccgWinLen+0.5))*binsize;
% %             BinCentersHalf = BinEdges(1:end-1);
% %             
% %             cInds = ClusterInds{ccClus};
% %             FullSpTimes = SpikeTimes(cInds);    
% %             AllPairSPinterval = [pdist(FullSpTimes),zeros(1,numel(FullSpTimes))]; % caluclate the spike time difference for all pairs, include self
% % %             AllPairSPinterval(AllPairSPinterval < (min(BinEdges)-binsize/2) | AllPairSPinterval > (max(BinEdges)+binsize/2)) = []; % exclude out of time window intervals
% %             Bincounts = histcounts(AllPairSPinterval,BinEdges);
% %             SubBincountsHalf = (Bincounts - ((numel(cInds))^2)*binsize/TotalTimes)/TotalTimes;
% %             SubBincountsHalf(end) = 0;
% %             BinCenters = [(-1)*fliplr(BinCentersHalf(2:end)),BinCentersHalf];
% %             SubBincounts = [fliplr(SubBincountsHalf(2:end)),SubBincountsHalf];
% %         else
% %             BinEdges = ((-ccgWinLen-0.5):(ccgWinLen+0.5))*binsize;
% %             BinCenters = BinEdges(1:end-1) + binsize/2;
% %             c1Inds = ClusterInds{ccClus};
% %             c2Inds = ClusterInds{cccClus};
% %             FullInds = c1Inds | c2Inds;
% %             FullSpTimes = SpikeTimes(FullInds);
% %             AllPairSPinterval = pdist(FullSpTimes); % caluclate the spike time difference for all pairs
% % %             AllPairSPinterval(AllPairSPinterval < (min(BinEdges)-binsize/2) | AllPairSPinterval > (max(BinEdges)+binsize/2)) = []; % exclude out of time window intervals
% %             Bincounts = histcounts(AllPairSPinterval,BinEdges);
% %             Bincounts(1) = 0;
% %             Bincounts(end) = 0;
% %             SubBincounts = (Bincounts - (numel(c1Inds)*numel(c2Inds))*binsize/TotalTimes)/TotalTimes;
% %         end
% %         NumclusCounts{k} = SubBincounts;
% %         ClusInds(k,:) = [ClusterType(ccClus),ClusterType(cccClus)];
% %         k = k + 1;
% %     end
% % end
% % 
% % clusccgStrc.ClusInds = ClusInds;
% % clusccgStrc.ccgCounts = NumclusCounts;
% % clusccgStrc.BinCenters = BinCenters;

        
        
        
        

