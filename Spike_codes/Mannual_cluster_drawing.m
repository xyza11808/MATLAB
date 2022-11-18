
% ROINum = length(ROIinfos)+1;
ROIinfos = struct('ROIpos',[],'ROImask',[]);
ROINum = 1;
IsROIAdd = true;

while IsROIAdd
    h_roi = imfreehand;
    finish_drawing = 0;
    while finish_drawing == 0
        choice = questdlg('confirm ROI drawing?','confirm ROI', 'Yes', 'Re-draw', 'Cancel','Yes');
        switch choice
            case'Yes'
                hPos = h_roi.getPosition;
                line(hPos(:,1), hPos(:,2),'color','g','linewidth',1.5);
                Centers = mean(hPos);
                text(Centers(1),Centers(2),num2str(ROINum,'%d'),'Color','m');
%                 hMask = createMask(h_roi);
                ROIinfos(ROINum).ROIpos = hPos;
%                 ROIinfos(ROINum).ROImask = hMask;

                delete(h_roi);
                finish_drawing = 1;
    %             ROI_updated_flag = 1;
            case'Re-draw'
                delete(h_roi);
                h_roi = imfreehand; 
                finish_drawing = 0;
            case'Cancel'
                delete(h_roi); 
                finish_drawing = 1;
    %             ROI_updated_flag = 0;
%                 return
        end
    end
    
    Choice = questdlg('Add Another ROI?','Add ROI', 'Yes', 'No', 'Cancel','Yes');
    switch Choice
        case 'Yes'
            ROINum = ROINum + 1;
        case 'No'
            IsROIAdd = false;
        case 'Cancel'
            IsROIAdd = false;
    end
    
end

%%
AllDataPoints = AllYs{4,1}(:,:);
NumROIs = length(ROIinfos);
UnitInterROI = nan(size(AllDataPoints,1),1);
UnitGrIndsNum = zeros(NumROIs+1,1);
for cROI = 1 : NumROIs
    cROIpos = ROIinfos(cROI).ROIpos;
    pgon = polyshape(cROIpos(:,1),cROIpos(:,2));
    ROIisInter = isinterior(pgon, AllDataPoints(:,1), AllDataPoints(:,2));
    
    UnitInterROI(ROIisInter) = cROI;
    UnitGrIndsNum(cROI) = sum(ROIisInter);
end

UnitGrIndsNum(NumROIs + 1) = sum(isnan(UnitInterROI));

UnitInterROI(isnan(UnitInterROI)) = NumROIs + 1;

%%
savePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';
% savePath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';
savefile = fullfile(savePath,'Mannual_clustering_data_RawNew10.mat'); 
save(savefile,'AllDataPoints', 'UnitInterROI','ExistAreaPSTHData_zs','ExistAreaPSTHAreaInds','ExistAreaErrorPSTHData_zs','-v7.3');
% 
% save(savefile,'AllDataPoints', 'UnitInterROI', 'GrInds', 'Clus2RawInds', 'NewClusInds',...
%     'SigUnitGrInds','sIndexInds','SigCorrAvgData','SigErroAvgData','-v7.3');

%% plot the ploted clusters
% % UsedYInds = UnitInterROI ~= NumROIs + 1;
% % figure;
% % ClusColors = linspecer(NumROIs);
% % gscatter(AllDataPoints(UsedYInds,1),AllDataPoints(UsedYInds,2),...
% %     UnitInterROI(UsedYInds),ClusColors,'o',6);
h2_0f = figure;
hold on
silh = silhouette(AllDataPoints, UnitInterROI, 'cityblock');
scatter(AllDataPoints(:,1),AllDataPoints(:,2),10,silh,'o','filled');
colorbar
xlabel('tsne 1');
ylabel('tsne 2');
set(gca,'FontSize',12);

% AboveThresInds = silh > -0.2;
% scatter(AllDataPoints(AboveThresInds,1),AllDataPoints(AboveThresInds,2),8,'r*');

