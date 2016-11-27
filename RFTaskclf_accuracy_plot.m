% this scription is used for plot rf and 2afc distance-dependence of
% stimclassification accuracy plot
TimeWin = 1.5;
RFData = multiCClass(SelectData,SelectSArray,ones(length(SelectSArray),1),frame_rate,frame_rate,1.5);

%%
% loading 2afc data for comparation plot
[fn,fp,fi] = uigetfile('DisErrorDataAllSave.mat','please select your task classification reult for each stimulus pair');
if ~fi
    fprintf('Abort task data file selection, quit following analysis.');
else
    if ~isdir('./Task_rf_errorplot/')
        mkdir('./Task_rf_errorplot/');
    end
    cd('./Task_rf_errorplot/');
    fprintf('Loading file name %s...\n',fullfile(fp,fn));
    TaskData = load(fullfile(fp,fn));
    TaskBetDiff = TaskData.BetweenClassCorrDataM(:,2) * TaskData.OvatveStep;  % octave steps for task data, between class
    TaskLWNDiff = TaskData.LeftClassCorrDataM(:,2) * TaskData.OvatveStep;  
    TaskRWNDiff = TaskData.RightClassCorrDataM(:,2) * TaskData.OvatveStep; 
    RFDataDiffSummary = [RFData.BCCDM;RFData.LCCDM;RFData.RCCDM];
    RFDisTypes = unique(RFDataDiffSummary(:,2));
    RFDisError = zeros(length(RFDisTypes),2);
    for nmnm = 1 : length(RFDisTypes)
        cDis = RFDisTypes(nmnm);
        cDisError = mean(RFDataDiffSummary(cDis,1));
        RFDisError(nmnm,:) = [cDisError,cDis];
    end
    %
    hcomp = figure('position',[200 200 1000 800]);
    hold on;
    h1 = plot(RFDisError(:,2)*RFData.OvatveStep,RFDisError(:,1),'k-o','LineWidth',1.6,'LineStyle','--');
    h2 = plot(TaskBetDiff,TaskData.BetweenClassCorrDataM(:,1),'k-o','LineWidth',1.6);
    h3 = plot(TaskLWNDiff,TaskData.LeftClassCorrDataM(:,1),'b-o','LineWidth',1.6);
    h4 = plot(TaskRWNDiff,TaskData.RightClassCorrDataM(:,1),'r-o','LineWidth',1.6);
    xlabel('Octave Diff');
    ylabel('Error rate');
    title('RF vs task compare plot of error rate');
    set(gca,'FontSize',20);
    legend([h1,h2,h3,h4],{'RF data','BetweenClass','LeftWithinClass','RightWithinClass'},'FontSize',12);
    saveas(hcomp,'RF and task compare plot');
    saveas(hcomp,'RF and task compare plot','png');
    close(hcomp);
    save DataSummary.mat RFData TaskData -v7.3
    cd ..;
    %bar plot of the error rate distribution between task and rf data
end