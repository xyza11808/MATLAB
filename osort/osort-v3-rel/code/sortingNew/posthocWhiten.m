%
%post-hoc whitening & upsampling of waveforms
%
%used in cases when online estimate of covariance is unstable
%
%returns:
%trans: transformed spikes
%corr:autocorrelation function of the noise
%stdWhitened: std of the whitened waveforms. if this is substantion > 0 -> electrode moved.
%
%
%urut/nov05
function [trans, transUp, corr, stdWhitened] = posthocWhiten(noiseTraces, origWaveforms, alignMethod )
nrSamplesPerSpike=size(origWaveforms,2);

noiseTraces=noiseTraces(:,2:nrSamplesPerSpike+1);


n=size(noiseTraces,1);
if n>10000
    n=10000;
end

noiseTraces=noiseTraces(1:n,:);
noiseTraces=noiseTraces';
noiseTraces=noiseTraces(:);

%estimate autocorrelation
corr=xcorr(noiseTraces,nrSamplesPerSpike,'biased');
corr=corr(nrSamplesPerSpike+1:end-1);

%whiten
C1=toeplitz(corr);
C1inv=inv(C1);
R1=chol(C1inv);
trans = origWaveforms * R1';

%stdWhitened = mean(std(trans));

stdWhitened=0; %no min/max here (to enforce strict re-alignment regardless of significance for pre-whitened data)

%upsample and re-align
transUp = upsampleSpikes(trans);
transUp = realigneSpikes(transUp, [], alignMethod, stdWhitened);  