% close
% figure;
% hold on
% PlotGr1 = 23;
% PlotGr2 = 30;
% NonColorInds = UnitInterROI ~= PlotGr1 & UnitInterROI ~= PlotGr2;
% GrInds1 = UnitInterROI == PlotGr1;
% GrInds2 = UnitInterROI == PlotGr2;
% scatter(AllDataPoints(NonColorInds,1),AllDataPoints(NonColorInds,2),6,...
%     'MarkerEdgeColor',[.6 .6 .6]);
% scatter(AllDataPoints(GrInds1,1),AllDataPoints(GrInds1,2),8,...
%     'MarkerEdgeColor','r');
% f_CI = EclipseCI_2DgaussianFun(AllDataPoints(GrInds1,:));
% plot(f_CI(:,1), f_CI(:,2),'--r');
% f_CI2 = EclipseCI_2DgaussianFun(AllDataPoints(GrInds1,:),0.5);
% plot(f_CI2(:,1), f_CI2(:,2),'--c');
% 
% if sum(GrInds2)
%     scatter(AllDataPoints(GrInds2,1),AllDataPoints(GrInds2,2),8,...
%         'MarkerEdgeColor','b');
% end


%%
UnitPSTHzs = ExistAreaPSTHData_zs;
AreaStrs = ExistAreaPSTHAreaInds;

[SortGrs,GrInds] = sort(UnitInterROI);
figure;
imagesc(UnitPSTHzs(GrInds,:),[-2,5])

Counts = accumarray(UnitInterROI,1);
AccumGrCounts = cumsum(Counts);
for cGr = 1 : numel(AccumGrCounts)
    line([1 700],[AccumGrCounts(cGr) AccumGrCounts(cGr)],'Color','m',...
        'linewidth',1.5);
end
NumClus = length(Counts)-1;

%% small group data list and plot
% TargetGrInds = [2,3,6,7,8,9,10,14,15,16,18:23];
% TargetGrInds = [3:6,8:13,15:NumROIs];
SortedData = UnitPSTHzs(GrInds,:);

% TargetGrInds = [6:NumClus];
TargetGrInds = [5:NumClus];
SmallGrInds = ismember(SortGrs,TargetGrInds);

SmallGrData = SortedData(SmallGrInds,:);
SmallGrInds = SortGrs(SmallGrInds);
SmallGrCounts = Counts(TargetGrInds);

figure;
imagesc(SmallGrData,[-2 5])

SmallGrCumCounts = cumsum(SmallGrCounts);
for cGr = 1 : numel(SmallGrCumCounts)
    line([1 700],[SmallGrCumCounts(cGr) SmallGrCumCounts(cGr)],'Color','m',...
        'linewidth',1.5);
end



%% calculate the mean psth for each mannual cluster
SortedData = UnitPSTHzs(GrInds,:);
NumPoints = size(SortedData,2);
ClusAvgTraceANDnum = zeros(NumClus,NumPoints);
ClusUnitNums = zeros(NumClus,1);
for cClus = 1 : NumClus
    cClusInds = SortGrs == cClus;
    cClusData = SortedData(cClusInds,:);
    ClusAvgTraceANDnum(cClus,:) = mean(cClusData);
    ClusUnitNums(cClus) = size(cClusData,1);
end

%%
hf = figure('position',[100 100 1020 820]);
hold on

ybase = 5;
ystep = 3;
TraceTickCent = zeros(NumClus,1);
for cplot = 1 : NumClus
    cTraceData = ClusAvgTraceANDnum(cplot,:);
    cTraceData_minSub = cTraceData - min(cTraceData);
    cTraceData_plot = cTraceData_minSub + ybase;
    plot(cTraceData_plot,'k','linewidth',1.5);
    text(NumPoints+10, mean(cTraceData_plot),num2str(ClusUnitNums(cplot),'%d'),'Color','m');
    TraceTickCent(cplot) = mean(cTraceData_plot);
    ybase = ybase + ystep + max(cTraceData_minSub);
end

