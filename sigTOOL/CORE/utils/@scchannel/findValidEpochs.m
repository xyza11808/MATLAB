function epochs=findValidEpochs(channel, time)
% findValidEpochs returns the valid epochs that a time falls within
% 
% Example:
% epochs=findValidEpochs(chanel, time);
% where
%    channel is a sigTOOL channel object
%    time is a scalar or vector of timestamps
% and
%    epochs is a size(time) vector, containing the relevant epoch for each
%           timestamp in time. If a timestamp does not fall within an epoch, 
%           epochs will contain zero


epochs=findPhysicalEpochs(channel, time);
TF=ismember(epochs, getValidEpochNumbers(channel));
epochs(TF==0)=0;
return
end

