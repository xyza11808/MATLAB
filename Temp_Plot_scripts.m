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

%% merge same and between group data noise correlation coefficient distribution
WinthinGrNC = [LeftROINCall;RightROINCall];
BetGrNC = BetLRROINCall;
[WithinFuny,WithinFunx] = ecdf(WinthinGrNC);
[BetFuny,BetFunx] = ecdf(BetGrNC);
p = ranksum(WinthinGrNC,BetGrNC);

h = figure;
hold on
hl1 = plot(WithinFunx,WithinFuny,'b','LineWidth',3);
hl2 = plot(BetFunx,BetFuny,'m','LineWidth',3);
set(gca,'xlim',[-1 1],'xtick',[-1 0 1],'ytick',[0,0.5,1]);
xlabel('Noise correlation coefficient');
ylabel('Cumulative fraction');
title({'Comparesion of between and within group NC',sprintf('BetNC mean = %.3f, WinNC = %.3f',mean(BetGrNC),mean(WinthinGrNC))});
set(gca,'FontSize',16);
text(0.7,0.3,sprintf('p = %.2e',p),'FontSize',12);
legend([hl1,hl2],{'WithinGR NC','BetGr NC'},'FontSize',12,'location','Northwest');
saveas(h,'Cumulative distribution of BetGr and WinGr NC');
saveas(h,'Cumulative distribution of BetGr and WinGr NC','png');
saveas(h,'Cumulative distribution of BetGr and WinGr NC','epsc');

%% loading the passive noise correlation data and corresponded ROI index
% passive NC summary datapath
% E:\DataToGo\data_for_xu\TaskPss_NCSC_compPlot
[PassNCfn,PassNCfp,PassNCfi] = uigetfile('SumDataSave.mat','Please select your Passive NC summary data');
PassNCPath = fullfile(PassNCfp,PassNCfn);
PassNCstrc = load(PassNCPath);

% Task Group Index data path
% E:\DataToGo\data_for_xu\GroupWise_NCplot
[indexfn,indexfp,indexfi] = uigetfile('GroupWise_NCsave.mat','Please select the Task Group index summary file');
TaskIndexPath = fullfile(indexfp,indexfn);
TaskIndexStrc = load(TaskIndexPath);

%% extract data
nSessions = length(TaskIndexStrc.DataSum);
PassNCGroupDataBet = cell(nSessions,1);
PassNCGroupDataLeft = cell(nSessions,1);
PassNCGroupDataRight = cell(nSessions,1);
for nnc = 1 : nSessions
    cSPassNCDataStrc = PassNCstrc.PassNCDataSum{nnc};
    cSPassNCData = cSPassNCDataStrc.PairedROIcorr;
    cSPassNCMatrix = squareform(cSPassNCData);
    
    cSTaskIndexStrc = TaskIndexStrc.DataSum{nnc};
    LeftIndex = cSTaskIndexStrc.LeftSigROIAUCIndex;
    RightIndex = cSTaskIndexStrc.RightSigROIAUCIndex;
    
    cSLeftDataMtx = cSPassNCMatrix(LeftIndex,LeftIndex);
    cSRightDataMtx = cSPassNCMatrix(RightIndex,RightIndex);
    cSLRDataMtx = cSPassNCMatrix(RightIndex,LeftIndex);
    
    PassNCGroupDataLeft{nnc} = cSLeftDataMtx(logical(tril(ones(size(cSLeftDataMtx)),-1)));
    PassNCGroupDataRight{nnc} = cSRightDataMtx(logical(tril(ones(size(cSRightDataMtx)),-1)));
    PassNCGroupDataBet{nnc} = cSLRDataMtx(:);
    
end
%
PassNCGroupDataLeftAll = cell2mat(PassNCGroupDataLeft);
PassNCGroupDataRightAll = cell2mat(PassNCGroupDataRight);
PassNCGroupDataBetAll = cell2mat(PassNCGroupDataBet);

