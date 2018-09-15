
% calculate the correct left trial mean trace
SessTrFreqs = double(behavResults.Stim_toneFreq(:));
SessTrChoice = double(behavResults.Action_choice(:));
SessTrTypes = double(behavResults.Trial_Type(:));

NMInds = SessTrChoice ~= 2;
NMTrFreqs = SessTrFreqs(NMInds);
NMTrChoice = SessTrChoice(NMInds);
NMTrTypes = SessTrTypes(NMInds);
NMNormIndexSummary = cLRIndexSumNor(NMInds,:);

NMTrOutcome = trial_outcome(NMInds);

