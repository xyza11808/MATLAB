
% this scripts is used for analysis of the trial by trial results by using
% error trials as real behavior choice for training
TimeScale = 1;
if length(TimeScale) == 1
    FrameScale = sort([(start_frame+1),(start_frame + round(TimeScale*frame_rate))]);
elseif length(TimeScale) == 2
    FrameScale = sort([(start_frame + round(TimeScale(1)*frame_rate)),(start_frame + round(TimeScale(2)*frame_rate))]);
end
if exist('UsedROIInds','var')
    RespData = mean(data_aligned(:,UsedROIInds,FrameScale(1):FrameScale(2)),3);
else
    RespData = mean(data_aligned(:,:,FrameScale(1):FrameScale(2)),3);
end
%%
% Trial outcomes correction
AnimalChoice = double(behavResults.Action_choice(:));
UsingTrInds = AnimalChoice ~= 2;
% UsingTrInds = trial_outcome == 1;
UsingAnmChoice = double(AnimalChoice(UsingTrInds));
UsingRespData = RespData(UsingTrInds,:);
Stimlulus = (double(behavResults.Stim_toneFreq(UsingTrInds)))';
TrialOutcomes = trial_outcome(UsingTrInds);
TrialTypes = (double(behavResults.Trial_Type(UsingTrInds)))';

StimTypes = unique(Stimlulus);
StimAvgDatas = zeros(numel(StimTypes),size(UsingRespData,2));
StimRProb = zeros(numel(StimTypes),1);
for cs = 1 : numel(StimTypes)
    csInds = Stimlulus == StimTypes(cs);
    StimAvgDatas(cs,:) = mean(UsingRespData(csInds,:));
    
    StimRProb(cs) = mean(UsingAnmChoice(csInds));
end
rescaleB = max(StimRProb);
rescaleA = min(StimRProb);

StimOctaves = log2(Stimlulus/min(Stimlulus)) - 1;
StimOctaveTypes = unique(StimOctaves);
BehavFit = FitPsycheCurveWH_nx(StimOctaves(:),UsingAnmChoice);

%%
% % % nTrs = size(UsingRespData,1);
% % % nROI = size(UsingRespData,2);
% % % foldsRange = 10:25;
% % % foldLen = length(foldsRange);
% % % IterPredChoice = zeros(foldLen,nTrs);
% % % for nIters = 1 : foldLen
% % %     kfolds = foldsRange(nIters);
% % %     cp = cvpartition(nTrs,'k',kfolds);
% % %     PredChoice = zeros(nTrs,1);
% % %     for nn = 1 : kfolds
% % %         TrIdx = cp.training(nn);
% % %         TeIdx = cp.test(nn);
% % % 
% % %         TrainingDataset = UsingRespData(TrIdx,:);
% % %         Trainclasslabel = UsingAnmChoice(TrIdx);
% % %         mdl = fitcsvm(TrainingDataset,Trainclasslabel(:));
% % % 
% % %         TestData = UsingRespData(TeIdx,:);
% % %         PredC = predict(mdl,TestData);
% % % 
% % %         PredChoice(TeIdx) = PredC;
% % %     end
% % %     IterPredChoice(nIters,:) = PredChoice;
% % % end
%%
% % % if ~isdir('./Test_anmChoice_pred/')
% % %     mkdir('./Test_anmChoice_pred/');
% % % end
% % % cd('./Test_anmChoice_pred/');