BlockChangePoints = NumPoints/2 + 0.5;
yscales = get(gca,'ylim');
line(BlockChangePoints*[1 1],[0 ybase],'Color',[1 0 0 0.3],'linewidth',2);
set(gca,'ylim',[0 ybase],'ytick',TraceTickCent,'yticklabel',(1:NumClus)',...
    'xtick',[NumPoints/4 NumPoints*3/4],'xticklabel',{'LowBlock';'HighBlock'});
ylabel('Clusters');


%%
[Corr, p] = corr(SortedData',ClusAvgTraceANDnum');

[MaxCorrValue, MaxCorrInds] = max(Corr,[],2);
[NewClusInds, NewClusSortInds] = sort(MaxCorrInds);
figure;imagesc(SortedData(NewClusSortInds,:),[-2 5])
Clus2RawInds = GrInds(NewClusSortInds);

Counts = accumarray(NewClusInds,1);
AccumGrCounts = cumsum(Counts);
for cGr = 1 : numel(AccumGrCounts)
    line([1 700],[AccumGrCounts(cGr) AccumGrCounts(cGr)],'Color','m',...
        'linewidth',1.5);
end

%%
figure;
imagesc(Corr(NewClusSortInds,:));
Counts = accumarray(NewClusInds,1);
AccumGrCounts = cumsum(Counts);
for cGr = 1 : numel(AccumGrCounts)
    line([1 NumClus],[AccumGrCounts(cGr) AccumGrCounts(cGr)],'Color','m',...
        'linewidth',1.5);
end
% %% plot the scatter points after first reclustering
% close
% SortGrPoints = AllDataPoints(Clus2RawInds,:);
% figure;
% hold on
% PlotGr1 = 1;
% PlotGr2 = 30;
% NonColorInds = NewClusInds ~= PlotGr1 & NewClusInds ~= PlotGr2;
% GrInds1 = NewClusInds == PlotGr1;
% GrInds2 = NewClusInds == PlotGr2;
% GrInds1_points = SortGrPoints(GrInds1,:);
% 
% scatter(SortGrPoints(NonColorInds,1),SortGrPoints(NonColorInds,2),6,...
%     'MarkerEdgeColor',[.6 .6 .6]);
% scatter(GrInds1_points(:,1),GrInds1_points(:,2),8,...
%     'MarkerEdgeColor','r');
% f_CI = EclipseCI_2DgaussianFun(SortGrPoints(GrInds1,:),0.5);
% plot(f_CI(:,1), f_CI(:,2),'--r');
% pgon = polyshape(f_CI(:,1),f_CI(:,2));
% ROIisInter = isinterior(pgon, GrInds1_points(:,1), GrInds1_points(:,2));
% WithinPoints = GrInds1_points(ROIisInter,:);
% f_CI2 = EclipseCI_2DgaussianFun(WithinPoints,0.01);
% plot(f_CI2(:,1), f_CI2(:,2),'--c');
% 
% if sum(GrInds2)
%     scatter(SortGrPoints(GrInds2,1),SortGrPoints(GrInds2,2),8,...
%         'MarkerEdgeColor','b');
% end



%% second arrangement unit clusters
SecondSortData = SortedData(NewClusSortInds,:);
% Clus2RawInds = GrInds(NewClusSortInds);
NumPoints = size(SecondSortData,2);
ReClusAvgTraceANDnum = zeros(NumClus,NumPoints);
ReClusSEMTraceANDnum = zeros(NumClus,NumPoints);
NumClus = length(Counts);
ReClusUnitNums = zeros(NumClus,1);
for cClus = 1 : NumClus
    cClusInds = NewClusInds == cClus;
    cClusData = SecondSortData(cClusInds,:);
    ReClusAvgTraceANDnum(cClus,:) = mean(cClusData);
    ReClusUnitNums(cClus) = size(cClusData,1);
    ReClusSEMTraceANDnum(cClus,:) = std(cClusData)/sqrt(size(cClusData,1));
