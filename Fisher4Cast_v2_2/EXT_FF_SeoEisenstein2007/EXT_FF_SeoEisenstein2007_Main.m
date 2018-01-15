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

function [Drms,Hrms,r,Rrms] = EXT_FF_SeoEisenstein2007_Main(Input_survey)
%This function is a wrapper for the Seo & Eisenstein (2007)
%arXiv:astro-ph/0701079 BAO surveys accuracy fitting formula.
%The matlab code of the fitting formula is the direct 
%translation of the c code that Seo & Eisenstein
%provided in their website
%http://cmb.as.arizona.edu/~eisenste/acousticpeak/bao_forecast.html

% The code takes an input structure, Input_survey with the following
% fields:

% 	Input_survey.number_density:    The galaxy number density in h^3 Mpc^-3 
%   Input_survey.wmap:              Flags defining which WMAP data release to use
%                                   for the power spectrum. The options are
%                                   1/3.
% 	Input_survey.sigma8:            The real-space, linear clustering amplitude 
% 	Input_survey.Sigma_perp:        The transverse rms Lagrangian displacement
% 	Input_survey.Sigma_par:         The line of sight rms Lagrangian displacement
% 	Input_survey.Sigma_z:           The line of sight rms comoving distance error due to
%                                   redshift uncertainties 
% -------------------------------------------------------------------------
% NOTE: that Sigma_perp and Sigma_par are for pairwise differences,
% 	    while Sigma_z is for each individual object
%--------------------------------------------------------------------------
% 	Input_survey.beta:              The redshift distortion parameter 
% 	Input_survey.volume:            The survey volume in h^-3 Gpc^3, set to 1 if input <=0% 
% 	Input_survey.Drms:              The rms error forecast for D/s, in fractional error. Multiply by 100 to get percentage. 
% 	Input_survey.Hrms:              The rms error forecast for H*s, in fractional error. Multiply by 100 to get percentage.
% 	Input_survey.r:                 The correlation coefficient between D and H 
% 	
%         The covariance matrix for D/s and H*s is hence
% 
% 				  / Drms**2    Drms*Hrms*r \
% 				  \ Drms*Hrms*r   Hrms**2  / 


% 	Input_survey.Rrms:              The rms error forecast for D/s and H*s,
%                                	as fractional error, if one requires that the radial 
%                                   and transverse scale changes are the
%                                   same. Multiply by 100 to get percentage. 

%--------------------------------------------------------------------------
% If NO argument is given, the default values are called from the
% pre-defined structure EXT_FF_SeoEisenstein2007_Input.m

if nargin==0
       Input_survey = EXT_FF_SeoEisenstein2007_Input;
end
%--------------------------------------------------------------------------
% The input structure is then modified with additional entries required by
% the codes that are called within this wrapper.
TempInput=Input_survey;

TempInput.beta = TempInput.zdistortion;

[Sigma_perp, Sigma_par] = EXT_FF_SeoEisenstein2007_LagrangianDisplacement(TempInput);
TempInput.Sigma_perp = Sigma_perp;
TempInput.Sigma_par=Sigma_par;
s = EXT_FF_SeoEisenstein2007_sound_horizon(TempInput);
TempInput.s =s;

[Drms,Hrms,r,Rrms] = EXT_FF_SeoEisenstein2007_errFit(TempInput);
                       % multiply by 100 to get percentage error.

