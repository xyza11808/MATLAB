function interval=getSampleInterval(channel)
% getSampleInterval returns the sampling interval in a scchannel object
% 
% Example:
% interval=getSampleInterval(channel)
%           interval is returned in seconds
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03.08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

interval=prod(channel.hdr.adc.SampleInterval);
return
end