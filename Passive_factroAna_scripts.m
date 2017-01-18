SmoothDatas = zeros(size(SelectData));
[nTrs,nROIs,~] = size(SelectData);
parfor ntr = 1 : nTrs
    for nROI = 1 : nROIs
        SmoothDatas(ntr,nROI,:) = smooth(SelectData(ntr,nROI,:),30);
    end
end
%%
Testdata = SmoothDatas;
sfData = permute(Testdata,[2,3,1]);
Data2Matrix = reshape(sfData,size(sfData,1),[]);
start_frame = frame_rate;
xticks = 0:frame_rate:size(Testdata,3);
xticklabels = xticks/frame_rate;
xTimes = (1:size(Testdata,3))/frame_rate;
StartTime = start_frame/frame_rate;
ManulBoundary = 16000;
PresumeTrialType = double(SelectSArray > ManulBoundary);
trial_outcome = ones(length(PresumeTrialType),1);
%%
[lambda,psi,T,stats,F] = factoran(Data2Matrix',15);

%%
FScoreData = reshape(F',15,size(Testdata,3),size(Testdata,1));
FSDataNorm = permute(FScoreData,[3,1,2]);
LeftCorrInds = PresumeTrialType == 0;
RightCorrInds = PresumeTrialType == 1;
LeftCorrData = FSDataNorm(LeftCorrInds,:,:);
RightMeanData = FSDataNorm(RightCorrInds,:,:);
LeftMeanTrace = squeeze(mean(LeftCorrData));
RightMeanTrace = squeeze(mean(RightMeanData));

%%
if ~isdir('./DimRed_Resplot/')
    mkdir('./DimRed_Resplot/');
end
cd('./DimRed_Resplot/');

save FactorAnaData.mat FSDataNorm trial_outcome LeftCorrInds RightCorrInds SelectSArray ManulBoundary xTimes StartTime frame_rate -v7.3

h_meanLine = figure('position',[200 200 1000 800]);
hold on
plot3(LeftMeanTrace(1,:),LeftMeanTrace(2,:),LeftMeanTrace(3,:),'b','LineWidth',1.6);
plot3(RightMeanTrace(1,:),RightMeanTrace(2,:),RightMeanTrace(3,:),'r','LineWidth',1.6);
scatter3(LeftMeanTrace(1,start_frame),LeftMeanTrace(2,start_frame),LeftMeanTrace(3,start_frame),50,'o',...
    'Markeredgecolor','m','MarkerFaceColor','g','LineWidth',1.6)
scatter3(RightMeanTrace(1,start_frame),RightMeanTrace(2,start_frame),RightMeanTrace(3,start_frame),50,'o',...
    'Markeredgecolor','m','MarkerFaceColor','g','LineWidth',1.6)
% plot3(LeftErroMean(1,:),LeftErroMean(2,:),LeftErroMean(3,:),'b','LineWidth',1.6,'LineStyle','--');
% plot3(RightErroMean(1,:),RightErroMean(2,:),RightErroMean(3,:),'r','LineWidth',1.6,'LineStyle','--');

xlabel('x1');
ylabel('x2');
zlabel('x3');
set(gca,'FontSize',20);


% Distance calculation
TraceDis = sqrt((LeftMeanTrace(1,:) - RightMeanTrace(1,:)).^2 + (LeftMeanTrace(2,:) - RightMeanTrace(2,:)).^2 + ...
    (LeftMeanTrace(3,:) - RightMeanTrace(3,:)).^2);
h_MeanDis = figure;
plot(xTimes,TraceDis,'k','LineWidth',1.4);
yaxiss = axis;
line([StartTime StartTime],[yaxiss(3) yaxiss(4)],'color',[.8 .8 .8],'LineStyle','--','LineWidth',2);
title('Mean Trace distance');
xlabel('Time (s)');
ylabel('Mean Trace Dis');
set(gca,'FontSize',20);

saveas(h_meanLine,'Mean Trace in factor space');
saveas(h_meanLine,'Mean Trace in factor space','png');
close(h_meanLine);

saveas(h_MeanDis,'Mean Trace Distance plot');
saveas(h_MeanDis,'Mean Trace Distance plot','png');
close(h_MeanDis);

%%
cLRIndexSum = zeros(length(trial_outcome),size(FSDataNorm,3));
for ntr = 1 : length(trial_outcome)
    cTrTrace = squeeze(FSDataNorm(ntr,:,:));
    cTrLeftDis = sqrt(sum((cTrTrace - LeftMeanTrace).^2));   % LeftMeanTrace
    cRightDis = sqrt(sum((cTrTrace - RightMeanTrace).^2));  % RightMeanTrace
    cTrLRIndex = (cTrLeftDis - cRightDis)/sum(cTrLeftDis + cRightDis);
    cLRIndexSum(ntr,:) = cTrLRIndex;
end
cLRIndexSumNor = cLRIndexSum./max(abs(cLRIndexSum(:)));
hh = figure('position',[200 100 1200 800]);
subplot(211)
imagesc(cLRIndexSumNor(LeftCorrInds,:),[-1,1]);
set(gca,'xtick',xticks,'xticklabel',xticklabels);
xlabel('Time (s)');
ylabel('Select Index');
title('Corr Left Trials');
colorbar;
set(gca,'FontSize',20);

subplot(212)
imagesc(cLRIndexSumNor(RightCorrInds,:),[-1,1]);
set(gca,'xtick',xticks,'xticklabel',xticklabels);
xlabel('Time (s)');
ylabel('Select Index');
title('Corr Right Trials');
colorbar;
set(gca,'FontSize',20);

saveas(hh,'Single Trial factor space color plot');
saveas(hh,'Single Trial factor space color plot','png');
close(hh);

%%
Leftmean = mean(cLRIndexSumNor(LeftCorrInds,:));
Rightmean = mean(cLRIndexSumNor(RightCorrInds,:));
Leftsem = std(cLRIndexSumNor(LeftCorrInds,:))/sqrt(size(cLRIndexSumNor(LeftCorrInds,:),1));
Rightsem = std(cLRIndexSumNor(RightCorrInds,:))/sqrt(size(cLRIndexSumNor(RightCorrInds,:),1));
xP = [xTimes,fliplr(xTimes)];
LeftPatch = [(Leftmean+Leftsem),fliplr(Leftmean-Leftsem)];
RightPatch = [(Rightmean+Rightsem),fliplr((Rightmean-Rightsem))];

hsf = figure('position',[200 200 1000 800]);
hold on
patch(xP,LeftPatch,1,'facecolor','b',...
              'edgecolor','none',...
              'facealpha',0.4);
patch(xP,RightPatch,1,'facecolor','r',...
              'edgecolor','none',...
              'facealpha',0.4);
plot(xTimes,Leftmean,'b','LineWidth',2);
plot(xTimes,Rightmean,'r','LineWidth',2);
% plot(xTimes,mean(cLRIndexSumNor(LeftErrorInds,:)),'b','LineStyle','--');
% plot(xTimes,mean(cLRIndexSumNor(RightErroInds,:)),'r','LineStyle','--');
AxisScale = axis;
% text(StartTime,0.7*AxisScale(4),sprintf('nErro = %d',sum(LeftErrorInds)),'color','b','HorizontalAlignment','right');
% text(StartTime,0.6*AxisScale(4),sprintf('nErro = %d',sum(RightErroInds)),'color','r','HorizontalAlignment','right');
line([StartTime StartTime],[AxisScale(3) AxisScale(4)],'color',[.8 .8 .8],'lineStyle','--','LineWidth',2);
ylim(AxisScale(3:4));
xlim([0 xTimes(end)]);
title('Selection index');
xlabel('Time(s)');
ylabel('Selection index');
set(gca,'FontSize',20);

%%
saveas(hsf,'LR selection index plot');
saveas(hsf,'LR selection index plot','png');
close(hsf);
save MeanPlotData.mat xTimes Leftmean Rightmean cLRIndexSumNor LeftCorrInds RightCorrInds cLRIndexSum start_frame frame_rate -v7.3

%%
cd ..;