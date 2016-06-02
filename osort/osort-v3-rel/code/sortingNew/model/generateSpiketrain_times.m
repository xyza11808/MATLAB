%
%randomly generates firing times for simulated neurons, poisson distributed. 
%used to simulate artifical spiketrains
%
%realWaveforms: how many neurons are simulated
%peakOffsets: for each waveform, offset to the real peak (which should be detected). is 95 by default.
%
%urut/april07
function spiketimes = generateSpiketrain_times( realWaveforms, firingRate, refractory, nrSamples, Fs, peakOffsets)
if nargin<=5
    peakOffsets=repmat(95,1,realWaveforms);
end

spiketimes=[];
for i=1:realWaveforms
    spiketimesClass=[];
        
    currentInd=0;
    c=0;
    while currentInd<nrSamples
        interspk_interval = rand_renewal_poisson (firingRate(i), refractory);
        currentInd=currentInd+floor(Fs*4*interspk_interval);  %this is sampled at 4*Fs
        
        if currentInd+255>nrSamples
            break;
        end
        
        c=c+1;
        spiketimesClass(c) = currentInd+peakOffsets(i);   %offset was 55 fixed before; peak of spike
    end
    
    spiketimes{i}=spiketimesClass/4;  %div by 4 so that the timestamps are right in the downsampled space
end