% % % TrialTypeMatrix = repmat(TrialTypes,foldLen,1);
% % % PredOutcomes = IterPredChoice == TrialTypeMatrix;
% % % StimTypes = unique(Stimlulus);
% % % GroupNum = length(StimTypes)/2;
% % % RealStimPerf = zeros(length(StimTypes),1);
% % % PredStimPerf = zeros(length(StimTypes),foldLen);
% % % for nmnm = 1 : length(StimTypes)
% % %     cStim = StimTypes(nmnm);
% % %     cStimInds = Stimlulus == cStim;
% % %     RealStimPerf(nmnm) = mean(TrialOutcomes(cStimInds));
% % %     PredStimPerf(nmnm,:) = mean(PredOutcomes(:,cStimInds),2);
% % % end
% % % StimOct = log2(StimTypes/min(StimTypes));
% % % Colormaps = cool(foldLen);
% % % h = figure;
% % % hold on;
% % % plot(StimOct,RealStimPerf,'k-o','LineWidth',2);
% % % for nxnx = 1 : foldLen
% % %     plot(StimOct,PredStimPerf(:,nxnx),'-o','LineWidth',2,'Color',Colormaps(nxnx,:));
% % % end
% % % xlabel('Octave');
% % % ylabel('Correct rate');
% % % ylim([0 1.1]);
% % % title({'behav and Neuron compare','With Error Trials'});
% % % set(gca,'fontSize',20)
% % % saveas(h,'TbyT Pred animal choice correct rate');
% % % saveas(h,'TbyT Pred animal choice correct rate','png');
% % % close(h);
% % % 
% % % save AnmChoicePredSave.mat UsingAnmChoice IterPredChoice StimOct RealStimPerf PredStimPerf TrialTypes Stimlulus -v7.3
% % % %%
% % % RealRightwardPerf = RealStimPerf;
% % % PredRightwardPerf = PredStimPerf;
% % % RealRightwardPerf(1:GroupNum) = 1 - RealRightwardPerf(1:GroupNum);
% % % PredRightwardPerf(1:GroupNum,:) = 1 - PredRightwardPerf(1:GroupNum,:);
% % % PredRightwardPerfMean = mean(PredRightwardPerf,2);
% % % [~,breal] = fit_logistic(StimOct,RealRightwardPerf);
% % % [~,bPred] = fit_logistic(StimOct,PredRightwardPerfMean);
% % % modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
% % % curvex = linspace(min(StimOct),max(StimOct),500);
% % % curve_realy = modelfun(breal,curvex);
% % % curve_fity = modelfun(bPred,curvex);
% % % 
% % % h2CompPlot=figure('position',[300 150 1100 900],'PaperpositionMode','auto');
% % % hold on;
% % % plot(curvex,curve_fity,'r','LineWidth',2);
% % % plot(curvex,curve_realy,'k','LineWidth',2);
% % % scatter(StimOct,RealRightwardPerf,80,'k','o','LineWidth',2);
% % % scatter(StimOct,PredRightwardPerfMean,80,'r','o','LineWidth',2);
% % % text(StimOct(2),0.8,sprintf('nROI = %d',nROI),'FontSize',15);
% % % legend('logi\_fitc','logi\_realc','Real\_data','Fit\_data','location','southeast');
% % % legend('boxoff');
% % % set(gca,'xtick',StimOct,'xticklabel',cellstr(num2str(StimTypes(:)/1000,'%.2f')),'FontSize',20);
% % % xlabel('Tone Frequency (kHz)');
% % % ylabel('Rightward Probability');
% % % saveas(h2CompPlot,'TBYT choice decoding result compare plot');
% % % saveas(h2CompPlot,'TBYT choice decoding result compare plot','png');
% % % % close(h2CompPlot);
% % % 
% % % cd ..;
%
%%
% repeats of same partition fold, using 100 times of repeats
% if exist('UsedROIInds','var')
%     if ~isdir('./Test_anmChoice_predPartROI/')
%         mkdir('./Test_anmChoice_predPartROI/');
%     end
%     cd('./Test_anmChoice_predPartROI/');
% else
    if ~isdir('./Test_anmChoice_predNewCROIs/')
        mkdir('./Test_anmChoice_predNewCROIs/');
    end
    cd('./Test_anmChoice_predNewCROIs/');
% end
%%
nTrs = size(UsingRespData,1);
nROI = size(UsingRespData,2);
nRepeats = 200;
foldsRange = 6*ones(nRepeats,1);
foldLen = length(foldsRange);
IterPredChoice = zeros(foldLen,nTrs);
ModelPerf = zeros(foldLen,foldsRange(1));
ModelScoreAll = cell(foldLen,foldsRange(1));
TestScoreAll = cell(foldLen,foldsRange(1));
parfor nIters = 1 : foldLen
    kfolds = foldsRange(nIters);
    cp = cvpartition(nTrs,'k',kfolds);
    PredChoice = zeros(nTrs,1);
    mdPerfTemp = zeros(kfolds,1);
    TempMDFitAll = cell(kfolds,1);
    TempTestScoreFit = cell(kfolds,1);
    for nn = 1 : kfolds
        TrIdx = cp.training(nn);
        TeIdx = cp.test(nn);

        TrainingDataset = UsingRespData(TrIdx,:);
        Trainclasslabel = UsingAnmChoice(TrIdx);
        mdl = fitcsvm(TrainingDataset,Trainclasslabel(:));
        
        mdPerfTemp(nn) = kfoldLoss(crossval(mdl));
        
        TestData = UsingRespData(TeIdx,:);
        PredC = predict(mdl,TestData);
        
        TestTrFreqs = StimOctaves(TeIdx);
        TrFreqAvgData = cell(numel(StimOctaveTypes),1);
        for cfreq = 1 : numel(StimOctaveTypes)
            cfreqInds = TestTrFreqs == StimOctaveTypes(cfreq);
