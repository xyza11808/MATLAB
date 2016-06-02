train=spiketrains{3};

TE=detect_spikes_wavelet(train(1:20000),25,[0.5 1.0],'reset',0.1,'bior1.5',1,0);

figure(3);plot(train(1:20000));

times=[spiketimes{1} spiketimes{2} spiketimes{3}];
times2=sort(times);
inds=find(times2<20000);

hold on
plot(times2(inds),-0.8, 'x','MarkerSize', 15);
hold off