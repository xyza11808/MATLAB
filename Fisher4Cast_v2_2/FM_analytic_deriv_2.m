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
% This function calculates the Fisher derivatives for the Angular Diameter
% Distance DA(a).
% It is named fisher_deriv_2.m as it is labelled by the second index of the 
% vector of observables in the input structure
% It is used in FM_run.m to create a general Fisher Matrix of the 
% (input.num_observables) observables, with
% an additional prior matrix (input.prior).
% 
% It expects as input:
%   data - a vector of length of the number of data points (in the
%           cosmological example this is the number of redshift bins.) 

%   base_values - a vector of length of the numbers of parameters 
%                    you are interested in, whose values are specified by
%                    the input.fiducial.model
% It returns:
%   deriv_mat - a matrix of Fisher derivatives ordered by the fiducial base
%               vector, evaluated at the data points
%   D_A         - the function value evaluated at the data points    

function [deriv_mat, D_A] = FM_analytic_deriv_2(data, base_values);
global input w0 wa om ok aval h0 c
double all;

%--------------------------------------------------------------------------
%Specifying constants
c = 3e5; % the speed of light
z = data(:)'; % naming the input data  'z'
base = base_values; % the fiducial model
num_w = length(base) - 3; % determining the number of w_i's in the paramterization
% taking the base data from the input model
h0 = base(1);
om = base(2);
ok = base(3);
limit = 1e-12; % the limit on Omega_k after which the Taylor Series Expansion applies
%--------------------------------------------------------------------------
% determining the radius of curvature

if abs(ok) < limit
    aval = 1;
else
    aval = 1/h0.*(sqrt(1./ok)); % calculating the radius of curvature
end
%--------------------------------------------------------------------------
% Taking the number of wi's for the CPL parameterisation
if num_w == 2
    w0 = base(4);
    wa = base(5);
    f = CPL(z);
else
    help = 'There is something wrong, this is not coded yet'
end
% calculating f(z) and hence E(z)
f = CPL(z);
e = E(z);
%--------------------------------------------------------------------------
% Integrals and Fisher derivatives for the comoving radius r(z) =
% int_0^z{dz'/E(z')}
for i = 1:length(z)
    r(i) = quadl(@RINT, 0, z(i), 1e-8);
    drdom(i) = quadl(@DROMINT, 0, z(i), 1e-12);
    drdok(i) = quadl(@DROKINT, 0, z(i), 1e-12);
    drdwo(i) = quadl(@DRWOINT, 0, z(i), 1e-12);
    drdwa(i) = quadl(@DRWAINT, 0, z(i), 1e-12);
end
%--------------------------------------------------------------------------
% Determining the value of D_A
el = sin(sqrt(ok).*r);

if abs(ok) < limit
    D_A = r.*(1./(1+z)).*(c./h0)';
else
    D_A =  (sinh(sqrt(ok).*r).*((1./(1+z)).*(c./(h0.*sqrt(ok)))))'; 
end

D_A = D_A(:);
%--------------------------------------------------------------------------
% Fisher derivatives of f and E wrt parameters
dfdw0 = f.*3.*log(1+z); 
dfdwa = f.*3.*(log(1+z) - z./(1+z)); 
dedom = 1./(2.*e).*((1+z).^3 - f) ; 
dedok = 1./(2.*e).*(-f +(1+z).^2);  
dedw0 = 1./(2.*e).*((1-om-ok).*dfdw0); 
dedwa = 1./(2.*e).*((1-om-ok).*dfdwa); %checked
dedf  = 1./(2.*e).*(1-om-ok); %checked

%--------------------------------------------------------------------------
% Fisher derivatives of D_A 
h = h0.*e;
ddadh0 = (-1/h0).*D_A; %rechecked
ddadom = (((c./h0).*(1./(1+z))).*cosh(sqrt(ok).*r).*drdom)'; %checked
ddadwo = (((c./h0).*(1./(1+z))).*cosh(sqrt(ok).*r).*drdwo)'; %checked
ddadwa = (((c./h0).*(1./(1+z))).*cosh(sqrt(ok).*r).*drdwa)'; %checked
if abs(ok) < limit
ddadok = (c./(h0.*(1+z))).*((r.^3./6) + drdok); % series expansion
else
% no series expansion needed
ddadok =((-1./(2.*ok)).*D_A'+((c./h0).*(1./(1+z))).*(cosh(sqrt(ok).*r).*((r./(2.*ok)) + drdok)))'; %checked
end
ddadok = ddadok(:);

deriv_mat = [ddadh0, ddadom, ddadok, ddadwo, ddadwa]; 
% saving the derivatives in one matrix for output

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTERNAL FUNCTIONS
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function e = E(z);
global w0 wa om ok aval h0 c
f = CPL(z);
e = sqrt(om.*(1+z).^(3) + (1-om-ok).*f + ok.*(1+z).^(2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fcpl = CPL(z);
global w0 wa om ok aval h0 c
fcpl = (1+z).^(3.*(1+w0+wa)).*exp(-3.*wa.*(z.*(1+z).^(-1) ));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The comoving radius 
function intr = RINT(z);
global w0 wa om ok aval h0 c
% takes individual z values
f = (1+z).^(3.*(1+w0+wa)).*exp(-3.*wa.*(z.*(1+z).^(-1) ));
e = sqrt(om.*(1+z).^(3) + (1-om-ok).*f + ok.*(1+z).^(2));
intr =(1./e);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The integrand for the derivative of r(z) wrt Omega_m
function int1 = DROMINT(z);
global w0 wa om ok aval h0 c
f = (1+z).^(3.*(1+w0+wa)).*exp(-3.*wa.*(z.*(1+z).^(-1)));
e = sqrt(om.*(1+z).^(3) + (1-om-ok).*f + ok.*(1+z).^(2));
dedom =  1./(2.*e).*((1+z).^(3) - f) ;
int1 = -1.*(1./(e.^2)).*dedom;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The integrand for the derivative of r(z) wrt Omega_k
function intdrdok = DROKINT(z,r);
global w0 wa om ok aval h0 c
f = (1+z).^(3.*(1+w0+wa)).*exp(-3.*wa.*(z.*(1+z).^(-1) ));
e = sqrt(om.*(1+z).^(3) + (1-om-ok).*f + ok.*(1+z).^(2));
dedok = 1./(2.*e).*(-f +(1+z).^2);
intdrdok = ((-1./e.^2).* dedok); 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The integrand for the derivative of r(z) wrt w_0
function intdrdwo = DRWOINT(z);
global w0 wa om ok aval h0
f = (1+z).^(3.*(1+w0+wa)).*exp(-3.*wa.*(z.*(1+z).^(-1) ));
e = sqrt(om.*(1+z).^(3) + (1-om-ok).*f + ok.*(1+z).^(2));
dedf = (1./(2.*e)).*(1-om-ok);
dfdw0 = f.*3.*log(1+z);
intdrdwo = -1.*((1./e.^2).*dedf.* dfdw0);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% The integrand for the derivative of r(z) wrt w_a
function intdrdwa = DRWAINT(z);
global w0 wa om ok aval h0
f = (1+z).^(3.*(1+w0+wa)).*exp(-3.*wa.*(z.*(1+z).^(-1) ));
e = sqrt(om.*(1+z).^(3) + (1-om-ok).*f + ok.*(1+z).^(2));
dedf = (1./(2.*e)).*(1-om-ok);
dfdwa = f.*3.*(log(1+z)- (z./(1+z)));
intdrdwa = -1.*((1./e.^2).*dedf.* dfdwa);
