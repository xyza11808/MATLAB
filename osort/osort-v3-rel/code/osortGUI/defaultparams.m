paths = [];

paths.basePath = 'C:\MATLAB\osort-v2\data';
paths.pathOut = [paths.basePath '\sort'];
paths.pathRaw = [paths.basePath '\raw\'];
paths.pathFigs = [paths.basePath '\figs\'];
paths.patientID = 'P13S2';
filesToProcess = [18];
groundChannels = [3 15 23 36 46];%
doGroundNormalization = 0;
extractionThreshold=0.2; %for wavelet method

paramsIn=[];

paramsIn.rawFileVersion=2; %1 is analog cheetah, 2 is digital cheetah (NCS), 3 is txt file.  determines sampling freq&dynamic range.
paramsIn.samplingFreq=24000; %only used if rawFileVersion==3
paramsIn.doDetection=1;
paramsIn.doSorting=1;
paramsIn.doFigures=1;
paramsIn.noProjectionTest=1;
paramsIn.doRawGraphs=1;
paramsIn.doGroundNormalization=doGroundNormalization;
paramsIn.outputFormat='png';
paramsIn.defaultAlignMethod=3;  %only used if peak finding method is "findPeak". 1=max, 2=min, 3=mixed
paramsIn.peakAlignMethod=2; %1 find Peak, 2 none, 3 peak of power, 4 MTEO peak
paramsIn.detectionMethod=1; %1 power, 2 T pos, 3 T min, 3 T abs, 4 wavelet
dp.scalesRange = [0.2 1.0]; %in ms 
dp.waveletName='bior1.5'; 
dp.kernelSize=18; 

savdir = '';
loaddir = '';

loadmerge = '';

save C:\MATLAB\osort-v2\GUI\default.mat -MAT