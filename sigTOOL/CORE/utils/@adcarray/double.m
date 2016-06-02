function obj=double(obj)
% DOUBLE methods overloaded for ADCARRAYS
%
% Example:
% x=double(obj);
% returns the data from obj.Map.Data.Adc as double precision after scaling
% and applying the offset (and the function in obj.Func if one is specified)
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2007

% Let subsref do the work
index(1).type='()';
index(1).subs=[];
obj=subsref(obj, index);
return
end