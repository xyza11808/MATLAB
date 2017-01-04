
% this scripts is used for analysis of the trial by trial results by using
% error trials as real behavior choice for training
TimeScale = 1.5;
if length(TimeScale) == 1
    FrameScale = sort([(start_frame+1),(start_frame + round(TimeScale*frame_rate))]);
elseif length(TimeScale) == 2
    FrameScale = sort([(start_frame + round(TimeScale(1)*frame_rate)),(start_frame + round(TimeScale(2)*frame_rate))]);
end
RespData = max(smooth_data(:,:,FrameScale(1):FrameScale(2)),[],3);
%%
% Trial outcomes correction
AnimalChoice = behavResults.Action_choice;
UsingTrInds = AnimalChoice ~= 2;
% UsingTrInds = trial_outcome == 1;
UsingAnmChoice = double(AnimalChoice(UsingTrInds));
UsingRespData = RespData(UsingTrInds,:);
Stimlulus = double(behavResults.Stim_toneFreq(UsingTrInds));
TrialOutcomes = trial_outcome(UsingTrInds);
TrialTypes = double(behavResults.Trial_Type(UsingTrInds));
%%
nTrs = size(UsingRespData,1);
nROI = size(UsingRespData,2);
foldsRange = 10:25;
foldLen = length(foldsRange);
IterPredChoice = zeros(foldLen,nTrs);
for nIters = 1 : foldLen
    kfolds = foldsRange(nIters);
    cp = cvpartition(nTrs,'k',kfolds);
    PredChoice = zeros(nTrs,1);
    for nn = 1 : kfolds
        TrIdx = cp.training(nn);
        TeIdx = cp.test(nn);

        TrainingDataset = UsingRespData(TrIdx,:);
        Trainclasslabel = UsingAnmChoice(TrIdx);
        mdl = fitcsvm(TrainingDataset,Trainclasslabel(:));

        TestData = UsingRespData(TeIdx,:);
        PredC = predict(mdl,TestData);

        PredChoice(TeIdx) = PredC;
    end
    IterPredChoice(nIters,:) = PredChoice;
end
%%
if ~isdir('./Test_anmChoice_pred/')
    mkdir('./Test_anmChoice_pred/');
end
cd('./Test_anmChoice_pred/');

TrialTypeMatrix = repmat(TrialTypes,foldLen,1);
PredOutcomes = IterPredChoice == TrialTypeMatrix;
StimTypes = unique(Stimlulus);
GroupNum = length(StimTypes)/2;
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
plot(StimOct,RealStimPerf,'k-o','LineWidth',2);
for nxnx = 1 : foldLen
    plot(StimOct,PredStimPerf(:,nxnx),'-o','LineWidth',2,'Color',Colormaps(nxnx,:));
end
xlabel('Octave');
ylabel('Correct rate');
ylim([0 1.1]);
title({'behav and Neuron compare','With Error Trials'});
set(gca,'fontSize',20)
saveas(h,'TbyT Pred animal choice correct rate');
saveas(h,'TbyT Pred animal choice correct rate','png');
close(h);

save AnmChoicePredSave.mat UsingAnmChoice IterPredChoice StimOct RealStimPerf PredStimPerf -v7.3
%%
RealRightwardPerf = RealStimPerf;
PredRightwardPerf = PredStimPerf;
RealRightwardPerf(1:GroupNum) = 1 - RealRightwardPerf(1:GroupNum);
PredRightwardPerf(1:GroupNum,:) = 1 - PredRightwardPerf(1:GroupNum,:);
PredRightwardPerfMean = mean(PredRightwardPerf,2);
[~,breal] = fit_logistic(StimOct,RealRightwardPerf);
[~,bPred] = fit_logistic(StimOct,PredRightwardPerfMean);
modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
curvex = linspace(min(StimOct),max(StimOct),500);
curve_realy = modelfun(breal,curvex);
curve_fity = modelfun(bPred,curvex);

h2CompPlot=figure('position',[300 150 1100 900],'PaperpositionMode','auto');
hold on;
plot(curvex,curve_fity,'r','LineWidth',2);
plot(curvex,curve_realy,'k','LineWidth',2);
scatter(StimOct,RealRightwardPerf,80,'k','o','LineWidth',2);
scatter(StimOct,PredRightwardPerfMean,80,'r','o','LineWidth',2);
text(StimOct(2),0.8,sprintf('nROI = %d',nROI),'FontSize',15);
legend('logi\_fitc','logi\_realc','Real\_data','Fit\_data','location','southeast');
legend('boxoff');
set(gca,'xtick',StimOct,'xticklabel',cellstr(num2str(StimTypes(:)/1000,'%.2f')),'FontSize',20);
xlabel('Tone Frequency (kHz)');
ylabel('Rightward Probability');
saveas(h2CompPlot,'TBYT choice decoding result compare plot');
saveas(h2CompPlot,'TBYT choice decoding result compare plot','png');
% close(h2CompPlot);

cd ..;