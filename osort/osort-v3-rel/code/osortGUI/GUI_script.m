%% params not defined in gui;

if exist('groundChannels') && ~paramsIn.doGroundNormalization
  filesToProcess=setdiff(filesToProcess, groundChannels);
end

filesAlignMax=[];
filesAlignMin=[];
thres         =[repmat(extractionThreshold, 1, length(filesToProcess))];

%paramsIn.blockNrRawFig=1;
paramsIn.thresholdMethod=1; %1=approx, 2=exact
paramsIn.prewhiten=0; %0=no, 1=yes,whiten raw signal (dont)
paramsIn.tillBlocks=999;  %how many blocks to process (each ~20s). 0=no limit.
paramsIn.detectionParams=dp; 
normalizationChannels=[];
normalizeOnly=[];
        
%% pre-processing. below this lines are no parameters.

%% --mapping of ground to electrode

if exist('noiseChannels')
    filesToProcess=setdiff(filesToProcess, noiseChannels);
end

if paramsIn.doGroundNormalization
    electrodeAssignment = [ 1:32; repmat(1,1,8) repmat(2,1,8) repmat(3,1,8) repmat(4,1,8) ]; %which wire is on which electrode

    for j=1:length(filesToProcess)
        if length(find(normalizeOnly==filesToProcess(j)))==1
            normalizationChannels(1:2,j) = [filesToProcess(j); electrodeAssignment(2, j)];
        end
    end

    excludeChannels=setdiff(filesToProcess, filesToProcess);

    if exist('noiseChannels')
        excludeChannels=[excludeChannels noiseChannels];
    end

    %exclude noise channels from the grand average.
    excludeInds=[];
    for i=1:length(excludeChannels)
        excludeInds = [ excludeInds find( normalizationChannels(1,:) == excludeChannels(i) ) ];
    end
    includeInds = setdiff( 1:size(normalizationChannels,2), excludeInds);
    normalizationChannels = normalizationChannels(:, includeInds);
end

%align method can be changed for each channe;; alignMethod is only used if peakAlignMethod=1 (findPeak)
paramsIn.alignMethod = repmat(paramsIn.defaultAlignMethod, 1, length(filesToProcess));
for i=1:length(filesToProcess)
	if length(find( filesAlignMax == filesToProcess(i) ))==1
		alignMethod(i) = 1;
	end
	if length(find( filesAlignMin == filesToProcess(i) ))==1
		alignMethod(i) = 2;
	end
end
paramsIn.groundChannels=groundChannels;
%% execute
StandaloneGUI(paths, filesToProcess, thres, normalizationChannels, paramsIn);