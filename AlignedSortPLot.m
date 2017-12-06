function varargout = AlignedSortPLot(AlignedData,TimeReward,TimeAnswer,align_time_point,TrialTypes,FrameRate,onset_time,varargin)
% aligned data sorted by answer time
isplot = 1;
if ~isempty(varargin)
    isplot = varargin{1};
end
if length(unique(TrialTypes)) == 2
    fprintf('Two tone 2afc session, generate data according to given parameters.\n');
    israndomSession = 0;
elseif length(unique(TrialTypes)) >= 6
    fprintf('Random puretone 2afc session, generate dataset only.\n');
    isplot = 0;
    israndomSession = 1;
end
AnswersT = double(TimeAnswer);
SelectInds = TimeReward > 0;  %only correct trials included for plot
RealAnsT = AnswersT(SelectInds);
DiffTimeAnsStim = double(onset_time(SelectInds) - align_time_point);
AdjustAnsT = RealAnsT - DiffTimeAnsStim;
SelectData = AlignedData(SelectInds,:,:);
[SortedValue,SortInds] = sort(AdjustAnsT);
SelectTrials = TrialTypes(SelectInds);
SortedTrials = SelectTrials(SortInds);

AlignFrame = round(double(align_time_point)/1000*FrameRate);
[nTrials,nROIs,nFrames] = size(SelectData);
SelectData = SelectData(SortInds,:,:);
xtick=FrameRate:FrameRate:nFrames;
xTick_lable=1:floor(nFrames/FrameRate);

if ~israndomSession
    LeftInds = SortedTrials == 0;
    RightInds = SortedTrials == 1;
    LeftAnswer = round(SortedValue(LeftInds)/1000*FrameRate);
    RightAnswer = round(SortedValue(RightInds)/1000*FrameRate);
    LeftAlignSortdata = permute(SelectData(LeftInds,:,:),[2,1,3]);
    RightAlignSortdata = permute(SelectData(RightInds,:,:),[2,1,3]);
else
   AllTrialType = unique(SortedTrials);
   FreqTypes = length(AllTrialType);
   AllAnsF = round(SortedValue/1000*FrameRate);
   FreqTypeInds = false(FreqTypes,length(SortedTrials));
   FreqTypeAnsF = cell(FreqTypes,1);
   for nn = 1 : FreqTypes
       cFreqInds = SortedTrials == AllTrialType(nn);
       FreqTypeInds(nn,cFreqInds) = true;
       FreqTypeAnsF{nn} = AllAnsF(cFreqInds);
   end
   FreqTypeData = cell(FreqTypes,nROIs);
end

% LeftAlignSortdata = permute(SelectData(LeftInds,:,:),[2,1,3]);
% RightAlignSortdata = permute(SelectData(RightInds,:,:),[2,1,3]);
climAll = zeros(nROIs,2);
if isplot
    if ~isdir('./Aligned_sort_plot/')
        mkdir('./Aligned_sort_plot/');
    end
    cd('./Aligned_sort_plot/');
end

for nROI = 1 : nROIs
    
    cROIData = squeeze(SelectData(:,nROI,:));
    clims=[];
    clims(1)=max(min(cROIData(:)),0);
    clims(2)=prctile(cROIData(:),85);
    if clims(2)>(10*median(cROIData(:)))
        clims(2) = (clims(2)+median(cROIData(:)))/3;
    end
