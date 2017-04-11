% scripts used for summarize distance binned signal correlation and noise
% correlation across session,
% passive data and task data will not plotted together
clear;clc;
addchar = 'y';
Datapath = {};
DataSum = {};
BinCenters = {};
SCBinMeanSEMAll = {};
NCBinMeanSEMAll = {};
m = 1;
%
while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('binnedCoefDataSave.mat','Please select the disBinned CoefValue Data save file');
    if ~fi
        break;
    else
        cPath = fullfile(fp,fn);
        Datapath{m} = cPath;
        xx = load(cPath);
        DataSum{m} = xx;
        BinCenters{m} = xx.BinCenter;
        SCBinMeanSEMAll{m} = xx.SCBinMeanSem;
        NCBinMeanSEMAll{m} = xx.NCBinMeanSem;
    end
    
    addchar = input('Would you like to add new session data?\n','s');
    m = m + 1;
end

%%
dataSavedir = uigetdir(pwd,'Please select a data folder to save current summarized data');
cd(dataSavedir);

fids = fopen('SCNCDis_summary_dataPath.txt','w');
fprintf(fids,'Data path used for current summarized analysis: \r\n');
fform = '%s;\r\n';
m = m - 1;
for nnnmmm = 1 : m
    fprintf(fids,fform,Datapath{nnnmmm});
end
fclose(fids);
save SummarydataSave.mat DataSum BinCenters SCBinMeanSEMAll NCBinMeanSEMAll Datapath -v7.3

%%
% nSession = m;
nSession = length(DataSum);
binNumber = cellfun(@length,BinCenters);
UseBinNum = min(binNumber);
[BincenterUse,NCdatauseall,SCdatauseAll] = cellfun(@(x,y,z) MinBinnumberDataExtrac(x,y,z,UseBinNum),...
    BinCenters,NCBinMeanSEMAll,SCBinMeanSEMAll,'UniformOutput',false);
DiffStep = 3;
hsum = figure('position',[300 200 1000 700]);
hold on;
for nS = 1 : nSession
    cBinCenter = BincenterUse{nS};
    cNCData = NCdatauseall{nS};
    nSCData = SCdatauseAll{nS};
    scatter(cBinCenter-3,cNCData(:,1),50,'ko','MarkerEdgeColor','k','LineWidth',1.6);
    scatter(cBinCenter+3,nSCData(:,1),50,'ro','MarkerEdgeColor','r','LineWidth',1.6);
end
NCdataMeanall = cellfun(@(x) x(:,1),NCdatauseall,'UniformOutput',false);
SCdataMeanAll = cellfun(@(x) x(:,1),SCdatauseAll,'UniformOutput',false);
NCdatauseMatrix = (cell2mat(NCdataMeanall))';
SCdatauseMatrix = (cell2mat(SCdataMeanAll))';

NCdatauseMean = mean(NCdatauseMatrix);
NCdatauseSem = std(NCdatauseMatrix)/sqrt(size(NCdatauseMatrix,1));

SCdatauseMean = mean(SCdatauseMatrix);
SCdatauseSem = std(SCdatauseMatrix)/sqrt(size(SCdatauseMatrix,1));

lc1 = errorbar(cBinCenter,NCdatauseMean,NCdatauseSem,'-o','Color','k','MarkerFaceColor','k','LineWidth',2);
lc2 = errorbar(cBinCenter,SCdatauseMean,SCdatauseSem,'-o','Color','r','MarkerFaceColor','r','LineWidth',2);
[NCcorr,NCp] = corrcoef(cBinCenter,NCdatauseMean);
[SCcorr,SCp] = corrcoef(cBinCenter,SCdatauseMean);

xlabel('Pair Distance (um)');
ylabel('Correlation Value');
title({sprintf('NCcorr = %.3f, SCcorr = %.3f',NCcorr(1,2),SCcorr(1,2)),sprintf('Session Num = %d',nSession)});
set(gca,'FontSize',16);
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
text(xscales(2)*0.9,yscales(2)*0.7,sprintf('NCcorr p = %.3e',NCp(1,2)));
text(xscales(2)*0.9,yscales(2)*0.6,sprintf('SCcorr p = %.3e',SCp(1,2)));
legend([lc1,lc2],{'NC Data','SC Data'},'FontSize',14);
saveas(hsum,'NCSC coef vs PairedDis summary plot');
saveas(hsum,'NCSC coef vs PairedDis summary plot','png');
% close(hsum);

%% only plot the noise correlation
% nSession = m;
nSession = length(DataSum);
binNumber = cellfun(@length,BinCenters);
UseBinNum = min(binNumber);
[BincenterUse,NCdatauseall,SCdatauseAll] = cellfun(@(x,y,z) MinBinnumberDataExtrac(x,y,z,UseBinNum),...
    BinCenters,NCBinMeanSEMAll,SCBinMeanSEMAll,'UniformOutput',false);
DiffStep = 3;
hsum = figure('position',[300 200 1000 700]);
hold on;
for nS = 1 : nSession
    cBinCenter = BincenterUse{nS};
    cNCData = NCdatauseall{nS};
    nSCData = SCdatauseAll{nS};
    scatter(cBinCenter-3,cNCData(:,1),50,'ko','MarkerEdgeColor','k','LineWidth',1.6);
