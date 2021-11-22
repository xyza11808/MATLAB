%% you need to change most of the paths in this block

% addpath(genpath('D:\GitHub\KiloSort2')) % path to kilosort folder
% addpath('D:\GitHub\npy-matlab') % for converting to Phy
% rootZ = 'G:\Spikes\Sample'; % the raw data binary file is in this folder
% rootH = 'H:\'; % path to temporary binary file (same size as data, should be on fast SSD)
rootH = fullfile(rootZ,'temp');
if ~isdir(rootH)
    mkdir(rootH);
end
pathToYourConfigFile = 'C:\Users\NPacq\Documents\kilosort_configFile\configFiles'; % take from Github folder and put it somewhere else (together with the master_file)
chanMapFile = 'neuropixPhase3B2_kilosortChanMap.mat';

ops.trange    = [0 Inf]; % time range to sort
ops.NchanTOT  = 385; % total number of channels in your recording

run(fullfile(pathToYourConfigFile, 'configFile384.m'))
ops.fproc   = fullfile(rootH, 'temp_wh.dat'); % proc file on a fast SSD
ops.chanMap = fullfile(pathToYourConfigFile, chanMapFile);

%% this block runs all the steps of the algorithm
fprintf('Looking for data inside %s \n', rootZ)

% main parameter changes from Kilosort2 to v2.5
ops.sig        = 20;  % spatial smoothness constant for registration
ops.fshigh     = 300; % high-pass more aggresively
ops.nblocks    = 5; % blocks for registration. 0 turns it off, 1 does rigid registration. Replaces "datashift" option. 

% is there a channel map file in this folder?
fs = dir(fullfile(rootZ, 'chan*.mat'));
if ~isempty(fs)
    ops.chanMap = fullfile(rootZ, fs(1).name);
end

% find the binary file
fs          = [dir(fullfile(rootZ, '*.ap.bin')) dir(fullfile(rootZ, '*.dat'))];
ops.fbinary = fullfile(rootZ, fs(1).name);

% extract trigger times
try
    ExtractTriggerInfo(ops);
catch
    fprintf('Trigger info extraction error.\n');
end
%%
% preprocess data to create temp_wh.dat
rez = preprocessDataSub(ops);
%
% NEW STEP TO DO DATA REGISTRATION
rez = datashift2(rez, 1); % last input is for shifting data

% ORDER OF BATCHES IS NOW RANDOM, controlled by random number generator
iseed = 1;
                 
% main tracking and template matching algorithm
rez = learnAndSolve8b(rez, iseed);

% OPTIONAL: remove double-counted spikes - solves issue in which individual spikes are assigned to multiple templates.
% See issue 29: https://github.com/MouseLand/Kilosort/issues/29
rez = remove_ks2_duplicate_spikes(rez);

% final merges
rez = find_merges(rez, 1);

% final splits by SVD
rez = splitAllClusters(rez, 1);

% decide on cutoff
rez = set_cutoff(rez);
% eliminate widely spread waveforms (likely noise)
rez.good = get_good_units(rez);

fprintf('found %d good units \n', sum(rez.good>0))

% write to Phy
fprintf('Saving results to Phy  \n')
rez.ops.ksFolderPath = rootZ;
rootZ = fullfile(rootZ,'ks2_5');
if ~isdir(rootZ)
    mkdir(rootZ);
end
rezToPhy(rez, rootZ);

%% if you want to save the results to a Matlab file...

% discard features in final rez file (too slow to save)
rez.cProj = [];
rez.cProjPC = [];

% final time sorting of spikes, for apps that use st3 directly
[~, isort]   = sortrows(rez.st3);
rez.st3      = rez.st3(isort, :);

% Ensure all GPU arrays are transferred to CPU side before saving to .mat
rez_fields = fieldnames(rez);
for i = 1:numel(rez_fields)
    field_name = rez_fields{i};
    if(isa(rez.(field_name), 'gpuArray'))
        rez.(field_name) = gather(rez.(field_name));
    end
end

% save final results as rez2
fprintf('Saving final results in rez2...\n')
fname = fullfile(rootZ, 'rez2.mat');
save(fname, 'rez', '-v7.3');

%% save figures
% save component figure

hf1 = gcf;
savename = fullfile(rootZ,'Component and amp plot');
saveas(hf1,savename);
saveas(hf1,savename,'png');
close(hf1);

% save spike position map plot
hf2 = gcf;
savename2 = fullfile(rootZ,'spike position map plot');
saveas(hf2,savename2);
saveas(hf2,savename2,'png');
close(hf2);

% save spike position map plot
hf3 = gcf;
savename3 = fullfile(rootZ,'drift trace plot');
saveas(hf3,savename3);
saveas(hf3,savename3,'png');
close(hf3);

%% delete temp files
DeletfilePath = ops.fproc;
rmdir(rootH,'s');

%% construct group info file
FolderPath = rootZ;
SR = rez.ops.fs;
disp('Constructing cluster info files...\n');
ks3_Result2Info_script;


%% calculate unit waveform for each unit
[UsedClus_IDs,~] = SpikeWaveFeature_single(rez);

%% calculate the ccg for each clusters
spdata.SpikeClus = readNPY(fullfile(rez.ops.ksFolderPath,'ks2_5','spike_clusters.npy'));
spdata.SpikeTimeSample = readNPY(fullfile(rez.ops.ksFolderPath,'ks2_5','spike_times.npy'));
spdata.ksfolder = rootZ;
spdata.sample_rate = rez.ops.fs;
spdata.UsedClus_IDs = UsedClus_IDs;

refractoryPeriodCal_sg(spdata,[],2,1e-3); % [] indicates all clustes

%% calculate LFP signals from *.lf.bin file
myKsDir = fullfile(rootZ,'..');
lfpD = dir(fullfile(myKsDir, '*.lf.bin')); % LFP file from spikeGLX specifically
lfpFilename = fullfile(myKsDir, lfpD(1).name);

lfpFs = 2500;  % neuropixels phase3B2
nChansInFile = 385;  % neuropixels phase3a, from spikeGLX

[lfpByChannel, allPowerEst, F, allPowerVar] = ...
    lfpBandPower(lfpFilename, lfpFs, nChansInFile, []);
%
try
    chanMap = readNPY(fullfile(myKsDir, 'ks2_5', 'channel_map.npy'));
catch
    chanMap = readNPY(fullfile(myKsDir, 'channel_map.npy'));
end
    nC = length(chanMap);

allPowerEst = allPowerEst(:,chanMap+1)'; % now nChans x nFreq

% plot LFP power
dispRange = [0 100]; % Hz
marginalChans = [10:50:nC];
freqBands = {[1.5 4], [4 10], [10 30], [30 80], [80 200]};
%
hf = plotLFPpower(F, allPowerEst, dispRange, marginalChans, freqBands);
savefigname = fullfile(rootZ,'LFP power for all channels');
saveas(hf,savefigname);
saveas(hf,savefigname,'png');
close(hf);

matfilesavename = fullfile(rootZ,'LFPpowerData.mat');
save(matfilesavename,'F', 'allPowerEst', 'dispRange', 'marginalChans', 'freqBands','-v7.3');








