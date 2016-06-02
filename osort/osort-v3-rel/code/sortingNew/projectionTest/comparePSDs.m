

spikes=newSpikesNegative(find(assignedNegative==671),:);
[pxxAvNoise,wN] = calcAvPowerspectrum( noiseTraces, 25000, 1000);
[pxxAvSpikes,wS] = calcAvPowerspectrum( spikes, 100000, 1000);


figure(8)

plot(wN,log(pxxAvNoise), 'r', wS, log(pxxAvSpikes), 'b')
xlabel('[Hz]');
ylabel('log(power)');

xlim([0 6000]);

title('Av PSD of noise and spikes');
