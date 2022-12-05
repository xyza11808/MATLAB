% script for locate and find merges for ks output results and save the
% merged clusters IDs

% load('mouse6_20220917.mat')
% [behavResults,behavSettings] = behav_cell2struct(SessionResults,SessionSettings);

if ~exist(fullfile(ksfolder,'TrigTimeANDallSampNum.mat'),'file')
    SampleNumsData = load(fullfile(ksfolder,'rez2.mat'),'TotalSamples');
    TotalSampleNums = SampleNumsData.TotalSamples;
    TaskTrigOnTimes = triggerOnTimeSearch(ksfolder,[6,2],30000);
    save(fullfile(ksfolder,'TrigTimeANDallSampNum.mat'),'TotalSampleNums','TaskTrigOnTimes','-v7.3')
end

[FinalSPClusters,FinalSPTimeSample,FinalSPMaxChn,FinalTemplateUW,FinalksLabels] = AfterKsoutput_mergeCheck(ksfolder);
mergeClusSavePath = fullfile(ksfolder,'AdjustedClusterInfo.mat');

save(mergeClusSavePath, 'FinalSPClusters', 'FinalSPTimeSample', 'FinalSPMaxChn',...
    'FinalTemplateUW', 'FinalksLabels', '-v7.3');



