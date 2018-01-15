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
% This function makes the current example code portable to the numerical derivative:
% to take our fisher_deriv files and make them one single file to 
% produce output for the num_deriv code.
%--------------------------------------------------------------------------
function f3 = FM_function_3(data, base, norm_flag, norm_z)
global input w0 wa ok omde om

if nargin==0    
    data = 0:1:300;
    base = [70 0.277 +0.2 -0.7 0.2];   
end

if nargin > 2     
    flag = norm_flag;
    z_n = norm_z;
elseif isfield(input,'growth_zn_flag') && isfield(input,'growth_zn')
    flag = input.growth_zn_flag;
    z_n = input.growth_zn;
else    
    flag = 1;
    z_n = 0;
end

%Specifying constants
c = 3e5; % the speed of light in km/s
z = data(:);
z = sort(z,1);

h0 = base(1); om = base(2); ok = base(3);
w0 = base(4); wa =  base(5); 
limit = 1e-12;
omde = 1-om-ok; 

%Growth function is evaluated to this redshift.
%It is set to 1 above for all redshifts higher than this one.
zINI = 147.4132;  
                  

%if z_n=z, the derivatives are zero.
if length(z)==1
    if z==z_n
        error('Growth function is normalized at the given single data point. All the derivatives are zero')
    end
end
%---------------------------------------------------
%Checking if z is a scalar or a vector.
%if the given vector of z has only a single value, 
%we make it a vector of length 3 (arbitrary choice). 
%This is because the spline from a to z requires a vector. 
%the output is growth value that corresponds to a given z. 

zFill = 0; %shows weather or not z is transformed to a vector
if length(z)==1
    ddz = 1e-2;
    z=[z; z+ddz; z+2*ddz];
    zFill=1;
end
%--------------------------------------------------------------------------
% Check to see if normalisation is required
added = 0;

if flag ==1
    indx = find(z_n == z); %search if z_n is a member of z        
    if isempty(indx)       %if index=0, normalize at z_n outside z           
        z = [z_n; z];  %add z_n at the begnning of z.
        added = 1;               
    else             
        non_zn_indx = find(indx~=(1:length(z)));%all but indx
        z = [z_n;z(non_zn_indx)];            
    end
else
    z = z;
end   


% The growth function above redshift zINI will be set to 1 by hand
indxGtZini = find(z>zINI);   %Index of z that will not be evaluated
indxLtZini = find(z<=zINI);  %Index of z that will be evaluated
zEval = z(indxLtZini);       %For these z's we evaluate the growth function
%--------------------------------------------------------------------------
% Calling the ODE solver.
% We perform integration in units of ln(x) = 1./(1+x), where x = a/a0 and a0 is the
% curvature radius.
% The limits of integration are 
% ln(xi) = -5 --> z = 147.4132
% ln(xf) = 0 -->  z = 0
% and delta(ln(xi)) = 1, delta'(ln(xi)) = 1
options = odeset('RelTol',1e-5,'AbsTol',[1e-5 1e-5 ]); % ODE solver options
xINI = log(1./(1+zINI));   %Initial condition is taken here, G(aINI)=1, G'(aINI)=1

[t,Y] = ode45(@growln,[xINI 0],[1 1],options); 
d = Y(:,1); % taking the part of the solution that we want

xobs = 1./(1+zEval); % the x values corresponding to the redshifts of interest.
GatZ = spline(exp(t), d, xobs);
GatZ(indxGtZini) = exp(-xINI)./(1+z(indxGtZini));

Gnorm = spline(exp(t), d, 1./(1+z_n));
%----------------------------------------------------------------
% Normalising the growth

if flag ==1 
    ft = GatZ(:)./Gnorm;
    if added == 1
        f3 = ft(2:end);
        z = z(2:end);
    else
        f3 = [ft(2:indx); ft(1); ft(indx+1:end)];
        z = [z(2:indx); z(1); z(indx+1:end)];
    end
else
    gt = GatZ(:);
    f3 = gt;
end
%--------------------------------------------------------
%if the input z was a scalar, we return a scalar growth value
%that corresponds to the given z.
if zFill~=0
    f3 = f3(1);
end

%plot the result if no input is passed
if nargin==0
    plot(z,f3)
end

%==========================================================================
  function dy = growln(x,y)
  global w0 wa om ok omde
  
  
  ok0=1-om-omde;
  
  w = w0+wa.*(1-exp(x)); %CPL parametrization  
  f = exp(-3.*x.*(1 + w0 + wa) - 3.*wa.*(1-exp(x)));   
  Hubble2 =om.*exp(-3.*x)+ok0.*exp(-2.*x)+omde.*f;
   
  OK=(ok0./Hubble2).*exp(-2.*x);
  ODE=(omde./Hubble2).*f; 
  OM = (om./Hubble2).*exp(-3.*x);
  
  dy = zeros(2,1); % initialising vector of differentials
  dy(1)= y(2); 
  dy(2) = -(3./2).*(1./3 + OK./2 -w.*ODE).*y(2) + (3./2).*OM.*y(1);
 
