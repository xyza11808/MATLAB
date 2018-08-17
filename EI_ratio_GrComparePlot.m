% events fraquency EI ratio plots
Gr1EventRatio = (Gr1Summary.EPSC.EventsAll./Gr1Summary.EPSC.TotalTime).\...
    (Gr1Summary.IPSC.EventsAll./Gr1Summary.IPSC.TotalTime);
Gr2EventRatio = (Gr2Summary.EPSC.EventsAll./Gr2Summary.EPSC.TotalTime).\...
    (Gr2Summary.IPSC.EventsAll./Gr2Summary.IPSC.TotalTime);
Gr1EventRatioSEM = std(Gr1EventRatio)/sqrt(length(Gr1EventRatio));
Gr2EventRatioSEM = std(Gr2EventRatio)/sqrt(length(Gr2EventRatio));

EventRatiop = ranksum(Gr1EventRatioSEM,Gr2EventRatioSEM);

if EventRatiop > 0.05
    IPStr = 'N.S.';
elseif EventRatiop > 0.01
    IPStr = '*';
elseif EventRatiop > 0.001
    IPStr = '**';
else
    IPStr = '***';
end

hf = figure('position',[100,100,600,380],'Paperpositionmode','auto');
subplot(121)
hold on
plot(ones(Gr1NeuNum,1),Gr1EventRatio,'*','Color',[.7 .7 .7],'MarkerSize',8);
plot(ones(Gr2NeuNum,1)*2,Gr2EventRatio,'*','Color',[.7 .7 .7],'MarkerSize',8);
errorbar([1,2],[mean(Gr1EventRatio),mean(Gr2EventRatio)],...
    [Gr1EventRatioSEM,Gr2EventRatioSEM],'k-o','Linewidth',2);
set(gca,'xtick',[1,2],'xlim',[0.5 2.5],'xticklabel',{'Tg1','WT'});
yscales = get(gca,'ylim');
title('EI ratio EventFreq.');
ylabel('Ratio');
set(gca,'FontSize',18);
text(1.5,yscales(2)*0.9,IPStr,'FOntSize',12,'Color','r');

subplot(122)
hold on
bar([1,2],[mean(Gr1EventRatio),mean(Gr2EventRatio)],0.4,'FaceColor',[.7 .7 .7],'EdgeColor',[.5 .5 .5]);
errorbar([1,2],[mean(Gr1EventRatio),mean(Gr2EventRatio)],[Gr1EventRatioSEM,Gr2EventRatioSEM],'ko','Linewidth',2);
set(gca,'xtick',[1,2],'xlim',[0.5 2.5],'xticklabel',{'Tg1','WT'});
yscales = get(gca,'ylim');
title('EI ratio EventFreq.');
ylabel('Ratio');
set(gca,'FontSize',18);
text(1.5,yscales(2)*0.9,IPStr,'FOntSize',12,'Color','r');

saveas(hf,'EventEIRatio compare plot ScatterBarplot');
saveas(hf,'EventEIRatio compare plot ScatterBarplot','png');

%% amplitude ratio compare plot
Gr1AmpEIratio = abs(cellfun(@nanmean,Gr1Summary.EPSC.PeakAmpAll)).\...
    cellfun(@nanmean,Gr1Summary.IPSC.PeakAmpAll);
Gr2AmpEIratio = abs(cellfun(@nanmean,Gr2Summary.EPSC.PeakAmpAll)).\...
    cellfun(@nanmean,Gr2Summary.IPSC.PeakAmpAll);
Gr1AmpRatioSEM = std(Gr1AmpEIratio)./sqrt(length(Gr1AmpEIratio));
Gr2AmpRatioSEM = std(Gr2AmpEIratio)./sqrt(length(Gr2AmpEIratio));
AmpRatiop = ranksum(Gr1AmpEIratio,Gr2AmpEIratio);

if AmpRatiop > 0.05
    RatioStr = 'N.S.';
elseif AmpRatiop > 0.01
    RatioStr = '*';
elseif AmpRatiop > 0.001
    RatioStr = '**';
else
    RatioStr = '***';
end

hf = figure('position',[100,100,600,380],'Paperpositionmode','auto');
subplot(121)
hold on
plot(ones(Gr1NeuNum,1),Gr1AmpEIratio,'*','Color',[.7 .7 .7],'MarkerSize',8);
plot(ones(Gr2NeuNum,1)*2,Gr2AmpEIratio,'*','Color',[.7 .7 .7],'MarkerSize',8);
errorbar([1,2],[mean(Gr1AmpEIratio),mean(Gr2AmpEIratio)],...
    [Gr1AmpRatioSEM,Gr2AmpRatioSEM],'k-o','Linewidth',2);
