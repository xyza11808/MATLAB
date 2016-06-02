function pretime=findMaxPreTime(channel, trigger)
% findMaxPreTime scchannel method
% 
% findMaxPreTime returns the maximum pre-trigger time for which data is
% available in all epochs given a set of trigger times
% 
% Example:
%     duration=findMaxPreTime(channel, trigers)
%     
%     channel is an scchannel object
%     triggers is a time or vector of times
%     
%     duration will be the maximum available pre-trigger time based on the 
%     times in triggers. This is the minimum of the times available from all
%     epochs
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

if size(channel.tim, 1)==1
    pretime=trigger(1)-channel.tim(1);
else
    epochs=findValidEpochs(channel, trigger);
    trigger=trigger(epochs>0);
    epochs=epochs(epochs>0);
    pretime=min(trigger(:)-channel.tim(epochs,1));
return
end