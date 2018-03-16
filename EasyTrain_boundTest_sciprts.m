AllStims = CorrTrialStim;
AllFreq = double(unique(CorrTrialStim));
AllFreqOctave = log2(AllFreq/16000);
GrFreqNum = floor(length(AllFreq)/2);
if mod(length(AllFreq),2)
    TestFreqInds = AllStims == AllFreq(GrFreqNum) | AllStims == AllFreq(GrFreqNum+1) | AllStims == AllFreq(GrFreqNum+2);
else
    TestFreqInds = AllStims == AllFreq(GrFreqNum) | AllStims == AllFreq(GrFreqNum+1);
end

TrainTrData = ConsideringData(~TestFreqInds,:);
TrainTrChoice = double(AnmTrChoice(~TestFreqInds));
TrainTrChoice = TrainTrChoice(:);

TestTrChoice = double(ChoiceAll(TestFreqInds));
TestTrData = ConsideringData(TestFreqInds,:);
mmdl = fitcsvm(TrainTrData,TrainTrChoice);
kfoldLoss(crossval(mmdl))
TestPredChoice = predict(mmdl,TestTrData);
TestCorrRate = mean(TestPredChoice(:) == TestTrChoice(:));
fprintf('Mean Test Correct = %.3f.\n',TestCorrRate);

%%
FreqMeanData = zeros(length(AllFreq),size(ConsideringData,2));
for cFreq = 1 : length(AllFreq)
    cFreqInds = AllStims == AllFreq(cFreq);
    cFreqData = ConsideringData(cFreqInds,:);
    cFreqMeanData = mean(cFreqData);
    FreqMeanData(cFreq,:) = cFreqMeanData;
end
[MeanChoice,PredScore] = predict(mmdl,FreqMeanData);
difscore = PredScore(:,2) - PredScore(:,1);

% %% loading behavior data
% [filename,filepath,~]=uigetfile('boundary_result.mat','Select your random plot fit result');
% load(fullfile(filepath,filename));
% Octavex=log2(double(CorrStimType)/min(double(CorrStimType)));
% % Octavefit=Octavex;
% Octavexfit=Octavex;
% % OctaveTest=Octavex;
% realy=boundary_result.StimCorr;
% realy(1:nPairs)=1-realy(1:nPairs);
% Curve_x=linspace(min(Octavex),max(Octavex),500);
% rescaleB=max(realy);
% rescaleA=min(realy);

%%
if max(difscore) > 2*abs(min(difscore))
    fityAll=(rescaleB-rescaleA)*((difscore-min(difscore))./(abs(min(difscore))-min(difscore)))+rescaleA; 
    fityAll(fityAll>rescaleB) = rescaleB;
    NorScaleValue = [min(difscore),abs(min(difscore))];
elseif abs(min(difscore)) > 2 * max(difscore) && max(difscore) > 0
    fityAll=(rescaleB-rescaleA)*((difscore+max(difscore))./(abs(max(difscore)*2)))+rescaleA; 
    fityAll(fityAll<rescaleA) = rescaleA;
    NorScaleValue = [(-1)*abs(max(difscore)),max(difscore)];
else
    fityAll=(rescaleB-rescaleA)*((difscore-min(difscore))./(max(difscore)-min(difscore)))+rescaleA;  %rescale to [0 1]
    NorScaleValue = [min(difscore),max(difscore)];
end

%%
% plot current results
% Curve_x = linspace(min(AllFreqOctave),max(AllFreqOctave),500);
% modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
% [~,breal] = fit_logistic(AllFreqOctave,realy);
% [~,bfit] = fit_logistic(AllFreqOctave,fityAll);
% Curve_realy = modelfun(breal,Curve_x);
% Curve_Fity = modelfun(bfit,Curve_x);

BehavRestult = FitPsycheCurveWH_nx(AllFreqOctave(:),realy(:));
NeuFitResult = FitPsycheCurveWH_nx(AllFreqOctave(:),fityAll(:));

h_NewBoundfit = figure('position',[200 200 1000 800]);
hold on;
plot(NeuFitResult.curve(:,1),NeuFitResult.curve(:,2),'r','LineWidth',2);
plot(BehavRestult.curve(:,1),BehavRestult.curve(:,2),'k','LineWidth',2);
scatter(AllFreqOctave,realy,80,'k','o','LineWidth',2);
scatter(AllFreqOctave,fityAll,80,'r','o','LineWidth',2);
text(AllFreqOctave(2),0.8,sprintf('nROI = %d',nROI),'FontSize',15);
legend('Behav\_curve','Neuro\_curve','Behav\_data','Neuro\_data','location','southeast');
legend('boxoff');
xlabel('Tone Frequency (kHz)');
ylabel('Rightward choice');
ylim([0 1]);
CorrStimTypeTick = AllFreq/1000;
set(gca,'xtick',AllFreqOctave,'xticklabel',cellstr(num2str(CorrStimTypeTick(:),'%.2f')),'FontSize',20);
set(gca,'FontSize',18);
% close(h_compPlot);
saveas(h_NewBoundfit,'Easy train and hard test plots');
saveas(h_NewBoundfit,'Easy train and hard test plots','png');
close(h_NewBoundfit);

save EasyTrainBoundTestSave.mat fityAll AllFreqOctave realy TestFreqInds mmdl BehavRestult NeuFitResult -v7.3