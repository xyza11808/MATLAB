% scripts for summarization of plots of animal choice and predict right
% paobability from multiple sessions

addchar = 'y';
DataPath = {};
DataSum = {};
PredRightChoice = [];
PredRightChoiceAll = [];
AnmChoice = [];
WorstPerfPredRightProb = [];
WorstPerfAnmChoice = [];
m = 1;

while ~strcmpi(addchar,'n')
    [fn,fp,fi] = uigetfile('AnmChoicePredSaveNew.mat','Please select you new trial by trial analysis save reult');
    if fi
        DataPath{m} = fullfile(fp,fn);
        xx = load(DataPath{m});
        DataSum{m} = xx;
        PredRightChoiceAll = [PredRightChoiceAll,xx.IterPredChoice];
        PredRightProb = mean(xx.IterPredChoice);
        PredRightChoice = [PredRightChoice,PredRightProb];
        AnmChoice = [AnmChoice,xx.UsingAnmChoice];
        
        StimPerf = xx.StimPerformance;
        [WorstPerf,WorstInds] = min(StimPerf);
        WanmChoice = xx.UsingAnmChoice(xx.StimInds{WorstInds});
        wPredRightProb = PredRightProb(xx.StimInds{WorstInds});
        WorstPerfPredRightProb = [WorstPerfPredRightProb,wPredRightProb];
        WorstPerfAnmChoice = [WorstPerfAnmChoice,WanmChoice];
        
        m = m + 1;
    end
    
    addchar = input('Would you like to add another session''s data?\n','s');
end

%%
m = m - 1;
SavePath = uigetdir('Please select a data saving path for current session');
cd(SavePath);
f = fopen('Anmchoice_rightPredProb_summation_path.txt','w+');
fprintf(f,'Session path used for analysis anmchoice and right-side prediction probability:\r\n');
FormatStr = '%s;\r\n';
for nbnb = 1 : m
    fprintf(f,FormatStr,DataPath{nbnb});
end
fclose(f);
save SumDataSave.mat DataSum PredRightChoiceAll PredRightChoice AnmChoice WorstPerfPredRightProb WorstPerfAnmChoice -v7.3

%%
% plot the worst perfmance trials
AnmChoiceTy = unique(WorstPerfAnmChoice);
ChoiceLen = length(AnmChoiceTy);
choiceProbDis = cell(ChoiceLen,1);
% RightChoiceProb = mean(PredRightChoice);
for nxnx = 1 : ChoiceLen
    cChoice = AnmChoiceTy(nxnx);
    cChoiceInds = WorstPerfAnmChoice == cChoice;
    choiceProbDis{nxnx} = WorstPerfPredRightProb(cChoiceInds);
end

%%
[ChoceLeftCounts,ChoceLeftCenters] = hist(choiceProbDis{1},50);
ChoceLeftCounts = ChoceLeftCounts/sum(ChoceLeftCounts);
[ChoceRightCounts,ChoceRightCenters] = hist(choiceProbDis{2},50);
ChoceRightCounts = ChoceRightCounts/sum(ChoceRightCounts);
[ROCSummary,LabelMeanS]=rocOnlineFoff([WorstPerfPredRightProb(:) double(WorstPerfAnmChoice(:))]);
if LabelMeanS
    ROCSummary = 1 - ROCSummary;
end

h_dis = figure('position',[200 200 1000 800]);
hold on;
bar(ChoceLeftCenters,ChoceLeftCounts*(-1),0.4,'FaceColor','b','EdgeColor','none');
bar(ChoceRightCenters,ChoceRightCounts,0.4,'FaceColor','r','EdgeColor','none');
alpha(0.4);
plot(ChoceLeftCenters,ChoceLeftCounts*(-1),'b-o','lineWidth',1.8);
plot(ChoceRightCenters,ChoceRightCounts,'r-o','lineWidth',1.8);
xlim([0,1]);
ylimvalues = get(gca,'ylim');
set(gca,'ytick',ylimvalues+[0.1,-0.1],'yticklabel',{'Left choice','Right choice'},'xtick',[0 1]);
ylabel('Anmimal choice');
xlabel('Right choice probability');
title('Probability distribution');
set(gca,'FontSize',18);
text(0.2,0.4,sprintf('AUC = %.4f',ROCSummary),'FontSize',16,'Color','k');
text(0.2,0.3,sprintf('nTrials = %d',length(WorstPerfPredRightProb)),'FontSize',16,'Color','k');
saveas(h_dis,'Worst Perf animal choice compared with rightpred probability');
saveas(h_dis,'Worst Perf animal choice compared with rightpred probability','png');
close(h_dis);

save WorstChoiceDisPlotsave.mat ChoceLeftCenters ChoceLeftCounts ChoceRightCenters ChoceRightCounts ROCSummary WorstPerfPredRightProb WorstPerfAnmChoice -v7.3


%%
% skip following analysis for now
% plots the trial by trial choice prob
AnmChoiceTy = unique(AnmChoice);
ChoiceLen = length(AnmChoiceTy);
choiceProbDis = cell(ChoiceLen,1);
% RightChoiceProb = mean(PredRightChoice);
for nxnx = 1 : ChoiceLen
    cChoice = AnmChoiceTy(nxnx);
    cChoiceInds = AnmChoice == cChoice;
    choiceProbDis{nxnx} = PredRightChoice(cChoiceInds);
end

%%
[ChoceLeftCounts,ChoceLeftCenters] = hist(choiceProbDis{1},50);
ChoceLeftCounts = ChoceLeftCounts/sum(ChoceLeftCounts);
[ChoceRightCounts,ChoceRightCenters] = hist(choiceProbDis{2},50);
ChoceRightCounts = ChoceRightCounts/sum(ChoceRightCounts);
[ROCSummary,LabelMeanS]=rocOnlineFoff([PredRightChoice(:) double(AnmChoice(:))]);
if LabelMeanS
    ROCSummary = 1 - ROCSummary;
end

h_dis = figure('position',[200 200 1000 800]);
hold on;
bar(ChoceLeftCenters,ChoceLeftCounts*(-1),0.4,'FaceColor','b','EdgeColor','none');
bar(ChoceRightCenters,ChoceRightCounts,0.4,'FaceColor','r','EdgeColor','none');
alpha(0.4);
plot(ChoceLeftCenters,ChoceLeftCounts*(-1),'b-o','lineWidth',1.8);
plot(ChoceRightCenters,ChoceRightCounts,'r-o','lineWidth',1.8);
xlim([0,1]);
ylimvalues = get(gca,'ylim');
set(gca,'ytick',ylimvalues+[0.1,-0.1],'yticklabel',{'Left choice','Right choice'},'xtick',[0 1]);
ylabel('Anmimal choice');
xlabel('Right choice probability');
title('Probability distribution');
set(gca,'FontSize',18);
text(0.2,0.4,sprintf('AUC = %.4f',ROCSummary),'FontSize',16,'Color','k');
text(0.2,0.3,sprintf('nTrials = %d',length(AnmChoice)),'FontSize',16,'Color','k');
saveas(h_dis,'Distribution of animal choice compared with rightpred probability');
saveas(h_dis,'Distribution of animal choice compared with rightpred probability','png');
close(h_dis);

save ChoiceDisPlotsave.mat ChoceLeftCenters ChoceLeftCounts ChoceRightCenters ChoceRightCounts ROCSummary PredRightChoice AnmChoice -v7.3