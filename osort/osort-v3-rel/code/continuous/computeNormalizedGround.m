%todo: note that this wont work if the gains are different on channels on the same ground.
%
%
%returns the average of a number of raw signals; the purpose of the returned value is to-renormalize to a common ground, in case the ground wire was noisy.
%
%input params:
%datapath
%channels: array of channels to be used for averaging. this should not include the ground channel itself.
%
%fromInd/tillInd: which blocks to read, in units of 512 datasamples (dependent on sampling rate)
%
%returns:
%dataAll is the normalized mean
%data is the data itself
%
%urut/april06
function [dataAll, data] = computeNormalizedGround(datapath, channels, fromInd, tillInd, rawFilePrefix, rawFilePostfix)

nrChannels = length(channels);

dataAll=[];
data=[];

p=1;
for i=1:nrChannels
    [timestampsRaw,dataSamplesRaw] = getRawCSCData( [datapath '' rawFilePrefix num2str(channels(i)) rawFilePostfix], ceil(fromInd/512), tillInd/512 );
    data{i} = dataSamplesRaw(:);

    
        if p==1
            dataAll = dataSamplesRaw(:);       
        else
            dataAll = dataAll + dataSamplesRaw(:); 
        end
        p=p+1;
    
end

dataAll = dataAll./nrChannels ; %do not include the ground channel in the averaging
