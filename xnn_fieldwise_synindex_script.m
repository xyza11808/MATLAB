ROITypeStrs = {'AllROI','AllNeu','ActNeu','AllAst','ActAst','ActROIs'};

WT_popuSynchronyVecEO = cell2mat(cat(1,WT_popuSynchrony_EveOy{:,1}));
Tg_popuSynchronyVecEO = cell2mat(cat(1,Tg_popuSynchrony_EveOy{:,1}));
AnaInds = 2; % 2 indecates all neurons
EOPopuSynIndexMeanSEM = [mean(WT_popuSynchronyVecEO(:,AnaInds)),std(WT_popuSynchronyVecEO(:,AnaInds))/sqrt(size(WT_popuSynchronyVecEO,1));...
    mean(Tg_popuSynchronyVecEO(:,AnaInds)),std(Tg_popuSynchronyVecEO(:,AnaInds))/sqrt(size(Tg_popuSynchronyVecEO,1))];

[~,p1] = ttest2(WT_popuSynchronyVecEO(:,AnaInds),Tg_popuSynchronyVecEO(:,AnaInds));

HSynf_EO = figure('position',[100 100 420 300]);
% ax1 = subplot(121);
hold on;
bar(1,EOPopuSynIndexMeanSEM(1,1),0.5,'FaceColor',[.7 .7 .7],'edgecolor','none');
bar(2,EOPopuSynIndexMeanSEM(2,1),0.5,'FaceColor','r','edgecolor','none');
errorbar([1 2],EOPopuSynIndexMeanSEM(:,1),EOPopuSynIndexMeanSEM(:,2),'k.','linewidth',1.5,'Marker','none');
GroupSigIndication([1,2],EOPopuSynIndexMeanSEM(:,1),p1,HSynf_EO,1.15);
set(gca,'xlim',[0.4 2.6],'xtick',[1,2],'xticklabel',{'Ctrl','Drug'},'box','off');
yscales = get(gca,'ylim');
text(0.8,yscales(2)*0.85,sprintf('p = %.4f',p1),'HorizontalAlignment','center');
ylabel('Sync Index');
title(sprintf('p12WT %s EventOnly SynchronyIndex',ROITypeStrs{AnaInds}));

%%
cclr
p12_synIndex_strc = load('p12synchronyindex.mat');
p18_synIndex_strc = load('p18synchronyindex.mat');
M4_synIndex_strc = load('M4synchronyindex.mat');
%%
ROITypes = p12_synIndex_strc.ROITypeStrs;

PlotTypw = 2;

p12_wt_datas = (p12_synIndex_strc.WT_popuSynchronyVecEO(:,PlotTypw));
p12_tg_datas = (p12_synIndex_strc.Tg_popuSynchronyVecEO(:,PlotTypw));

p18_wt_datas = (p18_synIndex_strc.WT_popuSynchronyVecEO(:,PlotTypw));
p18_tg_datas = (p18_synIndex_strc.Tg_popuSynchronyVecEO(:,PlotTypw));

M4_wt_datas = (M4_synIndex_strc.WT_popuSynchronyVecEO(:,PlotTypw));
M4_tg_datas = (M4_synIndex_strc.Tg_popuSynchronyVecEO(:,PlotTypw));

%%

WTColors = {[.2 .2 .2],[.5 .5 .5],[.7 .7 .7]};
TgColors = {[.6 .3 .3],[.8 .2 .2],[.9 .1 .1]};

hccf = figure('position',[100 200 680 320]);
ax1 = subplot(121);
hold on
% wt data plot
PlotAvgs = [mean(p12_wt_datas),mean(p18_wt_datas),...
        mean(M4_wt_datas)];
Plotfieldnums = [numel(p12_wt_datas),numel(p18_wt_datas),...
    numel(M4_wt_datas)];

PlotSEMs = [std(p12_wt_datas)/sqrt(Plotfieldnums(1)),...
    std(p18_wt_datas)/sqrt(Plotfieldnums(2)),...
    std(M4_wt_datas)/sqrt(Plotfieldnums(3))];


[~,p12_p18_p] = ttest2(p12_wt_datas,p18_wt_datas);
[~,M4_p18_p] = ttest2(p18_wt_datas,M4_wt_datas);
[~,M4_p12_p] = ttest2(p12_wt_datas,M4_wt_datas);


for ccp = 1 : 3
    bar(ccp,PlotAvgs(ccp),0.6,'edgecolor','none','Facecolor',WTColors{ccp});
end
errorbar(1:3,PlotAvgs,PlotSEMs,'k.','Marker','none','linewidth',1.2);

text(1:3,PlotAvgs*0.8,cellstr(num2str(Plotfieldnums(:),'%d')),...
    'HorizontalAlignment','center','Fontsize',8,'color','c');

GroupSigIndication([1,2],PlotAvgs(1:2),p12_p18_p,ax1,1.2,[],6);
GroupSigIndication([2,3],PlotAvgs(2:3),M4_p18_p,ax1,1.3,[],6);

GroupSigIndication([1,3],PlotAvgs([1,3]),M4_p12_p,ax1,1.4,[],6);

set(ax1,'xtick',1:3,'xticklabel',{'p12','p18','M4'},'xlim',[0 4]);
ylabel('Active frac.');
xlabel('WT');


% %%%%%%%%%%%%%%%%%%%%%%%%%%%
ax2 = subplot(122);
hold on
% wt data plot
PlotAvgs = [mean(p12_tg_datas),mean(p18_tg_datas),...
        mean(M4_tg_datas)];
Plotfieldnums = [numel(p12_tg_datas),numel(p18_tg_datas),...
    numel(M4_tg_datas)];

PlotSEMs = [std(p12_tg_datas)/sqrt(Plotfieldnums(1)),...
    std(p18_tg_datas)/sqrt(Plotfieldnums(2)),...
    std(M4_tg_datas)/sqrt(Plotfieldnums(3))];


[~,p12_p18_p] = ttest2(p12_tg_datas,p18_tg_datas);
[~,M4_p18_p] = ttest2(p18_tg_datas,M4_tg_datas);
[~,M4_p12_p] = ttest2(p12_tg_datas,M4_tg_datas);


for ccp = 1 : 3
    bar(ccp,PlotAvgs(ccp),0.6,'edgecolor','none','Facecolor',TgColors{ccp});
end
errorbar(1:3,PlotAvgs,PlotSEMs,'k.','Marker','none','linewidth',1.2);

text(1:3,PlotAvgs*0.8,cellstr(num2str(Plotfieldnums(:),'%d')),...
    'HorizontalAlignment','center','Fontsize',8,'color','c');

GroupSigIndication([1,2],PlotAvgs(1:2),p12_p18_p,ax2,1.2,[],6);
GroupSigIndication([2,3],PlotAvgs(2:3),M4_p18_p,ax2,1.3,[],6);

GroupSigIndication([1,3],PlotAvgs([1,3]),M4_p12_p,ax2,1.4,[],6);

set(ax2,'xtick',1:3,'xticklabel',{'p12','p18','M4'},'xlim',[0 4]);
ylabel('Active frac.');
xlabel('Tg');

%%
saveas(hccf,'Synchrony index across group compare plot');
saveas(hccf,'Synchrony index across group compare plot','png');
saveas(hccf,'Synchrony index across group compare plot','pdf');


