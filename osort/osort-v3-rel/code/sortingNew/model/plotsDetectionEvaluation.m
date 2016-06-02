
[pc,score,latent,tsquare] = princomp(spikeWaveformsUp);

figure(1)
hold on
indsAll=[];

for i=1:nrNeurons
    inds = findAllOrigTimestamps ( spiketimes{i}, spikeTimestamps);
    indsAll=[indsAll inds];

    plot(score(inds,1), score(inds,2),['.' colors{i}]);
end
indsNoise = setdiff( 1:size(score,1), indsAll);
plot(score(indsNoise,1), score(indsNoise,2),['.k']);
hold off

i=3;
inds = findAllOrigTimestamps ( spiketimes{i}, spikeTimestamps);
length(inds)
figure(3)
plot(score(inds,1), score(inds,2),['.' colors{i}]);

figure(5)
plot( spikeWaveformsUp(inds,:)', colors{i});

line([1 250],[stdEstimate stdEstimate]);
line([1 250],[2*stdEstimate 2*stdEstimate]);
line([1 250],[3*stdEstimate 3*stdEstimate]);
line([1 250],[4*stdEstimate 4*stdEstimate]);
line([1 250],-1*[stdEstimate stdEstimate]);
line([1 250],-1*[2*stdEstimate 2*stdEstimate]);
line([1 250],-1*[3*stdEstimate 3*stdEstimate]);
line([1 250],-1*[4*stdEstimate 4*stdEstimate]);

ylim([-1.4 1.4]);
xlim([1 256]);




indsBad=[8 313 316 250 58 326 56 154 195];
indsGood=[26 214 298 234 377 292];


figure(5);

plot(1:256,(spikeWaveformsUp(inds(indsGood),:)),'r',1:256,(spikeWaveformsUp(inds(indsBad),:)),'b')
ylim([-1.2 1.2]);

figure(6)
subplot(2,1,1)
plot(diff(diff(spikeWaveformsUp(inds(indsBad),:)))','b')
subplot(2,1,2)

plot(diff(diff(spikeWaveformsUp(inds(indsGood),:)))','r');
