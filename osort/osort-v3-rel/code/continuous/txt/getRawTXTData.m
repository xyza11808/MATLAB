%
%read data from txt file
%
%urut/april07
function	[timestamps,dataSamples] = getRawTXTData( filename, fromInd, toInd, samplingFreq )

%fid=fopen(filename);

%TODO -- this inefficient. only read part of file that is really needed.

D=dlmread(filename);
dataSamples=D(fromInd:toInd,2);

%dataSamples = dataSamples*1000; %convert to uV if stored in mV (temporary).
%dataSamples = dataSamples./1000; %convert to Volts if stored in uV (temporary).

timestamps=D(fromInd:toInd,1);

%convert to uS
timestamps = timestamps .* (1e6/samplingFreq);
 
dataSamples=dataSamples(:);
timestamps=timestamps(:);