%
%distance measure between mean waveforms (mean of clusters).
%
%version that uses covariance matrix. Cinv is the inverted covariance
%matrix
function [diffs,thresholds] = calculateDistanceT2(baseClusters, to, toID, Cinv, baseSpikesCounter)

alpha=0.05;

p=size(baseClusters,2);
n=size(baseClusters,1);
diffs=zeros(n,1);
thresholds=zeros(n,1);


for i=1:n
        %diffs(i) = (baseClusters(i,:) - to) * Cinv * (baseClusters(i,:) - to)';
        
        n1 = baseSpikesCounter(i);
        n2 = baseSpikesCounter(toID);

        %n1 = 35; n2=35;
        
        [diffs(i), thresholds(i)] = calcFDist( p, n1, n2, baseClusters(i,:), to, Cinv, alpha);

        
end

%diffs = ((baseClusters - repmat(to, size(baseClusters,1),1)).^2)*weights ; %/ (size(baseClusters,2));
