%
% generate a simulated tetrode recording (4 channels, same waveform but
% differently scaled).
%
%
function [ spiketrains_tetrode, spiketimes, scalingFactors ] = generateSpiketrain_tetrode( noiseStds, nrSamples, firingRate, refractory, Fs, realWaveformsInd, allMeans )
nChannels = 4;

pathCache = '/data/cache/';

%% get 4 independent background noise traces
spiketrains = zeros(nChannels,nrSamples);

parfor k=1:nChannels
    fnameCache = [pathCache 'tetrodeSim_ch' num2str(k) '.mat'];

    [cacheOK, theSpiketrain] = loadCacheVarsFromFile( fnameCache, 'theSpiketrain');
    if ~cacheOK
        theSpiketrain  = generateSpiketrain_noiseBackground( nrSamples );
        exportCacheVars( fnameCache, theSpiketrain);
    end
    spiketrains(k,:) = theSpiketrain;
end

%% add the spikes to the spiketrains
nrRealWaveforms = length(realWaveformsInd);
spiketimes = generateSpiketrain_times( nrRealWaveforms, firingRate, refractory, nrSamples, Fs);
spiketrains_tetrode =[];

%scalingFactorSpikes is how it looks on the max channel
maxChannel=[1 3 2 4]; % one entry for each waveform/unit. on which channel is this unit max amp.
scalingFactors=[]; % Columns: Waveform1, Wavefrom2, ... ; rows channels.
for unitNr = 1:nrRealWaveforms
    maxAmpOfUnit = max( abs(allMeans(realWaveformsInd(unitNr), :) ));
    maxScale = 1/maxAmpOfUnit;
    
    for channelNr = 1:nChannels
        if maxChannel( unitNr ) == channelNr
            %max amp on this channel
            s = maxScale;
        else
            a=0;
            b=0.7;
            randScale = a + (b-a).*rand;   %scale randomly between these values
            s = maxScale * randScale;  %less then max
        end
        scalingFactors(channelNr, unitNr) = s;
    end
end


% figure(2);
% for unitNr = 1:nrRealWaveforms
%     subplot(1,2,unitNr);
%     for channelNr = 1:nChannels
%         waveForm = allMeans( realWaveformsInd(unitNr), :) .* scalingFactors(channelNr,unitNr);
%     
%         hold on;
%         plot( (channelNr-1)*1.5+waveForm);
%     end
% end
% 
% keyboard; 

% add to each channel
spiketrains_tetrode=[];
for k=1:nChannels
    disp(['insert into channel ' num2str(k)]);
    
    [spiketrainsAll, waveformsOrig] = generateSpiketrain_insertSpikes( noiseStds, spiketrains(k,:), spiketimes, allMeans,  realWaveformsInd, scalingFactors(k,:) );

    spiketrains_tetrode{k} = spiketrainsAll;
end
