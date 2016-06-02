function buf=CFSCreateBuffer(points, varType)
% CFSCreateBuffer creates a MATLAB buffer with a class appropriate to the
% CFS varType
% 
% Example:
% buf=CFSCreateBuffer(points, varType)
%
% The CFS filing system is copyright Cambridge Electonic Design.
% See the Cambridge Electonic Design CFS manual for further details
% (www.ced.co.uk)
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 03/07
% Copyright © The Author & King's College London 2007
% -------------------------------------------------------------------------
vclass=CFSFindClass(varType);

if strcmp(vclass,'char')
    buf=char(ones(points,1)*' ');
else
    buf=zeros(points,1, vclass);
end