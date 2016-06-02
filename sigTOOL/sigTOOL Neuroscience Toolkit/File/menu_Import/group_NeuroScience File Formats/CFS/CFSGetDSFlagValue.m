function val=CFSGetDSFlagValue(number)
% CFSGetDSFlagValue returns the DS flag values form a cfs file
% 
% Example:
% val=CFSGetDSFlagValue(number)
%
% The CFS filing system is copyright Cambridge Electonic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------

val=calllib('CFS32','DSFlagValue',number);
return
end
