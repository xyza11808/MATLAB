function indices=ConvertTimeToIndex(channel, start, stop, epochs)
% ConvertTimeToIndex private helper function for scchannel methods
% 
% Example:
% indices=ConvertTimeToIndex(channel, start, stop, epochs)
% 
% returns the indices into the column of data for all epochs between start
% and stop.
% For each time in start/stop, epoch must contain the correct epoch 
% beginning at, or after, start (as returned by the convTime2XXXXXXXIndex
% methods).
%
% Toolboxes required: None
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King’s College London 2007
%--------------------------------------------------------------------------
% Acknowledgements:
% Revisions:


if isempty(epochs)
    indices=[];
    return
end

% Correct start and stop so they are aligned on the epochs
% (needed for findVectorIndices below)
start=max(start,channel.tim(epochs,1));
stop=min(stop, channel.tim(epochs,end));

if stop<start
    stop=start;
end

% Get the subscripts
[indices(:,1) indices(:,2)]=findVectorIndices(channel, start, stop);



% Convert subscripts to indices
if size(channel.tim,1)>1
    try
        indices(:,1)=sub2ind(size(channel.adc), indices(:,1), epochs');
        indices(:,2)=sub2ind(size(channel.adc), indices(:,2), epochs');
    catch
        % TODO:
        error(lasterror()); %#ok<LERR>
    end
end



return
end