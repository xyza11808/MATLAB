%generates resTable_*.mat files. plot with plotSimulationPerformance.m
%

variant=1;

simNr=1;
levels=[3];
parameterSets=2;  %1 -> wavelet, 2->power
export=0;
doPlot=1;

resAll=[];
for j=1:length(levels)
    levelNr=levels(j);

    [perf,nrAssigned,assigned,params] = runSimulatedEval(simNr, levelNr, parameterSets, export, doPlot);

    %store the results
    nrClusters=size(perf,1);
    res=[]; %detected, TP, FP, misses, nrassigned
    for i=1:nrClusters
        res(i,:) = [ perf(i,2) perf(i,5) perf(i,6) perf(i,9) perf(i,10)];
    end
    res(nrClusters+1,:) = sum(res);

    resAll{j} = res;
end

%merge to results table
resTable=[];
resTable(:,1)=perf(:,1)  %nr spikes inserted by simulation. same for all noise levels, pick from last
totAvailable=sum(perf(:,1));
resTable(end+1,1)=totAvailable;

startPos=[2 6 10 14 18];

for j=1:length(levels)
    %detected

    
    for k=1:5
        resTable(:,startPos(k)+j-1) = resAll{j}(:,k);
    end
end

%calc percentages
c=size(resTable,1);

resTable(c+1,2:5) = resTable(c,2:5)*100./totAvailable; % perc detected
resTable(c+1,6:9) = resTable(c,6:9)*100./resTable(c,18:21);  % perc tp, rel to assigned
resTable(c+1,10:13) = resTable(c,10:13)*100./resTable(c,18:21);  % perc fp

resTable(c+2,6:9) = resTable(c,6:9)*100./totAvailable; %resTable(c,2:5);  % perc tp, rel to theoretically available

%resTable is in same format as table1-3 in method paper.

%save(['/home/urut/precomputed/resTable_' num2str(simNr) '_' num2str(parameterSets) '_' num2str(variant) '.mat'], 'resTable');
