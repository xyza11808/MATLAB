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
% This function is an example case of the survey parameters needed input structure for 
% the DUNE mission described in [1]. 

% [1] - "Summary of the DUNE Mission Concept"
%         Alexandre Refregier, Marian Douspis, the DUNE collaboration
%         arXiv:0807.4036
%--------------------------------------------------------------------------
function Input_survey = EXT_FF_Blake_etal2005_Input
% the base parameter values for each of the approriate 
% parameters indexed in the parameter_names
Input_survey.base_parameters = [72, 0.3, 0, -1, 0];   
                                                    
Input_survey.surv_type = 'spec';  %spectroscopic survey. For photometric it will be 'phot'

Input_survey.dz = [];            %if z_type is 'central' dz needs to be specified.

Input_survey.z_type = 'edge';    %redshift vector that specifies the 'edge' or 'central' redshift of each bin
Input_survey.area = 1;           %area of the sky obserbed in units of 1000 sq degree

%number density of the survey for each redshift in units of (1e-3Mpc^-3h^3).
% A single value will be interpreted as the same number density for all the redshift
Input_survey.n = 5e-4;           

% redshift vector of the survey for Hubble parameter (H)
% and angular diameter distance (DA)
Input_survey.vecH = [0.5 0.7 0.9 1.1 1.3]; 
Input_survey.vecDA = [0.5 0.7 0.9 1.1 1.3];

% bias at each redshift (if this is scalar, it will be expanded
% such that it will be a vector of the same size as vecH/vecDA
% with the same bias in all redshifts)
Input_survey.biasH = [1 1.25 1.4 1.55 1.7]'; 
Input_survey.biasDA = [1 1.25 1.4 1.55 1.7]';

