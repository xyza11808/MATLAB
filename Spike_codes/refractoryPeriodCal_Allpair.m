function AllPairCCGs = refractoryPeriodCal_Allpair(spdataStrc,spclus,winsize,binsize)
% function to calculate the refractory period for given cluster
% inds, if empty cluster inds is given, try to calculate the
% ccg values for all valid clusters
% !!!!!!!!!!!!! currently not working well !!!!!!!!!!
if isempty(spclus)
    PlotclusInds = spdataStrc.UsedClus_IDs;
else
    PlotclusInds = sort(spclus); %
end
if binsize < 1 % in case of input as real time in seconds
    winsize = round(winsize * spdataStrc.sample_rate);
    binsize = round(binsize * spdataStrc.sample_rate);
end

TargetClusInds = ismember(spdataStrc.SpikeClus,PlotclusInds);
sptimeAllUsed = spdataStrc.SpikeTimeSample(TargetClusInds);
spclusAllUsed = spdataStrc.SpikeClus(TargetClusInds);

NumberClusTypes = length(PlotclusInds);
ProcessBatchSize = 6;
TotalBatchNums = ceil(NumberClusTypes/ProcessBatchSize);

AllPairCCGs = cell(NumberClusTypes);
TestCalculateTimes = zeros(NumberClusTypes);
% NumofBatches = length(ProcessBatchInds);
for ccB = 1 : TotalBatchNums %NumberClusTypes
    cClusInds = (ccB - 1) * ProcessBatchSize + 1;
    if (NumberClusTypes - cClusInds) <= ProcessBatchSize
        cRealClusInds = PlotclusInds(cClusInds:end);
        clus2fullInds = ismember(spclusAllUsed,cRealClusInds);
        sptimeAlls = sptimeAllUsed(clus2fullInds);
        spclusAlls = spclusAllUsed(clus2fullInds);
%         ccgs = Spikeccgfun(sptimeAlls,spclusAlls,winsize,binsize,false);
%         [rows, cols, Numbins] = size(ccgs);
%         CellCCG = mat2cell(ccgs,ones(1,rows),ones(1,cols),Numbins);
%         AllPairCCGs(cClusInds:NumberClusTypes,cClusInds:NumberClusTypes) = ...
%             cellfun(@squeeze,CellCCG,'UniformOutput',false);
%         break;
        TestCalculateTimes(cClusInds:NumberClusTypes,cClusInds:NumberClusTypes) = ...
            TestCalculateTimes(cClusInds:NumberClusTypes,cClusInds:NumberClusTypes)+1;
    else
        InloopBatchNum = ceil((NumberClusTypes - cClusInds)/ProcessBatchSize);
        InloopBatch_tempCell = cell(InloopBatchNum,2);
        for cB = 1 : InloopBatchNum
            cB_inds_start = cClusInds + ((cB-1)*ProcessBatchSize);
            cB_inds_end = min(cClusInds + cB*ProcessBatchSize-1, NumberClusTypes);
            cB_Clus_inds = [cB_inds_start:cB_inds_end];
            cB_Clus_realInds = PlotclusInds(cB_Clus_inds);
            clus2fullInds = ismember(spclusAllUsed,cB_Clus_realInds);
            sptimeAlls = sptimeAllUsed(clus2fullInds);
            spclusAlls = spclusAllUsed(clus2fullInds);
%             ccgs = Spikeccgfun(sptimeAlls,spclusAlls,winsize,binsize,false);
%             [rows, cols, Numbins] = size(ccgs);
%             CellCCG = mat2cell(ccgs,ones(1,rows),ones(1,cols),Numbins);
%             InloopBatch_tempCell(cB,:) = {CellCCG, cB_Clus_inds};
            InloopBatch_tempCell(cB,:) = {[],cB_Clus_inds};
        end
        for cB = 1 : InloopBatchNum
%             AllPairCCGs(InloopBatch_tempCell{cB,2},InloopBatch_tempCell{cB,2}) = ...
%                 cellfun(@squeeze,InloopBatch_tempCell{cB,1},'UniformOutput',false);
            TestCalculateTimes(InloopBatch_tempCell{cB,2},InloopBatch_tempCell{cB,2}) = ...
                TestCalculateTimes(InloopBatch_tempCell{cB,2},InloopBatch_tempCell{cB,2}) + 1;
        end
        clearvars InloopBatch_tempCell
    end
end
figure;
imagesc(TestCalculateTimes);
disp(1);
        
        
        
        

