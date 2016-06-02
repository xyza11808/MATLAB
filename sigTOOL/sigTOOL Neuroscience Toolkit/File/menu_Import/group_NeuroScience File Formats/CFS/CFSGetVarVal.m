function value=CFSGetVarVal(fid, varNo, flag, DS)
% CFSGetVarVal - gateway to cfs32.dll GetVarVal function
%
%
% Example:
% value=CFSGetVarVal(fid, varNo, flag, DS)
%
% The CFS filing system is copyright Cambridge Electonic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
[varSize, varType, units, about]=CFSGetVarDesc(fid, varNo, 1);
value=CFSCreateBuffer(varSize/sizeof(CFSFindClass(varType)), varType);
value=calllib('CFS32', 'GetVarVal', fid, varNo, flag , DS, value);
return
end


