%
%
%assign spikes to one of the waveforms supplied or throw away as noise
%
%cluster nr 999 is noise
%
function [assignedCluster, rankedClusters ] = assignToWaveform(allSpikes, allTimestamps, meanWaveforms, defaultThreshold, stdEstimate, maxDistance, envelopeSize)

assignedCluster = zeros(1,size(allSpikes,1));

noiseClusterNr=999;

x=1:size(meanWaveforms,2);
[weights,weightsInv] = setDistanceWeight(1:256,1);

%establish threshold -- difference between mean waveforms
diffs = [];
for i=1:size(meanWaveforms,1)
    diffs(i,:) = (calculateDistance(meanWaveforms, meanWaveforms(i,:), weights))';
    
    %diffs(i,:) = ((((meanWaveforms - repmat(meanWaveforms(i,:), size(meanWaveforms,1),1)).^2)*weights) / (256))';
end

%factor=3;

factor=maxDistance;
globalStd = repmat( factor * stdEstimate,1, 256);
thres = ((globalStd.^2)*weights)/256;

%thres=3*defaultThreshold;
% 
% %if there are 2 or more clusters -- automatically set threshold
% if size(meanWaveforms,1)>1
% 	%find smallest
% 	minT=99999999;
% 	minPos=[0 0];
% 	for i=1:size(meanWaveforms,1)
%         for j=size(meanWaveforms,1):-1:i+1
%             if diffs(i,j) < minT
%                 minT=diffs(i,j);
%                 minPos=[i j];
%             end
%         end
% 	end
% 	
% 	thres=minT;
%     
%     thres
% else
%     %if there is only one cluster -- go to default threshold
%     thres=defaultThreshold;
% end 


%thres=defaultThreshold;

%envThres = 0.1 * max( meanWaveforms(:,95) )

%avMean = 1/2*mean( meanWaveforms(:,95) )
upperEnvelope= meanWaveforms + stdEstimate*envelopeSize; %repmat(weightsInv'*avMean, size(meanWaveforms,1),1);
lowerEnvelope= meanWaveforms - stdEstimate*envelopeSize; %repmat(weightsInv'*avMean, size(meanWaveforms,1),1);
['std estimate used for envelope is ' num2str(stdEstimate)]

%----

nrOfMeanWaveforms = size(meanWaveforms,1);
for i=1:size(allSpikes,1)
    currentSpike=allSpikes(i,:);

    %default assignment
    assignedCluster(i)=noiseClusterNr;
    
    %diffs = ((((meanWaveforms - repmat(currentSpike, nrOfMeanWaveforms,1)).^2)*weights) / (256))';

    diffs = (calculateDistance(meanWaveforms, currentSpike, weights))';

    sortedDiffs=sort(diffs);    
    
    for j=1:size(sortedDiffs)
        if sortedDiffs(j) < thres   %smallest
            %additionally, needs to match envelope
            
            indOrig = find(diffs==sortedDiffs(j));
            if length( find ( (upperEnvelope(indOrig,:)-currentSpike) < 0 )>0) || length( find ( (currentSpike-lowerEnvelope(indOrig,:)) < 0 )>0)
                %['envelope not matched' num2str(i)]
                continue;
            end
            
            %assign to this cluster
            assignedCluster(i)=find ( diffs == sortedDiffs(j) );
            break;
        else
            %assign to noise
            assignedCluster(i)=noiseClusterNr;
            break;
        end   
    end
end

elementsInCluster=zeros(nrOfMeanWaveforms,2 );
for i=1:nrOfMeanWaveforms
    elementsInCluster(i,1) = i;
    elementsInCluster(i,2) = length( find(assignedCluster==i) );
end

rankedClusters = sortrows( elementsInCluster, 2);

