function t=getTimeVector(channel, units)
% getTimeVector generates a vector or matrix of sample times for a
% wavform channel
%  
% Example:
% t=getTimeVector(channel)
%  
%  where:
%  t          the output matrix containing the timebase, one value if t for
%             each sample in the waveform channel
%  channel    a waveform channel as an scchannel object
%
% Toolboxes required: None
%
%--------------------------------------------------------------------------
% Author: Malcolm Lidierth 09/06
% Copyright © King’s College London 2006
%--------------------------------------------------------------------------
%
% Acknowledgements:
% Revisions:


if nargin<2
    units='';
end

if isempty(channel.hdr.adc)
    t=[];
    return
end

[trows]=size(channel.tim,1);
if trows==0
    t=[];
    return
end

% Return the timestamps:
% multiplexed subchannels are assumed to be synchronous
interval=getSampleInterval(channel)/channel.tim.Units;
len=max(channel.hdr.adc.Npoints);
t=zeros(len, trows);
t(1,:)=channel.tim(:,1);
t(channel.hdr.adc.Multiplex+1:channel.hdr.adc.Multiplex:end,:)=interval;
t=cumsum(t,1);
     
switch units
    case 'seconds'
        t=t*channel.tim.Units;
    case 'milliseconds'
        t=t*channel.tim.Units*1e-3;
    case 'microseconds'
        t=t*channel.tim.Units*1e-6;
    otherwise
        % Do not scale
end
    
% Pad with NaNs where no adc data
% for i=1:size(t,2)
%     if channel.hdr.adc.Npoints(i)<size(t,1)
%         t(channel.hdr.adc.Npoints(i)+1:end,i)=NaN;
%     end
% end

return
end



