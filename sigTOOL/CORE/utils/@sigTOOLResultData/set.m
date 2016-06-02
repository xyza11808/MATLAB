function obj=set(obj, varargin)
% set method for sigTOOLResultData objects
% 
% Example:
% out=set(obj, field1, value1, field2, value2.....)
% 
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-
% -------------------------------------------------------------------------

for i=1:2:length(varargin)
    obj.(varargin{i})=varargin{i+1};
end
return
end
