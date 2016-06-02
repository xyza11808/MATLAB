%
%plots ROCs of detection algorithm with different parameters to compare performance
%between different detection algorithms and noise levels/parameters
%
%urut/april07

%detection methods are:
%1->power; 2->amplitude positive, 3->amplitude negative, 4->amplitude both, 5->WDM


%% set all default parameters 
params=[];
params.bandPass=[300 3000];
params.extractionThreshold = 5; 
params.nrNoiseTraces=0;
params.prewhiten=0;
params.samplingFreq=25000;
params.limit=100;
params.alignMethod=2; %1 pos, 2 neg, 3 mixed
params.peakAlignMethod=1; %1 findPeak, 2 none, 3 power, 4 mteo
params.detectionMethod=1;
params.detectionParams=[]; 

%% plots of same noise level but with different algorithms
%
% => see file calcDetectionROC_precompute.m . here,only the pre-computed files are loaded and processed.

simNr=6;
levelNr=1;
load(['/home/urut/tmpSim_sim_' num2str(simNr) '_l_' num2str(levelNr) '.mat']);


%% plot the ROC
figure(103);
ptitle=['simNr=' num2str(simNr) ' level=' num2str(levelNr) ' align=' num2str(params.peakAlignMethod)];
plotDetectionROC( TPall, FPall, thresholds, {['PDM K' num2str(dp1.kernelSize)],'T',['WDM ' num2str(dp3.scalesRange) ' ' dp3.waveletName]}, [0 1.0], [0 1], ptitle)


%% === eval waveforms and their alignment quality
w=waveforms{1};
hits=hits{1}(:,1);
timesFound=times{1};

%error is in terms of nr samples, need to know sampling rate to correct.
errors=alignErrors{1} * 1/params.samplingFreq*1000;
nonHits=setdiff(1:size(w,1),hits);

figure(10);
plotSimulatedAlignPerf(w, errors, hits, nonHits, noiseStds(levelNr) );

%% === plot pre-computed results

% --> files loaded in here are precomputed in calcDetectionROC_CPU2.m

simNr=2;
for levelNr=1:4
    load(['/home/urut/tmpSim_sim_' num2str(simNr) '_l_' num2str(levelNr)  '.mat']);

    figure(levelNr+500);
    plotDetectionROC( TPall, FPall, thresholds, {['PDM K' num2str(detectionParams{1})],'T',['WDM ' num2str(detectionParams{3})]}, [0 1.0], [0 1], ['simNr=' num2str(simNr) ' level=' num2str(levelNr)])
end


%====== plot raw trace of simulation for comparison
lNr=3;
load(['/data2/simulated/sim6/simulation6_100s_level_' num2str(lNr) '.mat']);


Fs=25000;
f=300000;t=390000;

%power signal
kernelSize=18;
runStd2 = runningStd(spiketrains{lNr}(f:t), kernelSize); 
runStd2 = [runStd2 zeros(1,kernelSize-1) ];

figure(88);

subplot(3,1,1)
plot([f:t]/Fs, spiketrains{lNr}(f:t) );
std(spiketrains{lNr})

plotMarkHits( spiketimes, Fs, -0.6);
plotMarkHits( {timesFound}, Fs, -1);

xlim([f t]/Fs);

subplot(3,1,2)
plot([f:t]/Fs, runStd2 );
xlim([f t]/Fs);


plotMarkHits( {timesFound}, Fs, 0.6);



%==== plot the raw waveforms of a simulation.

figure(90);
plot( allMeans(realWaveformsInd,:)')
xlim([1 256]);
title('sim5 waveforms');
