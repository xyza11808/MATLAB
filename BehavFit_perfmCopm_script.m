
% combining multisession SVM data together to do performance t-test
m = 1;
add_char = 'y';
UsedNamePath = {};
MeanPerform = [];
InputData = {};
SessionCenter = [];
SelectOctAll = [];
while ~strcmpi(add_char,'n')
    [fn ,fp,~] = uigetfile('randCurveFit.mat','Please Select your behavior and model compare data');
    cd(fp);
    UsedNamePath(m) = {fullfile(fp,fn)};
    xx = load(fullfile(fp,fn));
    OctDiff = max(xx.Octavex) - min(xx.Octavex);
    SelectOctAll(m,:) = xx.Octavex;
    if OctDiff < 2
        fprintf('Current Session Frequency isn''t includes training frequency, using all frequencies for calculation');
        ConsiderInds = true(size(xx.Octavex));
    else
        ConsiderInds = true(size(xx.Octavex));
        ConsiderInds(1) = false;
        ConsiderInds(end) = false;
    end
    TimeCourse = input('Please input current session time scale:\n','s');
    RealTime = str2num(TimeCourse);
    if length(RealTime) == 1
        CenterTime = RealTime/2;
    else
        CenterTime = mean(RealTime);
    end
    SessionCenter(m) = CenterTime;
    SelectOct = xx.Octavex(ConsiderInds);
    SelectBehav = xx.realy;
    SelectFit = xx.fityAll;
    HalfLength = length(SelectOct)/2;
    SelectBehav(1:HalfLength) = 1 - SelectBehav(1:HalfLength);
    SelectFit(1:HalfLength) = 1 - SelectFit(1:HalfLength);
    MeanPerform(m,1:2) = [mean(SelectBehav),mean(SelectFit)];
    InputData(m,1:2) = {SelectBehav,SelectFit};
    add_char = input('Do you want to add another session data?\n','s');
    m = m + 1;
end

%%
m=m-1;
Savepath = uigetdir(pwd,'Please select a folder to save current result');
cd(Savepath);
save ModelBehavComp.mat UsedNamePath MeanPerform InputData SessionCenter SelectOctAll -v7.3
fID = fopen('SVMBahevpath.txt','w+');
formatSpec = '%s\n';
fprintf(fID,'Data path used for model and behav performance comparament:\n');
for NSession = 1 : m
    cDataPath = UsedNamePath{NSession};
    fprintf(fID,formatSpec,cDataPath);
end
fclose(fID);

%%
BeforeDataInds = SessionCenter == -0.4;
BeforeBehavFitData = MeanPerform(BeforeDataInds,:);
AfterInds = SessionCenter == 0.75;
AfterBehavFitData = MeanPerform(AfterInds,:);
LateInds = SessionCenter == 3;
LateBehavFitData = MeanPerform(LateInds,:);

%%
BeforeDataCenter = -0.4;
AfterDataCenter = 0.75;
LateDataCenter = 3;
Variation = 0.2;

f_all = figure('position',[300,150,1050,900],'PaperPositionMode','auto');
hold on;
scatter((BeforeDataCenter + (rand(sum(BeforeDataInds),1)-0.5)*2*Variation - Variation),BeforeBehavFitData(:,1),100,'ko','filled');
scatter((BeforeDataCenter + (rand(sum(BeforeDataInds),1)-0.5)*2*Variation + Variation),BeforeBehavFitData(:,2),100,'ro','filled');

scatter((AfterDataCenter + (rand(sum(AfterInds),1)-0.5)*2*Variation - Variation),AfterBehavFitData(:,1),100,'ko','filled');
scatter((AfterDataCenter + (rand(sum(AfterInds),1)-0.5)*2*Variation + Variation),AfterBehavFitData(:,2),100,'ro','filled');

scatter((LateDataCenter + (rand(sum(LateInds),1)-0.5)*2*Variation - Variation),LateBehavFitData(:,1),100,'ko','filled');
scatter((LateDataCenter + (rand(sum(LateInds),1)-0.5)*2*Variation + Variation),LateBehavFitData(:,2),100,'ro','filled');

