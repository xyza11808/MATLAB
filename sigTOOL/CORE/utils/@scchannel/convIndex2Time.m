function time=convIndex2Time(channel, row, col)
% convIndex2Time returns the sample time(s) of waveform elements
% 
% Examples:
% Using indices
% time=convIndex2Time(channel, SampleNumber)
% or using subscripts:
% time=convIndex2Time(channel, Epoch, SampleNumberWithinEpoch)
% where:
% channel is a sigTOOL channel object
% 
% When SampleNumber is supplied, this is the 1-D index into the channel adc
% field (adc need not be 1-dimensional so this method can be used
% regardless of the dimensions of the adc matrix).
%
% Alternatively, subscripts may be used where Epoch and 
% SampleNumberWithinEpoch are the subscripts of the element that the sample
% time is required for e.g. convIndex2Time(channel, 10, 8) returns the time
% of the 8th sample in epoch 10. This is limited to vectors and 2-D matrices.
%
% To convert between subscripts and indices use ind2sub and sub2ind
%
% See also convTime2ValidIndex, ind2sub, sub2ind
%
% SampleNumber, Epoch and SampleNumberWithinEpoch may be column vectors
% with multiple indices. In that case time will a vector of sample times.
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © The Author & King's College London 2006-7
%--------------------------------------------------------------------------


if length(channel)>1
    error('Requires single channel input');
end


if nargin==2
    % row is the 1-D index
    [row col]=ind2sub(size(channel.adc),row);
    if any(row>size(channel.adc,1)) || any(col>size(channel.adc,2))
        warning('Index too large: %s', channel.hdr.title);
        time=[];
        return
    end
end

if any(row<1) || any(col<1)
    error('Indices must be positive');
end

% Remember that rows in tim correspond to columns in adc
if any(col>size(channel.tim,1))
    error('Requested epoch does not exist');
end

% Result in seconds
time=channel.tim(col,1)*channel.tim.Units...
    +((row-1)*prod(channel.hdr.adc.SampleInterval)/channel.hdr.adc.Multiplex);
% Convert to channel units
time=time/channel.tim.Units;
return
end
