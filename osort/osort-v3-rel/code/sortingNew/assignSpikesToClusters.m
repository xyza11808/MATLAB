%
%this function is a very much simplified version of sortSpikesOnline.m
%It takes a number of precomputed cluster centers and assigns each spike to them, if they
%are within the threshold. all others are assigned to noise. no new clusters are removed/merged.
%
%urut/sept06
function assigned = assignSpikesToClusters(baseSpikes, IDs, allWaveforms, stdEstimate)
defineSortingConstants;

noiseCluster=CLUSTERID_NOISE_CLUSTER;
    
n=size(allWaveforms,1);
nrDatapoints=size(allWaveforms,2);

thresholdMethod=1;
weights=ones(1,nrDatapoints);

thres = stdEstimate^2 * length(find(weights));
thres=thres*1.5;
%thres=thres*2;

baseSpikesID=[];
for i=1:size(baseSpikes,1)
    baseSpikesID(i,1:2) = [IDs(i) i];
end

assigned = zeros(1,n);
for i=1:n
    D=calcDistMacro( thresholdMethod, baseSpikes, allWaveforms(i,:), weights',[]);

    if min(D)>thres
        %noise
        assigned(i)=noiseCluster;
    else
        Dsorted=sortrows(D);
        ind=find(Dsorted(1)==D);
            
        %assign the spike to this cluster and increase counter
        IDassigned=baseSpikesID(find(baseSpikesID(:,2)==ind)  ,1);
        assigned(i)=IDassigned;
    end
end