%             disp(sum(cfreqInds));
            if sum(cfreqInds) == 1
                TrFreqAvgData{cfreq} = TestData(cfreqInds,:);
            else
                TrFreqAvgData{cfreq} = mean(TestData(cfreqInds,:));
            end
        end
        EmptyInds = cellfun(@isempty,TrFreqAvgData);
        if sum(EmptyInds)
            TempTestScoreFit{nn} = [];
        else
            TestFreqAvgData = cell2mat(TrFreqAvgData);
            [~,TestScore] = predict(mdl,TestFreqAvgData);
            TestUseScore = TestScore(:,2);
%             TEstFFit = (rescaleB-rescaleA)*((TestUseScore-min(TestUseScore))./(max(TestUseScore)-min(TestUseScore)))+rescaleA;
            TempTestScoreFit{nn} = TestUseScore;
        end 
        
        [~,Scores] = predict(mdl,StimAvgDatas);
        UsedScores = Scores(:,2);
        fityAll = (rescaleB-rescaleA)*((UsedScores-min(UsedScores))./(max(UsedScores)-min(UsedScores)))+rescaleA; 
        TempMDFitAll{nn} = fityAll;
        
        PredChoice(TeIdx) = PredC;
    end
    ModelPerf(nIters,:) = mdPerfTemp;
    IterPredChoice(nIters,:) = PredChoice;
    ModelScoreAll(nIters,:) = TempMDFitAll;
    TestScoreAll(nIters,:) = TempTestScoreFit;
end

save ModelPredictionSave.mat ModelPerf IterPredChoice ModelScoreAll TestScoreAll -v7.3
%% plots the prediction score result and real behavior data
MdPredsAll = (ModelScoreAll(:))';
mdPredScoreMtx = cell2mat(MdPredsAll);
OctMeanmdPredScore = mean(mdPredScoreMtx,2);
PredScoreOctMtx = repmat(StimOctaveTypes(:),1,sum(foldsRange));

PredScoreFits = FitPsycheCurveWH_nx(PredScoreOctMtx(:),mdPredScoreMtx(:));
hScoref = figure('position',[100 100 420 340]);
hold on
plot(PredScoreFits.curve(:,1),PredScoreFits.curve(:,2),'r','linewidth',2);
plot(BehavFit.curve(:,1),BehavFit.curve(:,2),'k','linewidth',2)
plot(StimOctaveTypes,OctMeanmdPredScore,'ro','linewidth',1.8);
plot(StimOctaveTypes,StimRProb,'ko','linewidth',1.8);
xlim([-1.1 1.1]);
ylim([-0.05 1.05]);
set(gca,'xtick',StimOctaveTypes,'xticklabel',cellstr(num2str(StimTypes/1000,'%.1f')),'ytick',[0 0.5 1]);
title('Pred score and behav compare plot');
set(gca,'FontSize',12);
xlabel('Frequnecy (kHz)');
ylabel('Right prob');

saveas(hScoref,'PredScore psychometric curve plots');
saveas(hScoref,'PredScore psychometric curve plots','png');
close(hScoref);

%%
% repeats of same partition fold, using 100 times of repeats

