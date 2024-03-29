function NBC_for2afc(RawData,TrialFreq,AlignFrame,FrameRate,Timescale,TrialTypes,varargin)
% this function is trying to build a naive bayes classifier to do
% population decoding

[TrialNum,ROINum,TimeTrace] = size(RawData);
if TrialNum ~= length(TrialFreq)
    error('Trial number isn''t consistent, please check the input data.');
end

freqTypes = unique(TrialFreq);
freqPrior = zeros(length(freqTypes),1);
Boundary = double(freqTypes(1))*power(2,log2(double(freqTypes(end))/double(freqTypes(1)))/2);
trialInds = TrialFreq > Boundary;
% freq2trialType = freqTypes > Boundary;
for nfreq = 1 : length(freqTypes)
    freqPrior(nfreq) = sum(TrialFreq == freqTypes(nfreq)) / length(TrialFreq);
end
TrialTypePrior = [sum(freqPrior(1:3)),sum(freqPrior(4:6))];
if length(Timescale) == 1
    FrameScale = sort([AlignFrame,AlignFrame+floor(Timescale*FrameRate)]);
elseif length(Timescale) == 2
    StartTime = min(Timescale);
    TimeScale = max(Timescale) - min(Timescale);
    FrameScale = sort([AlignFrame+floor(Timescale(1)*FrameRate),AlignFrame+floor(Timescale(2)*FrameRate)]);
else
    warning('Input TimeLength variable have a length of %d, but it have to be 1 or 2',length(TimeLength));
    return;
end
if FrameScale(1) < 1
    warning('Time Selection excceed matrix index, correct to 1');
    FrameScale(1) = 1;
end
if FrameScale(2) > TimeTrace
    warning('Time Selection excceed matrix index, correct to %d',DataSize(3));
    FrameScale(2) = TimeTrace;
end
SelectData = RawData(:,:,FrameScale(1): FrameScale(2));
TrainingDataAll = max(SelectData,[],3);
%the current will only used for natlab versions higher than 2014a
md1 = fitcnb(TrainingDataAll,trialInds(:),'prior',TrialTypePrior);
defaultCVMdl = crossval(md1);
defaultLoss = kfoldLoss(defaultCVMdl);
fprintf('Naive bayes classifier error rate equals %0.4f.\n',defaultLoss);
if length(Timescale) == 1
    if ~isdir(sprintf('./NBC_analysis_result_%dms/',Timescale*1000))
        mkdir(sprintf('./NBC_analysis_result_%dms/',Timescale*1000));
    end
    cd(sprintf('./NBC_analysis_result_%dms/',Timescale*1000));
else
    if ~isdir(sprintf('./NBC_analysis_result_%dms%dmsDur/',StartTime*1000,TimeScale*1000))
        mkdir(sprintf('./NBC_analysis_result_%dms%dmsDur/',StartTime*1000,TimeScale*1000));
    end
    cd(sprintf('./NBC_analysis_result_%dms%dmsDur/',StartTime*1000,TimeScale*1000));
end
% save NBC_result.mat md1 defaultCVMdl defaultLoss -v7.3


%%
% trial by trial crossvalidation
nIteration = 100;
NBCScoreAll = zeros(nfreq,nIteration);
NBCLossAll = zeros(1,nIteration);
NBCMd1All = cell(1,nIteration);

