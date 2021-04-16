function hsynf = FourGroupbarplots(WT_ctrl_Das,Tg_ctrl_Das,...
        WT_drug_Das,Tg_drug_Das)

WT_ctrl_Das(isnan(WT_ctrl_Das)) = [];    
Tg_ctrl_Das(isnan(Tg_ctrl_Das)) = [];
WT_drug_Das(isnan(WT_drug_Das)) = [];
Tg_drug_Das(isnan(Tg_drug_Das)) = [];

PlotAvgs = [mean(WT_ctrl_Das),mean(Tg_ctrl_Das),...
        mean(WT_drug_Das),mean(Tg_drug_Das)];
    Plotfieldnums = [numel(WT_ctrl_Das),numel(Tg_ctrl_Das),...
        numel(WT_drug_Das),numel(Tg_drug_Das)];

    PlotSEMs = [std(WT_ctrl_Das)/sqrt(Plotfieldnums(1)),...
        std(Tg_ctrl_Das)/sqrt(Plotfieldnums(2)),...
        std(WT_drug_Das)/sqrt(Plotfieldnums(3)),...
        std(Tg_drug_Das)/sqrt(Plotfieldnums(4))];

    [~,ctrl_p] = ttest2(WT_ctrl_Das,Tg_ctrl_Das);
    [~,drug_p] = ttest2(WT_drug_Das,Tg_drug_Das);

    [~,wt_p] = ttest2(WT_ctrl_Das,WT_drug_Das);
    [~,tg_p] = ttest2(Tg_ctrl_Das,Tg_drug_Das);

    hsynf = figure('position',[100 100 450 320]);
    hold on
    colors = {[0.2 0.2 0.2],[0.9 0.1 0.1],[0.6 0.6 0.6],[0.6 0.2 0.2]};
    for ccp = 1 : 4
        bar(ccp,PlotAvgs(ccp),0.6,'edgecolor','none','Facecolor',colors{ccp});
        text(ccp+0.3,PlotAvgs(ccp)+0.02,0.6,{num2str(PlotAvgs(ccp),'%.3f');num2str(PlotSEMs(ccp),'%.3f')});
    end
    errorbar(1:4,PlotAvgs,PlotSEMs,'k.','Marker','none','linewidth',1.2);

    text(1:4,PlotAvgs*0.8,cellstr(num2str(Plotfieldnums(:),'%d')),...
        'HorizontalAlignment','center','Fontsize',8,'color','c');

    GroupSigIndication([1,2],[max(PlotAvgs),max(PlotAvgs)],ctrl_p,hsynf,1.2,[],6);
    GroupSigIndication([3,4],[max(PlotAvgs),max(PlotAvgs)],drug_p,hsynf,1.2,[],6);

    GroupSigIndication([1,3],[max(PlotAvgs),max(PlotAvgs)],wt_p,hsynf,1.4,[],6);
    GroupSigIndication([2,4],[max(PlotAvgs),max(PlotAvgs)],tg_p,hsynf,1.6,[],6);


    set(gca,'xtick',1:4,'xticklabel',{'WTctrl','Tgctrl','WTdrug','Tgdrug'},'xlim',[0 5]);
    