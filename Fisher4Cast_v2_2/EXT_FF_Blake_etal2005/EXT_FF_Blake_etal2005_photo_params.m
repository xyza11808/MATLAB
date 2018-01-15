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
function coeff = EXT_FF_Blake_etal2005_photo_params
% This initialises the fitting parameters from Blake et al. (2005)
% for a photometric survey. 
% Since we are considering only the tangential directions in this
% photometric survey the coefficients will be a single-valued.

% Coefficients for the high-accuracy regime
coeff.x0 = 1.23; % percent
coeff.n0 = 0.71; % units 10^-3 h^3 MPc^-3
coeff.zmax = 1.4;
coeff.gamma = 0.61;
coeff.b = 0.52;

% Now coefficients for x ~ xt where is a characteristic accuracy given
% emprically by:
% xt = a(v/v0)(zmax/z)^beta for z < zmax
% xt = a(v/v0) for z> zmax
coeff.p = 4;
coeff.a = 4.2;
coeff.alpha = 0.11;
coeff.beta = 0.42;
