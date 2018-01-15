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
% This function sets the input structure and is a template to work from
% should you wish to define your own structure. All fields are required, so
% any other initialiser functions should assign the same fields to the
% input structure. The default values used here are meant to match that used
% in the Seo& Eisensten (2003) paper [1]. For another example see Cooray_et_al_2004.m
% [1] - "Probing Dark Energy with Baryonic Acoustic Oscillations from Future
%       Large Galaxy Redshift Surveys"
%       Hee-Jong Seo, Daniel J. Eisenstein (Steward Observatory)
%       Astrophys.J. 598 (2003) 720-740
% -------------------------------------------------------------------------
%
function input = Seo_Eisenstein_2003

input.function_names = {'FM_analytic_deriv_1' 'FM_analytic_deriv_2'};%This lists the names of the functions which contain the analytic derivatives to be used to calculate the Fisher matrices
input.observable_names = {'H' 'd_A' 'G'}; % the label of the observables  
input.observable_index = [ 1 2 ];% the indices of the observables you are interested 
%                               in...the first index corresponds to the 
%                               first entry in the input.observables_names 
%                               part of the struct
input.data{1} = [0.3, 0.6, 0.8, 1.0, 1.2 3]; % the redshift data in your survey indexed (1,2,3....) for the corresponding observable index
input.data{2} = [0.3, 0.6, 0.8, 1.0, 1.2 3 1000];
input.data{3} = [];

% -------------------------------------------------------------------------
input.parameter_names = {'H_0' 'O_m' 'O_k' 'w_0' 'w_a'}; % the names of the parameters
input.base_parameters = [70, 0.3, 0, -1, 0];% the base parameter values for each of the approriate parameters indexed in the parameter_names

input.prior_matrix = diag([1e4 1e4 1e4 0 0]); % the prior information matrix on those parameters
input.parameters_to_plot = [ 4 5]; % the indices of the parameters of interest, 1 = the first parameter in the 
%                                    input.parameter_names vector etc.

input.num_observables = length(input.observable_index); %number of observables you are considering  
input.num_parameters = length(input.parameters_to_plot); % the number of parameters you are considering 
%                                                           - 2 for an ellipse
% -------------------------------------------------------------------------
% Specify the error of the data in the survey. 
% NB: The form of this entry is important - if it is a vector the code will
% create a diagonal data covariance matrix, if it is a matrix it will assume you have specified 
% your own data covariance matrix 

input.error{1} = ([0.0580, 0.0519 0.0359, 0.0284, 0.0253, 0.0148]);
input.error{2} = ([0.0519, 0.0430, 0.0322, 0.023, 0.0203, 0.0119, 0.0022]);
input.error{3} = ([]);

%
%-------------------------------------------------------------------------
%growth_zn_flag is a flag to normalize the growth function at 
%normalize redshift which is set by growth_zn. This will be used only during computation 
%of growth function derivatives
input.growth_zn_flag = 1; %set to 1 to normalize the growth function. Set to 0 if you wish to leave it unormalized. 
input.growth_zn = 0; %set the normalised redshift for the growth function. Note the above flag (growth_zn_flag) must be set inorder to make this value applicable.


% -------------------------------------------------------------------------
% Flags for whether or not numerical derivatives must be used
% 0 = use analytical
% 1 = use numerical
numderiv.flag{1} = 0; 
numderiv.flag{2} = 0; 
numderiv.flag{3} = 1;

% If you do want numerical derivatives, the code that produces the function
% itself must be specified (eg. H(data, base))
numderiv.f{1} = sprintf('FM_function_1');
numderiv.f{2} = sprintf('FM_function_2');
numderiv.f{3} = sprintf('FM_function_3');

input.numderiv = numderiv;