for nIter = 1 : nIteration
    randInds = randsample(TrialNum,round(TrialNum*0.5));
    SelectInds = false(TrialNum,1);
    SelectInds(randInds) = true;
    %training data set generation
    cTrainingData = TrainingDataAll(SelectInds,:);
    cTrainingTType = TrialTypes(SelectInds);
    cTRainingFreq = TrialFreq(SelectInds);
    %testing data set generation
    cTestingData = TrainingDataAll(~SelectInds,:);
    cTestingTType = TrialTypes(~SelectInds);
    cTestingFreq = TrialFreq(~SelectInds);
    
    cmd1 = fitcnb(cTrainingData,cTrainingTType);
    cLoss = kfoldLoss(crossval(md1));
    TestingScore = predict(cmd1,cTestingData);
    CorrectPred = double(TestingScore == cTestingTType');
    
    cTestFreqScore = zeros(nfreq,1);
    for n = 1 : nfreq
        cFreq = freqTypes(n);
        cFreqTrials = cTestingFreq == cFreq;
        cFreqScore = CorrectPred(cFreqTrials);
        cTestFreqScore(n) = mean(cFreqScore);
    end
    NBCScoreAll(:,nIter) = cTestFreqScore;
    NBCLossAll(nIter) = cLoss;
    NBCMd1All(nIter) = {cmd1};
end

BadModelPerform = NBCLossAll > 0.3;
if sum(BadModelPerform) > 1
    fprintf('%.2f of Iterations is bad performed with loss fun larger than 0.3.\n',sum(BadModelPerform)/length(NBCLossAll));
    if (sum(BadModelPerform)/length(NBCLossAll)) > 0.3
        warning('More than 30% of trials show bad classifications, quit function.\n');
        fileID = fopen('BAD PERFORMANCE EXIST.txt','w+');
        fprintf(fileID,'%s\n',sprintf('%.1f of Iterations is bad performed with loss fun larger than 0.3.\n',100*sum(BadModelPerform)/length(NBCLossAll)));
        fclose(fileID);
        return;
    end
end
GoodFreqPeform = NBCScoreAll(:,~BadModelPerform);
MeanFreqScore = mean(GoodFreqPeform,2);
SEMFreq = std(GoodFreqPeform,[],2)/sqrt(size(GoodFreqPeform,2));

FitPerf = MeanFreqScore;
FitPerf(1:3) = 1 - FitPerf(1:3);
freqTypes = double(freqTypes);
FreqOct = log2(freqTypes/min(freqTypes));

modelfun = @(p1,t)(p1(2)./(1 + exp(-p1(3).*(t-p1(1)))));
Curve_x=linspace(min(FreqOct),max(FreqOct),500);
[~,bPopSEM]=fit_logistic(FreqOct,FitPerf);
Psemfitline = modelfun(bPopSEM,Curve_x);
CorrStimTypeTick = freqTypes/1000;
%%
% loading real behavior performance
[filename,filepath,~]=uigetfile('boundary_result.mat','Select your random plot fit result');
load(fullfile(filepath,filename));
% Octavex=FreqOct;
% Octavefit=Octavex;
realy=boundary_result.StimCorr;
realy(1:3)=1-realy(1:3);
% Curve_x=linspace(min(Octavex),max(Octavex),500);
[~,breal] = fit_logistic(FreqOct,realy);
RealLine = modelfun(breal,Curve_x);

%%
h_fitplot = figure('position',[300 150 1100 900]);
hold on;
errorbar(FreqOct,FitPerf,SEMFreq,'ro','LineWidth',1.5,'MarkerSize',7);
plot(Curve_x,Psemfitline,'color','r','LineWidth',2);
% plot(FreqOct,FitPerf,'o','color','r','MarkerSize',6,'LineWidth',1.4);
xlabel('Octave Diff.');
ylabel('RightWard Corr. rate');
title('Naive bayes classification');
if length(Timescale) == 1
    saveas(h_fitplot,sprintf('NBC fit scatterPlot%dms.png',Timescale*1000));
    saveas(h_fitplot,sprintf('NBC fit scatterPlot%dms.fig',Timescale*1000));
else
    saveas(h_fitplot,sprintf('NBC fit scatterPlot%dms%dmsDur.png',StartTime*1000,TimeScale*1000));
    saveas(h_fitplot,sprintf('NBC fit scatterPlot%dms%dmsDur.fig',StartTime*1000,TimeScale*1000));
end
close(h_fitplot);
%%
save NBCResult.mat NBCScoreAll NBCLossAll NBCMd1All BadModelPerform -v7.3

h_doubleyy = figure('position',[300 150 1100 900],'PaperpositionMode','auto');
hold on;
[hax,hline1,hline2] = plotyy(Curve_x,RealLine,Curve_x,Psemfitline);
set(hline1,'color','k','LineWidth',2);
set(hline2,'color','r','LineWidth',2);
set(hax(1),'xtick',FreqOct,'xticklabel',cellstr(num2str(CorrStimTypeTick(:),'%.2f')),'ycolor','k','ytick',[0 0.2 0.4 0.6 0.8 1]);
set(hax(2),'ycolor','r','ytick',[0 0.2 0.4 0.6 0.8 1]);
set(hax,'FontSize',20);
ylabel(hax(1),'Fraction choice (R)');
ylabel(hax(2),'Model performance');
ylim(hax(1),[-0.1,1.1]);
ylim(hax(2),[-0.1,1.1]);
xlim(hax(1),[FreqOct(1)-0.1 FreqOct(end)+0.1]);
xlim(hax(2),[FreqOct(1)-0.1 FreqOct(end)+0.1]);
xlabel('Tone Frequency (kHz)');
title('Real and fit data comparation');
scatter(FreqOct,realy,40,'k','o','LineWidth',2);
scatter(FreqOct,FitPerf,40,'r','o','LineWidth',2);
if length(Timescale) == 1
    saveas(h_doubleyy,sprintf('Neuro_psycho_%dms_BiyyNBC_plot.png',Timescale*1000));
    saveas(h_doubleyy,sprintf('Neuro_psycho_%dms_BiyyNBC_plot.fig',Timescale*1000));
else
    saveas(h_doubleyy,sprintf('Neuro_psycho_%dms%dmsDur_BiyyNBC_plot.png',StartTime*1000,TimeScale*1000));
    saveas(h_doubleyy,sprintf('Neuro_psycho_%dms%dmsDur_BiyyNBC_plot.fig',StartTime*1000,TimeScale*1000));
end
close(h_doubleyy);
save ModelPlotData.mat FreqOct realy FitPerf CorrStimTypeTick Timescale -v7.3
cd ..;

%     randInds = randsample(TrialNum,round(TrialNum*0.5));
%     SelectInds = false(TrialNum,1);
%     SelectInds(randInds) = true;
%     TrainingDataT = RawData(SelectInds,:,:);
% %     TestData = RawData(~SelectInds,:,:);
%     TrainingFreq = TrialFreq(SelectInds);
%     TrainingTTypes = TrialTypes(SelectInds);
%     
%     BaseInds = (nIter - 1)*length(freqTypes);
%     for nfreq = 1 : length(freqTypes)
%         cfreqInds = TrainingFreq == freqTypes(nfreq);
%         cData = TrainingDataT(cfreqInds,:,:);
%         cDataAvg = squeeze(mean(cData));
%         TestingData(BaseInds+nfreq,:) = max(cDataAvg,[],2);
%     end
%     