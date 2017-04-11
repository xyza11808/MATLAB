% scripts for single session psychometrix data plots
nSessions = size(BehavResultAll,1);
OctvaeNum = size(BehavResultAll,2);
opts = statset('nlinfit');
opts.RobustWgtFun = 'bisquare';
BehavSlope = zeros(nSessions,1);
NeuroSlope = zeros(nSessions,1);
BehavBound = zeros(nSessions,1);
NeuroBound = zeros(nSessions,1);
for nss = 1 :nSessions
    BehavData = BehavResultAll(nss,:);
    BehavData(1:(OctvaeNum/2)) = 1 - BehavData(1:(OctvaeNum/2));
    NeuroData = FitResultAll(nss,:);
    NeuroData(1:(OctvaeNum/2)) = 1 - NeuroData(1:(OctvaeNum/2));
    OctaveData = OctavesAll(nss,:);
    
    modelfun = @(b,x) (b(1)+ b(2)./(1+exp(-(x - b(3))./b(4))));
    b0 = [min(OctaveData); max(OctaveData); mean([min(OctaveData),max(OctaveData)]); 0.1];
    
    bBehav = nlinfit(OctaveData,BehavData,modelfun,b0,opts);
    bNeuro = nlinfit(OctaveData,NeuroData,modelfun,b0,opts);
    BehavSlope(nss) = 1/bBehav(4);
    NeuroSlope(nss) = 1/bNeuro(4);
    BehavBound(nss) = bBehav(3);
    NeuroBound(nss) = bNeuro(3);
    
    linex = linspace(min(OctaveData),max(OctaveData),500);
    fitBehavy = modelfun(bBehav,linex);
    fitNeuroy = modelfun(bNeuro,linex);
    
    hf = figure;
    hold on;
    plot(OctaveData,BehavData,'o','color',[1,0.5,0],'MarkerSize',12);
    plot(OctaveData,NeuroData,'o','color','b','MarkerSize',12);
    hl1 = plot(linex,fitBehavy,'Color',[1,0.5,0],'linewidth',1.5);
    hl2 = plot(linex,fitNeuroy,'Color','b','linewidth',1.5);
    xlabel('Octave');
    ylabel('Rightward Prob.');
    title(sprintf('Session%d result',nss));
    set(gca,'FontSize',18);
    saveas(hf,sprintf('Session %d psychometric data plot',nss));
    saveas(hf,sprintf('Session %d psychometric data plot',nss),'pdf');
    saveas(hf,sprintf('Session %d psychometric data plot',nss),'png');
    close(hf);
end
save BoundSlopeSave.mat BehavSlope NeuroSlope BehavBound NeuroBound -v7.3
%%
[h,p] = ttest2(BehavSlope,NeuroSlope);
hhf = figure;
hold on
plot(BehavSlope,NeuroSlope,'ko','MarkerSize',12);
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
AxisScale = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
set(gca,'xlim',AxisScale,'ylim',AxisScale);
line([AxisScale(1),AxisScale(2)],[AxisScale(1),AxisScale(2)],'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
text(0.7*AxisScale(2),0.2*AxisScale(2),sprintf('p = %.3f',p));
box off
set(gca,'FontSize',16);
xlabel('Behav. slope');
ylabel('Neuro. slope');
title('Behav and Neuro curve slope comprasion plot');
saveas(hhf,'Slope behav and neuro compare plot');
saveas(hhf,'Slope behav and neuro compare plot','png');
saveas(hhf,'Slope behav and neuro compare plot','pdf');

%%
[h,p] = ttest2(BehavBound,NeuroBound);
hhf = figure;
hold on
plot(BehavBound,NeuroBound,'ko','MarkerSize',12);
xscales = get(gca,'xlim');
yscales = get(gca,'ylim');
AxisScale = [min([xscales(1),yscales(1)]),max([xscales(2),yscales(2)])];
set(gca,'xlim',AxisScale,'ylim',AxisScale);
line([AxisScale(1),AxisScale(2)],[AxisScale(1),AxisScale(2)],'Color',[.7 .7 .7],'LineWidth',1.8,'LineStyle','--');
text(0.5*AxisScale(2),0.9*AxisScale(2),sprintf('p = %.3f',p));
box off
set(gca,'FontSize',16);
xlabel('Behav. boundary');
ylabel('Neuro. boundary');
title('Behav and Neuro curve boundary comprasion plot');
saveas(hhf,'Boundary behav and neuro compare plot');
saveas(hhf,'Boundary behav and neuro compare plot','png');
saveas(hhf,'Boundary behav and neuro compare plot','pdf');
