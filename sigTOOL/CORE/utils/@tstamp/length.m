function len=length(obj)
% LENGTH method overloaded for tstamp objects
%
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006-7


len=builtin('length', obj.Map.Data.Stamps);



