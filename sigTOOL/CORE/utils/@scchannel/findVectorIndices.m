function [n1, n2, epoch]=findVectorIndices(channel, start, stop)
% findVectorIndices converts time to the indices into a waveform vector
%
% Example:
% [n1 n2 epoch]=findVectorIndices(channel, start, stop)
% matrix=findVectorIndices(channel, start, stop)
%
% where:
%   channel is a sigTOOL channel object
%   start is the time of the first sample and must fall within a valid
%           data epoch for the channel or an error will result
%   stop is valid the time to search to for valid data
%
% n1 and n2 are the indices into the vector (epoch) corresponding to the
% times:
%                       start <= t < stop
% for continuous waveforms or
%                       start <= t <= stop
% for episodic waveforms and will be limited to (n1 >= 1) and
% (n2<=epoch length). 
% 
%
% start and stop may be vectors, in which case n1, n2 and epoch will be
% vectors with one entry for each of the specified data periods.
%
% If only one output is requested, this will be a 3-column matrix
% containing n1, n2 and epoch in each row.
%
%--------------------------------------------------------------------------
% Continuous waveforms
%--------------------------------------------------------------------------
% If channel contains a continuous waveform (i.e. a single vector of adc
% data), n1 and n2 are simply linear indices into the the vector and epoch
% will always be equal to 1.
% n1 and n2 will always be aligned on subchannel of multiplexed data.
%
%--------------------------------------------------------------------------
% Episodic sampled waveforms
%--------------------------------------------------------------------------
% Epoch and n1, n2 can be used for subscripted indexing into the adc field.
% n1 and n2 give the rows and epoch the columns. Thus, n1 and n2 are the
% indices into the column vector of data representing the epoch e.g.
%              [n1 n2 epoch]=findVectorIndices(channels{1}, 0.2, 0.3)
% The relevant adc data may be extracted with:
%              data=channels{1}.adc(n1:n2, epoch)
%
% The exact sample times may be retrieved using convIndex2Time e.g
%              t1=convIndex2Time(channels{1}, n1, epoch)
% With episodically sampled multiplexed data, n1 will always be aligned on
% subchannel 1. n2 will be aligned on subchannel 1 unless stop exceeds the
% epoch time in which case n2 will be aligned on the highest numbered
% subchannel and will be limited to the length of the data. This makes data
% extraction simpler, e.g. to extract subchannel 2 of 4:
%          [n1 n2 epochs]=findVectorIndices(channels{1}, 0.2, 0.3);
%          data=channels{1}.adc(n1+1:4:n2, epochs)
%
% See also convIndex2Time, ind2sub, sub2ind
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © King’s College London 2006-8
%-------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:

if length(channel)>1
    error('Single epoch from single channel required on input');
end

header=channel.hdr.adc;

epoch=findValidEpochs(channel, start);
start=start(epoch>0);
stop=stop(epoch>0);

if any(epoch==0)
    error('Start times must fall within a valid epoch');
end

% Calculate indices
SampleRate=getSampleRate(channel);

if size(channel.tim, 1)==1
    % n2<stop for continuous data
    n1=ceil((start-channel.tim(epoch,1))*SampleRate*channel.tim.Units)*channel.hdr.adc.Multiplex+1;
    n2=n1+(round((stop-start-eps)*SampleRate*channel.tim.Units)*channel.hdr.adc.Multiplex)...
        -channel.hdr.adc.Multiplex;
else
    % n2<=stop for episodic data
    n1=round((start-channel.tim(epoch,1))*SampleRate*channel.tim.Units)*channel.hdr.adc.Multiplex+1;
    n2=n1+round((stop-start)*SampleRate*channel.tim.Units)*channel.hdr.adc.Multiplex;
end

% Limit n2 to the length of the data for the required epochs
% (stop may be beyond the end of the epoch)
np=header.Npoints(epoch);
n2=min(n2, np(:));

% May have n2==0 if start==stop
n2(n2==0)=n1(n2==0);

if nargout==1
    n1=[n1 n2 epoch];
end

if any(n1==0)
    z=1
end
return
end
