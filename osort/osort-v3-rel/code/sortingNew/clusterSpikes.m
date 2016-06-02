%first step in online spike sorting.
%
%clusters spike according to their form.
%
%thres is the sensitive parameter -- change if result is not satisfying.
%
%
%%urut/april04
function [NrOfclustersFound, assigned] = clusterSpikes( allSpikes, allTimestamps,thres )
%thres=500;

%weights=ones(1,256);

%weights = [ ones(1,20)*1/2 ones(1,20)*1 ones(1,80)*10 ones(1,60)*1 ones(1,31)*1/2];
%weights = weights';

%set up weights
x=1:size(allSpikes,2);
weights = setDistanceWeight(x,1);

NrOfclustersFound=1;
baseClusters=[];

baseClusterLastUpdate=[];
baseClusterLastUpdate(1)=1;

baseClusters(1,:)=allSpikes(1,:);
clusterLastTimestamp=[];
clusterLastTimestamp(1) = allTimestamps(1);

assigned=zeros(1,size(allSpikes,1));
assigned(1) =1;

till=size(allSpikes, 1);
for i=2:till
    
    currentSpike = allSpikes(i,:);
    currentTimestamp = allTimestamps(i);
    
    smallestClust=0;
    
    %calculate difference to all base clusters
    
    %with weighting
    
    
    %diffs =  (((baseClusters - repmat(currentSpike, NrOfclustersFound,1)).^2) * weights) / (211*211) ;
    
    
    
    %normalized (per sample) and weighted square-error    
    %diffs = ((baseClusters - repmat(currentSpike, NrOfclustersFound,1)).^2)*weights / (256);

    diffs = calculateDistance(baseClusters, currentSpike, weights);
    
    %diffs
    
    sortedDiffs=sort(diffs); %ascending order
        
    %for j=NrOfclustersFound:-1:1
       pos = find ( diffs == sortedDiffs(1) );
       
       if length(pos)>1
           pos=pos(1);
       end
       
       if sortedDiffs(1) <= thres
%         if ( currentTimestamp-clusterLastTimestamp(pos))/1000 <= 75  %1=0.04ms, so 75=3ms
%            %this cluster matches but has not proper refractory
%            %'refractory problem '
%            %(clusterLastTimestamp(pos) - currentTimestamp)/1000
%            
%            %in 90 percent of cases, dont let go through
%            if rand<0.9
%             continue;
%            else
%             smallestClust=pos;
%             break;
%            end
%         else
            %assignment found
            smallestClust=pos;
%            break;
       end
%else
          % break;
           % end
       %end
   
    if smallestClust>0
        %add to smallest
        assigned(i)=smallestClust;
        clusterLastTimestamp(smallestClust) = currentTimestamp;

        baseClusterLastUpdate(smallestClust)=baseClusterLastUpdate(smallestClust)+1;

        %adjust base cluster
        
        if baseClusterLastUpdate(smallestClust)>=5
            %'update base cluster'
            clusterSpikes = allSpikes( find(assigned==smallestClust),:);
            baseClusters(NrOfclustersFound, :) = mean( clusterSpikes );
            baseClusterLastUpdate(smallestClust)=0;
        end
    else
        %no matching cluster found so far, create new
        NrOfclustersFound=NrOfclustersFound+1;
        baseClusters(NrOfclustersFound, :) = currentSpike;
        assigned(i) = NrOfclustersFound;
        clusterLastTimestamp(i) = currentTimestamp;
        baseClusterLastUpdate(NrOfclustersFound)=1;
    end
    
    if mod(i,100)==0
        i
    end
end

