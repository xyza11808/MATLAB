%
%read txt file format
%
%for now this function is very inefficient - it reads the entire file to extract the timestamps.
%
%urut/april07
function	[timestamps,nrBlocks,nrSamples] = getRawTXTTimestamps( filename )

%fid=fopen(filename);
D=dlmread(filename);

nrSamples=size(D,1);
nrBlocks=nrSamples/512000;

%this funct does not know the sampling rate,thus do not return timestamps.
%use getRawTXTData to get timestamps.
timestamps=[];

%timestamps=D(:,1);
%convert to uS
%Fs=24000;
%timestamps = timestamps .* (1e6/Fs);
 
