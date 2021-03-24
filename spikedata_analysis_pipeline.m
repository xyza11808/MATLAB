

% NPspikeDataMining processing pipeline
NPprocessks3 = NPspikeDataMining('G:\AuD_PASSIVE_TEST_g0\kilosort3'); % input the ks analysis folder path as start

%% load trigger onset times
NPprocessks3 = NPprocessks3.triggerOnsetTime([],2); 

%% given trigger time windows, and then calculate trigger onset PSTHs
TimeWin = [-1,5]; % time window used to calculate the psth, usually includes before and after trigger time, in seconds
Smoothbin = [50,10]; % time window for smooth psth, in ms format
NPprocessks3 = NPprocessks3.TrigPSTH(TimeWin, Smoothbin);

%% raster plot of the raw spike datas
% Passive_preprocessing; % calculate the aligned events and trial repeats values

NPprocessks3.RawRasterplot(AlignEvents,{'SoundOn','SoundOff'},{'r','m'},TrRepeats);

%% binned spike color plots
NPprocessks3.RawRespPreview(AlignEvents,{'SoundOn','SoundOff'},{'r','m'},TrRepeats);


