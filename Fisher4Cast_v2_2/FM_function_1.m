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
%
% This function makes the current example code portable to the numerical derivative:
% to take our fisher_deriv files and make them one single file to 
% produce output for the num_deriv code...
%--------------------------------------------------------------------------
function f1 = FM_function_1(data, base)
global input output plot_spec

z = data(:);
h0 = base(1); om0 = base(2); ok = base(3);
w0 = base(4); wa =  base(5); 

f = (1+z).^(3.*(1+w0+wa)).*exp(-3.*wa.*z./(1+z));
E = (om0.*(1+z).^3 + (1-om0-ok).*f + ok.*(1+z).^2).^0.5; 
f1 = h0.*E;