%     scatter(cBinCenter+3,nSCData(:,1),50,'ro','MarkerEdgeColor','r','LineWidth',1.6);
end
NCdataMeanall = cellfun(@(x) x(:,1),NCdatauseall,'UniformOutput',false);
SCdataMeanAll = cellfun(@(x) x(:,1),SCdatauseAll,'UniformOutput',false);
NCdatauseMatrix = (cell2mat(NCdataMeanall))';
SCdatauseMatrix = (cell2mat(SCdataMeanAll))';

NCdatauseMean = mean(NCdatauseMatrix);
NCdatauseSem = std(NCdatauseMatrix)/sqrt(size(NCdatauseMatrix,1));

SCdatauseMean = mean(SCdatauseMatrix);
SCdatauseSem = std(SCdatauseMatrix)/sqrt(size(SCdatauseMatrix,1));

lc = errorbar(cBinCenter,NCdatauseMean,NCdatauseSem,'-o','Color','k','MarkerFaceColor','k','LineWidth',2);
% lc2 = errorbar(cBinCenter,SCdatauseMean,SCdatauseSem,'-o','Color','r','MarkerFaceColor','r','LineWidth',2);
[NCcorr,NCp] = corrcoef(cBinCenter,NCdatauseMean);
% [SCcorr,SCp] = corrcoef(cBinCenter,SCdatauseMean);

xlabel('Pair Distance (um)');
ylabel('Correlation Value');
% title({sprintf('NCcorr = %.3f, SCcorr = %.3f',NCcorr(1,2),SCcorr(1,2)),sprintf('Session Num = %d',nSession)});
title({sprintf('NCcorr = %.3f',NCcorr(1,2)),sprintf('Session Num = %d',nSession)});
set(gca,'FontSize',16);
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
text(xscales(2)*0.9,yscales(2)*0.7,sprintf('NCcorr p = %.3e',NCp(1,2)));
% text(xscales(2)*0.9,yscales(2)*0.6,sprintf('SCcorr p = %.3e',SCp(1,2)));
legend(lc,{'NC Data'},'FontSize',14);
saveas(hsum,'NC coef vs PairedDis summary plot');
saveas(hsum,'NC coef vs PairedDis summary plot','pdf');
saveas(hsum,'NC coef vs PairedDis summary plot','png');
% close(hsum);

%%
% extracting strong signal correlation pairs and then calculate the
% distance dependence
nSessions = m;
nBinStrgSCdataSum = cell(nSessions,1);
nBinStrgSCdataAll = cell(nSessions,1);
nBinCentersAll = cell(nSessions,1);
for nss = 1 : nSessions
    cStrc = DataSum{nss};
    nBinCentersAll{nss} = cStrc.BinCenter;
    nBins = length(cStrc.BinCenter);
    cBinStrgCell = cell(nBins,1);
    cBinStrgMeanSem = zeros(nBins,3);
    for nBn = 1 : nBins
        cBinData = cStrc.SCBinDataCell{nBn};
        cBinStrongData = cBinData(abs(cBinData) > 0.3);
        if ~isempty(cBinStrongData)
            cBinStrgCell{nBn} = cBinStrongData;
            cBinStrgMeanSem(nBn,:) = [mean(cBinStrongData),(std(cBinStrongData)/sqrt(length(cBinStrongData))),length(cBinStrongData)];
        else
            cBinStrgCell{nBn} = 0;
            cBinStrgMeanSem(nBn,:) = [0,0,0];
        end
    end
    nBinStrgSCdataSum{nss} = cBinStrgMeanSem;
    nBinStrgSCdataAll{nss} = cBinStrgCell;
end
%%
nBinSCMean = cellfun(@(x) x(:,1),nBinStrgSCdataSum,'UniformOutput',false);
nBinSCSEM = cellfun(@(x) x(:,2),nBinStrgSCdataSum,'UniformOutput',false);
BinLenAll = cellfun(@length,nBinSCMean);
MinBinLen = min(BinLenAll);
[MinBinUse,MinSCSemUse,MinSCMeanUse] = cellfun(@(x,y,z) MinBinnumberDataExtrac(x,y,z,MinBinLen),nBinCentersAll,...
    nBinSCSEM,nBinSCMean,'UniformOutput',false);
PlotBinCent = MinBinUse{1};
SCSemUsematrix = (cell2mat(MinSCSemUse'))';
SCMeanUseMatrix = (cell2mat(MinSCMeanUse'))';
ACSessionSCMean = mean(SCSemUsematrix);
ACSessionSCSem = std(SCSemUsematrix)/sqrt(size(SCSemUsematrix,1));
h_Strgf = figure('position',[300 200 1000 700]);
hold on;
for nnuu = 1 : nSessions
    scatter(PlotBinCent,SCSemUsematrix(nnuu,:),40,'ro','Linewidth',1.6);
end
ec1 = errorbar(PlotBinCent,ACSessionSCMean,ACSessionSCSem,'-o','Color','r','MarkerFaceColor','r','LineWidth',2);
xlabel('Paired distance');
ylabel('Across Session Mean SC');
title({'MultiSession SC mean',sprintf('nSession = %d',nSessions)});
set(gca,'FontSize',14);
legend(ec1,'Mean Signal Corr.');
% saveas(h_Strgf,'Strong SC VS paired distance');
% saveas(h_Strgf,'Strong SC VS paired distance','png');
% close(h_Strgf);
% save StrgSCData.mat 