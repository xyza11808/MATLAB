%%
ChoicelickTime = double(FLickT);
OnsetT = double(behavResults.Time_stimOnset);
TrialOut = trial_outcome;
TrialType = double(behavResults.Trial_Type);

%%
RespTDiff = ChoicelickTime - OnsetT;
CorrTrials = TrialOut == 1;
CorrTTypes = TrialType(CorrTrials);
CorrDiffT = RespTDiff(CorrTrials);
CorrLeftDiffT = CorrDiffT(CorrTTypes == 0);
CorrRightDiffT = CorrDiffT(CorrTTypes == 1);

%%
h1=figure;
hist(CorrLeftDiffT,20);
title(sprintf('Mean RespT = %.2f, Median RespT = %d',mean(CorrLeftDiffT),median(CorrLeftDiffT)));
xlabel('Time(ms)');
ylabel('Count');

h2=figure;
hist(CorrRightDiffT,20);
title(sprintf('Mean RespT = %.2f, Median RespT = %d',mean(CorrRightDiffT),median(CorrRightDiffT)));
xlabel('Time(ms)');
ylabel('Count');

%%
LeftSelectTWin = median(CorrLeftDiffT);  % this definition may change accoridng to real condition

%%
FrameRate = frame_rate;
AfterFrame = LeftSelectTWin/1000;
RandNeuroMTestCrossV(smooth_data,behavResults.Stim_toneFreq,trial_outcome,start_frame,FrameRate,AfterFrame);
