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
function coeff = EXT_FF_Blake_etal2005_spectro_params(r_type)
% This initialises the fitting parameters from Blake et al. (2005)
% for a spectroscopic survey. Since we are considering both radial 
% and tangential directions for a spectroscopic survey the 
% coefficients will be a vector and the resulting errors on the 
% oscillation scale will also be a vector, with the
% tangential direction as the first entry.

% Coefficients for the high-accuracy regime
if strcmp(r_type,'radial')
	coeff.x0 = 1.48; % percent 
	coeff.n0 = 8.2e-4;% units 10^-3 h^3 MPc^-3
	coeff.zmax = 1.4;
	coeff.gamma =  0.5;
	coeff.b =  0.52;
	coeff.p = 2;
	coeff.a = 10.6;
	coeff.alpha = 0.49;
	coeff.beta = 1;


elseif strcmp(r_type,'tangential')
	% Now coefficients for x ~ xt where is a characteristic accuracy given
	% emprically by:
	% xt = a(v/v0)(zmax/z)^beta for z < zmax
	% xt = a(v/v0) for z> zmax
	coeff.x0 = 0.85; % percent 
	coeff.n0 = 8.2e-4 ;% units h^3 MPc^-3
	coeff.zmax = 1.4;
	coeff.gamma = 0.5;
	coeff.b = 0.52;
	coeff.p = 2;
	coeff.a = 7.3;
	coeff.alpha = 0.26;
	coeff.beta = 0.27;
else
	error('choose radial or tangential distance')
end