%%
[PassNCLefty,PassNCLeftx] = ecdf(PassNCGroupDataLeftAll);
[PassNCRighty,PassNCRightx] = ecdf(PassNCGroupDataRightAll);
[PassNCLRy,PassNCLRx] = ecdf(PassNCGroupDataBetAll);
p_L_R = ranksum(PassNCGroupDataLeftAll,PassNCGroupDataRightAll);
p_L_LR = ranksum(PassNCGroupDataLeftAll,PassNCGroupDataBetAll);
p_R_LR = ranksum(PassNCGroupDataRightAll,PassNCGroupDataBetAll);

hPassGrNC = figure;
hold on
hl1 = plot(PassNCLeftx,PassNCLefty,'b','LineWidth',2.5);
hl2 = plot(PassNCRightx,PassNCRighty,'r','LineWidth',2.5);
hl3 = plot(PassNCLRx,PassNCLRy,'k','LineWidth',2.5);
set(gca,'xlim',[-1 1],'xtick',[-1 0 1],'ytick',[0 0.5 1]);
xlabel('Noise correlation coefficient');
ylabel('Cumulative distribution');
title('PassNC Group wise comparison');
set(gca,'FontSize',18);
text(-0.8,0.8,sprintf('Mean Left NC = %.3f',mean(PassNCGroupDataLeftAll)),'FontSize',10,'Color','b');
text(-0.8,0.7,sprintf('Mean Right NC = %.3f',mean(PassNCGroupDataRightAll)),'FontSize',10,'Color','r');
text(-0.8,0.6,sprintf('Mean BetLR NC = %.3f',mean(PassNCGroupDataBetAll)),'FontSize',10,'Color','k');
text([0.5,0.5,0.5],[0.1,0.2,0.3],{sprintf('R-LR pValue = %.2e',p_R_LR),sprintf('L-LR pValue = %.2e',p_L_LR),...
    sprintf('L-R pValue = %.2e',p_L_R)},'FontSize',8);
legend([hl1,hl2,hl3],{'Left Group','Right Group','BetLR Group'},'Location','Southwest','FontSize',10);
saveas(hPassGrNC,'Passive Groupwise NC cumulative plot');
saveas(hPassGrNC,'Passive Groupwise NC cumulative plot','png');
saveas(hPassGrNC,'Passive Groupwise NC cumulative plot','epsc');
save PassGroupNCsave.mat PassNCstrc TaskIndexStrc PassNCGroupDataLeft PassNCGroupDataRight PassNCGroupDataBet -v7.3

%%
%% merge smae and between group data noise correlation coefficient distribution
% for passive data
WinthinGrNC = [PassNCGroupDataLeftAll;PassNCGroupDataRightAll];
BetGrNC = PassNCGroupDataBetAll;
[WithinFuny,WithinFunx] = ecdf(WinthinGrNC);
[BetFuny,BetFunx] = ecdf(BetGrNC);
p = ranksum(WinthinGrNC,BetGrNC);

h = figure;
hold on
hl1 = plot(WithinFunx,WithinFuny,'b','LineWidth',3);
hl2 = plot(BetFunx,BetFuny,'m','LineWidth',3);
set(gca,'xlim',[-1 1],'xtick',[-1 0 1],'ytick',[0,0.5,1]);
xlabel('Noise correlation coefficient');
ylabel('Cumulative fraction');
title({'Comparesion of between and within group NC',sprintf('BetNC mean = %.3f, WinNC = %.3f',mean(BetGrNC),mean(WinthinGrNC))});
set(gca,'FontSize',16);
text(0.7,0.3,sprintf('p = %.2e',p),'FontSize',12);
legend([hl1,hl2],{'WithinGR NC','BetGr NC'},'FontSize',12,'location','Northwest');
saveas(h,'Cumulative distribution of BetGr and WinGr NC');
saveas(h,'Cumulative distribution of BetGr and WinGr NC','png');
saveas(h,'Cumulative distribution of BetGr and WinGr NC','epsc');
save BetWithinNCdata.mat WinthinGrNC BetGrNC -v7.3