%     if clims(2) > 500
%         clims(2) = 400;
%     end
    climAll(nROI,:) = clims;
    if ~israndomSession
        cLeftData = cROIData(LeftInds,:);
        cRightData = cROIData(RightInds,:);
    else
        for nnn = 1 : FreqTypes
            FreqTypeData(nnn,nROI) = {cROIData(FreqTypeInds(nnn,:),:)};
        end
    end
    
    if isplot
        h_plot=figure('color','w','position',[350 50 1000 1000],'PaperPositionMode','auto');
    %     set(gcf,'RendererMode','manual')
    %     set(gcf,'Renderer','OpenGL')

        subplot(3,2,[1,3]);
        hold on;
        imagesc(cLeftData,clims);
        set(gca,'ydir','reverse')
    %     set(gca,'YDir','normal');
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
        ylabel('Left Trials');
        xlabel('Time (s)');
        for nn = 1 : sum(LeftInds)
            line([LeftAnswer(nn),LeftAnswer(nn)],[nn-0.5,nn+0.5],'color',[1 0 1],'LineWidth',1.8);
        end
        ylim([0.5,nn]);
        line([AlignFrame AlignFrame],[0.5,nn],'color',[.8 .8 .8],'LineWidth',1.5);
        set(gca,'FontSize',20);
        LeftMeanTrace = mean(cLeftData);

        subplot(3,2,[2,4]);
        hold on
        imagesc(cRightData,clims);
        set(gca,'ydir','reverse')
    %     set(gca,'YDir','normal');
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
    %     set(gca,'ytick',[]);
        ylabel('Right Trials');
        xlabel('Time (s)');
        cPosition = get(gca,'position');
        h_bar=colorbar;
        plot_position_2=get(h_bar,'position');
        set(h_bar,'position',[plot_position_2(1)*1.05 plot_position_2(2) plot_position_2(3)*0.4 plot_position_2(4)])
        set(get(h_bar,'Title'),'string','\DeltaF/F_0');
        set(gca,'position',cPosition);
        for nn = 1 : sum(RightInds)
            line([RightAnswer(nn),RightAnswer(nn)],[nn-0.5,nn+0.5],'color',[1 0 1],'LineWidth',1.8);
        end
        ylim([0.5,nn]);
    %     yaxis = axis;
        line([AlignFrame AlignFrame],[0.5,nn],'color',[.8 .8 .8],'LineWidth',1.5);
        set(gca,'FontSize',20);
        RightMeanTrace = mean(cRightData);

        LMax = max([max(LeftMeanTrace) max(RightMeanTrace)]) + 10;
        lMin = min([min(LeftMeanTrace) min(RightMeanTrace)]) - 10;

        subplot(3,2,5)
        hold on
        plot(LeftMeanTrace,'b','LineWidth',1.5);
        ylim([lMin LMax]);
        line([AlignFrame AlignFrame],[lMin LMax],'color',[.8 .8 .8],'LineWidth',1.4);
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
        xlabel('Time(s)');
        ylabel('Mean \DeltaF/F_0');
        title('Left Mean');

        subplot(3,2,6)
        hold on
        plot(RightMeanTrace,'r','LineWidth',1.5);
        ylim([lMin LMax]);
        line([AlignFrame AlignFrame],[lMin LMax],'color',[.8 .8 .8],'LineWidth',1.4);
        set(gca,'xtick',xtick,'xticklabel',xTick_lable);
        xlabel('Time(s)');
        ylabel('Mean \DeltaF/F_0');
        title('Right Mean');

        suptitle(sprintf('ROI%d aligned to sound',nROI));
        saveas(h_plot,sprintf('ROI%d Aligned and sort plot',nROI),'fig');
        saveas(h_plot,sprintf('ROI%d Aligned and sort plot',nROI),'png');
        close(h_plot);
    end
end
if nargout > 0
    if ~israndomSession
        DataForSumPlot.LeftAlignD = LeftAlignSortdata;
        DataForSumPlot.RightAlignD = RightAlignSortdata;
        DataForSumPlot.climsAll = climAll;
        DataForSumPlot.LeftAnsF = LeftAnswer;
        DataForSumPlot.RightAnsF = RightAnswer;
        DataForSumPlot.AlignFrame = AlignFrame;
        varargout{1} = DataForSumPlot;
    else
        DataForSumPlot.FreqRespData = FreqTypeData; % nfreq by nROI cell data array
        DataForSumPlot.climsAll = climAll;
        DataForSumPlot.FreqAnsFr = FreqTypeAnsF; % nfreq by 1 cell data array
        DataForSumPlot.FreqTypes = AllTrialType;
        varargout{1} = DataForSumPlot;
    end
end
if isplot
    cd ..;
end