function obj=setFilter(obj, coeff)
% setFilter method for the jpsth class
% 
% Example:
% obj=setFilter(obj, coeff);
%       where coeff is normally an NxN matrix of coefficients and N is odd
%
% Sets the filter to used by getMatrix and getCoincidence.
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

obj.filter=coeff;

if nargout==0 && ~isempty(inputname(1)) 
    assignin('caller', inputname(1), obj);
end

return
end
