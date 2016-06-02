function out=subsasgn(obj, index, val)
% subsasgn method for jpeth class
% 
% Example:
% out=subsasgn(obj, index, val)
% 
% Standard method
% Note that subsasgn currently permits write-access to all jpeth properties
% but only mode, display, filter and label should be altered by the user.
%
%
% See also jpeth
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 02/09
% Copyright © The Author & King's College London 2009-
% -------------------------------------------------------------------------

out=builtin('subsasgn', obj, index, val);

return
end