end
if any(ReClusUnitNums == 0)
    EmptyClus = ReClusUnitNums == 0;
    ReClusAvgTraceANDnum(EmptyClus,:) = [];
    ReClusUnitNums(EmptyClus) = [];
    ReClusSEMTraceANDnum(EmptyClus,:) = [];
    NumClus = NumClus - sum(EmptyClus);
end

 [rr,pp] = corrcoef(ReClusAvgTraceANDnum');
%%
hf = figure('position',[100 100 1020 840]);
hold on

ybase = 5;
ystep = 3;
TraceTickCent = zeros(NumClus,1);
for cplot = 1 : NumClus
    cTraceData = ReClusAvgTraceANDnum(cplot,:);
    cTraceData_minSub = cTraceData - min(cTraceData);
    cTraceData_plot = cTraceData_minSub + ybase;
    plot(cTraceData_plot,'k','linewidth',1.5);
    text(NumPoints+10, mean(cTraceData_plot),num2str(ReClusUnitNums(cplot),'%d'),'Color','m');
    TraceTickCent(cplot) = mean(cTraceData_plot);
    ybase = ybase + ystep + max(cTraceData_minSub);
end

BlockChangePoints = NumPoints/2 + 0.5;
yscales = get(gca,'ylim');
line(BlockChangePoints*[1 1],[0 ybase],'Color',[1 0 0 0.3],'linewidth',2);
set(gca,'ylim',[0 ybase],'ytick',TraceTickCent,'yticklabel',(1:NumClus)',...
    'xtick',[NumPoints/4 NumPoints*3/4],'xticklabel',{'LowBlock';'HighBlock'});
ylabel('Clusters');
title('Correct trials, correlation peak clustering')

%%

[NewClusCorr,NewClusp] = corr(SecondSortData',ReClusAvgTraceANDnum');
% %% loop through and merge groups if there is no difference between corrs
% 
% ClusInds = unique(NewClusInds);
% ClusNum = length(ClusInds);
% 
SigUnitGrInds = nan(NumPoints,1);
% cClus = 4;
for cClus = 1 : NumClus
    OtherGrInds = NewClusInds ~= cClus;
    OtherGr_cGr_corrs = NewClusCorr(OtherGrInds, cClus);
    
    cGr_corrs = NewClusCorr(~OtherGrInds, cClus);
    
    Thres = max(prctile(OtherGr_cGr_corrs,95),0.5);
    IsUnitSigCorr = cGr_corrs > Thres;
    
    SigUnitGrInds(~OtherGrInds) = IsUnitSigCorr;
    
end

%
SigUnitGrInds = logical(SigUnitGrInds);
SigGrIndsAll = NewClusInds(SigUnitGrInds);
SigGrDatas = SecondSortData(SigUnitGrInds,:);

SecondSortErrData = ExistAreaErrorPSTHData_zs(Clus2RawInds,:);
SigGrErrorData = SecondSortErrData(SigUnitGrInds,:);

SecondSortTsnePoint = AllDataPoints(Clus2RawInds,:);
SigtsnePoints = SecondSortTsnePoint(SigUnitGrInds,:);

SecondSortsilh = silh(Clus2RawInds);
SigtsneSilh = SecondSortsilh(SigUnitGrInds);

s2 = silhouette(SigtsnePoints,SigGrIndsAll,'CityBlock');
% sIndexInds = SigtsneSilh > 0;
sIndexInds = SigtsneSilh > 0;
FinalGrPSTHs = SigGrDatas(sIndexInds,:);
FinalGrInds = SigGrIndsAll(sIndexInds);
FinaltsnePoints = SigtsnePoints(sIndexInds,:);
FinalGrErrPSTH = SigGrErrorData(sIndexInds,:);


CrNumCounts = accumarray(FinalGrInds,1);
ClusTypes = find(CrNumCounts > 0);
ExistClusCounts = CrNumCounts(ClusTypes);
if any(ExistClusCounts < 10)
    % clusters with too small cluster size
    TinyGrInds = ExistClusCounts < 10;
    TinyGrIndex = ClusTypes(TinyGrInds);
    ExcludeInds = ismember(FinalGrInds, TinyGrIndex);
    FinalGrInds(ExcludeInds) = [];
    FinalGrPSTHs(ExcludeInds,:) = [];
    FinalGrErrPSTH(ExcludeInds,:) = [];
    FinaltsnePoints(ExcludeInds,:) = [];
end

LeftGrTypes = unique(FinalGrInds); % in case some cluster have no points left
IsClusLefted = zeros(NumClus,1);
IsClusLefted(LeftGrTypes) = 1;

[SigCorrAvgData, SigCorrSEMData, SigCorrGrNums] = DataTypeClassification(FinalGrPSTHs,FinalGrInds);

[SigErroAvgData, SigErroSEMData, SigErroGrNums] = DataTypeClassification(FinalGrErrPSTH,FinalGrInds);

% %% cluster units color plots view
% close
% cClus = 32;
% cClusInds = FinalGrInds == cClus;
% cClusData = FinalGrPSTHs(cClusInds,:);
% figure;
% imagesc(cClusData,[-2 4]);


%%
ClusColors = linspecer(NumClus);
h2_1f = figure;
hold on
scatter(AllDataPoints(:,1),AllDataPoints(:,2),6,'o','MarkerEdgeColor',[.7 .7 .7],'MarkerFaceColor',[.7 .7 .7]);
scatter(FinaltsnePoints(:,1),FinaltsnePoints(:,2),10,FinalGrInds,'o','filled');
colormap jet
xlabel('tsne 1');
ylabel('tsne 2');
set(gca,'FontSize',12);

% colormap(ClusColors);

% %% replot the scatter points
% % figure;
% % hold on
% % UsedYInds = SigGrIndsAll ~= 22;
% % 
% % ClusColors = linspecer(NumClus - 1);
% % gscatter(SigtsnePoints(UsedYInds,1),SigtsnePoints(UsedYInds,2),...
% %     SigGrIndsAll(UsedYInds),ClusColors,'o',6);
% % #####################
% % make plots to visualize one or two clusters
% close
% figure;
% hold on
% PlotGr1 = 14;
% PlotGr2 = 30;
% NonColorInds = SigGrIndsAll ~= PlotGr1 & SigGrIndsAll ~= PlotGr2;
% GrInds1 = SigGrIndsAll == PlotGr1;
% GrInds2 = SigGrIndsAll == PlotGr2;
% scatter(SigtsnePoints(NonColorInds,1),SigtsnePoints(NonColorInds,2),6,...
%     'MarkerEdgeColor',[.6 .6 .6]);
% Gr1Data = SigGrDatas(GrInds1,:);
% SelfCorrData = corrcoef(Gr1Data');
% MeanCorrs = mean(SelfCorrData-eye(size(SelfCorrData)));
% cGrUsedInds = MeanCorrs >= 0.3;
% Gr1PointDatas = SigtsnePoints(GrInds1,:);
% % scatter(Gr1PointDatas(cGrUsedInds,1),Gr1PointDatas(cGrUsedInds,2),20,MeanCorrs(cGrUsedInds),'filled');
% scatter(Gr1PointDatas(:,1),Gr1PointDatas(:,2),20,MeanCorrs,'filled'); %,...
% %     'MarkerEdgeColor','r');
% f_CI = EclipseCI_2DgaussianFun(Gr1PointDatas(cGrUsedInds,:));
% plot(f_CI(:,1), f_CI(:,2),'--r');
% f_CI2 = EclipseCI_2DgaussianFun(SigtsnePoints(GrInds1,:),0.5);
% plot(f_CI2(:,1), f_CI2(:,2),'--c');
% 
% if sum(GrInds2)
%     scatter(SigtsnePoints(GrInds2,1),SigtsnePoints(GrInds2,2),8,...
%         'MarkerEdgeColor','b');
% end

%%

% Step1_ExclusionInds = false(numel(s),1);
% for cClus = 1 : NumClus
%     cClusInds = SigGrIndsAll == cClus;
%     if mean(s(cClusInds)<0) ~= 1
%         Step1_ExclusionInds(cClusInds) = s(cClusInds) < 0;
%     end
% end
% Step1_leftPoints = SigtsnePoints(~Step1_ExclusionInds,:);
% Step1_leftGrInds = SigGrIndsAll(~Step1_ExclusionInds);
% 
% s2=silhouette(Step1_leftPoints,Step1_leftGrInds,'CityBlock');

%%
% % close;
% Step1_leftPoints = FinaltsnePoints;
% Step1_leftGrInds = FinalGrInds;
% close
% cClus = 34;
% cClusInds = Step1_leftGrInds == cClus;
% % cClusInds_sig = Step1_leftGrInds == cClus & s2 > -0.20;
% figure;
% hold on
% scatter(Step1_leftPoints(~cClusInds,1),Step1_leftPoints(~cClusInds,2),6,'o','MarkerEdgeColor',[.7 .7 .7]);
% scatter(Step1_leftPoints(cClusInds,1),Step1_leftPoints(cClusInds,2),14,'ro','filled');
% % scatter(Step1_leftPoints(cClusInds_sig,1),Step1_leftPoints(cClusInds_sig,2),10,'r*');



%%
% figure;
% imagesc(SigGrDatas,[-2 5])
% 
% Counts = accumarray(SigGrIndsAll,1);
% AccumGrCounts = cumsum(Counts);
% for cGr = 1 : numel(AccumGrCounts)
%     line([1 NumPoints],[AccumGrCounts(cGr) AccumGrCounts(cGr)],'Color','m',...
%         'linewidth',1.5);
% end

%% correlation value exclusion group average trace plot
h3f = figure('position',[100 100 1020 840]);
hold on

ybase = 5;
ystep = 3;
PlottedClusNum = length(LeftGrTypes);
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
set(gca,'ylim',[0 ybase],'ytick',TraceTickCent,'yticklabel',LeftGrTypes(:),...
    'xtick',[NumPoints/4 NumPoints*3/4],'xticklabel',{'LowBlock';'HighBlock'});
ylabel('Clusters');
title('Correlation threshold, Correct trials');

%% error trials plot
h4f = figure('position',[100 100 1020 840]);
hold on

ybase = 5;
ystep = 3;
TraceTickCent = zeros(PlottedClusNum,1);
for cplot = 1 : PlottedClusNum
    cTraceData = SigErroAvgData(cplot,:);
    cTraceData_minSub = cTraceData - min(cTraceData);
    cTraceData_plot = cTraceData_minSub + ybase;
    plot(cTraceData_plot,'k','linewidth',1.5);
    text(NumPoints+10, mean(cTraceData_plot,'omitnan'),num2str(SigCorrGrNums(cplot),'%d'),'Color','m');
    TraceTickCent(cplot) = mean(cTraceData_plot,'omitnan');
    ybase = ybase + ystep + max(cTraceData_minSub);
end

BlockChangePoints = NumPoints/2 + 0.5;
yscales = get(gca,'ylim');
line(BlockChangePoints*[1 1],[0 ybase],'Color',[1 0 0 0.3],'linewidth',2);
set(gca,'ylim',[0 ybase],'ytick',TraceTickCent,'yticklabel',LeftGrTypes(:),...
    'xtick',[NumPoints/4 NumPoints*3/4],'xticklabel',{'LowBlock';'HighBlock'});
ylabel('Clusters');
title('Correlation threshold, Error trials');

%%
savePath = 'K:\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';
% savePath = 'E:\sycDatas\Documents\me\projects\NP_reversaltask\summaryDatas\UnitPSTHdatas';
savefile = fullfile(savePath,'Mannual_clustering_data_NewData10.mat'); 
save(savefile,'AllDataPoints', 'UnitInterROI', 'GrInds', 'Clus2RawInds', 'NewClusInds',...
    'SigUnitGrInds','sIndexInds','SigCorrAvgData','SigErroAvgData','TinyGrIndex','-v7.3');
saveas(h3f,fullfile(savePath,'Mannual clustering NewData10 CorrTrials PSTH plot'));
saveas(h3f,fullfile(savePath,'Mannual clustering NewData10 CorrTrials PSTH plot'),'png');

saveas(h4f,fullfile(savePath,'Mannual clustering NewData10 ErrorTrials PSTH plot'));
saveas(h4f,fullfile(savePath,'Mannual clustering NewData10 ErrorTrials PSTH plot'),'png');

saveas(h2_1f,fullfile(savePath,'Mannual clustering NewData10 final clusters plot'));
saveas(h2_1f,fullfile(savePath,'Mannual clustering NewData10 final clusters plot'),'png');

saveas(h2_0f,fullfile(savePath,'Mannual clustering NewData10 initial clusters plot'));
saveas(h2_0f,fullfile(savePath,'Mannual clustering NewData10 initial clusters plot'),'png');

%%  plot back of all plotted groups
SecondSortRawPoint = AllDataPoints(Clus2RawInds,:);
ClusterPointDatas = SecondSortRawPoint(SigUnitGrInds,:);
LeftOutPoints = SecondSortRawPoint(~SigUnitGrInds,:);
% SigGrIndsAll
hf = figure;
hold on

gscatter(ClusterPointDatas(:,1),ClusterPointDatas(:,2),SigGrIndsAll);

%%
cGroup = 16;
sampleGrInds = SigGrIndsAll == cGroup;
SampleGrDatas = SigGrDatas(sampleGrInds,:);

[Grs, pps] = corr(SampleGrDatas',SigCorrAvgData(cGroup,:)');
figure;
hold on
PointData = SecondSortRawPoint(sampleGrInds,:);
plot(PointData(Grs > 0.5,1),PointData(Grs > 0.5,2),'ro')
%%
% this method is too sensitive, can not be used
% k = 1;
% TotalCompNumber = zeros(ClusNum*(ClusNum-1)/2,1);
% for cClus = 1 : ClusNum
%     for CompClus = cClus+1 : ClusNum
%         cClusInds = NewClusInds == cClus;
%         CompClusInds = NewClusInds == CompClus;
%         
%         cClusCorr = NewClusCorr(cClusInds, cClus);
%         CompClusCorr = NewClusCorr(CompClusInds, cClus);
%         
%         [~, p ] = ttest2(cClusCorr, CompClusCorr);
%         TotalCompNumber(k) = p;
%         k = k + 1;
%     end
% end

 
%%
% Clus_inds_1 = 4;
% Clus_inds_2 = 11;
% TwoClusCorr = rr(Clus_inds_1,Clus_inds_2);
% 
% if TwoClusCorr > 0.2 && pp(Clus_inds_1,Clus_inds_2)
%     CurrentPair = [Clus_inds_1,Clus_inds_2];
%     TotalCorrVec = rr(:,[Clus_inds_1,Clus_inds_2]);
%     TotalCorrVec(CurrentPair,:) = [];
%     
% end

k = 1;
TotalCompCorr = zeros(ClusNum*(ClusNum-1)/2,5);
for Clus_inds_1 = 1 : ClusNum
    for Clus_inds_2 = Clus_inds_1+1 : ClusNum
        TwoClusCorr = rr(Clus_inds_1,Clus_inds_2);

        if TwoClusCorr > 0.2 && pp(Clus_inds_1,Clus_inds_2) < 0.01
            CurrentPair = [Clus_inds_1,Clus_inds_2];
            TotalCorrVec = rr(:,[Clus_inds_1,Clus_inds_2]);
            TotalCorrVec(CurrentPair,:) = [];
            [rs,ps] = corrcoef(TotalCorrVec(:,1),TotalCorrVec(:,2));
            TotalCompCorr(k,:) = [Clus_inds_1,Clus_inds_2,TwoClusCorr,rs(1,2),ps(1,2)]; 
        else
            rs = nan;
            ps = nan;
            TotalCompCorr(k,:) = [Clus_inds_1,Clus_inds_2,TwoClusCorr,rs,ps];        
        end
        
        k = k + 1;
    end
end



