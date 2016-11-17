
%loading 2afc index
[fn2afc,fp2afc,fi2] = uigetfile('FreqMeanData.mat','Please select your 2afc analysis index value');
if fi2
    xx = load(fullfile(fp2afc,fn2afc));
    TuDIndex2afc = xx.TDindex;
    ClIndex2afc = xx.CIindex;
end

%%
% loading rf index
[fnrf,fprf,firf] = uigetfile('FreqMeanData.mat','Please select your rf analysis index value');
if firf
    xx = load(fullfile(fprf,fnrf));
    TuDIndexrf = xx.TDindex;
    ClIndexrf = xx.CIindex;
end

%%
% comparing the value between two different conditions
if length(TuDIndex2afc) ~= length(TuDIndexrf)
    fprintf('2afc ROI number %d is different from rf ROI number %d,\n',length(TuDIndex2afc),length(TuDIndexrf));
    ChoiceChar = input('Continue analysis?\n','s');
    if strcmpi(ChoiceChar,'n')
        return;
    else
        TargetIndx = min(length(TuDIndex2afc),length(TuDIndexrf));
        TuDIndex2afcP = TuDIndex2afc(1:TargetIndx);
        ClIndex2afcP = ClIndex2afc(1:TargetIndx);
        TuDIndexrfP = TuDIndexrf(1:TargetIndx);
        ClIndexrfP = ClIndexrf(1:TargetIndx);
    end
else
    TargetIndx = length(TuDIndex2afc);
    TuDIndex2afcP = TuDIndex2afc(1:TargetIndx);
    ClIndex2afcP = ClIndex2afc(1:TargetIndx);
    TuDIndexrfP = TuDIndexrf(1:TargetIndx);
    ClIndexrfP = ClIndexrf(1:TargetIndx);
end
%%
% scatter plot of two index
h_tdindex = figure('position',[300,120,1000,850]);
scatter(TuDIndex2afcP, TuDIndexrfP,40,'r*');
set(gca,'xlim',[0 1],'ylim',[0 1]);
line([0 1],[0 1],'color',[.8 .8 .8],'LineWidth',1.5);
xlabel('2afc Index');
ylabel('rf Index');
set(gca,'FontSize',20);
title('Tuning depth plot');
saveas(h_tdindex,'Tuning depth plot for comparation');
saveas(h_tdindex,'Tuning depth plot for comparation','png');

h_CIindex = figure('position',[300,120,1000,850]);
scatter(ClIndex2afcP,ClIndexrfP,40,'r*');
set(gca,'xlim',[0 1],'ylim',[0 1]);
line([0 1],[0 1],'color',[.8 .8 .8],'LineWidth',1.5);
xlabel('2afc Index');
ylabel('rf Index');
set(gca,'FontSize',20);
title('Classification index plot');
saveas(h_CIindex,'Classification index plot for comparation');
saveas(h_CIindex,'Classification index plot for comparation','png');

%%
hhx1 = figure('position',[300,120,1000,850]);
h = scatterhist(ClIndex2afcP, ClIndexrfP,'Location','NorthEast','Direction','out','color','k','Linewidth',2,'NBins',[20,20],'LineStyle',{'-'});
set(h(1),'FontSize',16)
set(h(1),'XAxisLocation','bottom','YAxisLocation','left')
set(h(1),'xtick',0:0.2:1,'ytick',0:0.2:1)
axes(h(1));
line([0.5,0.5],[0 1],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
line([0 1],[0.5 0.5],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
line([0 1],[0 1],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
xlim([0 1]);ylim([0 1]);
% x axis plot
histogram(h(2),ClIndex2afcP,20,'FaceColor','none','edgeColor','k','LineWidth',2);
set(h(2),'box','off');
axis(h(2),'off','tight');
xaxis = axis(h(2));
axes(h(2));
line([0 1],[0 0],'color','k','LineWidth',1.5)
line([0.5 0.5],[0 xaxis(4)],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
xlim([0 1])
% y axis plot
histogram(h(3),ClIndexrfP,20,'FaceColor','none','edgeColor','k','LineWidth',2);
axes(h(3));line([0 1],[0 0],'color','k','LineWidth',1.5)
yaxis = axis(h(3));
axes(h(3));line([0.5 0.5],[0 yaxis(4)],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
xlim([0 1])
view(h(3),90,270); 
set(h(3),'box','off');
axis(h(3),'off','tight');
% xlabel(h(3),'hehe1')

saveas(hhx1,'CI Scatter hist plot');
saveas(hhx1,'CI Scatter hist plot','png');
close(hhx1);

%%
hhx2 = figure('position',[300,120,1000,850]);
h = scatterhist(TuDIndex2afcP, TuDIndexrfP,'Location','NorthEast','Direction','out','color','k','Linewidth',2,'NBins',[20,20],'LineStyle',{'-'});
set(h(1),'FontSize',16)
set(h(1),'XAxisLocation','bottom','YAxisLocation','left')
set(h(1),'xtick',0:0.2:1,'ytick',0:0.2:1)
axes(h(1));
line([0.5,0.5],[0 1],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
line([0 1],[0.5 0.5],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
line([0 1],[0 1],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
xlim([0 1]);ylim([0 1]);
% x axis plot
histogram(h(2),TuDIndex2afcP,20,'FaceColor','none','edgeColor','k','LineWidth',2);
set(h(2),'box','off');
axis(h(2),'off','tight');
xaxis = axis(h(2));
axes(h(2));
line([0 1],[0 0],'color','k','LineWidth',1.5)
line([0.5 0.5],[0 xaxis(4)],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
xlim([0 1])
% y axis plot
histogram(h(3),TuDIndexrfP,20,'FaceColor','none','edgeColor','k','LineWidth',2);
axes(h(3));line([0 1],[0 0],'color','k','LineWidth',1.5)
yaxis = axis(h(3));
axes(h(3));line([0.5 0.5],[0 yaxis(4)],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
xlim([0 1])
view(h(3),90,270); 
set(h(3),'box','off');
axis(h(3),'off','tight');
xlabel(h(3),'hehe1')

saveas(hhx2,'TD Scatter hist plot');
saveas(hhx2,'TD Scatter hist plot','png');
close(hhx2);


%%
close(h_CIindex);
close(h_tdindex);