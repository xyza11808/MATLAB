% SessAUCDataAll{nSess,1} = Task1_5Data;
% SessAUCDataAll{nSess,2} = Task1Data;
% SessAUCDataAll{nSess,3} = Pass1_5Data;
% SessAUCDataAll{nSess,4} = Pass1Data;

% TaskSessAUCAll = cell2mat(TaskSess1s_sum');
% PassSessAUCAll = cell2mat(PassSess1s_sum');
% TaskSessRevert = cell2mat(TaskSess1s_isRevert');
% PassSessRevert = cell2mat(PassSess1s_isRevert');

% since unequal number of ROIs exist for some session
UsedROInum = cell(nSessions,1);
for cSess = 1 : nSessions
    UsedROInum{cSess} = length(SessAUCDataAll{cSess,2}.ROCareaReal);
end

nSessions = size(SessAUCDataAll,1);
TaskSess1s_sum = cellfun(@(x,y) x.ROCareaReal(1:y),SessAUCDataAll(:,2),UsedROInum,'Uniformoutput',false);
PassSess1s_sum = cellfun(@(x,y) x.ROCareaReal(1:y),SessAUCDataAll(:,4),UsedROInum,'Uniformoutput',false);
TaskSess1s_isRevert = cellfun(@(x,y) x.IsRevert(1:y),SessAUCDataAll(:,2),UsedROInum,'Uniformoutput',false);
PassSess1s_isRevert = cellfun(@(x,y) x.IsRevert(1:y),SessAUCDataAll(:,4),UsedROInum,'Uniformoutput',false);
% summed ROIs all together
TaskSessAUCAll = cell2mat(TaskSess1s_sum');
PassSessAUCAll = cell2mat(PassSess1s_sum');
TaskSessRevert = cell2mat(TaskSess1s_isRevert');
PassSessRevert = cell2mat(PassSess1s_isRevert');
%% AUCValue compare
TaskSessABSAUCAll = TaskSessAUCAll;
PassSessABSAUCAll = PassSessAUCAll;
TaskSessABSAUCAll(logical(TaskSessRevert)) = 1 - TaskSessABSAUCAll(logical(TaskSessRevert));
PassSessABSAUCAll(logical(PassSessRevert)) = 1 - PassSessABSAUCAll(logical(PassSessRevert));
%% plot the final data
[mds,CurveData] = lmFunCalPlot(TaskSessABSAUCAll,PassSessABSAUCAll,0);
AUC_p = ranksum(TaskSessABSAUCAll,PassSessABSAUCAll);
hf = figure('position',[100 100 380 300]);
hold on
plot(TaskSessABSAUCAll,PassSessABSAUCAll,'o','MarkerEdgeColor','none','MarkerFaceColor',[.7 .7 .7],'MarkerSize',4);
line([0.3 1],[0.3 1],'Color','k','Linewidth',1.8,'linestyle','--');
plot(CurveData(:,1),CurveData(:,2),'Color',[1 0.7 0.2],'linewidth',1.6);
plot(CurveData(:,1),CurveData(:,3),'Color',[1 0.8 0.5],'linewidth',1.6,'linestyle','-.');
plot(CurveData(:,1),CurveData(:,4),'Color',[1 0.8 0.5],'linewidth',1.6,'linestyle','-.');
text(0.35,0.95,sprintf('TaskAvg-%.4f-%.4f',mean(TaskSessABSAUCAll),std(TaskSessABSAUCAll)),'Color',[1 0.7 0.2],'FontSize',8);
text(0.35,0.9,sprintf('TaskAvg-%.4f-%.4f',mean(PassSessABSAUCAll),std(PassSessABSAUCAll)),'Color',[0.2 0.2 0.2],'FontSize',8);
title(sprintf('P = %.3e',AUC_p));
set(gca,'xlim',[0.3 1],'ylim',[0.3 1],'xtick',[0.3 0.5 1],'ytick',[0.3 0.5 1]);
saveas(hf,'Task Passive AUC compare plots');
saveas(hf,'Task Passive AUC compare plots','pdf');
