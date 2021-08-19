
% script to construct regression data from spike times and trigger times
UsedTrInds = 1:numel(ProbNPSess.UsedTrigOnTime{1}); % task sessions, convert to real used trial inds in real case
TrigOnsetTimes = ProbNPSess.UsedTrigOnTime{1}(UsedTrInds); % task trigger times

% session trial frequencies
SessFreqsAll = behavResults.Stim_toneFreq(UsedTrInds);
SessFreqsOnTimes = behavResults.Setted_TimeOnset(UsedTrInds);

% session trial choices 
SessChoicesAll = behavResults.Action_choice(UsedTrInds);
SessAnsTimes = behavResults.Time_answer(UsedTrInds);

% Session reward times


% constant variables, block types
SessionBloclTypes = behavResults.BlockType(UsedTrInds);







