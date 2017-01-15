
% nSession = 1;
[BetGrMask,WithinGrMask,~] = GroupDataMask(6);
for nSession = 1 : 8
    nSessionData = DataSum{nSession};
    cMatrixData = nSessionData.MatrixWiseAUCSelect;
    %
    
    BetGrData = cMatrixData(:,BetGrMask);
    WithinGeData = cMatrixData(:,WithinGrMask);
    BetGrMean = mean(BetGrData,2);
    WithinGrMean = mean(WithinGeData,2);

    %
    h = figure;
    scatter(BetGrMean,WithinGrMean,40,'ro','Linewidth',1.6);
    xlims = get(gca,'xlim');
    line(xlims,xlims,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
    set(gca,'xlim',xlims,'ylim',xlims);
    xlabel('BetClass AUC');
    ylabel('WithinClass AUC');
    title(sprintf('Session%d mean AUC compare plot',nSession));
    set(gca,'FontSize',20);
    saveas(h,sprintf('Session%d Mean auc compare plot',nSession));
    saveas(h,sprintf('Session%d Mean auc compare plot',nSession),'png');
    close(h);
end

%%
PassiveData = load('K:\Xulab_Share_Nutstore\Xin_Yu\Data_Sharing\Paired_AUC_Analysis\passive\cDataSetSaveNew.mat');
TaskData = load('K:\Xulab_Share_Nutstore\Xin_Yu\Data_Sharing\Paired_AUC_Analysis\Task\cDataSetSaveNew.mat');
[BetGrMask,WithinGrMask,~] = GroupDataMask(6);
for nSession = 1:8
    nSessionDataPass = PassiveData.DataSum{nSession};
    cMatrixDataPass = nSessionDataPass.MatrixWiseAUCSelect;
    
    nSessionDataTask = TaskData.DataSum{nSession};
    cMatrixDataTask = nSessionDataTask.MatrixWiseAUCSelect;
    
    PassBetData = mean(cMatrixDataPass(:,BetGrMask),2);
    TaskBetData = mean(cMatrixDataTask(:,BetGrMask),2);
    
    PassWithinData = mean(cMatrixDataPass(:,WithinGrMask),2);
    TaskWithinData = mean(cMatrixDataTask(:,WithinGrMask),2);
    
    hf = figure('position',[200 200 1200 800]);
    subplot(1,2,1)
    scatter(TaskBetData,PassBetData,40,'ro','Linewidth',1.6);
    xlims = get(gca,'xlim');
    line(xlims,xlims,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
    set(gca,'xlim',xlims,'ylim',xlims);
    xlabel('Task BetClass AUC');
    ylabel('Passive BetClass AUC');
    [~,p] = ttest(TaskBetData,PassBetData);
    title(sprintf('Between class tetst p=%.4f',p));
    set(gca,'FontSize',20);
    
    subplot(1,2,2)
    scatter(TaskWithinData,PassWithinData,40,'ro','Linewidth',1.6);
    xlims = get(gca,'xlim');
    line(xlims,xlims,'Color',[.7 .7 .7],'LineWidth',1.6,'LineStyle','--');
    set(gca,'xlim',xlims,'ylim',xlims);
    xlabel('Task WithinClass AUC');
    ylabel('Passive WithinClass AUC');
    [~,p] = ttest(TaskWithinData,PassWithinData);
    title(sprintf('Within class tetst p=%.4f',p));
    set(gca,'FontSize',20);
    
    suptitle(sprintf('Session%d compare plot',nSession));
    saveas(hf,sprintf('SaveType compare plot session%d',nSession));
    saveas(hf,sprintf('SaveType compare plot session%d',nSession),'png');
    close(hf);
end

%%
PassiveData = load('K:\Xulab_Share_Nutstore\Xin_Yu\Data_Sharing\Paired_AUC_Analysis\passive\cDataSetSaveNew.mat');
TaskData = load('K:\Xulab_Share_Nutstore\Xin_Yu\Data_Sharing\Paired_AUC_Analysis\Task\cDataSetSaveNew.mat');

[BetGrMask,WithinGrMask,~] = GroupDataMask(6);
VaryScale = 0.2;
for nSession = 1:8
    %
    nSessionDataPass = PassiveData.DataSum{nSession};
    cMatrixDataPass = nSessionDataPass.MatrixWiseAUCSelect;
    
    nSessionDataTask = TaskData.DataSum{nSession};
    cMatrixDataTask = nSessionDataTask.MatrixWiseAUCSelect;
    
    PassBetData = mean(cMatrixDataPass(:,BetGrMask),2);
    TaskBetData = mean(cMatrixDataTask(:,BetGrMask),2);
    
    PassWithinData = mean(cMatrixDataPass(:,WithinGrMask),2);
    TaskWithinData = mean(cMatrixDataTask(:,WithinGrMask),2);
    
    TaskDiff = TaskBetData - TaskWithinData;
    PassDiff = TaskWithinData - PassBetData;
    nPoints = length(PassDiff);
    
    hf = figure('position',[200 200 800 800]);
    hold on;
    bar([1,2],[mean(TaskBetData - TaskWithinData),mean(PassBetData - PassWithinData)],'FaceColor','c','EdgeColor','none');
    scatter((ones(nPoints,1) + (rand(nPoints,1)-0.5)*VaryScale),(TaskBetData - TaskWithinData),20,'ko');
    scatter((ones(nPoints,1)*2 + (rand(nPoints,1)-0.5)*VaryScale),(PassBetData - PassWithinData),20,'ko');
    [~,pTask] = ttest(TaskBetData - TaskWithinData);
    [~,pPass] = ttest(PassBetData - PassWithinData);
    ylim = get(gca,'ylim');
    text([1.5 1.5],[ylim(2)-0.05,ylim(2)-0.15],{sprintf('Task p = %.3f',pTask),sprintf('Passive p = %.3f',pPass)},...
        'FontSize',12,'HorizontalAlignment','center');
    
    set(gca,'xtick',[1,2],'xticklabel',{'Task','Passive'});
    title(sprintf('Session %d diff plot',nSession));
    set(gca,'FontSize',16);
    %
%     title(sprintf('Session%d compare plot',nSession));
    saveas(hf,sprintf('SaveType compare plot session%d',nSession));
    saveas(hf,sprintf('SaveType compare plot session%d',nSession),'png');
    close(hf);
end
