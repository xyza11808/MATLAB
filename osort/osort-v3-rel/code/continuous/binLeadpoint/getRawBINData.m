%reads the binary format of the leadpoint system. 
%
%urut/jan08
function [timestamps,dataSamples] = getRawBINData( filename, fromInd, toInd, samplingFreq )

N=16; %16bits per data sample
gainFact=100;
dataSamples = readLeadpointBinFormat( filename, N, gainFact);

if toInd>length(dataSamples)
    toInd=length(dataSamples);
end
dataSamples=dataSamples(fromInd:toInd);

%since the raw file contains no timestamps, just number them sequentially.
timestamps=[1:length(dataSamples)]+fromInd-1; 

%convert to uS
timestamps = timestamps .* (1e6/samplingFreq);
 
dataSamples=dataSamples(:);
timestamps=timestamps(:);
