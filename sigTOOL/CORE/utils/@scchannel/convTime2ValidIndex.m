function indices=convTime2ValidIndex(channel, start, stop)
% convTime2ValidIndex converts time to linear indices into a waveform matrix
% 
% Only indices for valid data epochs will be returned
%
% Example:
% idx=convTime2ValidIndex(channel, time)
% idx=convTime2ValidIndex(channel, start, stop)
%   channel is a sigTOOL channel object
%   time or start & stop are the times to convert
%
% idx contains the start and stop indices in columns 1 and 2 respectively
%
% When a single time is specified, idx is the index into adc for the sample
% at the specified time or the first sample afterwards
% When start and stop are given, idx are indices into the adc field such 
% that sampling occurred between the limits
%                           start <= t < stop.
%
% With episodic or framed waveforms, idx will be a matrix of indices with
% one row for each period contained in the interval start to stop.
% e.g. if channels{1} contains episodes of length 16001,
%               idx=convTime2ValidIndex(channels{1}, 0, 5);
% might return
%                     idx =
%                                1       16001
%                            16002       32002
%                            32003       48003
%                            48004       64004
%                            64005       80005
% Access the first period with:
%                     data=channels{1}.adc(idx(1,1):idx(1,2));
% 
%
% convTime2ValidIndex differs from findVectorIndices in that:
%       1. It returns indices only for valid epochs
%       2. It returns indices that are linear indices into the adc matrix,
%               not indices into the vector representing a specific epoch.
%
% See also findVectorIndices, ind2sub, sub2ind
%
%-------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © The Author & King’s College London 2006-2007
%-------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:

if length(channel)>1
    error('Requires single channel input');
end

if nargin==2
    stop=start;
end

if length(start)>1 || length(stop)>1
    error('Start and Stop must be scalar');
end

% Find relevant data epochs
epochs=convTime2ValidEpochs(channel, start, stop);
indices=ConvertTimeToIndex(channel, start, stop, epochs);
if nargin==2
    indices=indices(:,1);
end
return
end
