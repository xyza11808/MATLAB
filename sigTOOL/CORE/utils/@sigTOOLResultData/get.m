function out=get(obj, field)
% get method for sigTOOLResultData objects
% 
% Example:
% out=get(obj, field)
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------
if nargin==1
    out=struct(obj);
else
    out=obj.(field);
end

return
end
