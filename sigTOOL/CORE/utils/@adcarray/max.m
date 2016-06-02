function [M, I]=max(obj)
% MAX method overloaded for adcarray objects
%
%
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2009-

error('Not yet implemented');


if obj.Swapbytes==true || ~isempty(obj.Func)
    error('Not supported where byte swapping is needed or Func is defined');
end
        
[M, I]=max(obj.Map.Data.Adc);
M=double(M)*obj.Scale+obj.DC;
return
end




