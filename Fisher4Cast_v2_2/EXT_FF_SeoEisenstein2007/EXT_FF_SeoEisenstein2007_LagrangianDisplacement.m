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
function [Sigma_perp, Sigma_par] =  EXT_FF_SeoEisenstein2007_LagrangianDisplacement(TempInput)

%This function is part of the code used to determine the errors on the 
% oscillation scale used in Seo & Eisenstein (2007)
%arXiv:astro-ph/0701079 BAO.

% It evaluates transverse and radial components of the Langrangian
% displacement.

% It takes the input structure TempInput as argument. This structure is
% called in the wrapper code, and an example is given in EXT_FF_SeoEisenstein2007_Input.m

% The inputs required are:

% TempInput.sigma8:             The real-space, linear clustering amplitude
% TempInput.z:                  The line of sight rms comoving distance error due to
%                               redshift uncertainties
% TempInput.om:                 The matter density
%--------------------------------------------------------------------------
%
TempInput.Sigma_0 = 12.4.*0.9./TempInput.sigma8; %Sigma_0 has unit of h^-1Mpc
                              
% NOTE: Sigma_0 is 12.4h^-1 for sigma8 = 0.9 [Just above eq(3) of 
% Seo & Eisenstein (2007)]. Sigma_0 scales proportionaly with sigma8


%The growth function is normalized to be G=0.758 at z = 0 such that G(z) is 1/(1+z) at high z. 
%f = d(lnG)/(dlna) ~ om^0.6
if TempInput.z==0
    G = 0.758;
else
    G = 1./(1+TempInput.z);
end

f = TempInput.om.^0.6;

%This are The transverse and line of sight 
%rms Lagrangian displacement
Sigma_perp = TempInput.Sigma_0.*G;
Sigma_par =TempInput.Sigma_0.*G.*(1+f);

