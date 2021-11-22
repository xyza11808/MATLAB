% load a ks session
cclr
NPSess = NPspikeDataMining('F:\b106a01\catgt_b106a01_Dyetest1_20211102_g0\Cat_b106a01_Dyetest1_20211102_g0_imec0\ks2_5','task');

%% generate trigger
NPSess.CurrentSessInds = strcmpi('task',NPSess.SessTypeStrs);
NPSess = NPSess.triggerOnsetTime([],[2]);  % 4 is the trigger duration, in ms

%% given trigger time windows, and then calculate trigger onset PSTHs
% % for passive session
% TimeWin = [-0.5,3]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [100,20]; % time window for smooth psth, in ms format
% NPSess = NPSess.TrigPSTH(TimeWin, Smoothbin);

% for task session
TrTypes = double(behavResults.Trial_Type(:));
TrActionChoice = double(behavResults.Action_choice(:));
TrFreqUseds = double(behavResults.Stim_toneFreq(:));
TrStimOnsets = double(behavResults.Time_stimOnset(:));
TrTimeAnswer = double(behavResults.Time_answer(:));
TrTimeReward = double(behavResults.Time_reward(:));
TrManWaters = double(behavResults.ManWater_choice(:));

TimeWin = [-1.5,5]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
Smoothbin = [50,10]; % time window for smooth psth, in ms format
NPSess = NPSess.TrigPSTH(TimeWin, Smoothbin,TrStimOnsets);

%% cluster quality check
% % test script for calling the UsedClusIndsCheckFun()
% ScreenOps = struct('Unitwaveform',true,...
%     'ISIviolation',0.1,...  % default threshold value is 0.1, or 10%
%     'SessSpiketimeCheck',true,...
%     'Amplitude',30,... % threshold amplitude value, default is 70uv
%     'WaveformSpread',1000,... % 1000um, about 50 channels?.
%     'FiringRate',1,... % 1Hz
%     'SNR',3); 
% 
% OverAllExcludeInds = UsedClusIndsCheckFun(NPSess,ScreenOps);
% 
% %%
NPSess = NPSess.ClusScreeningFun;

%%
NPSess.EventsPSTHplot(AlignEvents,1,[TrFrequency,TrDBs],{'Frequency','DB'},...
    {'SOnset','SOffset';'r','m'},[],'Passive_colorplot');

%%
NPSess.EventRasterplot(AlignEvents,1,[TrFrequency,TrDBs],{'Frequency','DB'},...
{'SOnset','SOffset';'r','m'},[],'Passive_colorplot');

%% task session processing
NMChoiceInds = TrActionChoice ~= 2;
[lick_time_struct,Lick_bias_side]=beha_lickTime_data(behavResults,TimeWin(2)); 

EventsDelay = [TrStimOnsets,TrTimeAnswer];
AlignEvent = 1;
RepeatTypes = [TrFreqUseds,TrActionChoice];
RepeatStr = {'Sounds','Choice'};
EventColors = {'SOnset','AnswerT';'r','m'};
PlotNameStr = 'TaskEventPlots';

[NPSess,StimAvgTrace,StimTypes] = NPSess.EventsPSTHplot(EventsDelay,AlignEvent,RepeatTypes,RepeatStr,EventColors,...
               NMChoiceInds,PlotNameStr,lick_time_struct);

%% raster plot
PlotNameStr2 = 'TaskRasterPlots';
NPSess.EventRasterplot(EventsDelay,[1,2],RepeatTypes,RepeatStr,EventColors,...
            NMChoiceInds,PlotNameStr2,lick_time_struct);
%%
% save class handle
save NPclassHandle.mat NPSess -v7.3