errorbar(BeforeDataCenter-Variation,mean(BeforeBehavFitData(:,1)),std(BeforeBehavFitData(:,1))/sqrt(sum(BeforeDataInds)),'co','LineWidth',3);
errorbar(BeforeDataCenter+Variation,mean(BeforeBehavFitData(:,2),'omitnan'),std(BeforeBehavFitData(:,2),'omitnan')/sqrt(sum(BeforeDataInds)),'bo','LineWidth',3);
errorbar(AfterDataCenter-Variation,mean(AfterBehavFitData(:,1)),std(AfterBehavFitData(:,1))/sqrt(sum(AfterInds)),'co','LineWidth',3);
errorbar(AfterDataCenter+Variation,mean(AfterBehavFitData(:,2)),std(AfterBehavFitData(:,2))/sqrt(sum(AfterInds)),'bo','LineWidth',3);
errorbar(LateDataCenter-Variation,mean(LateBehavFitData(:,1)),std(LateBehavFitData(:,1))/sqrt(sum(LateInds)),'co','LineWidth',3);
errorbar(LateDataCenter+Variation,mean(LateBehavFitData(:,2)),std(LateBehavFitData(:,2))/sqrt(sum(LateInds)),'bo','LineWidth',3);
%%
xtickInds = [BeforeDataCenter,AfterDataCenter,LateDataCenter];
set(gca,'xtick',xtickInds ,'xticklabel',{'BeforeSound','AfterSound','Late'});
ylabel('Fraction of correct');
ylim([0,1.2]);
title('Time Varied population information')
[h_before,p_before] = ttest2(BeforeBehavFitData(:,1),BeforeBehavFitData(:,2));
[h_after,p_after] = ttest2(AfterBehavFitData(:,1),AfterBehavFitData(:,2));
[h_late,p_late] = ttest2(LateBehavFitData(:,1),LateBehavFitData(:,2));
h_all = [h_before,h_after,h_late];
p_all = [p_before,p_after,p_late];
scatter(xtickInds(logical(h_all)),ones(sum(h_all),1),40,'k*');
hold off;
set(gca,'fontsize',20);
saveas(f_all,'BehavModelPerf Compare','png');
saveas(f_all,'BehavModelPerf Compare','fig');
save Baseic_plot_result.mat xtickInds BeforeBehavFitData AfterBehavFitData LateBehavFitData h_all p_all -v7.3


%%
PlotCenters = [1,3,7,9,13,15];
PlotHeight = [mean(BeforeBehavFitData(:,1)),mean(BeforeBehavFitData(:,2),'omitnan'),...
    mean(AfterBehavFitData(:,1)),mean(AfterBehavFitData(:,2)),...
    mean(LateBehavFitData(:,1)),mean(LateBehavFitData(:,2))];
PlotError = [std(BeforeBehavFitData(:,1))/sqrt(sum(BeforeDataInds)),std(BeforeBehavFitData(:,2),'omitnan')/sqrt(sum(BeforeDataInds)),...
    std(AfterBehavFitData(:,1))/sqrt(sum(AfterInds)),std(AfterBehavFitData(:,2))/sqrt(sum(AfterInds)),...
    std(LateBehavFitData(:,1))/sqrt(sum(LateInds)),std(LateBehavFitData(:,2))/sqrt(sum(LateInds))];

f_all2 = figure('position',[300,150,1050,900],'PaperPositionMode','auto');
hold on;
bar(PlotCenters([1,3,5]),PlotHeight([1,3,5]),0.2,'k');  %'FaceColor','w','EdgeColor','k','LineWidth',2,[0.3 0.3 0.6]
bar(PlotCenters([2,4,6]),PlotHeight([2,4,6]),0.2,'r');
% alpha(0.4);
for n = 1 : sum(BeforeDataInds)
    plot([1,3],[BeforeBehavFitData(n,1),BeforeBehavFitData(n,2)],'color',[.5 .5 .5],'LineWidth',4);
    plot([7,9],[AfterBehavFitData(n,1),AfterBehavFitData(n,2)],'color',[.5 .5 .5],'LineWidth',4);
    plot([13,15],[LateBehavFitData(n,1),LateBehavFitData(n,2)],'color',[.5 .5 .5],'LineWidth',4);
end
errorbar(PlotCenters,PlotHeight,PlotError,'ko','LineWidth',3,'MarkerSize',0.1);

set(gca,'xtick',[2,8,14] ,'xticklabel',{'BeforeSound','AfterSound','Late'});
ylabel('Fraction of correct');
set(gca,'ytick',[0 0.5 1])
ylim([0,1.1]);
title('Time course of population decoding')
set(gca,'fontsize',20);
hold off
saveas(f_all2,'BehavModelPerf Compare bar','png');
saveas(f_all2,'BehavModelPerf Compare bar','fig');


%%
% for only one group within comparation
CMeanPerform = MeanPerform';
fcomp=figure;
hold on;
bar(1,mean(CMeanPerform(1,:)),0.2,'k');
bar(2,mean(CMeanPerform(2,:)),0.2,'r');
line([ones(11,1),2*ones(11,1)]',CMeanPerform,'color',[.5 .5 .5],'LineWidth',4);
PlotError = [std(CMeanPerform(1,:))/sqrt(numel(CMeanPerform(1,:))),std(CMeanPerform(2,:))/sqrt(numel(CMeanPerform(2,:)))];
PlotHeight = [mean(CMeanPerform(1,:)),mean(CMeanPerform(2,:))];
errorbar([1,2],PlotHeight,PlotError,'ko','LineWidth',3,'MarkerSize',0.1);
xlim([0 3]);
set(gca,'xtick',[1 2],'xticklabel',{'Behav','Neuro'});
set(gca,'ytick',[0 0.5 1])
ylabel('Fraction of correct');
[h,p] = ttest(CMeanPerform(1,:),CMeanPerform(2,:));
title({'Decision time performance',sprintf('p=%.4f',p)});
set(gca,'fontsize',20);
hold off
saveas(fcomp,'BehavModelPerfSingle Compare bar','png');
saveas(fcomp,'BehavModelPerfSingle Compare bar','fig');
