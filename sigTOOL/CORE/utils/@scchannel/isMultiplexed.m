function TF=isMultiplexed(varargin)
% isMultiplexed returns true if any of the channels contain multiplexed adc
% data
%
% Example:
% TF=isMultiplexed(chan1, chan2,...);
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/08
% Copyright © The Author & King's College London 2008-
% -------------------------------------------------------------------------

for i=1:length(varargin)
    if isfield(varargin{i}.hdr, 'adc') &&...
        varargin{i}.hdr.adc.Multiplex>1
        TF=true;
        return
    end
end
TF=false;
return
end



