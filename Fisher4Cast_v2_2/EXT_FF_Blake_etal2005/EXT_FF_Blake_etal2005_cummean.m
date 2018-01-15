% ------------------------------------------------------------------------
% Copyright (C) 2008-2010
% Bruce Bassett Yabebal Fantaye  Renee Hlozek  Jacques Kotze
%
%
%
% This file is part of Fisher4Cast.
%
% Fisher4Cast is free software: you can redistribute it and/or modify
% it under the terms of the Berkeley Software Distribution (BSD) license.
%
% Fisher4Cast is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% BSD license for more details.
% ------------------------------------------------------------------------
function y = EXT_FF_Blake_etal2005_cummean(x)
%This function EXT_FF_Blake_etal2005_cummean.m returns the mean value 
%between adjecent values of a vector x.
%The length of y is one less the length of x
%
%For example >> cummean(1:5) 
%            >> ans = [1.5 2.5 3.5 4.5] 

len = length(x);
if len>1    
   y = (x(1:end-1)+x(2:end))./2;    
else
    y = x;
end
        

