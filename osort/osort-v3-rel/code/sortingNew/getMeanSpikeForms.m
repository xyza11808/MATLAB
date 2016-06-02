%
%returns the mean waveform of all clusters.
%
%urut/april04
function meanSpikeForms = getMeanSpikeForms(allSpikes, assigned,nrOfClustersFound )
meanSpikeForms = zeros(nrOfClustersFound,size(allSpikes,2));
for i=1:nrOfClustersFound
        spikesToDraw = allSpikes( find(assigned==i),:);
        
        %if only one spike is in cluster, take this spike as mean of the
        %cluster
        meanOfCluster=[];
        if size(spikesToDraw,1)==1
            meanOfCluster=spikesToDraw;
        else
            meanOfCluster=mean(spikesToDraw);
        end
        meanSpikeForms(i,:) = meanOfCluster;
end
