%this is the main file for spikesorting after spike detection.
%there is also a GUI for this:  GUIsorting2.m/fig
%
%
%-----------------

%0. load data
allSpikes=OKspikesPositive;
allTimestamps=OKtimestampsPositive;

%1. first -- check raw data
plotRawWithHist('', allSpikes, allTimestamps);

%2. second -- filter raw waveforms to get rid of artifacts, non-real spikes and
%other shit
[newSpikes,newTimestamps,didntPass] = postDetectionFilter( allSpikes, allTimestamps);
newSpikes = realigneSpikes(newSpikes);


%3. third -- compare histogram to judge raw data quality
figure(111)
subplot(1,2,1)
d = diff(newTimestamps);
d = d/1000; %in ms
d = d/0.04; % 1 step is 0.04ms
n=histc(d,0:0.05:100);
bar(0:0.05:100,n,'histc');
title('new');

subplot(1,2,2)
d = diff(allTimestamps);
d = d/1000; %in ms
d = d/0.04; % 1 step is 0.04ms
n=histc(d,0:0.05:100);
bar(0:0.05:100,n,'histc');
title('old');

%4. check filtering results
figure(999)
%plot( didntPass','g');
plotRawWithHist('', newSpikes, newTimestamps);


%5. convert to RBF and realign
[spikesRBF, spikesSolved] = RBFconv( newSpikes );
spikesSolved = realigneSpikes(spikesSolved);


figure(999)
plotRawWithHist('', spikesSolved, newTimestamps);


%6. calculate threshold
x=1:size(spikesSolved,2);
[weights,weightsInv] = setDistanceWeight(x);

globalMean = mean(spikesSolved);
globalStd  = std(spikesSolved);

initialThres = ((globalStd.^2)*weights)/256;

%figure(654)
%plot(x, globalMean, x, globalMean+globalStd, x, globalMean-globalStd);

%7. cluster to find mean waveforms of cluster
[NrOfclustersFound, assignedCluster, meanSpikeForms, rankedClusters ] = sortBlock(spikesSolved, newTimestamps, initialThres);

%figure(653)
%plot(meanSpikeForms( rankedClusters(end-17:end,1),:)');


%----- calculate threshold for merging
%find all mean clusters such that 80% are covered; max 20
%for meanClustersToConsider=1:20
%    if sum(rankedClusters(end-meanClustersToConsider:end,2)) >= .8 * nrSpikes 
%        break;
%    end
%end

%meanStd=std(meanSpike


%8. merge mean clusters
[meanWaveforms,meanClusters] = createMeanWaveforms( size(spikesSolved,1), meanSpikeForms, rankedClusters, initialThres);

figure(36)
displayMeanWaveforms( meanWaveforms, meanClusters, initialThres, '');


%figure(34)
%plotClusters(newSpikes, newTimestamps, assignedCluster, rankedClusters, '');


%9. now re-cluster, using this new mean waveforms
[assignedCluster, rankedClusters ] = assignToWaveform(spikesSolved, newTimestamps, meanClusters, initialThres);



figure(34)
plotClusters(newSpikes, newTimestamps, assignedCluster, rankedClusters, '');

figure(35)
plotSingleCluster(newSpikes, newTimestamps, assignedCluster, rankedClusters, '', 2)


%figure(99)
%plot(1:256, spikesSolved( find(assignedCluster==1) ,:)','g', 1:256, spikesSolved( find(assignedCluster==2) ,:)','r');

%figure(100)
%plot(1:256, newSpikes( find(assignedCluster==1) ,:)','g', 1:256, newSpikes( find(assignedCluster==2) ,:)','r');

%figure(101)
%plot(1:256, newSpikes( find(assignedCluster==999) ,:)','g');



%find 11ms noise trash spikes

d = diff(newTimestamps);
d = d/1000; %in ms
d = d/0.04; % 1 step is 0.04ms

edges=0:1:70;
n=histc(d,edges);
figure(100)
bar(edges,n,'histc');

figure(111)
plot ( 1:256, newSpikes ( find ( d>2.0   ) , : ), 'b');
hold on
plot ( 1:256, newSpikes ( find ( d<=2.0 & d>=1  ) , : ), 'g');
hold off

figure(112)
badSpikes = newSpikes ( find ( (d<=1.15 & d>=1.1)  ),:);    
for i=1:100
    subplot(10,10,i)
    plot ( 1:256,  badSpikes(i,:) , 'g');
    ylim([-2000 2000])    
    xlim([1 256])    
    line([1 256],[0 0],'color','r');
    line([1 256],[-0.5*max(badSpikes(i,:)) -0.5*max(badSpikes(i,:))],'color','r');        
end


%good spikes
figure(113)
goodSpikes=newSpikes ( find ( (d>5)  ),:);
for i=1:100
    subplot(10,10,i)
    plot ( 1:256,  goodSpikes(i,:) , 'r');
    ylim([-2000 2000])    
    xlim([1 256])    
    line([1 256],[0 0],'color','r');
    line([1 256],[-0.5*max(goodSpikes(i,:)) -0.5*max(goodSpikes(i,:))],'color','r');        
end


figure(114)
plot( 1:256, badSpikes(20:30,:), 'g', 1:256, goodSpikes(1300:1330,:), 'r');