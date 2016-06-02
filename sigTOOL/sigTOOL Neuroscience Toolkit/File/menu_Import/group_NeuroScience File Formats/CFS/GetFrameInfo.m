function [Start markers]=GetFrameInfo(fid, DS, nDSVars)
% GetFrameInfo - returns the frame start time, frame state and DS Flags
%
% Values are read via the CED cfs32.dll Windows application extension
%
% Example:
% [Start markers]=GetFrameInfo(fid, DS, nDSVars)
%
% The CFS filing system is copyright Cambridge Electronic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
Start=[];
markers=[];
for i=0:nDSVars-1
    [varSize, varType, units, about]=CFSGetVarDesc(fid, i, 1);
    switch about
        case {'Start'}
            Start=CFSCreateBuffer(varSize/sizeof(CFSFindClass(varType)), varType);
            Start=CFSGetVarVal(fid, i, 1, DS);
        case {'State'}
            markers(1)=CFSCreateBuffer(varSize/sizeof(CFSFindClass(varType)), varType);
            markers(1)=CFSGetVarVal(fid, i, 1, DS);
    end
end

markers(2)=CFSGetDSFlags(fid, DS);



