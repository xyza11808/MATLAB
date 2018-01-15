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
function Input_survey = EXT_FF_SeoEisenstein2007_Input
% This function is a standard-predefined input structure to be used 
% to compute the error on the radial and transverse oscillation scale, as laid out in
% Seo & Eisenstein (2007) arXiv:astro-ph/0701079.

% The matlab code of the fitting formula is the direct 
% translation of the c code that Seo & Eisenstein
% provided in their website
% http://cmb.as.arizona.edu/~eisenste/acousticpeak/bao_forecast.html

% These input values are expected by the code, and hence must be specified.

Input_survey.z = 3; 
%                                   The line of sight rms comoving distance error due to
%                                   redshift uncertainties 
Input_survey.sigma8 = 1; 
%                                   The real-space clustering amplitude 
Input_survey.wmap = 3;
%                                   Flags defining which WMAP data release to use
%                                   for the power spectrum. The options are
%                                   1/3.
Input_survey.volume = 1;
%                                   The survey volume.
Input_survey.Sigma_z = 0.0001;
%                                   The line of sight rms comoving distance error due to
%                                   redshift uncertainties 
Input_survey.number_density = 1e-4; 
%                                   The galaxy number density in h^3 Mpc^-3
%                                   
Input_survey.zdistortion = 1;
%                                   The redshift distortion parameter 
    

Input_survey.ob = 0.04;
Input_survey.om = 0.26;
Input_survey.ode = 0.7;
%                                   The baryon, matter and dark energy
%                                   densities respectively
Input_survey.h = 0.72;
%                                   The fractional Hubble parameter.

%Call the Seo & Eisenstein (2007) fitting formula


