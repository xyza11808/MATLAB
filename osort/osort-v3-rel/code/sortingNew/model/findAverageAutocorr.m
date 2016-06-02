%
% generates a number of spiketrains to calculate the average
% autocorrelation
%
% this script runs independently and saves it's result in a file (because
% it takes a long time to run).
%
% urut/jan05
%

load('allMeans.mat');

nrSamples=50*100000;  %100 sec
%sim1
realWaveformsInd=([  81 122 77 ]);
nrNeurons=length(realWaveformsInd);
noiseStds=[0.20];

allCs =[];

nrTrials=10;

totNrNoiseTraces=[];

for i=1:nrTrials
    i
    [spiketrains, realWaveformsInd, noiseWaveformsInd,spiketimes,waveformsOrigAll,scalingFactorSpikes] = generateSpiketrain(allMeans, realWaveformsInd, nrSamples, noiseStds);

    levelNr=1;
    spiketrainDown=spiketrains{levelNr};
    noiseStd=noiseStds(levelNr);
    extractionThreshold=4.0;
    [filteredSignal, rawTraceSpikes,spikeWaveforms, spikeTimestamps, runStd2,upperlim,noiseTraces] = detectArtificialSpikes( spiketrainDown, extractionThreshold ) ;

    %allCs{i} = (cov(noiseTraces+.01*randn(size(noiseTraces,1),64)));
    
    [R,P]= corrcoef(noiseTraces);
    allCs{i} = R;
    
    totNrNoiseTraces(i) = size(noiseTraces,1);
end


Ctot=[];

for i=1:nrTrials
    currentC =  allCs{i};    
    Ctot(i,:) = currentC(1,:);
end

mean(Ctot)
std(Ctot)

save('Ctot.mat','Ctot','totNrNoiseTraces', 'nrTrials', 'noiseStds');

