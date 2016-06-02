function out=end(obj, position, numindices)
% END method overloaded for tstamp objects
%
% For tstamp objects, END applies to the data in the
% timesarray.Map.Data.Stamps property. Thus:
% end (obj(:,2))
% is equivalent to
% end (obj.Map.Data.Stamps(:,2))
%
% See also END
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006

out=builtin('end',obj.Map.Data.Stamps,position,numindices);


