% script for locate and find merges for ks output results and save the
% merged clusters IDs

[FinalSPClusters,FinalSPTimeSample,FinalSPMaxChn,FinalTemplateUW,FinalksLabels] = AfterKsoutput_mergeCheck(ksfolder);
mergeClusSavePath = fullfile(ksfolder,'AdjustedClusterInfo.mat');

save(mergeClusSavePath, 'FinalSPClusters', 'FinalSPTimeSample', 'FinalSPMaxChn',...
    'FinalTemplateUW', 'FinalksLabels', '-v7.3');



