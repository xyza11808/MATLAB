
clearvars SessionResultsR identifiedSOM trial_Stim_toneFreq FrameTime_2AFC dff_trials

load('SessionResultsR.mat','SessionResultsR');
load('identifiedSOM.mat','identifiedSOM');
load('nextTrig_dff_info.mat','trial_Stim_toneFreq','FrameTime_2AFC','dff_trials');

if ~isdir('./BatchedDataSave/')
    mkdir('./BatchedDataSave/');
end
cd('./BatchedDataSave/');
%%

Tr_isopto = double(cellfun(@(x) x.Trial_isOpto,SessionResultsR));
Tr_freqs = double(trial_Stim_toneFreq);

Tr_onsetTime = round(double(cellfun(@(x) x.Time_stimOnset,SessionResultsR))/FrameTime_2AFC); % convert to frames
[AlignF,AlignData] = RawData2AlignedData(Tr_onsetTime, dff_trials);

%%
BehavStrc.TrialStims = Tr_freqs;
BehavStrc.Trial_isOpto = Tr_isopto;
BehavStrc.Time_answer = double(cellfun(@(x) x.Time_answer,SessionResultsR));
BehavStrc.Trtypes = double(cellfun(@(x) x.Trial_Type,SessionResultsR));
BehavStrc.Action_choice = double(cellfun(@(x) x.Action_choice,SessionResultsR));
BehavStrc.Stim_toneFreq = BehavStrc.TrialStims;
BehavStrc.Time_stimOnset = double(cellfun(@(x) x.Time_stimOnset,SessionResultsR));
BehavStrc.Outcomes = BehavStrc.Trtypes(:) == BehavStrc.Action_choice(:);
fRate = round(1000/FrameTime_2AFC);

%%
SessDataobj = DataAnalysisSum(AlignData,BehavStrc,AlignF,fRate,1);

%%
TunCurveStrcs = SessDataobj.ROITunFun(1, 'Mean');
save TunDataSummary.mat TunCurveStrcs -v7.3

%%
FreqTypes = unique(BehavStrc.Stim_toneFreq);
BoundFreq = FreqTypes(ceil(numel(FreqTypes)/2));
BoundAUC = SessDataobj.SameStimChoiceDis(BoundFreq, 1, 'Mean');
CaledAUC = BoundAUC;
CaledAUCABS = CaledAUC.ContROIChoiceAUC(:,1);
CaledAUCABS(CaledAUC.ContROIChoiceAUC(:,2) == 1) = 1 - CaledAUCABS(CaledAUC.ContROIChoiceAUC(:,2) == 1);
save boundFreqChoiceAUC.mat BoundAUC CaledAUCABS -v7.3
% 
% %%
% NoiseCorrs = SessDataobj.optopopuZSCorr(1,'Mean');
% SigCorrs = SessDataobj.OptopopuSignalCorr(1,'Mean');
% 
% %%
% SessDataobj.OptoAlignDataColorplot(1,{'SOM',identifiedSOM});
% 
% %%
% ContSGCoefValues = AntiSquareform(SigCorrs{1});
% OptoSGCoefValues = AntiSquareform(SigCorrs{2});
% 
% %%
% ContNCCoefValues = AntiSquareform(NoiseCorrs{1});
% OptoNCCoefValues = AntiSquareform(NoiseCorrs{2});
% 
% %%
% save SGNCCoefData.mat NoiseCorrs SigCorrs ContSGCoefValues OptoSGCoefValues ContNCCoefValues OptoNCCoefValues -v7.3
% save DataClassSave.mat SessDataobj -v7.3


