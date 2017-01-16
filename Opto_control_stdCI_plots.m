for nSession = 1 : 6
%     nSession = 1;
    DataUsage = DataSum{nSession};
    %
    cOptoDataCell = DataUsage.optoBootResult;
    cContDataCell = DataUsage.ContBootResult;
    cOptoDatamat = 1 - cell2mat(cOptoDataCell);
    cContDatamat = 1 - cell2mat(cContDataCell);
    
%     cOptoDataCell = accuracy_Opto{nSession};
%     cContDataCell = accuracy_nonOpto{nSession};
%     cOptoDatamat = cOptoDataCell(end,:);
%     cContDatamat = cContDataCell(end,:);
    
    %
    Optomean = mean(cOptoDatamat);
    OptoDatasem = std(cOptoDatamat)/sqrt(numel(cOptoDatamat));
    ts = tinv([0.025  0.975],length(cOptoDatamat)-1); 
    optoUpLowBond = Optomean + ts*OptoDatasem;
    OptoDatasem = std(cOptoDatamat);
%     optoUpLowBond = quantile(cOptoDatamat,[0.025,0.975]);

    Contmean = mean(cContDatamat);
    ContDatasem = std(cContDatamat)/sqrt(numel(cContDatamat));
    ts = tinv([0.025  0.975],length(cContDatamat)-1);
    ContUpLowBond = Contmean + ts*ContDatasem;
    ContDatasem = std(cContDatamat);
%     ContUpLowBond = quantile(cContDatamat,[0.025,0.975]);
    
    x = randi(50, 1, 100);                      % Create Data
    SEM = std(x)/sqrt(length(x));               % Standard Error
    ts = tinv([0.025  0.975],length(x)-1);      % T-Score
    CI = mean(x) + ts*SEM;                      % Confidence Intervals

    %
    h = figure;
    hold on;
    bar(1,Optomean,0.2,'FaceColor','r','EdgeColor','none','facealpha',0.5);
    bar(2,Contmean,0.2,'FaceColor','k','EdgeColor','none','facealpha',0.5);
    xlim([0 3]);
    errorbar([0.8,1.2],[Optomean Optomean],[OptoDatasem Optomean - optoUpLowBond(1)],[OptoDatasem optoUpLowBond(2) - Optomean],...
        'ro','LineWidth',1.4);
    errorbar([1.8,2.2],[Contmean Contmean],[ContDatasem Contmean - ContUpLowBond(1)],[ContDatasem ContUpLowBond(2) - Contmean],...
        'ko','LineWidth',1.4);
    text([0.7,1.7],[Optomean,Contmean],'std','HorizontalAlignment','right');
    text([1.3,2.3],[Optomean,Contmean],'95% CI','HorizontalAlignment','left');
    ylim([0 1]);
    set(gca,'xtick',[1,2],'xticklabel',{'Opto','Control'},'ytick',[0,0.5,1]);
    set(gca,'FontSize',16);
    ylabel('Classification accuracy');
    saveas(h,sprintf('Session%d accuracy plots',nSession));
    saveas(h,sprintf('Session%d accuracy plots',nSession),'png');
    close(h);
end