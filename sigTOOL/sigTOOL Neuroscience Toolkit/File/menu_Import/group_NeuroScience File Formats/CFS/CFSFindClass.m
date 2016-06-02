function vclass=CFSFindClass(varType)
% CFSFindClass returns a MATLAB class corresponding to a CFS class
% The CFS classes are defined in the header files for cfs32.dll
%
% Example
% vclass=CFSFindClass(varType)
%       vclass is a string
%       varType is an integer
%
%
% The CFS filing system is copyright Cambridge Electonic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------

switch varType
    case 0
        vclass='int8';
    case 1
        vclass='uint8';
    case 2
        vclass='int16';
    case 3
        vclass='uint16';
    case 4
        vclass='int32';
    case 5
        vclass='single';
    case 6
        vclass='double';
    case 7
        vclass='char';
    otherwise
        error('CFSFindClass: Invalid variable class');
end