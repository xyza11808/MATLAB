SummaryDataPath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';

if ~exist('ExistAreaPSTHData_zs','var')
    load(fullfile(SummaryDataPath,'finalClusterTemplatefrom11.mat'),'ExistAreaPSTHData_zs');
end
FileNamePrefix = 'Mannual_clustering_data_';
PosFiles = dir(fullfile(SummaryDataPath,'Mannual_clustering_data_*.mat'));
FolderSavePath = 'SessClusAvgTracePlot';
fullSaveFolder = fullfile(SummaryDataPath,FolderSavePath);

NumFiles = length(PosFiles);

SessclusterDatas = cell(NumFiles, 5);
SessUnittsnePoints = cell(NumFiles,2);
for cf = 1 : NumFiles
    cfName = PosFiles(cf).name;
    cfileData = load(cfName);
    [SigCorrAvgData, FinalGrInds, LeftGrTypes, FinalGrUnitIDs, Raw2finalInds] = ...
        mannualClusterFun(ExistAreaPSTHData_zs,cfileData.AllDataPoints,cfileData.UnitInterROI);
    FinalGrPoints = cfileData.AllDataPoints(FinalGrUnitIDs,:);
    SessUnittsnePoints(cf,:) = {cfileData.AllDataPoints,cfileData.UnitInterROI};
    SessclusterDatas(cf,:) = {SigCorrAvgData, LeftGrTypes, FinalGrInds, FinalGrUnitIDs, Raw2finalInds};
    
    SigCorrGrNums = Raw2finalInds{end};
    
    h3f = figure('position',[100 100 1020 840]);
    hold on
    NumPoints = size(SigCorrAvgData,2);
    PlottedClusNum = size(SigCorrAvgData,1);
    ybase = 5;
    ystep = 3;

    TraceTickCent = zeros(PlottedClusNum,1);
    for cplot = 1 : PlottedClusNum
        cTraceData = SigCorrAvgData(cplot,:);
        cTraceData_minSub = cTraceData - min(cTraceData);
        cTraceData_plot = cTraceData_minSub + ybase;
        plot(cTraceData_plot,'k','linewidth',1.5);
        text(NumPoints+10, mean(cTraceData_plot),num2str(SigCorrGrNums(cplot),'%d'),'Color','m');
        TraceTickCent(cplot) = mean(cTraceData_plot);
        ybase = ybase + ystep + max(cTraceData_minSub);
    end

    BlockChangePoints = NumPoints/2 + 0.5;
    yscales = get(gca,'ylim');
    line(BlockChangePoints*[1 1],[0 ybase],'Color',[1 0 0 0.3],'linewidth',2);
    set(gca,'ylim',[0 ybase],'ytick',TraceTickCent,'yticklabel',(1:PlottedClusNum)',...
        'xtick',[NumPoints/4 NumPoints*3/4],'xticklabel',{'LowBlock';'HighBlock'});
    ylabel('Clusters');
    
    sessfigfile = sprintf('Sess%d cluster trace plot save',cf);
    
    saveas(h3f,fullfile(fullSaveFolder,sessfigfile));
    print(h3f,fullfile(fullSaveFolder,sessfigfile),'-dpdf','-bestfit');
    print(h3f,fullfile(fullSaveFolder,sessfigfile),'-dpng','-r350');
    close(h3f);
    
    % plot the clusters
    hff2 = figure;
    hold on
    scatter(cfileData.AllDataPoints(:,1),cfileData.AllDataPoints(:,2),6,'o','MarkerEdgeColor',[.7 .7 .7]);
    scatter(FinalGrPoints(:,1),FinalGrPoints(:,2),10,FinalGrInds,'o','filled');
    colormap(hsv);
    xlabel('tsne 1');
    ylabel('tsne 2');
    sessfigfile2 = fullfile(fullSaveFolder,sprintf('Sess%d cluster tsne point plot',cf));
    saveas(hff2,sessfigfile2);
    print(hff2,sessfigfile2,'-dpdf','-bestfit');
    print(hff2,sessfigfile2,'-dpng','-r350');
    close(hff2);
end

%%
dataSaveFile = fullfile(fullSaveFolder,'SessClusterDataAll.mat');
save(dataSaveFile,'SessclusterDatas','SessUnittsnePoints','-v7.3');



