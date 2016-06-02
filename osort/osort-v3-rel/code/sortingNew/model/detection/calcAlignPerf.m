%% main file for evaluation of alignment performance.
%
%

%% set global params
Fs=25000;
basepath='/home/urut/precomputed/align'; %location of pre-computed results.

%% plot alignment errors for each cluster of a given simulation
%load
simNrs=[3];
levelNr=4;
alignMethods=[4];
doUpsample=0;
doNormalize=1;
[allStds,allMeans, errorsNormalized,params] = calcAlignPerf_allSims(simNrs, levelNr, alignMethods, basepath, Fs, doUpsample,doNormalize);

%plot
figure(11);

nrClusters=length(errorsNormalized{1});
%plot errors for each simulated cluster
for i=1:nrClusters
    errorsThisCluster = errorsNormalized{1}{i};
    
    m(i)=mean(errorsThisCluster);
    s(i)=std(errorsThisCluster);
    
    subplot(3,3,i);
    edges=-0.5:0.02:0.5;
    n=histc(errorsThisCluster, edges);
    bar(edges,n,'histc');
    xlim([-0.5 0.5]);
    set(gca,'XTick',edges(1:5:end));
    
    xlabel(['error [ms]']);
    title(['sim/level' num2str(simNrs) '/' num2str(levelNr) ' cl ' num2str(i) ' method ' num2str(params.detectionMethod) ' align ' num2str(params.peakAlignMethod) ' s.d.' num2str(s(i))]);
end
subplot(3,3,9)
bar(1:nrClusters,s);
ylabel('variance of error [ms]');
xlabel('cluster nr');
title(['mean s.d.=' num2str(mean(s))]);
%% compare different align algos with and without upsampling

figure(12);
maxY=0;

for doUpsample=0:1

    simNrs=[2];
    levelNr=3;
    alignMethods=[1 4];
    normalizeError=0;
    [allStds,allMeans, errorsNormalized] = calcAlignPerf_allSims(simNrs, levelNr, alignMethods, basepath, Fs, doUpsample, normalizeError);


    m=[];
    s=[];
    n=[];
    for i=1:size(allStds,2)
        %tmp = abs(allMeans(:,i));   %plot mean error
        tmp = allStds(:,i);          %plot std of error
        m(i)=mean(tmp);
        s(i)=std(tmp);
        n(i)=length(tmp);
    end
    se=s./sqrt(n);

    if max(m)>maxY
        maxY=max(m);
    end
    
    subplot(1,2,doUpsample+1)
    bar(1:length(m),m);
    hold on
    errorbar(1:length(m),m,se,'.');
    hold off
    
    xlabel('alignment algo');
    ylabel('mean s.d. [ms]');
    title(['comp alignment algos.detect=4. upsample:' num2str(doUpsample) ' sims:' num2str(simNrs) '/l' num2str(levelNr)]);

end
for i=1:2
    subplot(1,2,i);
    ylim([0 maxY*1.2]);
end

%% compute the effect of up-sampling

%% plot one particular instance
%simNr=6;
%levelNr=1;
% load the simulation
%loadSimulationFiles;

% load result of detect spikes
% see file calcDetectionROC_precompute.m ; here, only the pre-computed results are loaded.
%useAlignMethod=4;
%basepath2=[basepath num2str(useAlignMethod) '/'];

%load([basepath2 'tmpSim_sim_' num2str(simNr) '_l_' num2str(levelNr) '.mat']);

%=== eval waveforms and their alignment quality

whichToPlot=methodToPlot;
w=allWaveforms{whichToPlot}{indT};
hits=allHits{whichToPlot}{indT}(:,1);
timesFound=allTimes{whichToPlot}{1};

%error is in terms of nr samples, need to know sampling rate to correct.
errors=allErrors{whichToPlot}{indT} * 1/Fs*1000;
nonHits=setdiff(1:size(w,1),hits);

figure(12);
plotSimulatedAlignPerf(w, errors, hits, nonHits, noiseStds(levelNr) );

subplot(2,2,1);
title(['sim/level' num2str(simNr) '/' num2str(levelNr) ' method ' num2str(methods(whichToPlot)) ' align ' num2str(params.peakAlignMethod)]);

%% test upsampling, how much does it contribute
wUp=upsampleSpikes(w);
[newSpikes,newTimestamps, shifted] = realigneSpikes(wUp, timesFound, [], [], 3);

shiftedT=shifted./4; %nr steps in the 25kHz space
fixedTimestamps = newTimestamps+shiftedT;

%re-evaluate the error made
alignErrors2 = evalSimulatedAlignPerf( spiketimes, fixedTimestamps,  allHits{whichToPlot}{1});
alignErrors2 = alignErrors2*1/Fs*1000; %are in terms of 25kHz sampling rate.

%plot time errors before/after
figure(23);
for i=1:2
    switch(i)
        case 1
            err=errors;
        case 2
            err=alignErrors2;
    end
    
    subplot(2,2,i)
    hist(err,30)
    title(['mean=' num2str(mean(err)) ' s.d.=' num2str(std(err))]);
    ylim([0 700]);
end


%how much shift
figure(21);
hist(shifted/1000);
xlabel('shift [ms]');

%illustration of upsampling
figure(20);
ind=67;
plot( [1:4:256], w(ind,:), '-dr', 1:256, wUp(ind,:), '-xb');
legend('orig','up')