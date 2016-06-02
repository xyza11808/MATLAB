close all;
TrialNum=1;
ROINum=3;
testTrace=squeeze(FChangeData(TrialNum,ROINum,:));
figure;
plot(testTrace);

%%
events_time = CaEventDetector(squeeze(testTrace));



%%
testTraceSM=squeeze(FChangeData(TrialNum,ROINum,:));
events_time = CaEventDetector(smooth(squeeze(testTraceSM)));
figure;
plot(smooth(testTraceSM));

%%
SingleROIdata=squeeze(FChangeData(:,1,:));
% SingleROIdata=SingleROIdata';
rerangeVector=SingleROIdata(:);
figure;
plot(rerangeVector)