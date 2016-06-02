%
%distance measure between different spikes.
%
%version that uses covariance matrix. Cinv is the inverted covariance
%matrix
function diffs = calculateDistanceChi2(baseClusters, to, Cinv)
n=size(baseClusters,1);
diffs=zeros(n,1);
for i=1:n
        %diffs(i) = (baseClusters(i,:) - to) * Cinv * (baseClusters(i,:) - to)';
        diffs(i) = (to - baseClusters(i,:)) * Cinv * (to - baseClusters(i,:) )';
        
        if diffs(i) < 0
            warning(['problem: distance negative??' num2str(diffs(i)) ]);
            diffs(i)=10000;
        end
end

%diffs = ((baseClusters - repmat(to, size(baseClusters,1),1)).^2)*weights ; %/ (size(baseClusters,2));
