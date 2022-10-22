function BlockpsyInfo = behav2blockcurve(behavResults,isplot)
% function to calculate block wise psychometric curve

if ~exist('isplot','Var')
    isplot = 0;
end
TrFreqsAll = double(behavResults.Stim_toneFreq(:));
TrBlocksAll = double(behavResults.BlockType(:));
TrChoicesAll = double(behavResults.Action_choice(:));

NonMissTrInds = TrChoicesAll ~= 2;
NMTrFreqs = TrFreqsAll(NonMissTrInds);
NMChoces = TrChoicesAll(NonMissTrInds);
NMBlockTypes = TrBlocksAll(NonMissTrInds);

FreqTypes = unique(NMTrFreqs);
NumFreqTypes = length(FreqTypes);
NMFreq2Octs = log2(NMTrFreqs/FreqTypes(1));
OctTypes = log2(FreqTypes/FreqTypes(1));

% block 0 (low bound block) psychometric curves
LowblockInds = NMBlockTypes == 0;
LowblockTrOcts = NMFreq2Octs(LowblockInds);
LowblockTrChoices = NMChoces(LowblockInds);

LowChoiceProbs = zeros(NumFreqTypes,1);
LowChoiceProbCI = zeros(NumFreqTypes,2);
for cf = 1 : NumFreqTypes
    cfTypeChoice = LowblockTrChoices(OctTypes(cf) == LowblockTrOcts);
    [phat,pci] = binofit(sum(cfTypeChoice),numel(cfTypeChoice));
    LowChoiceProbs(cf) = phat;
    LowChoiceProbCI(cf,:) = abs(pci-phat);
end

UL = [0.5, 0.5, max(OctTypes), 100];
SP = [min(LowChoiceProbs),1 - max(LowChoiceProbs)-min(LowChoiceProbs), mean(OctTypes), 1];
LM = [0, 0, min(OctTypes), 0];
ParaBoundLim = ([UL;SP;LM]);
lowfit_curveAll = FitPsycheCurveWH_nx(LowblockTrOcts,LowblockTrChoices,ParaBoundLim);
lowCurveBounds = lowfit_curveAll.ffit.u;

% block 1 (high bound block) psychometric curves
HighblockInds = NMBlockTypes == 1;
HighblockTrOcts = NMFreq2Octs(HighblockInds);
HighblockTrChoices = NMChoces(HighblockInds);

HighChoiceProbs = zeros(NumFreqTypes,1);
HighChoiceProbCI = zeros(NumFreqTypes,2);
for cf = 1 : NumFreqTypes
    cfTypeChoice = HighblockTrChoices(OctTypes(cf) == HighblockTrOcts);
    [phat,pci] = binofit(sum(cfTypeChoice),numel(cfTypeChoice));
    HighChoiceProbs(cf) = phat;
    HighChoiceProbCI(cf,:) = abs(pci-phat);
end

UL = [0.5, 0.5, max(OctTypes), 100];
SP = [min(HighChoiceProbs),1 - max(HighChoiceProbs)-min(HighChoiceProbs), mean(OctTypes), 1];
LM = [0, 0, min(OctTypes), 0];
ParaBoundLim = ([UL;SP;LM]);
Highfit_curveAll = FitPsycheCurveWH_nx(HighblockTrOcts,HighblockTrChoices,ParaBoundLim);
HighCurveBounds = Highfit_curveAll.ffit.u;

BlockpsyInfo.lowBound = lowCurveBounds;
BlockpsyInfo.highBound = HighCurveBounds;
BlockpsyInfo.lowfitmd = lowfit_curveAll;
BlockpsyInfo.highfitmd = Highfit_curveAll;
BlockpsyInfo.lowOctChoiceProb = LowChoiceProbs;
BlockpsyInfo.highOctChoiceProb = HighChoiceProbs;
BlockpsyInfo.lowprobCI = LowChoiceProbCI;
BlockpsyInfo.highprobCI = HighChoiceProbCI;

if isplot
    hf = figure('position',[100 100 420 350]);
    hold on
    plot(Highfit_curveAll.curve(:,1),Highfit_curveAll.curve(:,2),'Color',[0.8 0.5 0.2],'linewidth',1.2);
    errorbar(OctTypes,HighChoiceProbs,HighChoiceProbCI(:,1),HighChoiceProbCI(:,2),...
        'o','Color',[0.8 0.5 0.2],'linewidth',1)
    line([HighCurveBounds HighCurveBounds],[0 1],'Color',[0.8 0.5 0.2],'linewidth',0.75,'linestyle','--');
%     plot(OctTypes,HighChoiceProbs,'o','Color',[0.8 0.5 0.2],'linewidth',1);
    plot(lowfit_curveAll.curve(:,1),lowfit_curveAll.curve(:,2),'Color',[0.2 0.8 0.2],'linewidth',1.2)
    errorbar(OctTypes,LowChoiceProbs,LowChoiceProbCI(:,1),LowChoiceProbCI(:,2),...
        'o','Color',[0.2 0.8 0.2],'linewidth',1);
    line([lowCurveBounds lowCurveBounds],[0 1],'Color',[0.2 0.8 0.2],'linewidth',0.75,'linestyle','--');
    title(sprintf('BoundaryShift = %.4f',HighCurveBounds-lowCurveBounds));
    set(gca,'xtick',OctTypes,'xticklabel',cellstr(num2str(FreqTypes(:)/1000,'%.2f')));
    xlabel('Frequency (kHz)');
    ylabel('Rightward Choice');
    set(gca,'FontSize',12);
end
 
