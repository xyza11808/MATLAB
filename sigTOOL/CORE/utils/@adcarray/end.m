function out=end(obj, position, numindices)
% END method overloaded for adcarray objects
%
% For adcarray objects, END applies to the data in the
% Adcarray.Map.Data.Adc property. Thus:
% end (obj(:,2))
% is equivalent to
% end (obj.Map.Data.Adc(:,2))
%
% See also END
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2006


out=builtin('end',obj.Map.Data.Adc,position,numindices);


