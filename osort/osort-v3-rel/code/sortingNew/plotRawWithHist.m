%plot raw
function plotRawWithHist(label, allSpikes, allTimestamps)


subplot(2,1,1)
plot( allSpikes','b');
xlim( [1 256] )
xlabel('samples (1...256=2.5ms). 0.01ms per step');
ylabel('[uV]');
title(['raw waveforms n=' num2str( size(allSpikes,1)) ' ' label ]);

subplot(2,1,2)
d = diff(allTimestamps);
d = d/1000; %in ms
d = d/0.04; % 1 step is 0.04ms

edges=0:1:70;
n=histc(d,edges);
bar(edges,n,'histc');
xlim( [0 70] );
xlabel('[ms]');
title('histogram of all waveforms');
