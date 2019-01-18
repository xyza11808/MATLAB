
UsedROIs = 2;

% cSess = pwd;
%
% cd('E:\DataToGo\NewDataForXU\FreqRange_exampleROI_plots\exampleROI4');
close all
SessionPath = {'P:\BatchData\batch55\20180818\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch55\20180908\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change',...
    'S:\BatchData\batch55\20180913\anm01\test01\im_data_reg_cpu\result_save\plot_save\Type5_f0_calculation\NO_Correction\mode_f_change'};
nSess = length(SessionPath);

for cSs = 1 : nSess
    cSess = SessionPath{cSs};
    BehavData = load(fullfile(cSess,'CSessionData.mat'),'behavResults');
    FreqTypes = unique(double(BehavData.behavResults.Stim_toneFreq));
    TaskAlignDataStrc = load(fullfile(cSess,'All BehavType Colorplot','PlotRelatedData.mat'));
    cROIData = squeeze(TaskAlignDataStrc.ROIMeanTraceData(UsedROIs,:,:));

    [~,EndInds] = regexp(cSess,'test\d{2,3}');
    cPassDataUpperPath = fullfile(sprintf('%srf',cSess(1:EndInds)),'im_data_reg_cpu','result_save');

    [~,InfoDataEndInds] = regexp(cSess,'result_save');
    PassPathline = fullfile(sprintf('%srf%s',cSess(1:EndInds),cSess(EndInds+1:InfoDataEndInds)),'plot_save','NO_Correction');

    PasssAlignDataStrc = load(fullfile(PassPathline,'Uneven_colorPlot','UnevenPassdata.mat'));
    cROIPassData = squeeze(PasssAlignDataStrc.typeData(UsedROIs,:,:));

    if numel(FreqTypes) ~= numel(PasssAlignDataStrc.FreqTypes)
        warning('The freq number between task and passive session is not the same.');
        return;
    end

    TaskTimeLine = (1:numel(cROIData{1,1}))/TaskAlignDataStrc.Frate;
    TaskOnset = TaskAlignDataStrc.AlignedFrame/TaskAlignDataStrc.Frate;
    Onset0TaskTimes = TaskTimeLine - TaskOnset;

    PassTimeline = (1:size(cROIPassData{1,1},2))/PasssAlignDataStrc.FrameRate - 1;

    nFreqs = numel(FreqTypes);
    hf = figure('position',[50+350*(cSs-1) 80 350 650]);
    ylimAlls = zeros(nFreqs,2);
    xlimAlls = zeros(nFreqs,2);
    PlotAx = [];
    for cf = 1 : nFreqs

        cFreqTasktrace = cROIData{cf,1};
        cFreqPassMtx = cROIPassData{cf,1};
        cFreqPasstrace = mean(cFreqPassMtx);

        cAx = subplot(nFreqs,1,cf);
        hold on
        if cf == 1
            hl1 = plot(Onset0TaskTimes,cFreqTasktrace,'Color','k','linewidth',1.6);
            hl2 = plot(PassTimeline,cFreqPasstrace,'Color','k','linewidth',1.6,'linestyle','--');
        else
            plot(Onset0TaskTimes,cFreqTasktrace,'Color','k','linewidth',1.6);
            plot(PassTimeline,cFreqPasstrace,'Color','k','linewidth',1.6,'linestyle','--');
        end
        ylabel({sprintf('Freq %d',FreqTypes(cf));sprintf('PassFreq %d',PasssAlignDataStrc.FreqTypes(cf))});
        cycales = get(gca,'ylim');
        ylimAlls(cf,:) = cycales;
        xlimAlls(cf,:) = get(gca,'xlim');

        PlotAx = [PlotAx;cAx];
    end
    CommonyLims = [min(ylimAlls(:,1)),max(ylimAlls(:,2))];
    CommonxLims = [-1.1,min(xlimAlls(:,2))];
    for cff = 1 : nFreqs
        set(PlotAx(cff),'ylim',CommonyLims);
        line(PlotAx(cff),[0 0],CommonyLims,'Color',[.7 .7 .7],'linewidth',1.2);
        line(PlotAx(cff),[0.3 0.3],CommonyLims,'Color',[.7 .7 .7],'linewidth',1.2,'linestyle','--');
        set(PlotAx(cff),'xlim',CommonxLims);
        set(PlotAx(cff),'FontSize',8);
    end
    xlabel(PlotAx(end),'Time (s)');
    title(PlotAx(1),sprintf('Sess %d',cSs));
    legend(PlotAx(1),[hl1,hl2],{'Task','Passive'},'box','off','Location','NorthEast','FontSize',8,'AutoUpdate','off');
    
%     saveas(hf,sprintf('Sess%d example ROI trace plot',cSs));
%     saveas(hf,sprintf('Sess%d example ROI trace plot',cSs),'png');
%     saveas(hf,sprintf('Sess%d example ROI trace plot',cSs),'pdf');
end

% cd('E:\DataToGo\NewDataForXU\FreqRange_exampleROI_plots\exampleROI1');
% save ExampleROIData.mat SessionPath UsedROIs -v7.3


