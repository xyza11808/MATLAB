%
%fits radial basis function to each spike and returns coeffiecents.
%
%
%
function [spikesRBF, spikesSolved] = RBFconv( spikes )
%spikesSolved=spikes;
%return;

x=1:size(spikes,2);
nrOfCenters = 16;
centers = linspace( x(1), x(end), nrOfCenters );   %  pick centers 

spikesRBF=zeros(size(spikes,1), nrOfCenters);
spikesSolved=zeros(size(spikes,1), size(spikes,2));

for i=1:size(spikes,1)
    spikesRBF(i,:) = rfit( x, spikes(i,:), centers );
    spikesSolved(i,:) = rsolve( spikesRBF(i,:), centers, x);
end