function thres = getThreshold(spikes, stdEstimateRaw)

%calculate threshold
x=1:size(spikes,2);
[weights,weightsInv] = setDistanceWeight(x, 1);

stdEstimateSpikes  = mean(std(spikes));

factor = stdEstimateSpikes/stdEstimateRaw;

factor=1;
['factor for threshold is ' num2str(factor)]

globalStd = repmat( factor * stdEstimateRaw,1, 256);

%globalMean = mean(spikes);

%['global std is ' num2str(mean(spikes))]


thres = ((globalStd.^2)*weights)/256;
