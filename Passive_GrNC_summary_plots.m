% this scipts is used for passive noise correlation coefficient data
% grouped together using AUC group
% this script is also availuable for distance-based noise correlation
% correction method, the corresponded data saved in PassNCDataStrc.NCDataStrc
% The correction method have already performed in another script, do not
% using this method currently
clear
clc

addchar = 'y';
m = 1;
LeftDataAll = [];
RightDataAll = [];
BetDataAll = [];
DataSum = {};
DataPath = {};

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('DisNCData.mat','Please select your Passive Group wised data');
    if ~fi
        return;
    else
        cpath = fullfile(fp,fn);
        DataPath{m} = cpath;
%         fprintf('%s\n',cpath);
        PassNCDataStrc = load(cpath);
        DataSum{m} = PassNCDataStrc;
        PassNCVec = PassNCDataStrc.NCDataStrc.PairedNoiseCoef;
        PassNCMtx = squareform(PassNCVec);
        
        LeftDataMtx = PassNCMtx(PassNCDataStrc.IndexStrc.LeftSigROIAUCIndex,PassNCDataStrc.IndexStrc.LeftSigROIAUCIndex);
        RightDataMtx = PassNCMtx(PassNCDataStrc.IndexStrc.RightSigROIAUCIndex,PassNCDataStrc.IndexStrc.RightSigROIAUCIndex);
        BetDataMtx = PassNCMtx(PassNCDataStrc.IndexStrc.LeftSigROIAUCIndex,PassNCDataStrc.IndexStrc.RightSigROIAUCIndex);
        
        cLeftData = LeftDataMtx(logical(tril(ones(size(LeftDataMtx)),-1)));
        cRightData = RightDataMtx(logical(tril(ones(size(RightDataMtx)),-1)));
        cLRdata = BetDataMtx(:);
         
%         cLeftData = PassNCDataStrc.IndexStrc.LeftROINCVector; % task data
%         cRightData = PassNCDataStrc.IndexStrc.RightROINCvector; % task data
%         cLRdata = PassNCDataStrc.IndexStrc.betLRNoiseCorrVector; % task data
        
        LeftDataAll = [LeftDataAll;cLeftData];
        RightDataAll = [RightDataAll;cRightData];
        BetDataAll = [BetDataAll;cLRdata];
    end
    
    addchar = input('Would you like to add another session data?\n','s');
    if ~strcmp(addchar,'n')
        m = m + 1;
    end
end

%% save summarized data set
savePath = uigetdir('Please select your current data saving path');
cd(savePath);
fid = fopen('Pass_GrData_path.txt','w');
fprintf(fid,'The datapath used within current analysis:\r\n');
fform = '%s;\r\n';
for nnmn=1:m
    fprintf(fid,fform,DataPath{nnmn});
end
fclose(fid);
save PassDataSave.mat DataSum DataPath LeftDataAll RightDataAll BetDataAll -v7.3

%% plot the result
% cumulative plot and comparasion of different Noise correlation
% populations
LeftROINCall = LeftDataAll;
RightROINCall = RightDataAll;
BetLRROINCall = BetDataAll;

[LeftCumFrac,Leftx] = ecdf(LeftROINCall);
[RightCumFrac,Rightx] = ecdf(RightROINCall);
[LRCumFrac,LRx] = ecdf(BetLRROINCall);

h_all = figure('position',[200 200 1000 800]);
hold on;
plot(Leftx,LeftCumFrac,'b','LineWidth',1.8);
plot(Rightx,RightCumFrac,'r','LineWidth',1.8);
plot(LRx,LRCumFrac,'k','LineWidth',1.8);
set(gca,'xlim',[-1 1]);
p_L2R = ranksum(LeftROINCall,RightROINCall);
p_L2Betn = ranksum(LeftROINCall,BetLRROINCall);
p_R2Betn = ranksum(RightROINCall,BetLRROINCall);
xlabel('Noise correlation coefficient');
ylabel('Cumulative fraction');
title('Group wise Noise correlation distribution');
set(gca,'FontSize',18);
text(0.6,0.3,sprintf('L2R pValue = %.3e',p_L2R),'Color','k','FontSize',12);
text(0.6,0.2,sprintf('L2Betn pValue = %.3e',p_L2Betn),'Color','k','FontSize',12);
text(0.6,0.1,sprintf('R2Betn pValue = %.3e',p_R2Betn),'Color','k','FontSize',12);
text(-0.8,0.9,sprintf('Mean LeftPopu NC = %.3f, nPairs = %d',mean(LeftROINCall),length(LeftROINCall)),'FontSize',10,'Color','b');
text(-0.8,0.8,sprintf('Mean RightPopu NC = %.3f, nPairs = %d',mean(RightROINCall),length(RightROINCall)),'FontSize',10,'Color','r');
text(-0.8,0.7,sprintf('Mean L2RPopu NC = %.3f, nPairs = %d',mean(BetLRROINCall),length(BetLRROINCall)),'FontSize',10,'Color','k');
saveas(h_all,'Summarized Groupwise NC cumulative plot passive');
saveas(h_all,'Summarized Groupwise NC cumulative plot passive','png');
% closoe(h_all);

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
saveas(h,'Cumulative distribution of BetGr and WinGr NC passive');
saveas(h,'Cumulative distribution of BetGr and WinGr NC passive','png');
saveas(h,'Cumulative distribution of BetGr and WinGr NC passive','pdf');