%
%read bin file format
%16bit format: 2 bytes per datapoint
%
%urut/feb08
function	[timestamps,nrBlocks,nrSamples] = getRawBINTimestamps( filename )

[fid, message] = fopen(filename, 'r', 'l');
fseek(fid,0,'eof'); %to end of file
nrBytes = ftell(fid); %how many bytes?
fclose(fid);

nrSamples=nrBytes/2;
nrBlocks=nrSamples/512000;

%this funct does not know the sampling rate,thus do not return timestamps.
%use getRawBINData to get timestamps.
timestamps=[];

%convert to uS
%Fs=24000; % assume a sampling rate here - does not matter,this function is just used to determine the blocksize
%timestamps=1:nrSamples;
%timestamps = timestamps .* (1e6/Fs);
 
