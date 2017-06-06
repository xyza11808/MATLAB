% script for summarize group wised NC and distance data together
clear
clc

addchar = 'y';
DataSum = {};
DataLeftNC = {};
DataLeftDis = {};
DataRightNC = {};
DataRightDis = {};
DataBetNC = {};
DataBetDis = {};
m = 0;

while ~strcmpi(addchar,'n')
    m = m + 1;
    [fn,fp,fi] = uigetfile('GroupDisCoefStrc.mat','Please select the Paired NC and distance data');
    if ~fi
        return;
    end
    cpath = fullfile(fp,fn);
    cDataStrc = load(cpath);
    DataSum{m} = cDataStrc;
    cLeftNCData = cDataStrc.LeftGroupDataStrc.ROINCcoef;
    cLeftNCMask = logical(tril(ones(size(cLeftNCData)),-1));
    cLeftNCDataV = cLeftNCData(cLeftNCMask);
    cLeftDisDataV = cDataStrc.LeftGroupDataStrc.ROIdis(cLeftNCMask);
    DataLeftNC{m} = cLeftNCDataV;
    DataLeftDis{m} = cLeftDisDataV;
    
    cRightData = cDataStrc.RightGroupDataStrc.ROINCcoef;
    cRightNCMask = logical(tril(ones(size(cRightData)),-1));
    cRightNCDataV = cRightData(cRightNCMask);
    cRightDisDataV = cDataStrc.RightGroupDataStrc.ROIdis(cRightNCMask);
    DataRightNC{m} = cRightNCDataV;
    DataRightDis{m} = cRightDisDataV;
    
    cLRData = cDataStrc.LRGroupDataStrc.ROINCcoef;
    cLRNCdataV = cLRData(:);
    cLRDisDataV = cDataStrc.LRGroupDataStrc.ROIdis(:);
    DataBetNC{m} = cLRNCdataV;
    DataBetDis{m} = cLRDisDataV;
    
    addchar = input('would you like to add another session data?\n','s');
end

%% save current data
SaveDir = uigetdir(pwd,'Please select a data path for summarized data savage');
cd(SaveDir);
save Grwise_NC_DisSave.mat DataLeftNC DataLeftDis DataRightNC DataRightDis DataBetNC DataBetDis -v7.3

%%
LeftNCAll = cell2mat(DataLeftNC(:));
LeftDisAll = cell2mat(DataLeftDis(:));
RightNCAll = cell2mat(DataRightNC(:));
RightDisAll = cell2mat(DataRightDis(:));
LRNCAll = cell2mat(DataBetNC(:));
LRDisAll = cell2mat(DataBetDis(:));
[LeftDisy,LeftDisx] = ecdf(LeftDisAll);
[RightDisy,RightDisx] = ecdf(RightDisAll);
[LRDisy,LRDisx] = ecdf(LRDisAll);

hhf = figure;
hold on
hl1 = plot(LeftDisx,LeftDisy,'b','LineWidth',2);
hl2 = plot(RightDisx,RightDisy,'r','LineWidth',2);
hl3 = plot(LRDisx,LRDisy,'k','LineWidth',2);
xlabel('Pixel Distance');
ylabel('Cumulative fraction');
set(gca,'ytick',[0 0.5 1],'xlim',[0 400],'FontSize',20);
text([300 300 300]-100,[0.3 0.2 0.1],{sprintf('Left mean = %.1f',mean(LeftDisAll)),...
    sprintf('Right mean = %.1f',mean(RightDisAll)),sprintf('Bet mean = %.1f',mean(LRDisAll))},'FontSize',14);
saveas(hhf,'Group wised NC Distance cumulative plot');
saveas(hhf,'Group wised NC Distance cumulative plot','png');
saveas(hhf,'Group wised NC Distance cumulative plot','pdf');
close(hhf);
%%
hSumf = figure;
hold on;
WithinDis = [LeftDisAll;RightDisAll];
BetDis = LRDisAll;
[WinDisy,WinDisx] = ecdf(WithinDis);
[BetDisy,BetDisx] = ecdf(BetDis);
% [~,pDis] = ttest2(WithinDis,BetDis);
pDis = ranksum(WithinDis,BetDis);

plot(WinDisx,WinDisy,'k','LineWidth',2);
plot(BetDisx,BetDisy,'color',[.7 .7 .7],'LineWidth',1.8);
text([200 200],[0.1 0.2],{sprintf('MeanWin = %.1f, N = %d',mean(WithinDis),numel(WithinDis));...
    sprintf('MeanBet = %.1f, N = %d',mean(BetDis),numel(BetDis))},'FontSize',12);
text(30,0.7,sprintf('P = %.3e',pDis));
xlabel('paired-distance')
ylabel('Cumulaive distribution');
set(gca,'ytick',[0 0.5 1],'xtick',0:100:400,'FontSize',20,'xlim',[0 400])
saveas(hSumf,'BetWin_dis_compare_plot');
saveas(hSumf,'BetWin_dis_compare_plot','png');
saveas(hSumf,'BetWin_dis_compare_plot','pdf');
close(hSumf);
