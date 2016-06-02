function epochs=convTime2PhysicalEpochs(channel, start, stop)
% convTime2PhysicalEpochs returns physical epoch numbers within a time range
%
% Example:
% epochs=convTime2PhysicalEpochs(channel, start, stop)
% where
% channel is a sigTOOL channel object
% start & stop are the beginning and end times
% 
% Returns physical epoch numbers where
%               start <= channel.tim(:, 1) <= stop 
%
% Toolboxes required: None
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King’s College London 2007
%--------------------------------------------------------------------------
% Acknowledgements:
% Revisions:


if size(channel.tim,1)==1
    epochs=1;
    return
else
    firstrow=min(find(channel.tim(:,1)>=start,1),...
        find(channel.tim(:,end)>start,1));
    if nargin==2
        epochs=firstrow;
    else
        lastrow=find(channel.tim(:,1)<=stop,1,'last');
        if isempty(firstrow)
            firstrow=size(channel.tim,1);
        end
        if isempty(lastrow) || lastrow<firstrow
            lastrow=firstrow;
        end
        epochs=firstrow:lastrow;
    end
end
return
end

