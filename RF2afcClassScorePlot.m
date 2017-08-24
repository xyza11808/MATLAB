function RF2afcClassScorePlot(RFdata,RFStim,RFboundary,AlignFrame,FrameRate,TimeScale,TrComeType)
% this function is called while performing rf related analysis, and try to
% plot the RF data trial by trial classification analysis result vs 2afc
% classification result

if isempty(RFboundary)
    RFboundary = 16000;
end
RFStim = double(RFStim);
TrialTypes = double(RFStim > RFboundary);

% if length(TimeScale) == 1
%     FrameScale = sort([AlignFrame,AlignFrame+round(TimeScale*FrameRate)]);
% elseif length(TimeScale) == 2
%     FrameScale = sort([AlignFrame+round(TimeScale(1)*FrameRate),AlignFrame+round(TimeScale(2)*FrameRate)]);
% else
%     error('Error time scale length, please check your input.');
% end
% if FrameScale(1) < 1
%     fprintf('FrameScale less than 1, adjust to initial frame.\n');
%     if FrameScale(2) < 1
%         error('Matrix index out');
%     end
% end
% if FrameScale(2) > size(RFdata,3)
%     fprintf('FrameScale end larger than maxium frame index, adjust to frame end value.\n');
%     if FrameScale(1) > size(RFdata,3)
%         error('Matrix index out');
%     end
% end

if ~isdir('./Frac_class_compPlot/')
    mkdir('./Frac_class_compPlot/');
end
cd('./Frac_class_compPlot/');

[fn,fp,fi] = uigetfile('FracModelClass.mat','Please select your 2AFC ROI fraction inds data');
if ~fi
    error('Error file selection, quit analysis');
end
xxxx = load(fullfile(fp,fn));
FracROIValue = xxxx.AUCThres;
FracROIinds = xxxx.ROIFracIAll;
% FracROIMaxAUC = xxxx.AUCValueThres;
ClassScore = xxxx.CellFracClassPerfAll;
FracMaxAUCV = xxxx.MaxAUCvalue;
SUFVlassScore = xxxx.SUFFracclfPerfAll;
TaskPerfMean = 1 - mean(ClassScore,2);
SUFTaskPerfMean = 1 - mean(SUFVlassScore,2);

TaskPerfsemU = TaskPerfMean + std(ClassScore,[],2)/sqrt(size(ClassScore,1));
TaskPerfsemL = TaskPerfMean - std(ClassScore,[],2)/sqrt(size(ClassScore,1));
SUFTaskPerfsemU = SUFTaskPerfMean + std(SUFVlassScore,[],2)/sqrt(size(SUFVlassScore,1));
SUFTaskPerfsemL = SUFTaskPerfMean - std(SUFVlassScore,[],2)/sqrt(size(SUFVlassScore,1));

% TaskPerfsemU = 1 - prctile(ClassScore,2.5,2);
% TaskPerfsemL = 1 - prctile(ClassScore,97.5,2);
if length(xxxx.ROIauc) ~= size(RFdata,2)
    if length(xxxx.ROIauc) > size(RFdata,2)
        error('2AFC data ROI number can''t be less than RF data ROI number, Pleas check your input data file,');
    end
    fprintf('Two sessions have different ROI number, using the smaller ROI index to do the calculation.\n');
    RFdata(:,(length(xxxx.ROIauc)+1):end,:) = [];
end

RFFracClassPerfAll = zeros(length(FracROIValue),1000);
% MinCLassScoreRF = zeros(length(FracROIValue),1);
for nnn = 1:length(FracROIValue)
    ROIfracInds = FracROIinds{nnn};
    [AllTloss,~] = TbyTAllROIclass(RFdata,TrialTypes,ones(size(RFdata,1),1),AlignFrame,FrameRate,...
        TimeScale,0,[],ROIfracInds,TrComeType,1);
    RFFracClassPerfAll(nnn,:) = AllTloss;
%     MinCLassScoreRF(nnn) = MinLoss;
end

ModelPerfMean = 1 - mean(RFFracClassPerfAll,2);
ModelPerfsemL = ModelPerfMean - std(RFFracClassPerfAll,[],2)/sqrt(size(RFFracClassPerfAll,1));
ModelPerfsemU = ModelPerfMean + std(RFFracClassPerfAll,[],2)/sqrt(size(RFFracClassPerfAll,1));
% ModelPerfsemL = 1 - prctile(RFFracClassPerfAll,97.5,2);
% ModelPerfsemU = 1 - prctile(RFFracClassPerfAll,2.5,2);
xPrc = [FracROIValue,fliplr(FracROIValue)];
RFyperf = [ModelPerfsemU;flipud(ModelPerfsemL)];
Taskyperf = [TaskPerfsemU;flipud(TaskPerfsemL)];
SUFTaskyperf = [SUFTaskPerfsemU;flipud(SUFTaskPerfsemL)];
h_sumPlot = figure('position',[200,200,800,650]);
hold on
patch(xPrc,RFyperf,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
patch(xPrc,Taskyperf,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.7);
patch(xPrc,SUFTaskyperf,1,'facecolor',[.8 .8 .8],...
              'edgecolor','none',...
              'facealpha',0.6);
h1 = plot(FracROIValue,ModelPerfMean,'r','LineWidth',1.8);
h2 = plot(FracROIValue,TaskPerfMean,'k','LineWidth',1.8);
h3 = plot(FracROIValue,SUFTaskPerfMean,'color',[.6 .6 .6],'LineWidth',1.8);
xlabel('ROI percentile')
ylabel('Classification perf.');
title('population classification score vs ROI fraction')
set(gca,'FontSize',20);
legend([h1,h2,h3],{'RF data' ,'Task data','Shuffled data'},'FontSize',12);
saveas(h_sumPlot,'Cell Fraction vs Popu Perf plot');
saveas(h_sumPlot,'Cell Fraction vs Popu Perf plot','png');
close(h_sumPlot);
save RFtaskFracClass.mat ClassScore RFFracClassPerfAll SUFVlassScore FracROIValue FracMaxAUCV -v7.3
cd ..;