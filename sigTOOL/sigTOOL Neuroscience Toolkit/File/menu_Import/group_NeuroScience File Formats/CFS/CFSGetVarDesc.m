function [varSize, varType, units, about]=CFSGetVarDesc(fid, n, flag)
% CFSGetVarDesc returns a varaivble description from a cfs file
% 
% Example:
% [varSize, varType, units, about]=CFSGetVarDesc(fid, n, flag)
% 
% The CFS filing system is copyright Cambridge Electonic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
units='012345678';
about='012345678901234567891';
[varSize, varType, units, about]=...
    calllib('CFS32', 'GetVarDesc', fid, n, flag, 0, 0, units, about);
return
end