set(gca,'xtick',[1,2],'xlim',[0.5 2.5],'xticklabel',{'Tg1','WT'});
yscales = get(gca,'ylim');
title('EI ratio Amp.');
ylabel('Ratio');
set(gca,'FontSize',18);
text(1.5,yscales(2)*0.9,RatioStr,'FOntSize',12,'Color','r');

subplot(122)
hold on
bar([1,2],[mean(Gr1AmpEIratio),mean(Gr2AmpEIratio)],0.4,'FaceColor',[.7 .7 .7],'EdgeColor',[.5 .5 .5]);
errorbar([1,2],[mean(Gr1AmpEIratio),mean(Gr2AmpEIratio)],[Gr1AmpRatioSEM,Gr2AmpRatioSEM],'ko','Linewidth',2);
set(gca,'xtick',[1,2],'xlim',[0.5 2.5],'xticklabel',{'Tg1','WT'});
yscales = get(gca,'ylim');
title('EI ratio Amp.');
ylabel('Ratio');
set(gca,'FontSize',18);
text(1.5,yscales(2)*0.9,RatioStr,'FOntSize',12,'Color','r');

saveas(hf,'AmpEIRatio compare plot ScatterBarplot');
saveas(hf,'AmpEIRatio compare plot ScatterBarplot','png');

%% area EI ratio plot
Gr1AreaEIratio = abs(cellfun(@nanmean,Gr1Summary.EPSC.area)).\...
    cellfun(@nanmean,Gr1Summary.IPSC.area);
Gr2AreaEIratio = abs(cellfun(@nanmean,Gr2Summary.EPSC.area)).\...
    cellfun(@nanmean,Gr2Summary.IPSC.area);
Gr1AreaRatioSEM = std(Gr1AreaEIratio)./sqrt(length(Gr1AreaEIratio));
Gr2AreaRatioSEM = std(Gr2AreaEIratio)./sqrt(length(Gr2AreaEIratio));
AreaRatiop = ranksum(Gr1AreaEIratio,Gr2AreaEIratio);

if AreaRatiop > 0.05
    RatioStr = 'N.S.';
elseif AreaRatiop > 0.01
    RatioStr = '*';
elseif AreaRatiop > 0.001
    RatioStr = '**';
else
    RatioStr = '***';
end

hf = figure('position',[100,100,600,380],'Paperpositionmode','auto');
subplot(121)
hold on
plot(ones(Gr1NeuNum,1),Gr1AreaEIratio,'*','Color',[.7 .7 .7],'MarkerSize',8);
plot(ones(Gr2NeuNum,1)*2,Gr2AreaEIratio,'*','Color',[.7 .7 .7],'MarkerSize',8);
errorbar([1,2],[mean(Gr1AreaEIratio),mean(Gr2AreaEIratio)],...
    [Gr1AreaRatioSEM,Gr2AreaRatioSEM],'k-o','Linewidth',2);
set(gca,'xtick',[1,2],'xlim',[0.5 2.5],'xticklabel',{'Tg1','WT'});
yscales = get(gca,'ylim');
title('EI ratio Area');
ylabel('Ratio');
set(gca,'FontSize',18);
text(1.5,yscales(2)*0.9,RatioStr,'FOntSize',12,'Color','r');

subplot(122)
hold on
bar([1,2],[mean(Gr1AreaEIratio),mean(Gr2AreaEIratio)],0.4,'FaceColor',[.7 .7 .7],'EdgeColor',[.5 .5 .5]);
errorbar([1,2],[mean(Gr1AreaEIratio),mean(Gr2AreaEIratio)],[Gr1AreaRatioSEM,Gr2AreaRatioSEM],'ko','Linewidth',2);
set(gca,'xtick',[1,2],'xlim',[0.5 2.5],'xticklabel',{'Tg1','WT'});
yscales = get(gca,'ylim');
title('EI ratio Area');
ylabel('Ratio');
set(gca,'FontSize',18);
text(1.5,yscales(2)*0.9,RatioStr,'FOntSize',12,'Color','r');

saveas(hf,'AreaEIRatio compare plot ScatterBarplot');
saveas(hf,'AreaEIRatio compare plot ScatterBarplot','png');
