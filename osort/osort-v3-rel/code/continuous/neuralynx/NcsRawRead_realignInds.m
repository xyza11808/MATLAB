%
% to get a range of timestamps across several channels from Ncs files
% usually this can be achieved by reading the same indices from all the files,but sometimes the same
% indices do not return the same timestamps so a dynamic adjustment is necessary.
%
% this file performs this adjustment if necessary and re-reads the raw data
%
%
function [couldResolve, timestampsNew, dataSamplesNew ] = NcsRawRead_realignInds( filenameToUse, rawFileVersion, origTimestamps, trialInds )


[timestampsThisChannel] = getRawTimestamps( filenameToUse, rawFileVersion );

newFromInd = 512*(find( timestampsThisChannel == origTimestamps(1) )-1);
newToInd = newFromInd+(trialInds(2)-trialInds(1));
                              
%re-read
[timestampsNew,dataSamplesNew] = getRawData( filenameToUse, newFromInd, newToInd, rawFileVersion );

%check if the problem could be resolved by shifting
if origTimestamps(1) ~= timestampsNew(1)
    couldResolve=0;
else
    couldResolve=1;
end