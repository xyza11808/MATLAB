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
% This function is the wrapper for the process of generating a Fisher 
% matrix and plotting the associated Error ellipse. For a more 
% comprehensive description of this function its flowchart and details of
% the functions it calls, see the User Manual.

% FM_run.m produces an output structure while taking an input function 
% initialiser that will be called to assign values to the input structure. 
% This initialising function is user-defined. If no input is passed the 
% default input of Cooray_et_al_2004.m is used (Seo_Eisenstein_2003 is a 
% similar default input available). 
%--------------------------------------------------------------------------
% Example:
% 
% >>output = FM_run(Cooray_et_al_2004)
%
%--------------------------------------------------------------------------
% FM_run.m Outline
%
% 1. Reads values from the global input structure concerning which
%    observables and parameters are of interest. If no input is specified 
%    then Cooray_et_al_2004 is loaded.
% 2. Loop over the observables listed in input.num_observables: 
%------------------- 
% 2.1. Checks whether you want analytical or numerical derivatives
% 2.2. Calculates the derivative matrix (deriv) and the observable
%      function value vector(func_val) from the relevant FM_process_analytic or
%      FM_process_numeric function - as a function of the input data and
%      base parameters, outlined in the input structure.
% 2.3. FM_covariance determines the data covariance matrix (data_cov) 
%      either from data covariance specified in the input structure 
%      or from the variance vector specified in input.
%-------------------
% 3.  The combined Fisher matrice for each of the observables are summed
%     by FM_sum and the final matrix is passed to the output structure. 
% 4.  The Fisher Matrix is marginalised over the parameters we are not
%     interested in with FM_marginalise. This is also passed to the
%     output structure.
% 5.  The Figure of Merits are generated in FM_output_fom and passed to
%     the output structure. 
% 6.  The resulting Fisher ellipse or Likelihood function is plotted with
%     FM_generate_plot.
% 7.  The input and output structures are saved using FM_save_struct.
% ------------------------------------------------------------------------

function output = FM_run(initialiser)
global input output;
double all;
 
tic
if nargin==0
    input = Cooray_et_al_2004; %generate test input.
else    
    input = initialiser; % initialise all input - specific to your initialise function.    
end
input.num_observables = length(input.observable_index); %number of observables you are considering  
input.num_parameters = length(input.parameters_to_plot); % the number of parameters you are considering % 


for i = 1:input.num_observables; % looping over the observables
    x = input.observable_index(i); % the index of the observable (e.g. 1 = H, 2 = DA etc)
    
    if input.numderiv.flag{x} == 0; % check to see if we want numerical derivatives (flag = 1) for this observable
        [deriv, func_val] = FM_process_analytic(x); % calculate derivatives and function values        
    elseif input.numderiv.flag{x} == 1;
        disp('Numerical derivatives will be used.');
        [deriv,func_val] = FM_process_numeric(x); % call the numerical derivatives
    else
        errordlg('input.numderiv.flag in the input structure is not set to 0 or 1. Please set it to the appropriate value.')      
    end % end the numerical derivative check
  
    data_cov = FM_covariance(func_val,x); % calculate the data covariance matrix
    fm = FM_matrix(data_cov, deriv,x); % calculate the Fisher matrix for this observable
    
    % Assigning the current calculated values to the output structure 
    output.function_value{x} = func_val;
    output.function_derivative{x} = deriv;
    output.data_covariance{x} = data_cov;        
    output.matrix{x} = fm;

end % end the loop over the observables

% Assigning remaining calculation to the output strcuture
output.summed_matrix = FM_sum; % calling code to sum the various matrices with the prior matrix
output.marginalised_matrix = FM_marginalise;
output.fom = FM_output_fom;

FM_generate_plot; % call the function which will plot either a likelihood or error ellipse

FM_save_struct('FM_saved_data',input,output); % saving the output structure to a file

toc

