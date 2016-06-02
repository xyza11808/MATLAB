%
%upsample spikes from raw sampling to 100kHz.
%
%urut/april04
function upsampledSpikes = upsampleSpikes( allSpikesRawFiltered )

%L=4;        %upsample factor
%would like to have 256 datapoints at 100kHz.
%L*size(allSpikesRawFiltered,2)
nrDatapoints=256;

if size(allSpikesRawFiltered,1)>0
    upsampledSpikes=interpft( allSpikesRawFiltered', nrDatapoints);
    upsampledSpikes=upsampledSpikes';
else
    upsampledSpikes=[];
end


