%
% Standalone_textGUI_demo1.m
%
% This file processes the A18.ncs demo file provided


%% which files to sort
paths=[];

paths.basePath='/home/urut/data/OSortDemo/';
paths.pathOut=[paths.basePath 'sort/'];
paths.pathRaw=[paths.basePath '/raw/'];
paths.pathFigs=[paths.basePath '/figs/'];
paths.timestampspath=paths.basePath;             % if a timestampsInclude.txt file is found in this directory, only the range(s) of timestamps specified will be processed. 

paths.patientID='PDemo1'; % label in plots

filesToProcess = [  18 ];  %which channels to detect/sort
noiseChannels  = [   ]; % which channels to ignore

groundChannels=[]; %which channels are ground (ignore)

doGroundNormalization=0;
normalizeOnly=[]; %which channels to use for normalization

if exist('groundChannels') && ~doGroundNormalization
  filesToProcess=setdiff(filesToProcess, groundChannels);
end

%default align is mixed, unless listed below as max or min.
filesAlignMax=[ ];
filesAlignMin=[ ];


%% global settings
paramsIn=[];

paramsIn.rawFilePrefix='A';        % some systems use CSC instead of A
paramsIn.processedFilePrefix='A';

paramsIn.rawFileVersion = 1; %1 is analog cheetah, 2 is digital cheetah (NCS), 3 is txt file.  determines sampling freq&dynamic range.
paramsIn.samplingFreq = 0; %only used if rawFileVersion==3

%which tasks to execute
paramsIn.tillBlocks = 999;  %how many blocks to process (each ~20s). 0=no limit.
paramsIn.doDetection = 1;
paramsIn.doSorting = 1;
paramsIn.doFigures = 1;
paramsIn.noProjectionTest = 1;
paramsIn.doRawGraphs = 1;
paramsIn.doGroundNormalization=doGroundNormalization;

paramsIn.displayFigures = 1 ;  %1 yes (keep open), 0 no (export and close immediately); for production use, use 0 

paramsIn.minNrSpikes=50; %min nr spikes assigned to a cluster for it to be valid
                                                                                                                         
%params
paramsIn.blockNrRawFig=[ 1 2 ];
paramsIn.outputFormat='png';
paramsIn.thresholdMethod=1; %1=approx, 2=exact
paramsIn.prewhiten=0; %0=no, 1=yes,whiten raw signal (dont)
paramsIn.defaultAlignMethod=3;  %only used if peak finding method is "findPeak". 1=max, 2=min, 3=mixed
paramsIn.peakAlignMethod=1; %1 find Peak, 2 none, 3 peak of power, 4 MTEO peak
                        
%for wavelet detection method
%paramsIn.detectionMethod=5; %1 power, 2 T pos, 3 T min, 4 T abs, 5 wavelet
%dp.scalesRange = [0.2 1.0]; %in ms
%dp.waveletName='bior1.5'; 
%paramsIn.detectionParams=dp;
%extractionThreshold=0.1; %for wavelet method

%for power detection method
paramsIn.detectionMethod=1; %1 power, 2 T pos, 3 T min, 3 T abs, 4 wavelet
dp.kernelSize=18; 
paramsIn.detectionParams=dp;
extractionThreshold = 5;  % extraction threshold

thres         = [repmat(extractionThreshold, 1, length(filesToProcess))];

%% execute
[normalizationChannels,paramsIn] = StandaloneGUI_prepare(noiseChannels,doGroundNormalization,paramsIn,filesToProcess,filesAlignMax, filesAlignMin);
StandaloneGUI(paths, filesToProcess, thres, normalizationChannels, paramsIn);
