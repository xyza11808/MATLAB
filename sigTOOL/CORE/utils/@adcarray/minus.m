function OUT=minus(A,B)
% MAX method overloaded for adcarray objects
%
%
% Author: Malcolm Lidierth
% Copyright © The Author & King's College London 2009-

error('Not yet implemented');

index.type='()';
index.subs={};

if isa(A, 'adcarray')
    x1=subsref(A, index);
end

if isa(B, 'adcarray')
    x2=subsref(B, index);
end

OUT=x1-x2;
return
end




