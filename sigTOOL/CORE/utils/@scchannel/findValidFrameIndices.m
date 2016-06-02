function [idx epochs trigger]=findValidFrameIndices(channel, trigger, duration, pretime)
% findValidFrameIndices returns the indices of valid frames
% 
% Example:
% [idx epochs trigger]=findValidFrameIndices(channel, trigger, duration, pretime)
% where
%     channel     is a sigTOOL channels object
%     trigger     is a vector of trigger times
%     duration    is the duration of the sweep
%     pre-time    is the pre-trigger time
%  All times are in the same units (as returned by getTimeUnits(channel))
%     
% Returns
%     idx         a 2-column vector with the start and end row indices for 
%                 each trigger
%     epochs      the epochs (columns) that idx refers to
%     trigger     an updated copy of the input, with invalid trigger times
%                 omitted
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 01/08
% Copyright © The Author & King's College London 2008
% -------------------------------------------------------------------------
% 
% Revisions:
%       26.09.09 See within

trig2=trigger-pretime;
epochs=findValidEpochs(channel, trig2);

trig3=trig2+duration;
epochs2=findValidEpochs(channel, trig3);
TF=epochs==epochs2 & epochs>0 & epochs2>0;
trig2=trig2(TF>0);
trig3=trig3(TF>0);

if isempty(trig2) || isempty(trig3)
    fprintf('findValidFrameIndices:Inappropriate duration/pretime for channel\n');
    idx=[];
    epochs=[];
    return
end

[idx(:,1) idx(:,2) epochs]=findVectorIndices(channel, trig2, trig3);
% Make sure frames are the same length
if length(unique(idx(:,2)-idx(:,1)))>1
    % 26.09.09
    N=channel.hdr.adc.Npoints(epochs);
    N=N(:);
    if (length(channel.hdr.adc.Npoints)==1 && any(idx(:,2)>channel.hdr.adc.Npoints)) ||...
            (any(idx(:,2)>N)) || length(unique(idx(:,2)-idx(:,1)))>1
            %(any(idx(:,2)>channel.hdr.adc.Npoints(epochs)') || length(unique(idx(:,2)-idx(:,1)))>1)
    n=min(idx(:,2)-idx(:,1));
    idx(:,2)=idx(:,1)+n;
    fprintf('DEBUG message: findValidFrameIndices: Frame length truncated (to %d)\n',n+1);
    end
end

trigger=trigger(epochs>0);

return
end