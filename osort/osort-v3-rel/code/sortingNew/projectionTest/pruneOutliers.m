function assignedNegativeTmp = pruneOutliers(clNr, assignedNegative, residuals1)

clNr=295;

[d,residuals1,residuals2] = figureClusterOverlap(allSpikesCorrFree, newSpikesNegative, assignedNegative, clNr, 0, '',3);
indsClusters = find(assignedNegative==clNr);


sResd = std(residuals1);

sResd=1;

indsPrune = find( residuals1 > 3*sResd | residuals1 < -3*sResd ) ;
removedWaveforms = newSpikesNegative( indsClusters(indsPrune), :);

assignedNegativeTmp=assignedNegative;
assignedNegativeTmp( indsClusters(indsPrune) ) = 999;

figure(2);
plot( 1:256, removedWaveforms )



figure(3)

plotSingleCluster(newSpikesNegative, newTimestampsNegative, assignedNegativeTmp, '', clNr);
