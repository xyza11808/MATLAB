%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
% Psych 216A Final Project 
% Helen Yang 
% 
% This script demonstrates how to calculate a one-dimensional 
% spike-triggered average. A spike-triggered average is a description of 
% the average stimulus that the neuron responds to. Given that a neuron 
% fires an action potential every time the stimulus presented exceeds some 
% threshold of similiarity to its optimal stimulus, one can average all the 
% stimuli in a small time window preceeding every spike the neuron fires. 
% Noise in the stimulus that is not in the direction of the neuron's 
% preferred stimulus will be averaged out, leaving only what the neuron 
% responds to. If the original stimulus is sphereically symmetric--that is, 
% it has no correlational structure in it of itself (Gaussian white noise, 
% for example--the spike-triggered average represents the neuron's linear 
% receptive field, the stimulus that the neuron prefers. Among other 
% applications, this technique is used in generating a linear-nonlinear 
% model and has been used to characterize retinal ganglion cell receptive 
% fields (Chichilnisky 2001, A simple white noise analysis of neuronal 
% light responses, Network). 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 
Generate some synthetic data 

% Loads from .mat file an array that describes the neuron's actual response 
% kernal that we'll use to make a synthetic spike train. The 
% spike-triggered average we eventually calculate should therefore be very 
% similar to this. 
load('kernal'); 

% Generates a stimulus. Supposing our fake neuron is a retinal ganglion 
% cell, the stimulus will be full field flashes of various intensities of 
% gray (range from black to white), where the distribution of intensities 
% is randomly drawn from a Gaussian distribution. 
stimLen = 100000; % how long the stimulus is, in seconds 
stimDelta = 0.0025; % time each flash is presented, in seconds 
numFrames = stimLen/stimDelta; % number of times the stimulus changes 
% so the stimulus is the same every time this tutorial is run 
stimSeed = 0; 
[s1] = RandStream.create('mrg32k3a','NumStreams',1,'Seed',stimSeed); 
meanInten = 0.5; % set mean stimulus intensity 
% generates stimulus, centered at the mean intensity 
stimulus = randn(s1, numFrames, 1)*meanInten*0.35+meanInten; 

% Generate synthetic spike train. Convolve the kernal with the 
% stimulus. When the convolution exceeds a threshold, call it a spike. 

% convolve kernal with stimulus (generator signal) 
gen = conv((kernal.*meanInten+meanInten), stimulus); 
gen(length(stimulus)+1:end)=[]; % eliminate end where conv w/0s 
thresh = 27; 
% spike when generator signal exceeds threshold; convert to time by 
% multiplying by stimDelta 
spikes = find(gen>thresh) * stimDelta; 
Calculate the spike-triggered average 

timeWindow = 0.25; % time prior to spike to look at stimulus, in seconds 
numBins = timeWindow/stimDelta; % number of time bins for STA 

% remove spikes that occur in 1st timeWindow time (no stimulus for whole 
% block of time prior to those spikes) 
spikes(spikes < timeWindow) = []; 

numSpikes = length(spikes); % number of spikes 

% calculate spike-triggered average 
allStims = zeros(numBins,numSpikes); 
% pull out stimulus in timeWindow prior to each spike 
for i=1:numSpikes 
    allStims(:,i) = stimulus(ceil(spikes(i)/stimDelta-numBins+1):... 
        ceil(spikes(i)/stimDelta)); 
end 
% get average 
avgStim = mean(allStims, 2); 
% spike-triggered average is normalized average flipped so time 0 is at the 
% end 
STA= flipud((avgStim-meanInten) ./ meanInten); 

% normalize spike-triggered average to match units for kernal 
normSTA=(STA-mean(STA))./mean(STA); 
Plot the spike-triggered average 

% times corresponding to bins of spike-triggered average 
time = (-1*timeWindow+stimDelta):stimDelta:0; 

plot(time,kernal, 'Color', 'r', 'LineWidth', 2); % plot kernal 
hold on % plot STA on same axes 
plot(time,normSTA, 'LineWidth', 2); % plot STA 

% add labels 
legend('kernal', 'STA'); 
xlabel('Seconds before spike', 'FontSize', 16); 
ylabel('Filter 1/sec', 'FontSize', 16); 
title('Spike-Triggered Average', 'FontSize', 18, 'FontWeight', 'bold');