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
function f2 = FM_function_2(data, base)
global w0 wa om ok aval h0 c

%Specifying constants
c = 3e5; % the speed of light in km/s
z = data(:)';
h0 = base(1); om = base(2); ok = base(3);
w0 = base(4); wa =  base(5); 
limit = 1e-12;
%--------------------------------------------------------------------------
%integral of the hubble parameter
for i = 1:length(z)
    r(i) = quadl(@RINT, 0, z(i), 1e-8);
end

if abs(ok) < limit
    D_A = r.*(1./(1+z)).*(c./h0)';
else
    D_A =  (sinh(sqrt(ok).*r).*((1./(1+z)).*(c./(h0.*sqrt(ok)))))'; 
end

f2 = D_A(:);


%==============================
% The comoving radius 
function intr = RINT(z)
global w0 wa om ok aval h0 c
% takes individual z values
f = (1+z).^(3.*(1+w0+wa)).*exp(-3.*wa.*(z.*(1+z).^(-1) ));
e = sqrt(om.*(1+z).^(3) + (1-om-ok).*f + ok.*(1+z).^(2));
intr =(1./e);
