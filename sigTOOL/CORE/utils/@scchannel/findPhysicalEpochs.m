function epochs=findPhysicalEpochs(channel, time)
% findPhysicalEpochs returns the physical epochs that a time falls within
%
% Example:
% epochs=findPhysicalEpochs(chanel, time);
% where
%    channel is a sigTOOL channel object
%    time is a scalar or vector of timestamps
% and
%    epochs is a size(time) vector, containing the relevant epoch for each
%           timestamp in time. If a timestamp does not fall within an epoch,
%           epochs will contain zero. A +/- 1 sample interval jitter is
%           allowed to account for sequentially sampled waveform channels
%           where samples are not simultaneous.


jitter=prod(channel.hdr.adc.SampleInterval)+eps(max(time(:)));

if size(channel.adc, 2)==1
    epochs=ones(size(time));
else
    epochs=zeros(size(time));
    
    temp=channel.tim();
    temp(:,end)=temp(:,end)+jitter;
    stime=time+jitter;
    etime=time-jitter;
    
    % TODO: Replace this loop with mex
    for i=1:length(time)
        ep=find(temp(:,1)<=stime(i), 1, 'last');
        if ~isempty(ep) && etime(i)<=temp(ep,end)
             epochs(i)=ep;
         end
    end
end
return
end

        