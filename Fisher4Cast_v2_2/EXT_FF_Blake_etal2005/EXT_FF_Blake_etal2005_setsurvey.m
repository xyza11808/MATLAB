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
function input = EXT_FF_Blake_etal2005_setsurvey
% This is an example of the structure for one particular survey configuration.
% The input parameters from this structure will be passed to the 
% input data which needs to be specified here:

%   For a spectroscopic data survey:
%    - the survey area 
%    - number density of galaxies, n

%   For a photometric survey:
%     - the same as before, only with the addition of 
%     - the redshift error, sigz

input = Cooray_et_al_2004; %this calls the example input parameters for FM_run.m
input.survey.area = 20; 
%survey.n = 1e4;
%units of n is (1e-3Mpc^-3h^3)
input.survey.n = 1e3.*[1.56e-2 9.34e-3 5.63e-3 3.08e-3 1.48e-3 9.15e-4 6.02e-4 3.58e-4 2.31e-4]';  
%survey.n = 1e3.*[7.1e-3 4.92e-3 3.07e-3 1.74e-3 9.05e-4 4.34e-4 1.93e-4 8.00e-5 3.08e-5]';
input.survey.sigz = 0.01;

input.survey.biasH= 0.1;
input.survey.biasDA = 0.4;
