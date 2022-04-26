function refractoryPeriodCal_Allpair_fast(spdataStrc,...
    spclus,winsize,binsize,SessPath)
% function to calculate the refractory period for given cluster
% inds, if empty cluster inds is given, try to calculate the
% ccg values for all valid clusters
% This function works well~~~
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



TempDataSavePath = fullfile(SessPath,'CCGDataSaves','CCGAndSPtimesData.mat');
if ~exist(TempDataSavePath,'file')
    % ccgs = Spikeccgfun(sptimeAllUsed,spclusAllUsed,winsize,binsize,false);
    [ccgs, ConnectionWinSPTs] = Spikeccgfun_withSPtimes(sptimeAllUsed,spclusAllUsed,winsize,binsize,false);
    save(TempDataSavePath,'ccgs', 'ConnectionWinSPTs','-v7.3');
    clearvars ccgs ConnectionWinSPTs
end
%%
tic
if numel(PlotclusInds) < 150 % to save memory
    JitterScale = (5/1000) * spdataStrc.sample_rate; % jitter within [-5 5]ms window
    JitterRepeatTimes = 1000;
    SPTrainLen = numel(sptimeAllUsed);
    JitWinSize = round(0.05 * spdataStrc.sample_rate);
    JitterRepeatCCGs = cell(JitterRepeatTimes,1);
    parfor cJ = 1 : JitterRepeatTimes
        SPtimeJitterNum = (rand(SPTrainLen,1)-0.5)*2*JitterScale;
        JitterSPtrain = uint64(double(sptimeAllUsed) + SPtimeJitterNum);
        [JitterSPResort, SortInds] = sort(JitterSPtrain);
        JitterSortCLusInds = spclusAllUsed(SortInds);
    %     Jitccgs = Spikeccgfun(JitterSPResort,JitterSortCLusInds,JitWinSize,binsize,false);
        Jitccgs = Spikeccgfun_mex(JitterSPResort,JitterSortCLusInds,JitWinSize,binsize,false);
        JitterRepeatCCGs{cJ} = uint32(Jitccgs);
    end

    JitDataSizes = size(JitterRepeatCCGs{1});
    JitCCGSummary = zeros(JitDataSizes(1),JitDataSizes(2),4,JitDataSizes(3));
    for cRow = 1 : JitDataSizes(1)
        for cCol = 1 : JitDataSizes(2)
            cJitData = cellfun(@(x) (squeeze(x(cRow,cCol,:)))',JitterRepeatCCGs,'UniformOutput',false);
            cAllJitData = double(cat(1,cJitData{:}));
            cJitCI = prctile(cAllJitData,[1 99]);
            cJitAvg = mean(cAllJitData);
            cJitSD = std(cAllJitData);
            JitCCGSummary(cRow,cCol,:,:) = [cJitAvg;cJitSD;cJitCI];
        end
    end
else
   % batched processing to save memory
   fprintf('Using batched processing to decrease memory usage.\n');
   if exist(fullfile(SessPath,'CCGDataSaves','CCGtempData6.mat'),'file')
       cBStart = 7;
   else
       cBStart = 1;
   end
   BatchSize = 100;
   for cB = cBStart : 10
       fprintf('Processing batch %d...\n',cB);
       JitterScale = (5/1000) * spdataStrc.sample_rate; % jitter within [-5 5]ms window
%         JitterRepeatTimes = 1000;
        SPTrainLen = numel(sptimeAllUsed);
        JitWinSize = round(0.05 * spdataStrc.sample_rate);
        JitterRepeatCCGs = cell(BatchSize,1);
        parfor cJ = 1 : BatchSize
            SPtimeJitterNum = (rand(SPTrainLen,1)-0.5)*2*JitterScale;
            JitterSPtrain = uint64(double(sptimeAllUsed) + SPtimeJitterNum);
            [JitterSPResort, SortInds] = sort(JitterSPtrain);
            JitterSortCLusInds = spclusAllUsed(SortInds);
        %     Jitccgs = Spikeccgfun(JitterSPResort,JitterSortCLusInds,JitWinSize,binsize,false);
            Jitccgs = Spikeccgfun_mex(JitterSPResort,JitterSortCLusInds,JitWinSize,binsize,false);
            JitterRepeatCCGs{cJ} = uint32(Jitccgs);
        end
        
        TempJitFile = fullfile(SessPath,'CCGDataSaves',sprintf('CCGtempData%d.mat',cB));
        save(TempJitFile,'JitterRepeatCCGs','-v7.3'); 
        clearvars JitterRepeatCCGs
        fprintf('Batch %d complete!\n',cB);
   end
   
   delete(gcp('nocreate'));
   AllJitCCGDataCell = cell(10,1);
   for cB = 1 : 10
      cDataFile =  fullfile(SessPath,'CCGDataSaves',sprintf('CCGtempData%d.mat',cB));
      AllJitCCGDataStrc = load(cDataFile);
      AllJitCCGDataCell{cB} = AllJitCCGDataStrc.JitterRepeatCCGs;
      delete(cDataFile);
   end
   JitterRepeatCCGs = cat(1,AllJitCCGDataCell{:});
   clearvars AllJitCCGDataCell AllJitCCGDataStrc
   
   JitDataSizes = size(JitterRepeatCCGs{1});
    JitCCGSummary = zeros(JitDataSizes(1),JitDataSizes(2),4,JitDataSizes(3));
    for cRow = 1 : JitDataSizes(1)
        for cCol = 1 : JitDataSizes(2)
            cJitData = cellfun(@(x) (squeeze(x(cRow,cCol,:)))',JitterRepeatCCGs,'UniformOutput',false);
            cAllJitData = double(cat(1,cJitData{:}));
            cJitCI = prctile(cAllJitData,[1 99]);
            cJitAvg = mean(cAllJitData);
            cJitSD = std(cAllJitData);
            JitCCGSummary(cRow,cCol,:,:) = [cJitAvg;cJitSD;cJitCI];
        end
    end
end

toc;
%%
TempDataSavePath2 = fullfile(SessPath,'CCGDataSaves','JitterCCGData.mat');
save(TempDataSavePath2,'JitterRepeatCCGs','JitCCGSummary','-v7.3');
clearvars JitterRepeatCCGs JitCCGSummary

if isempty(gcp('nocreate'))
    parpool('local',6);
end
fprintf('Calculation complete!\n');
% AllPairCCGs = cell(NumberClusTypes);
% TestCalculateTimes = zeros(NumberClusTypes);
% % NumofBatches = length(ProcessBatchInds);
% for ccB = 1 : TotalBatchNums %NumberClusTypes
%     cClusInds = (ccB - 1) * ProcessBatchSize + 1;
%     if (NumberClusTypes - cClusInds) <= ProcessBatchSize
%         cRealClusInds = PlotclusInds(cClusInds:end);
%         clus2fullInds = ismember(spclusAllUsed,cRealClusInds);
%         sptimeAlls = sptimeAllUsed(clus2fullInds);
%         spclusAlls = spclusAllUsed(clus2fullInds);
% %         ccgs = Spikeccgfun(sptimeAlls,spclusAlls,winsize,binsize,false);
% %         [rows, cols, Numbins] = size(ccgs);
% %         CellCCG = mat2cell(ccgs,ones(1,rows),ones(1,cols),Numbins);
% %         AllPairCCGs(cClusInds:NumberClusTypes,cClusInds:NumberClusTypes) = ...
% %             cellfun(@squeeze,CellCCG,'UniformOutput',false);
% %         break;
%         TestCalculateTimes(cClusInds:NumberClusTypes,cClusInds:NumberClusTypes) = ...
%             TestCalculateTimes(cClusInds:NumberClusTypes,cClusInds:NumberClusTypes)+1;
%     else
%         InloopBatchNum = ceil((NumberClusTypes - cClusInds)/ProcessBatchSize);
%         InloopBatch_tempCell = cell(InloopBatchNum,2);
%         for cB = 1 : InloopBatchNum
%             cB_inds_start = cClusInds + ((cB-1)*ProcessBatchSize);
%             cB_inds_end = min(cClusInds + cB*ProcessBatchSize-1, NumberClusTypes);
%             cB_Clus_inds = [cB_inds_start:cB_inds_end];
%             cB_Clus_realInds = PlotclusInds(cB_Clus_inds);
%             clus2fullInds = ismember(spclusAllUsed,cB_Clus_realInds);
%             sptimeAlls = sptimeAllUsed(clus2fullInds);
%             spclusAlls = spclusAllUsed(clus2fullInds);
% %             ccgs = Spikeccgfun(sptimeAlls,spclusAlls,winsize,binsize,false);
% %             [rows, cols, Numbins] = size(ccgs);
% %             CellCCG = mat2cell(ccgs,ones(1,rows),ones(1,cols),Numbins);
% %             InloopBatch_tempCell(cB,:) = {CellCCG, cB_Clus_inds};
%             InloopBatch_tempCell(cB,:) = {[],cB_Clus_inds};
%         end
%         for cB = 1 : InloopBatchNum
% %             AllPairCCGs(InloopBatch_tempCell{cB,2},InloopBatch_tempCell{cB,2}) = ...
% %                 cellfun(@squeeze,InloopBatch_tempCell{cB,1},'UniformOutput',false);
%             TestCalculateTimes(InloopBatch_tempCell{cB,2},InloopBatch_tempCell{cB,2}) = ...
%                 TestCalculateTimes(InloopBatch_tempCell{cB,2},InloopBatch_tempCell{cB,2}) + 1;
%         end
%         clearvars InloopBatch_tempCell
%     end
% end
% figure;
% imagesc(TestCalculateTimes);
% disp(1);
        
        
        
        

