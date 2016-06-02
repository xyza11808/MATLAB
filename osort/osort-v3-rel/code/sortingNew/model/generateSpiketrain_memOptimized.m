%continuation of generateSpiketrain.m for simulating very long trains with only one noise level (saves memory)
%
%this file picks up after saving simTmp.mat in generateSimulatedSpiketrains.m . this here is much slower,but the only
%thing that works for large files (>500s).
%memory demand for a 1000s simulation is approx 1GB
%
%
%urut/aug06
tmpDir='/data2/simulated/sim6/';

load([tmpDir 'simTmp.mat']);

noiseStds=[0.05 0.1 0.15 0.2 ];

spiketrainsAll=[];
%--- insert spikes into each noise level
waveformsOrig=[];

%estimate std -- only from first part of train (is same everywhere)
stdEstimate=std(spiketrain(1:100000*10));

for kk=1:length(noiseStds)
    disp(['starting level ' num2str(kk)]);

    %want -> std of noise fixed at noiseStd
    scaleNoiseFactor = 1/(stdEstimate/noiseStds(kk) );
  
    %load the original version,because this loop overwrote it (to save memory) 
    clear spiketrain
    load([tmpDir 'simTmp.mat'],'spiketrain');
    spiketrain = spiketrain*scaleNoiseFactor;
 
    waveformsOrigLevel=[];

    for i=1:realWaveforms
        spikeFormsOrigClass=[];

        spiketimesClass=spiketimes{i}*4;
    
        spikeWaveform= allMeans(realWaveformsInd(i), :);
        %scale amplitude
        spikeWaveform = spikeWaveform * scalingFactorSpikes(i);
        
        c=0;
        for j=1:length(spiketimesClass)  %for each spike for this neuron
            %add a spike here

            waveformOffset=20;
            
            currentInd=spiketimesClass(j)-peakOffsets(i)+waveformOffset;
            
            
            spiketrain( currentInd:currentInd+220) = spiketrain(currentInd:currentInd+220)+spikeWaveform(waveformOffset:240); 
            c=c+1;
            spikeFormsOrigClass(c,:)=spiketrain(currentInd:currentInd+220);
        end

        waveformsOrigLevel{i}=spikeFormsOrigClass;    
    end
    waveformsOrig{kk}=waveformsOrigLevel;    

    %== downsample, save and clear
    disp(['downsample and store level ' num2str(kk)]);
    spiketrainsAll=[];
    spiketrainsAll{kk} = downsample(spiketrain,4);
    %same naming convention as in file
    renvar spiketrainsAll spiketrains
    %store-rename file appropriately afterwards (X=sim number)
    save(['/data2/simulated/sim6/simulation6_100s_level_' num2str(kk) '.mat'], 'spiketrains', 'realWaveformsInd', 'allMeans', 'spiketimes', 'scalingFactorSpikes', 'noiseStds','nrSamples');
    clear spiketrains
    clear spiketrainsAll
    %==
    
    disp(['finished level ' num2str(kk)]);
end

