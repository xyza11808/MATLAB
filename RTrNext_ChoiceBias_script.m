
TrTypes = double(behavResults.Trial_Type(:));
TrChoice = double(behavResults.Action_choice(:));
TrFreqs = double(behavResults.Stim_toneFreq(:));
ReTrInds = TrTypes == TrChoice;
RewardLTrInds = ReTrInds & TrTypes == 0;
if RewardLTrInds(end)
    RewardLTrInds(end) = false;
end
RewardRTrInds = ReTrInds & TrTypes == 1;
if RewardRTrInds(end)
    RewardRTrInds(end) = false;
end

ReLNextTrInds = false(length(RewardLTrInds),1);
ReLNextTrInds(2:end) = RewardLTrInds(1:end-1);

ReRNextTrInds = false(length(RewardRTrInds),1);
ReRNextTrInds(2:end) = RewardRTrInds(1:end-1);

%%
ReLNextTrChoice = TrChoice(ReLNextTrInds);
ReLNextTrFreqs = TrFreqs(ReLNextTrInds);

ReRNextTrChoice = TrChoice(ReRNextTrInds);
ReRNextTrFreqs = TrFreqs(ReRNextTrInds);

FreqTypes = unique(TrFreqs);
nFreqs = length(FreqTypes);
ReLNextRChoiceProb = zeros(nFreqs,1);
ReRNextRChoiceProb = zeros(nFreqs,1);
for cFreq = 1 : nFreqs
    cLFreqInds = ReLNextTrFreqs == FreqTypes(cFreq) & ReLNextTrChoice~= 2;
    cRFreqInds = ReRNextTrFreqs == FreqTypes(cFreq) & ReRNextTrChoice~= 2;
    ReLNextRChoiceProb(cFreq) = mean(ReLNextTrChoice(cLFreqInds));
    ReRNextRChoiceProb(cFreq) = mean(ReRNextTrChoice(cRFreqInds));
end
FreqOcts = log2(FreqTypes/min(FreqTypes)) - 1;

hf = figure('position',[100 100 380 300]);
hold on
plot(FreqOcts,ReLNextRChoiceProb,'bo');
plot(FreqOcts,ReRNextRChoiceProb,'ro');
UL = [0.5, 0.5, max(FreqOcts), 100];
SP_L = [ReLNextRChoiceProb(1),1 - ReLNextRChoiceProb(end)-ReLNextRChoiceProb(1), mean(FreqOcts), 1];
SP_R = [ReLNextRChoiceProb(1),1 - ReLNextRChoiceProb(end)-ReLNextRChoiceProb(1), mean(FreqOcts), 1];
LM = [0, 0, min(FreqOcts), 0];
ParaBoundLimL = ([UL;SP_L;LM]);
ParaBoundLimR = ([UL;SP_R;LM]);
Fit_L = FitPsycheCurveWH_nx(FreqOcts,ReLNextRChoiceProb,ParaBoundLimL);
Fit_R = FitPsycheCurveWH_nx(FreqOcts,ReRNextRChoiceProb,ParaBoundLimR);

plot(Fit_L.curve(:,1),Fit_L.curve(:,2),'b','linewidth',1.6);
plot(Fit_R.curve(:,1),Fit_R.curve(:,2),'r','linewidth',1.6);
line([Fit_L.ffit.u,Fit_L.ffit.u],[0 1],'Color','b','linewidth',1,'linestyle','--');
line([Fit_R.ffit.u,Fit_R.ffit.u],[0 1],'Color','r','linewidth',1,'linestyle','--');
text(Fit_L.ffit.u-0.04,0.4,sprintf('%.4f',Fit_L.ffit.u),'HorizontalAlignment','right','Color','b');
text(Fit_R.ffit.u+0.04,0.6,sprintf('%.4f',Fit_R.ffit.u),'HorizontalAlignment','Left','Color','r');
xlim([-1.1,1.1]);
ylim([-0.1,1.1]);
set(gca,'xTick',[-1 0 1],'ytick',[0 0.5 1]);
xlabel('Octave');
ylabel('Right Prob.');
title('Choice hysteresis bias')
set(gca,'FontSize',14);
if exist('fn','var')
    saveas(hf,sprintf('%s Choice hysteresis bias',fn(1:end-4)));
    saveas(hf,sprintf('%s Choice hysteresis bias',fn(1:end-4)),'png');
else
    saveas(hf,'Choice hysteresis bias');
    saveas(hf,'Choice hysteresis bias','png');
end