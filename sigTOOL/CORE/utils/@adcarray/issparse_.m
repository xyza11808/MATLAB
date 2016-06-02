function TF=issparse_(obj)
% issparse method for adcarray objects
%
% Example
% TF=issparse(obj)
%
% returns true is the contents of obj.Map.Data.Adc are sparse
%
% -------------------------------------------------------------------------
% Author: Malcolm Lidierth 12/07
% Copyright © The Author & King's College London 2007-2008
% -------------------------------------------------------------------------

TF=issparse(obj.Map.Data.Adc);
return
end