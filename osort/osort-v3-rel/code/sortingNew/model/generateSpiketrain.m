%generates a set of spiketrains,at different noise levels but with the same
%neuronal firing. simulates a single-wire recording.
%
%input
%allMeans: collection of mean waveforms
%realWaveformsInd: real waveforms to use
%nrsamples:# samples to generate,sampled at 100000Hz
%noiseStds: vector of noise stds to generate
%
%returns
%spiketrainsAll: cell array of spike trains for each noise level
%realWaveformsInd:same as input
%noiseWaveformsInd:which of the mean waveforms were chosen to be used for
%noise
%spiketimes: cell array of points of time when neurons fire (for each
%neuron one element in cell array).
%
%waveformsOrig: cell array of cell arrays, orig waveforms of each noise
%level for each neuron.
%
%scalingFactorSpikes: scaling factor used for each of the real (=neuron)
%mean waveforms.
%
%
%urut/dec04
%urut/aug11 moved things into sub functions
function [spiketrainsAll, realWaveformsInd, noiseWaveformsInd, spiketimes,waveformsOrig, scalingFactorSpikes] = generateSpiketrain(allMeans, realWaveformsInd, nrSamples, noiseStds)
noiseWaveformsInd=[];

%% --- params
%firingRate=[5 7 4 6 9];  %Hz
%firingRate=[10 5 8 20 15]; % 7 4 6 9];  %Hz
firingRate=[5 8];
refractory=3/1000; %3ms
Fs=25000; %sampling rate in Hz of spiketrain

%% --- prepare noise
fnameCache='/fs2/simulated/simTmp.mat';
if exist(fnameCache)
	disp(['Loading existing noise train: ' fnameCache]);
	load(fnameCache, 'spiketrain');
else
    spiketrain = generateSpiketrain_noiseBackground( nrSamples );
end

%% --- prepare spiketimes
nrRealWaveforms=length(realWaveformsInd);
spiketimes=generateSpiketrain_times( nrRealWaveforms, firingRate, refractory, nrSamples, Fs);

%% -- insert the spikes into the spiketrain
[spiketrainsAll,waveformsOrig,scalingFactorSpikes] = generateSpiketrain_insertSpikes( noiseStds, noiseSpiketrain, spiketimes, allMeans,  realWaveformsInd);

