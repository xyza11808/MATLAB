
%
% plots simulated tetrode recordings
%
simFile='/fs2/simulated/simulatedTetrode_sim2.mat';
load(simFile);
load('allMeans.mat');

%, 'spiketrains_tetrode', 'realWaveformsInd', 'scalingFactors' );

Fs=25000;
nChannels=4;

%% plot the simulated waveforms
nrRealWaveforms = length(realWaveformsInd);

colors = {'r','m','g','b'};
tWaveform = [ 1:256 ] / (Fs*4)*1000;
figure(2);
for unitNr = 1:nrRealWaveforms
    subplot(2,4,unitNr);
    for channelNr = 1:nChannels
        waveForm = allMeans( realWaveformsInd(unitNr), :) .* scalingFactors(channelNr,unitNr);
        
        hold on;
        plot( tWaveform, (channelNr-1)*-1.5+waveForm, colors{channelNr}, 'LineWidth',2);
    end
    xlim([0 2.5]);
    title(['Cl ' num2str(unitNr) ' waveInd=' num2str(realWaveformsInd(unitNr))]);
    xlabel('[ms]');
    ylabel('amp [au]');
end

for unitNr = 1:nrRealWaveforms
    subplot(2,4,4+unitNr);

    % in ms
    d = diff(spiketimes{unitNr})/Fs*1000;

    edges1=0:1:400;
    n1=histc( d, edges1);
    bar(edges1,n1,'histc');
    xlim([0 100]);
    xlabel('time [ms]');
    ylabel('nr ISIs');
    title(['n=' num2str(length(spiketimes{unitNr}))]);
end


%% plot raw traces

indsToPlot = 1*Fs:50*Fs;

figure(3);
offsetY = 2;

noiseLevel = 2;

for channelNr = 1:nChannels

    toplot = spiketrains_tetrode{channelNr}{noiseLevel}( indsToPlot );

    if channelNr>1
        hold on
    end
    
    plot( indsToPlot/Fs, toplot + (channelNr-1)*-offsetY, colors{channelNr}, 'LineWidth',2 );
    hold off
end

% mark the known spiketimes
for unitNr = 1:nrRealWaveforms
    hold on
    spikesOfUnit = spiketimes{unitNr};
    
    spikesOfUnitToPlot = spikesOfUnit( find(spikesOfUnit>indsToPlot(1) & spikesOfUnit<indsToPlot(end)));
    
    plot( spikesOfUnitToPlot/Fs, 1, ['x' colors{unitNr}],'MarkerSize',10,'LineWidth', 2);
    
    hold off
end
title([simFile ' noiseL=' num2str(noiseLevel) ]);
xlabel(['time [sec]']);s
ylabel(['amp [au]']);

ylim([-7 1.2]);
xlim([5 6]);
