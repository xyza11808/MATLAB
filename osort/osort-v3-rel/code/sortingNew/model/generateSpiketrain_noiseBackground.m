%
% prepare a noise background consisting of many randomly scaled waveforms
% for later insertion of simulated spikes.
%
% moved out of generateSpiketrain.m
%
%urut/aug11
function spiketrain = generateSpiketrain_noiseBackground( nrSamples )
nrIters=30; %how many iterations

load('allMeans.mat');

%find all waveforms with amplitude <500 to simulate noise realistically
allMeansNoise=[];
c=0;
for i=1:size(allMeans,1)
    if max(abs(allMeans(i,:))) <= 600 && abs(mean(allMeans(i,1:10)))<100    %exclude artifactual mean waveforms (which are not 0 at beginning (??) and also exclude high-peak once (those are not noise but real once)
        c=c+1;
        allMeansNoise(c,:)=allMeans(i,:);
    end
end
nrNoiseWaveforms=size(allMeansNoise,1)
r = randperm(nrNoiseWaveforms);
noiseWaveformsInd= r(1:nrNoiseWaveforms);

spiketrain = zeros(1, nrSamples);
for kk=2:nrIters
    [num2str(kk) ' of ' num2str(nrIters) ]
    tic
    for ind=1:kk:nrSamples-300
        spikeInd=ceil(rand*nrNoiseWaveforms);
     
        if spikeInd<1 || spikeInd>nrNoiseWaveforms
             continue;
        end
        
        noiseSpike = allMeansNoise(noiseWaveformsInd(spikeInd),:)  * randn/10000 ;     
        spiketrain(ind:ind+220) = spiketrain( ind:ind+220) + noiseSpike(20:240);
    end
    toc
end