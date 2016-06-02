function [M, I]=min(obj)
% MAX method overloaded for adcarray objects
%
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2009-


if obj.Swapbytes==true || ~isempty(obj.Func)
    error('Not supported where byte swapping is needed or Func is defined');
end
        
[M, I]=min(obj.Map.Data.Adc);
M=double(M)*obj.Scale+obj.DC;
return
end




