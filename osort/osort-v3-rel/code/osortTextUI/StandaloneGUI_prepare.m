function [normalizationChannels,paramsIn] = StandaloneGUI_prepare(noiseChannels,doGroundNormalization,paramsIn,filesToProcess, filesAlignMax, filesAlignMin )

normalizationChannels=[]; %maps channel to electrode. All that are listed are used for normalization.
if exist('noiseChannels')
    filesToProcess=setdiff(filesToProcess, noiseChannels);
end

if doGroundNormalization
    electrodeAssignment = [ 1:64; repmat(1,1,8) repmat(2,1,8) repmat(3,1,8) repmat(4,1,8) repmat(5,1,8) repmat(6,1,8) repmat(7,1,8) repmat(8,1,8) ]; %which wire is on which electrode

    %map channels to El number
    for j=1:length(normalizeOnly)
        indOfEl = find( electrodeAssignment(1,:)==normalizeOnly(j) );
        normalizationChannels(1:2,j) = [normalizeOnly(j); electrodeAssignment(2, indOfEl)];
    end
    
    %for j=1:length(filesToProcess)
    %    if length(find(normalizeOnly==filesToProcess(j)))==1
    %        normalizationChannels(1:2,j) = [filesToProcess(j); electrodeAssignment(2, j)];
    %    end
    %end

    excludeChannels=[]; %setdiff(filesToProcess, filesToProcess);

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

    paramsIn.groundChannels=groundChannels;
end

%align method can be changed for each channe;; alignMethod is only used if peakAlignMethod=1 (findPeak)
paramsIn.alignMethod = repmat(paramsIn.defaultAlignMethod, 1, length(filesToProcess));
for i=1:length(filesToProcess)
	if length(find( filesAlignMax == filesToProcess(i) ))==1
		paramsIn.alignMethod(i) = 1;
	end
	if length(find( filesAlignMin == filesToProcess(i) ))==1
		paramsIn.alignMethod(i) = 2;
	end
end