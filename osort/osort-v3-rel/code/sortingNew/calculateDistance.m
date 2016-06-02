%
%distance measure between different spikes.
%
%
function diffs = calculateDistance(baseClusters, to, weights)

diffs = ((baseClusters - repmat(to, size(baseClusters,1),1)).^2)*weights ; %/ (size(baseClusters,2));
