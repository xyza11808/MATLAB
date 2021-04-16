

% NPspikeDataMining processing pipeline
NPprocessks3 = NPspikeDataMining('G:\AuD_PASSIVE_TEST_g0\kilosort3'); % input the ks analysis folder path as start

%% load trigger onset times
NPprocessks3 = NPprocessks3.triggerOnsetTime([],2);  % 2 is the trigger duration, in ms

%% given trigger time windows, and then calculate trigger onset PSTHs
TimeWin = [-0.4,1.8]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
Smoothbin = [50,10]; % time window for smooth psth, in ms format
NPprocessks3 = NPprocessks3.TrigPSTH(TimeWin, Smoothbin);

%% load passive sound results
soundTextfile = 'G:\AuD_PASSIVE_TEST_g0\passive tones20210316.txt';
Datas = readmatrix(soundTextfile);
BeforeSoundDelay = 1000; % in mili-second
TrFrequency = Datas(:,1);
TrDBs = Datas(:,2);
TrDuration = Datas(:,3);
NumTrials = length(TrFrequency);
TrOnsetVec = repmat(BeforeSoundDelay,NumTrials,1);
AlignEvents = [TrOnsetVec,TrOnsetVec+TrDuration,TrOnsetVec+TrDuration+floor((rand(numel(TrDuration),1)*200)+100)];

%% raster plot of the raw spike datas
% Passive_preprocessing; % calculate the aligned events and trial repeats values

NPprocessks3.RawRasterplot(AlignEvents,{'SoundOn','SoundOff'},{'r','m'},TrRepeats);

%% binned spike color plots
NPprocessks3.RawRespPreview(AlignEvents,{'SoundOn','SoundOff'},{'r','m'},TrRepeats);

%% Events sort color plots
NPprocessks3.EventsPSTHplot(AlignEvents,1,[TrFrequency,TrDBs],{'Frequency','DB'},{'SOnset','SOffset','sTest';'r','m','c'});


%% Task analysis sessions










