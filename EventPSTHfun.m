function [Clus_event_sts,Clus_event_psth] = EventPSTHfun(st, sclu, usedclu, eventTime, window, Isplot)
% time window used to display psth time
% All spike times should in seconds format

if isempty(window)
    window = [-0.3 1];
end
isplots = 0;
if ~isempty(Isplot)
    isplots = Isplot;
end
NumUsed_Clus = length(usedclu);
NumEventTimes = length(eventTime);
if isplots
    if ~isdir('./Cluster_eventPSTH/')
        mkdir('./Cluster_eventPSTH/');
    end
    cd('./Cluster_eventPSTH/');
end
    
Clus_event_sts = cell(NumUsed_Clus,1);
Clus_event_psth = cell(NumUsed_Clus,3);
for cClus = 1 : 3%NumUsed_Clus
    cClu_index = usedclu(cClus);
    cClus_st = st(sclu == cClu_index);
    event_ts = cell(NumEventTimes,2);
    for cEvent = 1 : NumEventTimes
        cEvTime = eventTime(cEvent);
        st2EventTimes = cClus_st - cEvTime;
        cUsed_event_st = st2EventTimes(st2EventTimes >= window(1) & st2EventTimes <= window(2));
        event_ts{cEvent,1} = cUsed_event_st(:);
        event_ts{cEvent,2} = cEvent*ones(numel(cUsed_event_st),1);
    end
    Clus_event_sts(cClus) = {event_ts};
    
    % generate raster plot dataset
    Event_st_cell = cellfun(@(x) [x;NaN],event_ts(:,1),'UniformOutput',false);
    Event_st_Alltrace = cell2mat(Event_st_cell);
    Event_ylabel_cell = cellfun(@(x) [x;NaN],event_ts(:,2),'UniformOutput',false);
    Event_ylabel_Alltrace = cell2mat(Event_ylabel_cell);
    if isplots
        hcluf = figure('position',[100 100 480 450]);
        ax1 = subplot(2,1,1);
        hold on
        plot(Event_st_Alltrace,Event_ylabel_Alltrace,'k.','MarkerSize',6);
        set(ax1,'xtick',[fliplr(0:-0.2:window(1)),0.2:0.2:window(2)],'xlim',window+[-0.05 0.05],...
            'ylim',[0 NumEventTimes+1]);
        line(ax1,[0 0],[0 NumEventTimes+1],'Color','c','linewidth',0.8);
        xlabel('time (sec)');
        ylabel('Event num');
        title(sprintf('cluster %d',cClus));
    end
    
    %% PSTH data processing
    binsize = 0.01;
    binEdges = [fliplr(0:-binsize:window(1)),binsize:binsize:window(2)];
    [Bincounts,~] = histcounts(cell2mat(event_ts(:,1)),binEdges);
    BinCenters = binEdges(1:end-1) + binsize/2;
    BinFiRate = (Bincounts/NumEventTimes)/binsize;
    
    SmoothFRs = smooth(BinFiRate);
%     SmoothFRs = BinFiRate;
%     SmoothFRs(BinCenters < 0) = smooth(SmoothFRs(BinCenters < 0));
%     SmoothFRs(BinCenters >= 0) = smooth(SmoothFRs(BinCenters >= 0));
    
    if isplots
        ax2 = subplot(2,1,2);
        hold on
        plot(BinCenters,SmoothFRs,'Color',[0.1 0.1 0.8],'linewidth',1.5);
        yscales = get(ax2,'ylim');
        line([0 0],yscales,'Color','m','linewidth',0.8,'linestyle','--');
        set(ax2,'xtick',[fliplr(0:-0.2:window(1)),0.2:0.2:window(2)],'xlim',window+[-0.05 0.05],...
            'ylim',yscales);
        xlabel('time (sec)');
        ylabel('firing rate (Hz)');
    end
    %%
    
    
    Clus_event_psth(cClus,:) = {BinCenters(:),BinFiRate(:),SmoothFRs(:)};
    if isplots
        saveas(hcluf,sprintf('Cluster %03d rater and psth plot',cClus));
        saveas(hcluf,sprintf('Cluster %03d rater and psth plot',cClus),'png');
        close(hcluf);
    end
end
if isplots
    save eventPSTHdata.mat Clus_event_sts Clus_event_psth -v7.3
    cd ..;
end
