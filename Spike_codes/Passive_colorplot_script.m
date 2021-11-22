% NPspikeDataMining processing pipeline
% ProbNPSess = NPspikeDataMining([],'passive'); % input the ks analysis folder path as start

%% load trigger onset times
ProbNPSess = ProbNPSess.triggerOnsetTime([],4);  % 4 is the trigger duration, in ms

%% given trigger time windows, and then calculate trigger onset PSTHs
TimeWin = [-0.4,3]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
% Smoothbin = [100,20]; % time window for smooth psth, in ms format
ProbNPSess = ProbNPSess.TrigPSTH(TimeWin, []);

%% load passive sound results
soundTextfile = PassiveFileFullPath;
Datas = readmatrix(soundTextfile);
BeforeSoundDelay = 1000; % in mili-second
TrFrequency = Datas(:,1);
TrDBs = Datas(:,2);
TrDuration = Datas(:,3);
NumTrials = length(TrFrequency);
TrOnsetVec = repmat(BeforeSoundDelay,NumTrials,1);
AlignEvents = [TrOnsetVec,TrOnsetVec+TrDuration];%,TrOnsetVec+TrDuration+floor((rand(numel(TrDuration),1)*200)+100)

%% raster plot of the raw spike datas
% % Passive_preprocessing; % calculate the aligned events and trial repeats values
TrRepeats = Datas(:,1:2);
 ProbNPSess.RawRasterplot(AlignEvents,{'SoundOn','SoundOff'},{'r','m'},TrRepeats);
% 
% %% binned spike color plots
% ProbNPSess.RawRespPreview(AlignEvents,{'SoundOn','SoundOff'},{'r','m'},TrRepeats);

%% Events sort color plots
% NPprocessks3_pass.EventsPSTHplot(AlignEvents,1,[TrFrequency,TrDBs],{'Frequency','DB'},{'SOnset','SOffset','sTest';'r','m','c'});
ProbNPSess.EventsPSTHplot(AlignEvents,1,[TrFrequency,TrDBs],{'Frequency','DB'},...
    {'SOnset','SOffset';'r','m'},[],'Passive_colorplot',[],ProbeChn_regionCells);

%%
NPSess.EventRasterplot(AlignEvents,1,[TrFrequency,TrDBs],{'Frequency','DB'},...
{'SOnset','SOffset';'r','m'},[],'Passive_colorplot');
