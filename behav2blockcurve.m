function BlockpsyInfo = behav2blockcurve(behavResults)
% function to calculate block wise psychometric curve
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

UL = [0.5, 0.5, max(SessFreqOcts), 100];
SP = [min(ChoiceProbs),1 - max(ChoiceProbs)-min(ChoiceProbs), mean(SessFreqOcts), 1];
LM = [0, 0, min(SessFreqOcts), 0];
ParaBoundLim = ([UL;SP;LM]);
fit_curveAll = FitPsycheCurveWH_nx(cBTrFreqOcts,cBTrChoiceNM,ParaBoundLim);
CurveBounds = fit_curveAll.ffit.u;