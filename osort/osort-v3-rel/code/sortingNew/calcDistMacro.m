%calculate the appropriate distance for the method chosen
%
%used by sortSpikesOnline.m
%
%urut
function D=calcDistMacro(thresholdMethod, baseSpikes, testSpike, weights,Cinv)

if thresholdMethod==1
    D=calculateDistance(baseSpikes, testSpike, weights);
else
    D=calculateDistanceChi2(baseSpikes, testSpike, Cinv);
end