TrialTypeMatrix = repmat((TrialTypes(:))',foldLen,1);
PredOutcomes = IterPredChoice == TrialTypeMatrix;
StimTypes = unique(Stimlulus);
GroupNum = length(StimTypes)/2;
if mod(length(StimTypes),2)
    warning('Current session may contains boundary sounds, please check the following analysis result.');
end
RealStimPerf = zeros(length(StimTypes),1);
PredStimPerf = zeros(length(StimTypes),foldLen);
for nmnm = 1 : length(StimTypes)
    cStim = StimTypes(nmnm);
    cStimInds = Stimlulus == cStim;
    RealStimPerf(nmnm) = mean(TrialOutcomes(cStimInds));
    PredStimPerf(nmnm,:) = mean(PredOutcomes(:,cStimInds),2);
end
StimOct = log2(StimTypes/min(StimTypes));
Colormaps = cool(foldLen);
h = figure;
hold on;

for nxnx = 1 : foldLen
    plot(StimOct,PredStimPerf(:,nxnx),'-o','LineWidth',2,'Color',Colormaps(nxnx,:));
end
plot(StimOct,RealStimPerf,'k-o','LineWidth',2);
xlabel('Octave');
ylabel('Correct rate');
ylim([0 1.1]);
title({'behav and Neuron compare','With Error Trials'});
set(gca,'fontSize',20)
saveas(h,'TbyT Pred animal choice correct rate');
saveas(h,'TbyT Pred animal choice correct rate','png');
close(h);
%%
TrialOutcomes = double(UsingAnmChoice(:) == TrialTypes(:));

NumStim = length(StimTypes);
StimPerformance = zeros(NumStim,1);
StimInds = cell(NumStim,1);
for nknk = 1 : NumStim
    cStim = StimTypes(nknk);
    cStimInds = Stimlulus == cStim;
    StimPerformance(nknk) = mean(TrialOutcomes(cStimInds));
    StimInds{nknk} = cStimInds;
end
[BadPerfStim,BadInds] = min(StimPerformance);
fprintf('The worst perf within current session is frequency %d, perf = %.3f.\n',StimTypes(BadInds),BadPerfStim);
save AnmChoicePredSaveNew.mat UsingAnmChoice IterPredChoice StimOct RealStimPerf PredStimPerf TrialTypes Stimlulus StimPerformance StimInds -v7.3

%%
RealRightwardPerf = RealStimPerf;
PredRightwardPerf = PredStimPerf;
RealRightwardPerf(1:GroupNum) = 1 - RealRightwardPerf(1:GroupNum);
PredRightwardPerf(1:GroupNum,:) = 1 - PredRightwardPerf(1:GroupNum,:);
PredRightwardPerfMean = mean(PredRightwardPerf,2);
PredRightwardPerfSEM = std(PredRightwardPerf,[],2);%/sqrt(size(PredRightwardPerf,2));
PerfFit = FitPsycheCurveWH_nx(StimOctaveTypes,PredRightwardPerfMean);

% [~,breal] = fit_logistic(StimOctaveTypes,RealRightwardPerf);
% [~,bPred] = fit_logistic(StimOctaveTypes,PredRightwardPerfMean);
% modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
% curvex = linspace(min(StimOctaveTypes),max(StimOctaveTypes),500);
% curve_realy = modelfun(breal,curvex);
% curve_fity = modelfun(bPred,curvex);

h2CompPlot=figure('position',[300 150 500 400],'PaperpositionMode','auto');
hold on;
plot(PerfFit.curve(:,1),PerfFit.curve(:,2),'r','LineWidth',2);
plot(BehavFit.curve(:,1),BehavFit.curve(:,2),'k','linewidth',2)
plot(StimOctaveTypes,StimRProb,'ko','linewidth',1.8);
errorbar(StimOctaveTypes,PredRightwardPerfMean,PredRightwardPerfSEM,'ro','linewidth',1.8);
text(StimOctaveTypes(2),0.8,sprintf('nROI = %d',nROI),'FontSize',10);
legend('logi\_fitc','logi\_realc','Real\_data','Fit\_data','location','southeast');
legend('boxoff');
xlim([-1.1 1.1]);
ylim([-0.05 1.05]);
set(gca,'xtick',StimOctaveTypes,'xticklabel',cellstr(num2str(StimTypes(:)/1000,'%.2f')),'FontSize',12);
xlabel('Tone Frequency (kHz)');
ylabel('Rightward Probability');
saveas(h2CompPlot,'TBYT choice decoding result compare plot');
saveas(h2CompPlot,'TBYT choice decoding result compare plot','png');
close(h2CompPlot);

%% Test score Prediction plot
TestScoreMtx = cell2mat((TestScoreAll(:))');
PosNaNInds = sum(isnan(TestScoreMtx)) == 0;
UsedTestScoreMtx = TestScoreMtx(:,PosNaNInds);
AvgUsedTestScore = mean(UsedTestScoreMtx,2);
AvgUsedTestRPRob = (rescaleB-rescaleA)*((AvgUsedTestScore-min(AvgUsedTestScore))./...
    (max(AvgUsedTestScore)-min(AvgUsedTestScore)))+rescaleA; 
% StdUsedTestScore = std(UsedTestScoreMtx,[],2);
% UsedNum = size(UsedTestScoreMtx,2);
% CurBehavFits = FitPsycheCurveWH_nx(StimOctaves(:),UsingAnmChoice(:));
CurTestScorFit = FitPsycheCurveWH_nx(StimOctaveTypes(:),AvgUsedTestRPRob);

hTestScoref = figure('position',[100 100 420 340]);
hold on
plot(CurTestScorFit.curve(:,1),CurTestScorFit.curve(:,2),'r','linewidth',2);
plot(BehavFit.curve(:,1),BehavFit.curve(:,2),'k','linewidth',2)
plot(StimOctaveTypes,AvgUsedTestRPRob,'ro','linewidth',1.8);
plot(StimOctaveTypes,StimRProb,'ko','linewidth',1.8);
xlim([-1.1 1.1]);
ylim([-0.05 1.05]);
set(gca,'xtick',StimOctaveTypes,'xticklabel',cellstr(num2str(StimTypes/1000,'%.1f')),'ytick',[0 0.5 1]);
title('Testing trial score and behav compare plot');
set(gca,'FontSize',12);
xlabel('Frequnecy (kHz)');
ylabel('Right prob');

saveas(hTestScoref,'TestPredScore psychometric curve plots');
saveas(hTestScoref,'TestPredScore psychometric curve plots','png');
close(hTestScoref);

save NeuroCurveVSBehav.mat StimOctaveTypes AvgUsedTestRPRob StimRProb PredRightwardPerfMean -v7.3
%%
% new distribution plots for only worst trials
% plots the trial by trial choice prob
RightChoiceProb = mean(IterPredChoice);
BadAnmChoice = UsingAnmChoice(StimInds{BadInds});
BadRChiceProb = RightChoiceProb(StimInds{BadInds});

AnmChoiceTy = unique(BadAnmChoice);
ChoiceLen = length(AnmChoiceTy);
choiceProbDis = cell(ChoiceLen,1);

for nxnx = 1 : ChoiceLen
    cChoice = AnmChoiceTy(nxnx);
    cChoiceInds = BadAnmChoice == cChoice;
    choiceProbDis{nxnx} = BadRChiceProb(cChoiceInds);
end

%%
[ChoceLeftCounts,ChoceLeftCenters] = hist(choiceProbDis{1});
ChoceLeftCounts = ChoceLeftCounts/sum(ChoceLeftCounts);
[ChoceRightCounts,ChoceRightCenters] = hist(choiceProbDis{2});
ChoceRightCounts = ChoceRightCounts/sum(ChoceRightCounts);
[ROCSummary,LabelMeanS]=rocOnlineFoff([BadRChiceProb(:) double(BadAnmChoice(:))]);
if LabelMeanS
    ROCSummary = 1 - ROCSummary;
end

h_dis = figure('position',[100 100 500 400]);
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
set(gca,'FontSize',10);
text(0.2,0.4,sprintf('AUC = %.4f',ROCSummary),'FontSize',16,'Color','k');
saveas(h_dis,'Distribution of animal choice compared with rightpred probability worstPerf');
saveas(h_dis,'Distribution of animal choice compared with rightpred probability worstPerf','png');
close(h_dis);

save RightChoiceProb_anmCWorst.mat RightChoiceProb UsingAnmChoice ChoceLeftCounts ChoceLeftCenters ChoceRightCounts ChoceRightCenters ROCSummary -v7.3

%%
% plots the trial by trial choice prob
AnmChoiceTy = unique(UsingAnmChoice);
ChoiceLen = length(AnmChoiceTy);
choiceProbDis = cell(ChoiceLen,1);
RightChoiceProb = mean(IterPredChoice);
for nxnx = 1 : ChoiceLen
    cChoice = AnmChoiceTy(nxnx);
    cChoiceInds = UsingAnmChoice == cChoice;
    choiceProbDis{nxnx} = RightChoiceProb(cChoiceInds);
end

%%
[ChoceLeftCounts,ChoceLeftCenters] = hist(choiceProbDis{1},20);
ChoceLeftCounts = ChoceLeftCounts/sum(ChoceLeftCounts);
[ChoceRightCounts,ChoceRightCenters] = hist(choiceProbDis{2},20);
ChoceRightCounts = ChoceRightCounts/sum(ChoceRightCounts);
[ROCSummary,LabelMeanS]=rocOnlineFoff([RightChoiceProb(:) double(UsingAnmChoice(:))]);
if LabelMeanS
    ROCSummary = 1 - ROCSummary;
end

h_dis = figure('position',[100 100 500 400]);
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
set(gca,'FontSize',10);
text(0.2,0.4,sprintf('AUC = %.4f',ROCSummary),'FontSize',16,'Color','k');
saveas(h_dis,'Distribution of animal choice compared with rightpred probability');
saveas(h_dis,'Distribution of animal choice compared with rightpred probability','png');
close(h_dis);

save RightChoiceProb_anmChoicesave.mat RightChoiceProb UsingAnmChoice ChoceLeftCounts ChoceLeftCenters ChoceRightCounts ChoceRightCenters ROCSummary -v7.3
%%
cd ..;