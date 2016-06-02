function obj=setMode(obj, targetmode)
% setMode method for the jpsth class
% 
% Example:
% obj=setMode(obj);
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


obj.mode=targetmode;

if nargout<1 && ~isempty(inputname(1))
    assignin('caller', inputname(1), obj);
end

return
end