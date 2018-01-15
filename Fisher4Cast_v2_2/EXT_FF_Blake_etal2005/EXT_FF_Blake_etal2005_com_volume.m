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
function comoving_V = EXT_FF_Blake_etal2005_com_volume(area,z,base)
% COM_VOLUME calculates the comoving volume
% from the present to the redshift z. 
% The area provided must be in radians.
% Depending of the sign of the curvature, 
% the code calculates the volume with the 
% equation provided in the Hogg paper astro-ph/9905116v4. If
% the curvature value, ok, is not
% Specified, the volume calculated will 
% be for the flat Universe.
%
% ------------------------------------------------------------------------

global c h0 om ok w0 wa

c = 3e5;
h0 = 100;%base(1); in units of h
om = base(2);
ok = base(3);
w0 = base(4);
wa = base(5);

%Check number of input arguments
if nargin == 2
    
    spaceTime = 'flat';
    
elseif nargin == 3
    
    if ok > 1e-12
        spaceTime = 'open';
    elseif abs(ok) <= 1e-12
        ok = 1e-15; %set ok near zero as division by 0 is undifined
        spaceTime = 'flat';
    else
        spaceTime = 'closed';
    end
    
elseif nargin<2 | nargin>3 

     error('Wrong number of input arguments. Number of input arguments must be either two or three.')
      
end

%Definition of Hubble distance, DH
Dh = c/h0;

%The total line-of-sight co-moving distace
for i = 1:length(z)
    if z(i)==0
        intgrand(i) = 0; %the volume at z=0 is zero
    else
        intgrand(i) = quadl(@hubb,0,z(i));
    end
end
Dc = Dh.*intgrand; 

%The transverse co-moving distance
if strcmp(spaceTime, 'open')
    Dh = Dh(:);
    Dc = Dc(:);
    Dm = Dh.*(1/sqrt(ok)).*sinh(sqrt(ok).*Dc./Dh);  
    
    comoving_V = (area.*Dh^3./(2.*ok)).*((Dm./Dh).*sqrt(1+ok.*(Dm./Dh).^2)...
                  - 1/sqrt(ok).*asinh(sqrt(ok).*Dc./Dh));
             
elseif strcmp(spaceTime, 'flat')
    
    Dm = Dc;
    comoving_V = (area.*(1e-3.*Dm).^3)./3;  %1e-3 is to make the unit of Dm in Gpc
    
else  %closed
    
    Dm = Dh.*(1/sqrt(abs(ok))).*sinh(sqrt(abs(ok)).*Dc./Dh);
    
    comoving_V = (area.*Dh^3./(2.*ok)).*((Dm./Dh).*sqrt(1+ok.*(Dm./Dh).^2)...
                 - 1/sqrt(abs(ok)).*asinh(sqrt(abs(ok)).*Dc./Dh));
    
end

%=============================
% Subfunctions
function hubb_inv = hubb(z)

global c h0 om ok w0 wa

aval = c/h0.*(sqrt(1./ok));
f = LINDER(z, aval, w0, wa);
e = sqrt(om.*(1+z).^(3) + (1-om-ok).*f + ok.*(1+z).^(2));
hubb_inv = 1./e;


function flin = LINDER(z, aval, w0, wa);
flin = (1+z).^(3.*(1+w0+wa)).*exp(-3.*wa.*(z.*(1+z).^(-1) ));
