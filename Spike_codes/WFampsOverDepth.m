
function [SpAmps, SpRates] = WFampsOverDepth(spikeAmps, spikeDepths, depthBins, recordingDur)

if ~exist('depthBins','var') || isempty(depthBins)
    depthBins = 0:20:3840;
end
nDbins = length(depthBins) - 1;

SpAmps = zeros(nDbins, 1);
SpRates = zeros(nDbins, 1);
for b = 1:nDbins
    cDepth_Amps = spikeAmps(spikeDepths>depthBins(b) & spikeDepths<=depthBins(b+1));
    if ~isempty(cDepth_Amps)
        SpAmps(b) = prctile(cDepth_Amps,95);
        SpRates(b) = numel(cDepth_Amps)/recordingDur;
    end
end

