function val=CFSGetDSFlags(fid, DS)
% CFSGetDSFlags returns the DS flags form a cfs file
% 
% Example:
% val=CFSGetDSFlags(fid, DS)
%
% The CFS filing system is copyright Cambridge Electonic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
val=uint16(0);
val=calllib('CFS32','DSFlags', fid, DS, 0, val);
return
end
