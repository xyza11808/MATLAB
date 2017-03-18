figure;
imagesc(1-matrixData,[0.4,0.8]);
hbar = colorbar;

%%
line([3.5,3.5],[0.5,6.5],'Color','r','LineWidth',3);
line([4.5,4.5],[0.5,6.5],'Color','r','LineWidth',3);
line([0.5,6.5],[4.5,4.5],'Color','r','LineWidth',3);
line([0.5,6.5],[3.5,3.5],'Color','r','LineWidth',3);

%%
set(hbar,'ytick',[0.4,0.6,0.8]);
Tickstr = cellstr(num2str(StimTypesAll(:)/1000,'%.1fKHz'));
set(gca,'xticklabel',Tickstr,'yticklabel',Tickstr);
set(gca,'fontsize',18);
title('Population Frequency classification  correct rate')
saveas(gcf,'Multi-class classification correct rate');
saveas(gcf,'Multi-class classification correct rate','png');
saveas(gcf,'Multi-class classification correct rate','epsc');

%% temparory plot code
% NC compared plot with paired distance
figure;
hold on
scatter(ROIEucDis,PairedNoiseCoef,10,'o','MarkerEdgeColor','none','MarkerFaceColor',[0.7,0.7,0.7]);
hebar = errorbar(BinCenter,NCBinMeanSem(:,1),NCBinMeanSem(:,2),'k-o','MarkerEdgeColor','none','MarkerFaceColor','k','LineWidth',2);
[tbl,PredData] = lmFunCalPlot(ROIEucDis,PairedNoiseCoef,0);
plot(PredData{1},PredData{2},'color','r','LineWidth',2,'LineStyle','--');
set(gca,'xtick',0:100:400);
xlabel('Distance (um)');
ylabel('NOise correlation coefficient');
set(gca,'FontSize',16);
saveas(gcf,'Noise Distance compared plot');
saveas(gcf,'Noise Distance compared plot','png');
saveas(gcf,'Noise Distance compared plot','epsc');

%% NC colorplot matrix
h_NCcolor = figure;
NCmatrix = squareform(PairedNoiseCoef);
NCmatrix = NCmatrix + diag(ones(size(NCmatrix,1),1));
imagesc(NCmatrix,[-0.5,1]);
set(gca,'xtick',[0 50 100],'xTicklabel',{'';'50';'100'},'ytick',[0 50 100],'yTicklabel',{'';'50';'100'});
set(gca,'TickLength',[0,0]);
set(gca,'xlim',[0 100],'ytick',[0 100]);
hbar = colorbar;
xlabel('# ROIs');
ylabel('# ROIs');
saveas(h_NCcolor,'Paired Noise correlation color plot');
saveas(h_NCcolor,'Paired Noise correlation color plot','png');
saveas(h_NCcolor,'Paired Noise correlation color plot','epsc');

%% merge smae and between group data noise correlation coefficient distribution
WinthinGrNC = [LeftROINCall;RightROINCall];
BetGrNC = BetLRROINCall;

