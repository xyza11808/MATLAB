addpath('D:\code\neuropixel-utils')
% Create an ImecDataset pointing at a specific
channelMapFile='D:\code\neuropixel-utils\map_files\neuropixPhase3B2_kilosortChanMap.mat';

imec = Neuropixel.ImecDataset('D:\Data\M3_20200518_g2\M3_20200518_g2_imec1\M3_20200518_g2_t0_1.imec.ap.bin', 'channelMap', channelMapFile);

ImecDataset with properties:
% Mark individual channels as bad based on RMS voltage
rmsBadChannels = imec.markBadChannelsByRMS('rmsRange', [3 100]);

% Specify names for the individual bits in the sync channel
imec.setSyncBitNames([1 2 3], {'trialInfo', 'trialStart', 'stim'});

% Save the bad channels and Sync bit names to the .imec.ap.meta file so they are loaded next time
imec.writeModifiedAPMeta();

% Perform common average referencing on the file and save the results to a new location
cleanedPath = 'D:\Data\M3_20200518_g2\M3_20200518_g2_imec1_cleaned\M3_20200518_g2_t0_1.imec.ap.bin';
extraMeta = struct();
extraMeta.commonAverageReferenced = true;
fnList = {@Neuropixel.DataProcessFn.commonAverageReference};
imec = imec.saveTranformedDataset(cleanedPath, 'transformAP', fnList, 'extraMeta', extraMeta);

% Sym link the cleaned dataset into a separate directory for Kilosort2
ksPath = '/data/kilosort/neuropixel_01.imec.ap.bin';
imec = imec.symLinkAPIntoDirectory(ksPath);

% Inspect the raw IMEC traces
imec.inspectAP_timeWindow([200 201]); % 200-201 seconds into the recording
