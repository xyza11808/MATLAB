function Fs=getSampleRate(channel)
% getSampleRate returns the sample rate in a scchannel object
% 
% Example:
% Fs=getSampleRate(channel)
%       Fs is returned as samples/second
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03.08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

try
    Fs=1/channel.hdr.adc.SampleInterval(2)/channel.hdr.adc.SampleInterval(1);
catch
    % Not a waveform channel
    Fs=[];
end

return
end