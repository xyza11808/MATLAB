function FracTbyTPlot(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,ROIauc,varargin)
% this function is used for correction rate calculation with increased ROI
% choice selectivity and plot the correct ratio change for different
% fraction of cells

if ~isdir('./Frac_vs_perf/')
    mkdir('./Frac_vs_perf/');
end
cd('./Frac_vs_perf/');

hAUC = figure;
cdfplot(ROIauc);
xlabel('ROIauc');
ylabel('Sum Frac.');
title('All ROI''s AUC cumulative plot')
saveas(hAUC,'ROI AUC cumulative plot');
saveas(hAUC,'ROI AUC cumulative plot','png');
close(hAUC);

[TimeLength,TrOutcome] = deal(varargin{1:2});

if length(TimeLength) == 1
    if ~isdir(sprintf('./AfterTimeLength-%dms/',TimeLength*1000))
        mkdir(sprintf('./AfterTimeLength-%dms/',TimeLength*1000));
    end
    cd(sprintf('./AfterTimeLength-%dms/',TimeLength*1000));
else
    StartTime = min(TimeLength);
    TimeScale = max(TimeLength) - min(TimeLength);
    
    if ~isdir(sprintf('./AfterTimeLength-%dms%dmsDur/',StartTime*1000,TimeScale*1000))
        mkdir(sprintf('./AfterTimeLength-%dms%dmsDur/',StartTime*1000,TimeScale*1000));
    end
    cd(sprintf('./AfterTimeLength-%dms%dmsDur/',StartTime*1000,TimeScale*1000));
end
Isshuffle = 0;
if length(varargin) > 2
    if ~isempty(varargin{3})
        Isshuffle = varargin{3};
    end
end

AUCThres = 0.1:0.05:1;
AUCValueThres = prctile(ROIauc,AUCThres*100);
MaxAUCvalue = zeros(1,length(AUCValueThres));
% CellFracClassPerf = zeros(length(AUCValueThres),1);
% CellFracClassModel = cell(length(AUCValueThres),1000);
CellFracClassPerfAll = zeros(length(AUCValueThres),1000);
SUFFracclfPerfAll = zeros(length(AUCValueThres),1000);
ROIFracIAll = cell(length(AUCThres),1);
for nAUCthres = 1 : length(AUCValueThres)
    fprintf('ROI fraction is %.2f, with AUC thres value is %.4f.\n ',AUCThres(nAUCthres),AUCValueThres(nAUCthres));
    ROIFracInds = ROIauc < AUCValueThres(nAUCthres);
    MaxAUCvalue(nAUCthres) = max(ROIauc(ROIFracInds));
    ROIFracIAll{nAUCthres} = ROIFracInds;
%     ROIFrac = ROIauc(ROIFracInds);
    [AllTloss,~,SUFTloss,~] = TbyTAllROIclass(RawDataAll,StimAll,TrialResult,AlignFrame,FrameRate,...
        TimeLength,Isshuffle,[],ROIFracInds,TrOutcome,1);
%     CellFracClassPerf(nAUCthres) = MinTloss;
    CellFracClassPerfAll(nAUCthres,:) = AllTloss;
    SUFFracclfPerfAll(nAUCthres,:) = SUFTloss;
%     CellFracClassModel(nAUCthres,:) = TrainM;
end
%%
ModelPerfMean = 1 - mean(CellFracClassPerfAll,2);
ModelPerfsem = std(CellFracClassPerfAll,[],2)/sqrt(size(CellFracClassPerfAll,1));
SUFTperfMean = 1 - mean(SUFFracclfPerfAll,2);
SUFTperfsem = std(SUFFracclfPerfAll,[],2)/sqrt(size(SUFFracclfPerfAll,1));
xauc = [AUCValueThres,fliplr(AUCValueThres)];
yperf = ([ModelPerfMean+ModelPerfsem;flipud(ModelPerfMean - ModelPerfsem)]);
SUFyperf = ([SUFTperfMean+SUFTperfsem;flipud(SUFTperfMean - SUFTperfsem)]);
% ModelPerfsemL = 1 - prctile(CellFracClassPerfAll,97.5,2);
% ModelPerfsemU = 1 - prctile(CellFracClassPerfAll,2.5,2);
% yperf = [ModelPerfsemU;flipud(ModelPerfsemL)];
h_fracPlot = figure;
hold on;
patch(xauc,yperf,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
patch(xauc,SUFyperf,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
plot(AUCValueThres,ModelPerfMean,'k','LineWidth',1.8);
plot(AUCValueThres,SUFTperfMean,'b','LineWidth',1.8);
xlims = get(gca,'xlim');
line(xlims,xlims,'Color',[.8 .8 .8],'LineWidth',1.6,'LineStyle','--');
xlabel('Percentile AUC value');
ylabel('Frac ROI Perf.');
title('FracCell v.s. TbyT perf.');
set(gca,'FontSize',20);
saveas(h_fracPlot,'Cell Frac to Perf plot Percentile');
saveas(h_fracPlot,'Cell Frac to Perf plot Percentile','png');
close(h_fracPlot);

xaucMax = [MaxAUCvalue,fliplr(MaxAUCvalue)];
h_fracPlotMax = figure;
hold on;
patch(xaucMax,yperf,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
plot(MaxAUCvalue,ModelPerfMean,'k','LineWidth',1.8);
xlims = get(gca,'xlim');
line(xlims,xlims,'Color',[.8 .8 .8],'LineWidth',1.6,'LineStyle','--');
line(xlims,[0.5 0.5],'Color',[.8 .8 .8],'LineWidth',1.6,'LineStyle','--');
xlim(xlims);
xlabel('Max AUC value');
ylabel('Frac ROI Perf.');
title('FracCell v.s. TbyT perf.');
set(gca,'FontSize',20);
saveas(h_fracPlotMax,'Cell Frac to Perf plot PercMax');
saveas(h_fracPlotMax,'Cell Frac to Perf plot PercMax','png');
close(h_fracPlotMax);

save FracModelClass.mat MaxAUCvalue CellFracClassPerfAll SUFFracclfPerfAll ROIFracIAll AUCValueThres AUCThres ROIauc -v7.3

cd ..;
cd ..;