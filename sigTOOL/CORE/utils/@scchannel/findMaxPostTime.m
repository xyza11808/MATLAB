function duration=findMaxPostTime(chan, trig)
% findMaxPostTime scchannel method
% 
% findMaxPostTime returns the maximum post-trigger time for which data is
% available in all epochs given a set of trigger times
% 
% Example:
%     duration=findMaxPostTime(chan, trig)
%     
%     chan is an scchannel object
%     trig is a time or vector of times
%     
%     duration will be the maximum available post-trigger time based on the 
%     times in trig. This is the minimum of the times available from all
%     epochs
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------    
%
% Revisions
%       26.09.09    Revised for continuous waveforms. 

duration=Inf;

if size(chan.tim, 1)>1
    epochs=findValidEpochs(chan, trig);
    temp=trig(epochs>0);
    epochs=epochs(epochs>0);
    duration=min([duration; chan.tim(epochs, end)-temp]);
elseif size(chan.tim, 1)==1
    % 26.09.09 May have longer sampling on trigger channel than waveform.
    % Avoid negative durations
    duration=chan.tim(end)-trig;
    duration=duration(duration>0);
    duration=duration(end);
end

if duration==Inf
    duration=0;
end

return
end