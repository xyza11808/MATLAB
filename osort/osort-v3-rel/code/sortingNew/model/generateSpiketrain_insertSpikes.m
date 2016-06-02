%
% insert waveforms of simulated units into background of simulated noise.
% this function is deterministic, no randomness is added.
%
%
% allMeans : waveforms from previous recordings, at 4 times the Fs of the
% simulated data
%
%urut/aug11. moved out of generateSpiketrain.m
%
function [spiketrainsAll,waveformsOrig,scalingFactorSpikes] = generateSpiketrain_insertSpikes( noiseStds, noiseSpiketrain, spiketimes, allMeans,  realWaveformsInd, scalingFactorSpikes)

nrRealWaveforms = length( realWaveformsInd );

%% scale the to-be-inserted spikes
%pool all selected waveforms and scale the max amplitude among all them to
%be =1. So all waveforms will be scaled by the same factor.

if nargin<6
    scalingFactorSpikes=[];
end

%only overwrite them if not externally given ( for tetrode simulations )
if isempty( scalingFactorSpikes )
    for i=1:nrRealWaveforms
        maxAmp = max(max(abs(allMeans(realWaveformsInd, :))));
        scalingFactorSpikes(i) = 1/maxAmp;
    end
end

%% insert the spikes
spiketrainsAll=[];
%--- insert spikes into each noise level
waveformsOrig=[];
for kk=1:length(noiseStds)
    
    %want -> std of noise fixed at noiseStd
    scaleNoiseFactor = 1/( std(noiseSpiketrain)/noiseStds(kk) );
    spiketrainLevel = noiseSpiketrain*scaleNoiseFactor;
    
    waveformsOrigLevel=[];

    for i=1:nrRealWaveforms            
        disp(['add waveforms to noise level ' num2str(kk) ' unit ' num2str(i) ]);

            
        spikeFormsOrigClass=[];

        spiketimesClass=spiketimes{i}*4;
    
        spikeWaveform= allMeans( realWaveformsInd(i), :);
        
        %scale amplitude
        spikeWaveform = spikeWaveform * scalingFactorSpikes(i);
        
        c=0;
        for j=1:length(spiketimesClass)  %for each spike for this neuron
            %add a spike here
            currentInd=spiketimesClass(j)-55;
            
            %add the spike to the noise (superimpose)
            spiketrainLevel( currentInd:currentInd+220) = spiketrainLevel(currentInd:currentInd+220) + spikeWaveform(20:240); 
            
            c=c+1;
            spikeFormsOrigClass(c,:)=spiketrainLevel(currentInd:currentInd+220);
        end

        waveformsOrigLevel{i}=spikeFormsOrigClass;    
    end
    waveformsOrig{kk}=waveformsOrigLevel;    

    %downsample
    spiketrainsAll{kk} = downsample(spiketrainLevel,4);
end