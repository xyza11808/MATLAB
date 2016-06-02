function obj=setLabel(obj, label)
% setLabel method for the jpsth class
% 
% Example:
% obj=setLabel(obj, label);
%       where label is a string
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------


obj.label=label;

if nargout<1 && ~isempty(inputname(1))
    assignin('caller', inputname(1), obj);
end

return
end