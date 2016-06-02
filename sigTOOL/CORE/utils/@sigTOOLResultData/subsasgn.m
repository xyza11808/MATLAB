function obj=subsasgn(obj, index, val)
% subsasgn method for sigTOOLResultData objects
% 
% Example:
% out=subsasgn(obj, index, value)
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
obj=builtin('subsasgn', obj, index, val);
return
end
