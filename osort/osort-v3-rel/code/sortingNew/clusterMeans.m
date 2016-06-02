%
%merges mean waveforms of found clusters, according to order (meanClusters
%is sorted, first one is strongest).
%
%urut/april04
%------
function [newMeans,success] = clusterMeans(meanClusters, nrAssigned, thres)
success=false;

newMeans=meanClusters;

if size(meanClusters,1)==1
    return;
end

x=1:size(meanClusters,2);
weights = setDistanceWeight(x,2);

%re-order mean Clusters

rankingNew=zeros(size(meanClusters,1),2);
rankingNew(:,1)=(1:size(meanClusters,1))';
rankingNew(:,2)= meanClusters(:,95);  %maxPos

rankingSorted = sortrows(rankingNew,1);

rankingSorted

%merging, from top to bottom

minT=999999999;
minPos=[];
for i=1:size(rankingNew,1)
    %check all others,except itself
    diffs = (calculateDistance(meanClusters(rankingSorted(:,1),:), meanClusters(rankingSorted(i,1),:), weights))';

    for j=1:length(diffs)
        if j~=i
            if diffs(j) < minT
                minT=diffs(j);    
                minPos=[rankingSorted(i,1) rankingSorted(j,1)];
            end
        end
    end
    
    if minT <= thres
        newMeansTmp = meanClusters;
    
        %copy all old ones
        %totSpikes = nrAssigned(i)+nrAssigned(j);
        %weights1 = nrAssigned(i)/totSpikes;
        %weights2 = nrAssigned(j)/totSpikes;
    
        weights1=.5;
        weights2=.5;
    
        %replace old one with new (merged) one, to retain ranked order
        %if commented out -- only remove, so that at the end only mean
        %waveforms remain that are thres apart
        %newMeansTmp(minPos(1),:) = weights1*meanClusters(minPos(1),:) + weights2*meanClusters(minPos(2),:);   %merge two waveforms

        %remove old one
        indsNew = [];
        cl=1;
        for k=1:size(meanClusters,1)
            if k~=minPos(2)
                indsNew(cl)=k;
                cl=cl+1;
            end
        end
    
        newMeans = newMeansTmp(indsNew,:);
    
        success=true;
        break;
    end
end


%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


%-----following code:merging according to smallest is merged first
% 
% minT=999999999;
% minPos=[];
% for i=1:size(meanClusters,1)
%     %check all others,except itself
%     diffs = (calculateDistance(meanClusters, meanClusters(i,:), weights))';
% 
%     for j=1:size(meanClusters,1)
%         if j~=i
%             if diffs(j) < minT
%                 minT=diffs(j);    
%                 minPos=[i j];
%             end
%         end
%     end
% end
% 
% %merge this
% if minT <= thres
%     newMeansTmp = meanClusters;
%     
%     %copy all old ones
%     %totSpikes = nrAssigned(i)+nrAssigned(j);
%     %weights1 = nrAssigned(i)/totSpikes;
%     %weights2 = nrAssigned(j)/totSpikes;
%     
%     weights1=.5;
%     weights2=.5;
%     
%     %replace old one with new (merged) one, to retain ranked order
%     %if commented out -- only remove, so that at the end only mean
%     %waveforms remain that are thres apart
%     %newMeansTmp(minPos(1),:) = weights1*meanClusters(minPos(1),:) + weights2*meanClusters(minPos(2),:);
% 
%     %remove old one
%     indsNew = [];
%     cl=1;
%     for k=1:size(meanClusters,1)
%         if k~=minPos(2)
%             indsNew(cl)=k;
%             cl=cl+1;
%         end
%     end
%     
%     newMeans = newMeansTmp(indsNew,:);
%     
%     success=true;
% end
