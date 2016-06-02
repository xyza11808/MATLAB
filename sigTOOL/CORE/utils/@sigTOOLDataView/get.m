function out=get(obj, varargin)
% get method for sigTOOLResultView objects
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
    try
        out=obj.(varargin{1});
    catch
        error('No ''%s'' property in ''%s'' class', varargin{1}, class(obj));
    end
    return
end
