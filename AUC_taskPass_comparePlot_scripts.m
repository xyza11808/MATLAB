% E:\DataToGo\data_for_xu\Task_Pass_AUCComp\Temp1\TaskPassSaveData.mat
UsedInds = [1,2,3,6,7,8,9,11,12,13,14];
UsedTaskCell = AFCdataAll(UsedInds);
UsedPassCell = RFdataAll(UsedInds);

%% extract cell data
TaskAUCDataCell = cellfun(@(x) x.ROCdata2afc,UsedPassCell, 'UniformOutput', false);
RFAUCDataCell = cellfun(@(x) x.ROCdataRF,UsedPassCell, 'UniformOutput', false);
TaskAUCData = cell2mat(TaskAUCDataCell');
RFAUCData = cell2mat(RFAUCDataCell');

%%
hhx1 = figure('position',[600,320,700,550],'Paperpositionmode','auto');
h = scatterhist(TaskAUCData, RFAUCData,'Location','NorthEast','Direction','out','color','k','Linewidth',2,'NBins',[20,20],...
    'LineStyle',{'-'},'MarkerSize',8,'Kernel','overlay');
set(h(1),'FontSize',16)
set(h(1),'XAxisLocation','bottom','YAxisLocation','left')
set(h(1),'xtick',0:0.2:1,'ytick',0:0.2:1)
axes(h(1));
line([0.5,0.5],[0 1],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
line([0 1],[0.5 0.5],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
line([0 1],[0 1],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
xlim([0 1]);ylim([0 1]);
xlabel('Task AUC');
ylabel('Passive AUC');
[~,p_test] = ttest2(TaskAUCData, RFAUCData);
text(0.7,0.2,sprintf('p = %.3e',p_test),'FontSize',8,'Color','b');
%
% x axis plot
% histogram(h(2),ClIndex2afcP,20,'FaceColor','none','edgeColor','k','LineWidth',2);
% set(h(2),'box','off');
% axis(h(2),'off','tight');
xaxis = axis(h(2));
axes(h(2));
% line([0 1],[0 0],'color','k','LineWidth',1.5)
line([0.5 0.5],[0 xaxis(4)],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
xlim([0 1])
% y axis plot
% histogram(h(3),ClIndexrfP,20,'FaceColor','none','edgeColor','k','LineWidth',2);
axes(h(3));
% line([0 1],[0 0],'color','k','LineWidth',1.5)
yaxis = axis(h(3));
% axes(h(3));
line([0.5 0.5],[0 yaxis(4)],'color',[.8 .8 .8],'LineWidth',1.8,'lineStyle','--');
xlim([0 1])
% view(h(3),90,270); 
set(h(3),'box','off');
axis(h(3),'off','tight');
% xlabel(h(3),'hehe1')
%
saveas(hhx1,'Task passive AUC compare plot scatter hist');
saveas(hhx1,'Task passive AUC compare plot scatter hist','png');
close(hhx1);
