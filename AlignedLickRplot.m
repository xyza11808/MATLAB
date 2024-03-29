function AlignedLickRplot(AlignedBinDataL,AlignedBinDataR,minTrBinNum,trial_outcome,TrialTypes,varargin)
% specifically used for lick rate plots
TimePoints = 1:size(AlignedBinDataL,2);
StimOnBin = minTrBinNum;
IsTimeInput = 0;
if nargin > 5
    if ~isempty(varargin{1})
        TimePoints = varargin{1};
        StimOnBin = TimePoints(minTrBinNum);
        IsTimeInput = 1;
    end
end   
TimeLimts = length(TimePoints);
if nargin > 6
    if ~isempty(varargin{2})
        TimeLimts = varargin{2};
    end
end
if TimeLimts > 20  % Matrix index being input
    AlignedBinDataLUse = AlignedBinDataL(:,1:TimeLimts);
    AlignedBinDataRUse = AlignedBinDataR(:,1:TimeLimts);
    TimePointsUse = TimePoints(1:TimeLimts);
elseif IsTimeInput
    EndInds = find(TimePoints > TimeLimts,1,'first');
    AlignedBinDataLUse = AlignedBinDataL(:,1:(EndInds-1));
    AlignedBinDataRUse = AlignedBinDataR(:,1:(EndInds-1));
    TimePointsUse = TimePoints(1:(EndInds-1));
else
    error('Input timelimts is not compatable with input time scale');
end
MaxLickRate = max([max(AlignedBinDataLUse(:)),max(AlignedBinDataRUse(:))]);
AlignedBinDataLUse = AlignedBinDataLUse./MaxLickRate;
AlignedBinDataRUse = AlignedBinDataRUse./MaxLickRate;

AbsTrialTypes = unique(TrialTypes);
nStims = length(AbsTrialTypes);
if nStims == 2
    fprintf('Two-tone 2afc session.\n');
    h_plots = figure('position',[350 390 1050 650]);
    StimStr = {'Left','Right'};
elseif nStims >= 6
    fprintf('Random pure tone session.\n');
    h_plots = figure('position',[130 200 1750 850]);
    StimStr = cellstr(num2str(AbsTrialTypes(:)/1000,'%.1fkHz'));
else
    fprintf('Presumed prob trials session.\n');
    h_plots = figure('position',[130 200 1250 850]);
    StimStr = cellstr(num2str(AbsTrialTypes(:)/1000,'%.1fkHz'));
end

for nStim = 1 : nStims
    cStim = AbsTrialTypes(nStim);
    
    cCorrStim = TrialTypes == cStim & trial_outcome == 1;
    cCorrLickRateL = AlignedBinDataLUse(cCorrStim,:);
    cCorrLickRateR = AlignedBinDataRUse(cCorrStim,:);
    
    hax1 = subplot(2,nStims,nStim);
    hold on
    hl1 = plot(TimePointsUse,BinBoundSmooth(cCorrLickRateL,minTrBinNum),'Color','b','LineWidth',1.5);
    hl2 = plot(TimePointsUse,BinBoundSmooth(cCorrLickRateR,minTrBinNum),'Color','r','LineWidth',1.5);
    yScales = get(gca,'ylim');
    xscales = get(gca,'xlim');
    line([StimOnBin,StimOnBin],yScales,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
    ylim(yScales);
    xlabel('Time(s)');
    if nStim == 1
        ylabel('Corr LickRates');
    end
    set(gca,'FontSize',14,'xlim',[0 ceil(TimePointsUse(end))]);
    text(xscales(2)*0.7,yScales(2)*0.8,sprintf('nTr = %d',sum(cCorrStim)),'color','k','FontSize',11);
    legend([hl1,hl2],{'Left lickRate','Right lickRate'},'FontSize',6);
    if cStim < 1
        title(sprintf('%s',StimStr{cStim+1}));
    else
        title(sprintf('%s',StimStr{nStim}));
    end
    
    cErroStim = TrialTypes == cStim & trial_outcome == 0;
    cErroLickRateL = AlignedBinDataLUse(cErroStim,:);
    cErroLickRateR = AlignedBinDataRUse(cErroStim,:);
    
    if ~isempty(cErroLickRateL) || ~isempty(cErroLickRateR)
        hax2 = subplot(2,nStims,nStim+nStims);
        hold on
        hl3 = plot(TimePointsUse,BinBoundSmooth(cErroLickRateL,minTrBinNum),'Color','b','LineWidth',1.6);
        hl4 = plot(TimePointsUse,BinBoundSmooth(cErroLickRateR,minTrBinNum),'Color','r','LineWidth',1.6);
        yScales = get(gca,'ylim');
        xscales = get(gca,'xlim');
        line([StimOnBin,StimOnBin],yScales,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
        ylim(yScales);
        xlabel('Time(s)');
        if nStim == 1
            ylabel('Error LickRates');
        end
        set(gca,'FontSize',14,'xlim',[0 ceil(TimePointsUse(end))]);
        text(xscales(2)*0.7,yScales(2)*0.8,sprintf('nTr = %d',sum(cErroStim)),'color','k','FontSize',11);
        if cStim < 1
            title(sprintf('%s',StimStr{cStim+1}));
        else
            title(sprintf('%s',StimStr{nStim}));
        end
    end
    
end
saveas(h_plots,'Stim Types lick rate plots');
saveas(h_plots,'Stim Types lick rate plots','png');
close(h_plots);
