% reshape data
Testdata = smooth_data;
sfData = permute(Testdata,[2,3,1]);
Data2Matrix = reshape(sfData,size(sfData,1),[]);
xticks = 0:frame_rate:size(Testdata,3);
xticklabels = xticks/frame_rate;
xTimes = (1:size(Testdata,3))/frame_rate;
StartTime = start_frame/frame_rate;

%%
[lambda,psi,T,stats,F] = factoran(Data2Matrix',15);

%%
FScoreData = reshape(F',15,size(Testdata,3),size(Testdata,1));
FSDataNorm = permute(FScoreData,[3,1,2]);
LeftCorrInds = trial_outcome' == 1 & behavResults.Trial_Type == 0;
LeftErrorInds = trial_outcome' == 0 & behavResults.Trial_Type == 0;
RightCorrInds = trial_outcome' == 1 & behavResults.Trial_Type == 1;
RightErroInds = trial_outcome' == 0 & behavResults.Trial_Type == 1;
LeftCorrData = FSDataNorm(LeftCorrInds,:,:);
RightMeanData = FSDataNorm(RightCorrInds,:,:);
LeftMeanTrace = squeeze(mean(LeftCorrData));
RightMeanTrace = squeeze(mean(RightMeanData));

LeftErroMean = squeeze(mean(FSDataNorm(LeftErrorInds,:,:)));
RightErroMean = squeeze(mean(FSDataNorm(RightErroInds,:,:)));
%%
if ~isdir('./DimRed_Resplot/')
    mkdir('./DimRed_Resplot/');
end
cd('./DimRed_Resplot/');

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
plot(xTimes,mean(cLRIndexSumNor(LeftErrorInds,:)),'b','LineStyle','--');
plot(xTimes,mean(cLRIndexSumNor(RightErroInds,:)),'r','LineStyle','--');
AxisScale = axis;
line([StartTime StartTime],[AxisScale(3) AxisScale(4)],'color',[.8 .8 .8],'lineStyle','--','LineWidth',2);
ylim(AxisScale(3:4));
xlim([0 xTimes(end)]);
set(gca,'FontSize',20);
%
saveas(hsf,'LR selection index plot');
saveas(hsf,'LR selection index plot','png');
close(hsf);

cd ..;
%%
% hold on;
% for nnn = 1 : length(trial_outcome)
%     if ~behavResults.Trial_Type(nnn)
%         if trial_outcome(nnn)
%             plot3(squeeze(FSDataNorm(nnn,1,:)),squeeze(FSDataNorm(nnn,2,:)),squeeze(FSDataNorm(nnn,3,:)),'b','LineWidth',0.8);
%         else
%             plot3(squeeze(FSDataNorm(nnn,1,:)),squeeze(FSDataNorm(nnn,2,:)),squeeze(FSDataNorm(nnn,3,:)),'b','LineWidth',0.8,'LineStyle','--');
%         end
%     else
%         if trial_outcome(nnn)
%             plot3(squeeze(FSDataNorm(nnn,1,:)),squeeze(FSDataNorm(nnn,2,:)),squeeze(FSDataNorm(nnn,3,:)),'r','LineWidth',0.8);
%         else
%             plot3(squeeze(FSDataNorm(nnn,1,:)),squeeze(FSDataNorm(nnn,2,:)),squeeze(FSDataNorm(nnn,3,:)),'r','LineWidth',0.8,'LineStyle','--');
%         end
%     end
% end
%%
% [Coeff, score, ~, ~, Explain, ~] = pca(Data2Matrix);
% 
% %%
% CorrDataInds = trial_outcome == 1;
% CorrData = Testdata(CorrDataInds,:,:);
% CorrTrTypes = double(behavResults.Trial_Type(CorrDataInds));
% % MeanLeftMatrix = squeeze(mean(CorrData(CorrTrTypes == 0,:,:)));
% % MeanRightMatrix = squeeze(mean(CorrData(CorrTrTypes == 1,:,:)));
% 
% %%
% TimeResp = squeeze(max(CorrData(:,:,(start_frame+1):(start_frame+frame_rate*2)),[],3));
% NorResp = zeros(size(TimeResp));
% for ncol = 1 : size(TimeResp,2)
%     NorResp(:,ncol) = zscore(TimeResp(:,ncol));
% end
% %%
% [Coeff, score, ~, ~, Explain, ~] = pca(NorResp','Economy',false);