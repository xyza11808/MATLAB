function obj=setDisplay(obj, funch)
% setDisplay method for jpeth class
%
% Example:
% obj=setDisplay(obj, func)
%   where obj is a jpeth object and func is the handle of a function to plot
%   the coincidence matrix
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

obj.display=funch;

if nargout==0 && ~isempty(inputname(1))
    assignin('caller', inputname(1), obj);
end

return
end
