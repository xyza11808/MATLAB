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
% This function calculates the Fisher derivatives for the Hubble parameter
% H(a). It is named fisher_deriv_1.m as it is labelled by the first index of the vector of observables in the input structure
% It is used in FM_run.m to create a general Fisher Matrix of the (input.num_observables) observables, with
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
%   h         - the function value evaluated at the data points    

function [deriv_mat, h] = FM_analytic_deriv_1(data, base_values);
double all;
global input;
z = data(:); % making sure that the data is a column
base = base_values;% taking the base input model

% taking the values for the base model from the input model
h0 = base(1); 
om = base(2);
ok = base(3);
w0 = base(4);
wa = base(5);

if ok ==0
    aval = 1;
else
    aval = 1/h0.*(sqrt(1./ok)); % calculating the radius of curvature
end
%--------------------------------------------------------------------------
% f and its derivatives
f = CPL(z, aval,  w0, wa); % taking the function for f as the CPL parameterisation w = w0 +wa z/(1+z)
dfdw0 = f.*3.*log(1+z); % the f derivative wrt w0
dfdwa = f.*3.*(log(1+z) - z./(1+z)); % the f derivative wrt wa
%--------------------------------------------------------------------------
e = E(z, aval, h0, om, ok, w0, wa); % the function for E(z)
h = h0.*e; % calculating the Hubble parameter

%--------------------------------------------------------------------------
% The Fisher derivatives
dhdho = e;
dhdho./h;
dhdom = h0./(2.*e).*((1+z).^(3) - f) ;
dhdom./h;
dhdok = h0./(2.*e).*(-f + +(1+z).^2);
dhdw0 = h0./(2.*e).*((1-om-ok).*dfdw0);
dhdwa = h0./(2.*e).*((1-om-ok).*dfdwa);

% Saving the derivatives into a matrix to be returned
deriv_mat = [dhdho, dhdom, dhdok, dhdw0, dhdwa];
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% EXTERNAL FUNCTIONS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function  e = E(z, aval, h0, om, ok, w0, wa);
f = CPL(z, aval, w0, wa);
e = sqrt(om.*(1+z).^(3) + (1-om-ok).*f + ok.*(1+z).^(2));
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function fcpl = CPL(z, aval, w0, wa);
fcpl = (1+z).^(3.*(1+w0+wa)).*exp(-3.*wa.*(z.*(1+z).^(-1) ));
